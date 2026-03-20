---
name: TradeWeave light theme redesign
description: User wants to switch TradeWeave from dark-only to a bright, soothing design inspired by oec.world. Major undertaking affecting globals.css, all 52 pages, 17 viz components.
type: project
---

User wants TradeWeave redesigned with a light/bright theme, inspired by oec.world. Current design is dark-only (no light mode toggle).

**Why:** User finds the dark design not soothing to the eyes. Wants institutional, bright, clean look like OEC.

**How to apply:** Next session, plan a full theme migration: new CSS custom properties in globals.css, audit all D3/Deck.gl components for hardcoded dark hex colors, test all 52 pages. Consider OEC's palette (white backgrounds, light grays, clean blues/teals). This touches every page and component.
