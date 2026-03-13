Run a data integrity audit on the current project. Check:

## Database Integrity
- Open each `.db` file with `sqlite3` and run `PRAGMA integrity_check`.
- Check for stale WAL/SHM files alongside any .db file.
- Verify all tables have data (not empty).
- Check for NULL values in columns that should not be NULL.
- Verify row counts are reasonable (not 0, not suspiciously low).

## API Endpoints (if web project)
- List all API routes from the codebase.
- For each route, verify the SQL query references valid tables and columns.
- Check that response schemas match what the frontend expects.
- Flag any endpoints that return hardcoded/mock data.

## Data Sources
- Verify all data files referenced in code actually exist on disk.
- Check file sizes are reasonable (not 0 bytes, not truncated).
- For CSV/JSON data files, verify headers match what the code expects.

## Cross-Reference
- Verify numbers displayed on the frontend match what the database returns.
- Check units (USD vs thousands, percentages vs decimals, kg vs tonnes).
- Flag any magic numbers or unexplained multipliers (1000, 1e6, etc.) and verify they are correct.

Report findings grouped by severity: CRITICAL (wrong data shown to users), WARNING (potential issue), INFO (minor observation).
