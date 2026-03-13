# Cross-Project Reference

## Three Projects at a Glance

| | BDFacts | TradeWeave | OMTT |
|---|---|---|---|
| **Domain** | bdfacts.org | tradeweave.org | bdpolicylab.com |
| **Repo** | `~/bddata` | `~/trade-explorer` | `~/omtt` |
| **Stack** | React 19 + Vite + FastAPI | Next.js 16 + React 19 + TS | FastAPI + Jinja2 |
| **Styling** | CSS vars + per-page CSS | Tailwind v4 + CSS vars | Tailwind CDN + inline |
| **Theme** | Dark (glassmorphism) | Dark (glassmorphism) | Dark (glassmorphism, gold) |
| **Fonts** | Sora, Noto Sans Bengali, Manrope | Inter, JetBrains Mono | Playfair Display, Source Serif 4, Inter |
| **Accent** | Green #00d4a8 | Teal #06b6d4 | Gold #c4a35a |
| **Charts** | Recharts | D3 + Deck.gl | Plotly (CDN) |
| **Deploy** | deploy.sh + GH Actions, systemd | deploy.sh + GH Actions, PM2 | deploy.sh + GH Actions, systemd |
| **DB** | SQLite (analytics, wdi, bangladesh) | SQLite (trade.db 19GB, app.db) | SQLite (bdpolicy.db) |
| **Pages** | 69 routes, 48 pages | 49 pages, 127 API routes | ~10 templates |
| **Tests** | Playwright (smoke + E2E) | None (build validation) | pytest (158 tests) |

## Shared Design DNA (BDFacts + TradeWeave)

Both share a dark glassmorphism design language:
- Dark navy backgrounds (#020810 / #0a0e1a)
- `.glass-card` with backdrop-filter blur + gradient borders
- Green/teal primary accents
- Sans-serif UI fonts (Sora/Inter)
- Monospace-like number fonts (Manrope/JetBrains Mono)
- Ambient glow effects, layered shadows
- Mobile-first responsive, bottom nav on mobile
- Framer Motion / CSS keyframe animations

OMTT now shares the dark glassmorphism language: dark navy (#080c18), Playfair Display serif headings, gold accent (#c4a35a), glass-card effects.

## Shared Infrastructure

- **VPS**: OVH (`$VPS_HOST` from `~/dotfiles/config.sh`)
- **Cloudflare**: All 3 domains proxied, Full (strict) SSL
  - bdfacts.org + bdpolicylab.com: Let's Encrypt origin certs
  - tradeweave.org: Cloudflare Origin Certificate (expires 2041)
- **GitHub**: github.com/`$GITHUB_USER`
- **CI/CD**: All 3 have GitHub Actions deploy on push to main
- **No mock data, no hallucination, no shady things** (all 3 projects)
- **Secret signature**: 6-layer `del` watermark in all projects

## Security & Ops

- **Security headers** (all 3): HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, CSP
- **Rate limiting**: BDFacts (SlowAPI), OMTT (SlowAPI, 60/min), TradeWeave (Next.js built-in)
- **DB backups**: Daily 3am UTC cron on VPS, 7-day retention. Pull to OneDrive: `make vps-pull`
- **Health checks**: `make sites` (local), all 3 have /api/health endpoints
- **Backup DBs on VPS**: `$VPS_BACKUP_PATH` (bdpolicy, bdfacts-analytics, bdfacts-bangladesh, tradeweave-app)

## Cross-Referencing Status

Sites should link to each other in footers and about pages:
- BDFacts footer/about should link to TradeWeave and OMTT
- TradeWeave footer/about should link to BDFacts and OMTT
- OMTT footer/about should link to BDFacts and TradeWeave

## Social Links

- LinkedIn: https://www.linkedin.com/in/mddeluairhossen/
- X: https://x.com/DeluairHossen
- GitHub: https://github.com/`$GITHUB_USER`

## Key Files Per Project

### BDFacts
- Templates: `src/pages/`, `src/components/`
- Design system: `src/index.css` (CSS vars, glassmorphism, animations)
- Nav: `src/components/Navbar.jsx`, `src/components/BottomNav.jsx`
- Footer: `src/components/Footer.jsx`
- Routes: `src/config/routes.js`

### TradeWeave
- Layout: `src/app/layout.tsx`
- Design system: `src/app/globals.css`
- Nav: TopBar.tsx, Sidebar.tsx, MobileNav.tsx in `src/components/layout/`
- Footer: `src/components/layout/Footer.tsx`
- Colors: `src/lib/colors.ts`

### OMTT
- Templates: `app/web/templates/` (Jinja2)
- Base layout: `app/web/templates/base.html` (Tailwind config, nav, footer)
- Homepage: `app/web/templates/index.html`
- Dashboard: `app/web/templates/dashboard.html`
- Backend: `app/main.py`
