"""Trade Data Toolkit - Reusable utilities for international trade analysis.

Handles BACI/Comtrade data conventions, product complexity, HHI calculation,
elasticity validation, and HS code lookups. Designed to be imported from any
project or run as CLI.

Usage:
    uv run python ~/scripts/trade-toolkit/trade_toolkit.py validate-units data.csv
    uv run python ~/scripts/trade-toolkit/trade_toolkit.py check-complexity results.json
    uv run python ~/scripts/trade-toolkit/trade_toolkit.py hhi --column=exports data.csv

Or import:
    from trade_toolkit import BACIData, validate_elasticity, compute_hhi
"""

from __future__ import annotations

import json
import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# BACI data conventions
BACI_VALUE_UNIT = "thousand_usd"  # values in thousands of USD
BACI_QUANTITY_UNIT = "metric_tons"  # quantities in metric tons

# Display conversion factors from BACI raw values
DISPLAY_CONVERSIONS = {
    "billions": 1_000_000,   # divide BACI thousands by 1M to get billions
    "millions": 1_000,       # divide BACI thousands by 1K to get millions
    "usd": 1_000,            # multiply BACI thousands by 1K to get USD
}

# Reference values for sanity checks (approximate, in billion USD)
REFERENCE_TRADE_VALUES = {
    "world_total": 25_000,     # ~$25T world merchandise trade
    "CHN_exports": 3_500,      # ~$3.5T China exports
    "USA_imports": 3_200,      # ~$3.2T USA imports
    "BGD_exports": 55,         # ~$55B Bangladesh exports
    "BGD_rmg_exports": 47,     # ~$47B Bangladesh RMG exports
    "IND_exports": 450,        # ~$450B India exports
    "VNM_exports": 370,        # ~$370B Vietnam exports
}

# Elasticity ranges (reasonable bounds)
ELASTICITY_BOUNDS = {
    "own_price": (-5.0, 0.0),       # should be negative
    "cross_price": (-1.0, 2.0),     # usually small positive
    "income": (-0.5, 3.0),          # 0-1 necessities, >1 luxuries
    "substitution": (0.0, 10.0),    # Armington: typically 2-10
}

# HHI thresholds
HHI_THRESHOLDS = {
    "competitive": 1_500,
    "moderate": 2_500,
    # > 2500 = concentrated
}

# Common HS2 chapter descriptions
HS2_DESCRIPTIONS = {
    "01": "Live animals",
    "02": "Meat",
    "03": "Fish",
    "04": "Dairy, eggs, honey",
    "05": "Products of animal origin",
    "06": "Live trees, plants",
    "07": "Vegetables",
    "08": "Fruits, nuts",
    "09": "Coffee, tea, spices",
    "10": "Cereals",
    "11": "Milling products",
    "12": "Oil seeds",
    "15": "Fats and oils",
    "16": "Meat/fish preparations",
    "17": "Sugars",
    "18": "Cocoa",
    "19": "Cereal preparations",
    "20": "Vegetable preparations",
    "21": "Misc food preparations",
    "22": "Beverages",
    "23": "Food waste, animal feed",
    "24": "Tobacco",
    "25": "Salt, sulphur, earth, stone",
    "26": "Ores",
    "27": "Mineral fuels, oils",
    "28": "Inorganic chemicals",
    "29": "Organic chemicals",
    "30": "Pharmaceuticals",
    "31": "Fertilizers",
    "32": "Tanning, dyeing extracts",
    "33": "Essential oils, perfumery",
    "34": "Soap, waxes",
    "35": "Albuminoidal substances",
    "37": "Photographic goods",
    "38": "Misc chemical products",
    "39": "Plastics",
    "40": "Rubber",
    "41": "Raw hides, leather",
    "42": "Leather articles",
    "43": "Furskins",
    "44": "Wood",
    "47": "Wood pulp",
    "48": "Paper",
    "49": "Printed materials",
    "50": "Silk",
    "51": "Wool",
    "52": "Cotton",
    "53": "Vegetable textile fibres (incl. jute)",
    "54": "Man-made filaments",
    "55": "Man-made staple fibres",
    "56": "Wadding, felt",
    "57": "Carpets",
    "58": "Special woven fabrics",
    "59": "Impregnated textiles",
    "60": "Knitted fabrics",
    "61": "Knitted apparel",
    "62": "Woven apparel",
    "63": "Other textile articles",
    "64": "Footwear",
    "65": "Headgear",
    "68": "Stone, plaster, cement articles",
    "69": "Ceramic products",
    "70": "Glass",
    "71": "Precious stones, metals, jewellery",
    "72": "Iron and steel",
    "73": "Iron/steel articles",
    "74": "Copper",
    "75": "Nickel",
    "76": "Aluminium",
    "78": "Lead",
    "79": "Zinc",
    "80": "Tin",
    "82": "Tools, cutlery",
    "83": "Misc base metal articles",
    "84": "Machinery, mechanical appliances",
    "85": "Electrical machinery, electronics",
    "86": "Railway",
    "87": "Vehicles",
    "88": "Aircraft",
    "89": "Ships, boats",
    "90": "Optical, medical instruments",
    "91": "Clocks, watches",
    "92": "Musical instruments",
    "93": "Arms and ammunition",
    "94": "Furniture",
    "95": "Toys, games",
    "96": "Misc manufactured articles",
    "97": "Works of art",
}

