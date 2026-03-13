Audit all 3 projects (bddata, trade-explorer, omtt) for cross-project consistency. Use subagents to check each project in parallel.

## Visual Consistency
- Verify shared design DNA: dark glassmorphism, glass-card effects, consistent accent colors per project.
- Check footer links: each site should link to the other two.
- Verify social links (LinkedIn, X, GitHub) are present and correct in all footers/about pages.

## Watermark Integrity
- Check all 6 layers of the secret signature in each project:
  1. HTML comment with attribution
  2. Steganographic code comment (`del::` marker)
  3. Meta tags (author, creator)
  4. Console message on page load
  5. HTTP headers (X-Crafted-By, X-Origin)
- Report any missing or inconsistent layers.

## Security Headers
- Check each project serves: HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, CSP.
- Flag any missing or misconfigured headers.

## Infrastructure
- Verify all 3 sites respond to health checks.
- Check SSL certificate status for each domain.
- Verify GitHub Actions deploy workflows exist and are configured for push-to-main.

Report as a matrix: project x check = PASS/FAIL/WARN.
