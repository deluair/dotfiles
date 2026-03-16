# Research Paper Pipeline

Guide for writing a publishable economics research paper. Follow this workflow.

## Workflow

### Phase 1: Setup
1. Identify the research question and contribution
2. Locate relevant data (OneDrive, APIs, downloaded files)
3. Set up analysis environment (econai toolkit if available, or standalone scripts)

### Phase 2: Analysis
1. Load and clean data
2. Run descriptive statistics
3. Implement empirical strategy:
   - OLS/PPML/IV as appropriate
   - Include standard controls
   - Cluster standard errors correctly
4. Robustness checks (at least 3 alternative specifications)

### Phase 3: Paper Generation
1. Structure: Abstract, Introduction, Literature, Data, Methodology, Results, Discussion, Conclusion
2. **Tables and figures**: NEVER inline in body text
   - Collect into a queue during generation
   - Render after References, before Appendix
   - Each on its own page with caption and source notes
3. Use working paper style (see wine analysis paper as reference)
4. Include all regression tables with standard errors in parentheses
5. Star notation: * p<0.10, ** p<0.05, *** p<0.01

### Phase 4: Review
1. Self-review: run `/reviewer2` on the paper
2. Check: "Would a second-tier journal accept this?"
3. Visual check: render PDF, screenshot, verify formatting
4. Fix issues from review
5. Final visual check

### Phase 5: Output
- Generate PDF via LaTeX or PaperPipeline
- Save to project directory
- If using econai toolkit: `uv run python -m econai.latex.pipeline`

## Quality Bar
- Every claim must have a citation or data reference
- Every number in text must match a table or figure
- No "we find that X is significant" without showing the coefficient
- Acknowledge limitations honestly
