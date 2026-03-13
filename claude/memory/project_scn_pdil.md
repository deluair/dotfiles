---
name: SCN Race 2 PDIL Paper Project
description: PMGAI project for Sultana & Hewezi SCN PDIL resistance gene manuscript, with LaTeX and DOCX generation
type: project
---

## SCN Race 2 PDIL Paper

- **Location**: `~/pmgai/projects/scn_race2_pdil/`
- **Repo**: `deluair/pmgai` (private)
- **Authors**: Mst Shamira Sultana, Tarek Hewezi (Neal Stewart removed 2026-03-11)
- **Topic**: Functional characterization of PDIL gene (Glyma.14g050600) on chromosome 14 conferring soybean resistance to SCN Hg Type 1.2.5.7

### Key Files
- `src/generate_paper.py`: LaTeX manuscript (MPMI published two-column format)
- `src/generate_docx.py`: DOCX working paper (single-column, double-spaced, 12pt TNR)
- `src/analyze_data.py`: Parse Excel data, generate 4 bar plots with significance annotations
- `src/make_photo_figures.py`: Composite photo figures (transformation pipeline, nematode assay, confocal)
- `src/references.bib`: 42 references

### Data Sources (on USB, gitignored)
- `data/raw/*.xlsx`: VIGS, hairy root, T2 nematode assay, qPCR Excel files
- `data/raw/Soybean transformation pic/`: JPGs from transformation stages, Basta, greenhouse, nematode assay
- `data/raw/Subcellular localization.../`: Leica confocal TIF files (RPDIL and SPDIL series)

### Output Structure
- `output/figures/`: 7 main figures (PDF + PNG) plus source photos
- `output/tables/`: 4 LaTeX tabular files
- `paper_output/paper.pdf`: Compiled MPMI-format manuscript
- `paper_output/working_paper.docx`: Single-column working paper with 6 supplementary figures

### Supplementary Figures (DOCX only)
- S1: Basta herbicide selection (2x2 grid)
- S2: Transformation stages detail (2x3 grid)
- S3: Greenhouse plants (2x2 grid)
- S4: Nematode assay setup (2x3 grid)
- S5: Additional RPDIL confocal (2x2 grid, TIF->PNG conversion)
- S6: Additional SPDIL confocal (2x2 grid, TIF->PNG conversion)

### Journal Style
- MPMI published format: two-column, Times (newtxtext), unnumbered bold headers, "Fig." abbreviation, (Author Year) citations, Literature Cited heading
- Section order: Introduction, Results, Discussion, Materials and Methods