# Products that should be HIGH complexity (for validation)
HIGH_COMPLEXITY_HS2 = {"84", "85", "87", "88", "90", "30"}
# Products that should be LOW complexity
LOW_COMPLEXITY_HS2 = {"01", "02", "03", "07", "08", "09", "10", "26", "27", "53"}


# ---------------------------------------------------------------------------
# Data Classes
# ---------------------------------------------------------------------------

@dataclass
class ValidationIssue:
    """A data validation issue."""
    severity: str          # "CRITICAL", "WARNING", "INFO"
    category: str          # "units", "complexity", "elasticity", "hhi", etc.
    description: str
    value: Optional[float] = None
    expected_range: Optional[str] = None
    location: Optional[str] = None


# ---------------------------------------------------------------------------
# Unit Validation
# ---------------------------------------------------------------------------

def validate_baci_values(
    values: list[float],
    label: str = "trade value",
    expected_unit: str = "thousand_usd",
) -> list[ValidationIssue]:
    """Validate BACI trade values are in expected units.

    Checks if values are plausible given BACI's thousand-USD convention.
    If values look like they're in raw USD or billions, flags the issue.
    """
    issues = []
    if not values:
        return issues

    max_val = max(values)
    min_val = min(v for v in values if v > 0) if any(v > 0 for v in values) else 0

    # World trade is ~$25T = 25 billion thousands
    # If max > 50 billion (in thousands), something is wrong
    if max_val > 50_000_000_000:
        issues.append(ValidationIssue(
            severity="CRITICAL",
            category="units",
            description=f"{label}: max value {max_val:,.0f} is too large for thousand-USD. "
                        f"Values may be in raw USD (divide by 1000).",
            value=max_val,
            expected_range="< 50,000,000,000 (in thousands)",
            location=label,
        ))

    # If max < 1 and it's supposed to be trade value, likely in billions
    if max_val < 1 and max_val > 0:
        issues.append(ValidationIssue(
            severity="WARNING",
            category="units",
            description=f"{label}: max value {max_val:.4f} is very small for thousand-USD. "
                        f"Values may already be in billions.",
            value=max_val,
            expected_range="> 1 (in thousands)",
            location=label,
        ))

    return issues


def convert_baci_value(value: float, to_unit: str) -> float:
    """Convert BACI thousand-USD value to display unit."""
    factor = DISPLAY_CONVERSIONS.get(to_unit)
    if factor is None:
        raise ValueError(f"Unknown unit: {to_unit}. Use: {list(DISPLAY_CONVERSIONS.keys())}")
    if to_unit == "usd":
        return value * factor
    return value / factor


# ---------------------------------------------------------------------------
# Product Complexity
# ---------------------------------------------------------------------------

