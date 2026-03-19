# Trade Data Check

Validate trade data using the trade toolkit. Use for TradeWeave or any trade analysis.

## Quick Checks

### Validate trade.db
```bash
uv run python ~/scripts/trade-toolkit/trade_toolkit.py validate-db ~/tradeweave/data/trade.db
```

### Look up HS code
```bash
uv run python ~/scripts/trade-toolkit/trade_toolkit.py hs 85
# Output: HS 85: Electrical machinery, electronics
```

### Compute HHI
```bash
uv run python ~/scripts/trade-toolkit/trade_toolkit.py hhi 85 5 3 2 1.5 1 0.5
# Pass market shares as percentages
```

### Convert BACI units
```bash
uv run python ~/scripts/trade-toolkit/trade_toolkit.py convert 25000000 billions
# Output: 25,000,000 (thousand USD) = 25.0000 billions
```

## In-Code Validation
When reviewing trade analysis code, import and use:

```python
import sys
sys.path.insert(0, str(Path.home() / "scripts" / "trade-toolkit"))
from trade_toolkit import (
    validate_baci_values,
    validate_complexity_ranking,
    validate_elasticity,
    validate_gravity_coefficients,
    compute_hhi,
    check_mirror_discrepancy,
)
```

## What to Check
1. **BACI units**: values in thousand USD, quantities in metric tons
2. **Complexity**: semiconductors > raw materials (if inverted, calc is wrong)
3. **Elasticities**: own-price [-5, 0], cross-price [-1, 2], income [-0.5, 3]
4. **HHI**: 0-10,000 scale, BGD exports should be "highly concentrated" (RMG ~85%)
5. **Gravity coefficients**: GDP positive ~1.0, distance negative ~-1.0
6. **Mirror data**: reporter vs partner-reported should agree within 30%
7. **Country codes**: no duplicates (common bug: DEU appearing twice)
