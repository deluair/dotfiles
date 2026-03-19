---
name: AI & Bangladesh 100 stories project
description: 100 interconnected Bengali short stories about AI impact on Bangladesh, Humayun Ahmed style, deployed on bdfacts.org
type: project
---

100 Bengali short stories written and deployed to bdfacts.org/ai-stories.

**Why:** Explore AI's impact on Bangladesh through fiction, not policy papers. Humayun Ahmed literary style. Sweet and sour, hope and warning.

**How to apply:**
- Source: `~/bdfacts/content/narratives/2026-03-18-ai-bd-part-{1-100}/` (meta.yaml + index.md)
- Migration: `cd ~/bdfacts && uv run --with pyyaml python scripts/migrate-narratives.py`
- Series slug in narrativeData.js: "কৃত্রিম বুদ্ধিমত্তা ও বাংলাদেশ"
- Page: `/ai-stories` (AIStories.jsx)
- 5 characters: Rahima (garment), Karim (farmer), Tania (tech), Zahid (migrant), Selina (health)
- 10 chapters spanning 2025-2045
- Quality: audited at 8.2/10, stories 86 and 92 rated 9/10
- Key fix: parts 54-56 had JSON meta.yaml (fixed to YAML)
- bdfacts owns all narrative content now, no dependency on bdpolicylab/omtt