def validate_complexity_ranking(
    products: list[dict],
    hs_key: str = "hs_code",
    complexity_key: str = "complexity",
) -> list[ValidationIssue]:
    """Validate product complexity rankings make economic sense.

    Checks that high-tech products (machinery, electronics, pharma) rank higher
    than raw materials (ores, cereals, crude oil).
    """
    issues = []
    if not products:
        return issues

    # Sort by complexity descending
    sorted_products = sorted(products, key=lambda p: p.get(complexity_key, 0), reverse=True)

    # Get HS2 chapters
    top_10_hs2 = set()
    bottom_10_hs2 = set()

    for p in sorted_products[:10]:
        hs = str(p.get(hs_key, ""))[:2]
        top_10_hs2.add(hs)

    for p in sorted_products[-10:]:
        hs = str(p.get(hs_key, ""))[:2]
        bottom_10_hs2.add(hs)

    # Check if low-complexity products appear in top 10
    misplaced_high = LOW_COMPLEXITY_HS2 & top_10_hs2
    if misplaced_high:
        descs = [HS2_DESCRIPTIONS.get(h, h) for h in misplaced_high]
        issues.append(ValidationIssue(
            severity="CRITICAL",
            category="complexity",
            description=f"Raw materials in top-10 complexity: {', '.join(descs)}. "
                        f"Complexity calculation may be inverted.",
            location="product complexity ranking",
        ))

    # Check if high-complexity products appear in bottom 10
    misplaced_low = HIGH_COMPLEXITY_HS2 & bottom_10_hs2
    if misplaced_low:
        descs = [HS2_DESCRIPTIONS.get(h, h) for h in misplaced_low]
        issues.append(ValidationIssue(
            severity="CRITICAL",
            category="complexity",
            description=f"High-tech products in bottom-10 complexity: {', '.join(descs)}. "
                        f"Complexity calculation may be inverted.",
            location="product complexity ranking",
        ))

    return issues


# ---------------------------------------------------------------------------
# Elasticity Validation
# ---------------------------------------------------------------------------

def validate_elasticity(
    value: float,
    elasticity_type: str = "own_price",
    product_name: str = "",
) -> list[ValidationIssue]:
    """Validate a trade elasticity value is within reasonable bounds."""
    issues = []
    bounds = ELASTICITY_BOUNDS.get(elasticity_type)

    if bounds is None:
        return issues

    lo, hi = bounds

    if value < lo or value > hi:
        issues.append(ValidationIssue(
            severity="CRITICAL" if abs(value) > 10 else "WARNING",
            category="elasticity",
            description=f"{elasticity_type} elasticity for '{product_name}' = {value:.3f} "
                        f"is outside expected range [{lo}, {hi}].",
            value=value,
            expected_range=f"[{lo}, {hi}]",
            location=product_name or "unknown product",
        ))

    return issues


def validate_elasticity_matrix(
    matrix: dict[str, dict[str, float]],
) -> list[ValidationIssue]:
    """Validate an entire elasticity matrix (own-price on diagonal, cross-price off)."""
    issues = []

    for product, elasticities in matrix.items():
        for other_product, value in elasticities.items():
            if product == other_product:
                issues.extend(validate_elasticity(value, "own_price", product))
            else:
                issues.extend(validate_elasticity(value, "cross_price", f"{product}/{other_product}"))

    return issues


# ---------------------------------------------------------------------------
# HHI (Herfindahl-Hirschman Index)
# ---------------------------------------------------------------------------

def compute_hhi(shares: list[float], already_percentage: bool = False) -> float:
    """Compute HHI from market shares.

    Args:
        shares: Market shares. Can be fractions (0-1) or percentages (0-100).
        already_percentage: If True, shares are already in percentage form.

    Returns:
        HHI value (0-10,000 scale).
    """
    if not shares:
        return 0.0

    if not already_percentage:
        # Convert fractions to percentages
        total = sum(shares)
        if total > 0:
            shares = [(s / total) * 100 for s in shares]

    return sum(s ** 2 for s in shares)


def classify_hhi(hhi: float) -> str:
    """Classify HHI into competition categories."""
    if hhi < HHI_THRESHOLDS["competitive"]:
        return "competitive"
    elif hhi < HHI_THRESHOLDS["moderate"]:
        return "moderately concentrated"
    else:
        return "highly concentrated"


