# Document Generation Patterns

## Paper Format: Tables/Figures After References

All document generation scripts should follow this structure:

### Document Order
1. Title Page
2. Abstract
3. Body Sections (prose only, no inline tables/figures)
4. References
5. **Tables** (main-text tables, each on own page)
6. **Appendix** (appendix tables + figures)

### Implementation Pattern
```python
# At start of build_document():
table_queue = []

# In body sections, instead of rendering tables inline:
table_queue.append({
    'title': 'Table N: ...',
    'headers': [...],
    'rows': [...],
    'note': '...',
    'col_widths': None,        # optional
    'bold_first_col': True,    # optional
})

# After References section, before Appendix:
for tbl_info in table_queue:
    doc.add_page_break()
    add_table_caption(doc, tbl_info['title'])
    make_table(doc, tbl_info['headers'], tbl_info['rows'],
               col_widths=tbl_info.get('col_widths'),
               bold_first_col=tbl_info.get('bold_first_col', True))
    if tbl_info.get('note'):
        add_table_note(doc, tbl_info['note'])
```

### Key Points
- Data-building logic stays in the body section where it contextually belongs
- Only rendering is deferred to after References
- Each table gets its own page break
- Same pattern applies to figures if needed (use `figure_queue`)