def validate_hhi(
    hhi: float,
    context: str = "",
    expected_classification: Optional[str] = None,
) -> list[ValidationIssue]:
    """Validate an HHI value."""
    issues = []

    if hhi < 0:
        issues.append(ValidationIssue(
            severity="CRITICAL",
            category="hhi",
            description=f"HHI = {hhi:.1f} is negative. Must be >= 0.",
            value=hhi,
            expected_range="[0, 10000]",
            location=context,
        ))

    if hhi > 10_000:
        issues.append(ValidationIssue(
            severity="CRITICAL",
            category="hhi",
            description=f"HHI = {hhi:.1f} exceeds maximum (10,000). "
                        f"May be using wrong scale (shares should be percentages).",
            value=hhi,
            expected_range="[0, 10000]",
            location=context,
        ))

    if expected_classification:
        actual = classify_hhi(hhi)
        if actual != expected_classification:
            issues.append(ValidationIssue(
                severity="WARNING",
                category="hhi",
                description=f"HHI = {hhi:.1f} classified as '{actual}' "
                            f"but expected '{expected_classification}' for {context}.",
                value=hhi,
                location=context,
            ))

    return issues


# ---------------------------------------------------------------------------
# HS Code Utilities
# ---------------------------------------------------------------------------

def hs_description(code: str) -> str:
    """Get description for an HS2 chapter code."""
    chapter = str(code).zfill(2)[:2]
    return HS2_DESCRIPTIONS.get(chapter, f"Unknown chapter {chapter}")


def hs_chapter(code: str) -> str:
    """Extract HS2 chapter from any HS code."""
    return str(code).zfill(6)[:2]


# ---------------------------------------------------------------------------
# Mirror Data Utilities
# ---------------------------------------------------------------------------

def check_mirror_discrepancy(
    reporter_value: float,
    mirror_value: float,
    threshold: float = 0.3,
) -> list[ValidationIssue]:
    """Check if reporter and mirror (partner-reported) trade values differ too much.

    Args:
        reporter_value: Value reported by the exporting/importing country.
        mirror_value: Value reported by the trade partner.
        threshold: Maximum acceptable relative difference (0.3 = 30%).
    """
    issues = []

    if reporter_value == 0 and mirror_value == 0:
        return issues

    # Use the larger as denominator
    denom = max(reporter_value, mirror_value)
    if denom == 0:
        return issues

    diff = abs(reporter_value - mirror_value) / denom

    if diff > threshold:
        issues.append(ValidationIssue(
            severity="WARNING" if diff < 0.5 else "CRITICAL",
            category="mirror",
            description=f"Reporter ({reporter_value:,.0f}) vs mirror ({mirror_value:,.0f}) "
                        f"differ by {diff:.0%}. May indicate data quality issues.",
            value=diff,
            expected_range=f"< {threshold:.0%}",
        ))

    return issues


# ---------------------------------------------------------------------------
# Trade DB Queries (for TradeWeave's trade.db)
# ---------------------------------------------------------------------------

def query_trade_db(
    db_path: str | Path,
    query: str,
    params: tuple = (),
) -> list[dict]:
    """Run a query against trade.db and return results as list of dicts."""
    db_path = Path(db_path)
    if not db_path.exists():
        raise FileNotFoundError(f"Trade database not found: {db_path}")

    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(query, params).fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def spot_check_trade_value(
    db_path: str | Path,
    reporter: str,
    year: int,
    expected_billions: float,
    tolerance: float = 0.2,
) -> list[ValidationIssue]:
    """Spot-check a country's total trade against known reference values."""
    issues = []

    try:
        results = query_trade_db(
            db_path,
            "SELECT SUM(v) as total FROM baci WHERE i = ? AND t = ?",
            (reporter, year),
        )
        if results and results[0]["total"] is not None:
            # BACI values in thousands, convert to billions
            actual_billions = results[0]["total"] / 1_000_000
            diff = abs(actual_billions - expected_billions) / expected_billions

            if diff > tolerance:
                issues.append(ValidationIssue(
                    severity="WARNING",
                    category="spot_check",
                    description=f"{reporter} {year} total exports: "
                                f"${actual_billions:.1f}B (expected ~${expected_billions:.1f}B, "
                                f"diff {diff:.0%})",
                    value=actual_billions,
                    expected_range=f"~${expected_billions:.0f}B +/- {tolerance:.0%}",
                ))
    except Exception as e:
        issues.append(ValidationIssue(
            severity="INFO",
            category="spot_check",
            description=f"Could not spot-check {reporter} {year}: {e}",
        ))

    return issues


# ---------------------------------------------------------------------------
# Gravity Model Validation
# ---------------------------------------------------------------------------

def validate_gravity_coefficients(
    coefficients: dict[str, float],
) -> list[ValidationIssue]:
    """Validate gravity model coefficient signs and magnitudes."""
    issues = []

    expected = {
        "gdp_reporter": (0.5, 1.5, "positive, ~0.7-1.2"),
        "gdp_partner": (0.5, 1.5, "positive, ~0.7-1.2"),
        "ln_gdp": (0.5, 1.5, "positive, ~0.7-1.2"),
        "distance": (-2.0, -0.3, "negative, ~-0.7 to -1.5"),
        "ln_distance": (-2.0, -0.3, "negative, ~-0.7 to -1.5"),
        "ln_dist": (-2.0, -0.3, "negative, ~-0.7 to -1.5"),
        "contiguity": (0.0, 2.0, "positive, ~0.3-0.8"),
        "common_language": (0.0, 1.5, "positive, ~0.2-0.6"),
        "colonial": (0.0, 2.0, "positive, ~0.5-1.5"),
        "rta": (0.0, 2.0, "positive, ~0.3-1.0"),
    }

    for var, value in coefficients.items():
        var_lower = var.lower().replace(" ", "_")
        for key, (lo, hi, desc) in expected.items():
            if key in var_lower:
                if value < lo or value > hi:
                    issues.append(ValidationIssue(
                        severity="WARNING",
                        category="gravity",
                        description=f"Gravity coefficient '{var}' = {value:.3f} "
                                    f"outside expected range. Should be {desc}.",
                        value=value,
                        expected_range=f"[{lo}, {hi}]",
                        location=var,
                    ))
                break

    return issues


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _print_issues(issues: list[ValidationIssue]) -> None:
    """Pretty-print validation issues."""
    if not issues:
        print("  No issues found.")
        return

    for issue in sorted(issues, key=lambda i: {"CRITICAL": 0, "WARNING": 1, "INFO": 2}[i.severity]):
        prefix = {"CRITICAL": "!!!", "WARNING": " ! ", "INFO": " i "}[issue.severity]
        print(f"  [{prefix}] {issue.description}")
        if issue.expected_range:
            print(f"       Expected: {issue.expected_range}")


def cli_main():
    """Simple CLI for trade data validation."""
    if len(sys.argv) < 2:
        print("Trade Data Toolkit")
        print("Usage:")
        print("  trade_toolkit.py validate-db <path-to-trade.db>")
        print("  trade_toolkit.py hs <code>")
        print("  trade_toolkit.py hhi <share1> <share2> ...")
        print("  trade_toolkit.py convert <value> <to-unit>")
        sys.exit(0)

    cmd = sys.argv[1]

    if cmd == "hs":
        code = sys.argv[2] if len(sys.argv) > 2 else ""
        print(f"HS {code}: {hs_description(code)}")

    elif cmd == "hhi":
        shares = [float(x) for x in sys.argv[2:]]
        hhi = compute_hhi(shares, already_percentage=True)
        print(f"HHI: {hhi:.1f} ({classify_hhi(hhi)})")

    elif cmd == "convert":
        value = float(sys.argv[2])
        unit = sys.argv[3] if len(sys.argv) > 3 else "billions"
        result = convert_baci_value(value, unit)
        print(f"{value:,.0f} (thousand USD) = {result:,.4f} {unit}")

    elif cmd == "validate-db":
        db_path = sys.argv[2] if len(sys.argv) > 2 else "data/trade.db"
        print(f"Validating trade database: {db_path}")
        all_issues = []

        # Spot check known values
        for country, expected in [("CHN", 3500), ("USA", 1700), ("BGD", 55)]:
            for year in [2020, 2021, 2022]:
                all_issues.extend(
                    spot_check_trade_value(db_path, country, year, expected, 0.3)
                )

        _print_issues(all_issues)

    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    cli_main()
