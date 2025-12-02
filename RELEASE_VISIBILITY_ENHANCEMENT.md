# Release Visibility Enhancement - Implementation Plan

## Issue Description
Reference: https://all.devstats.cncf.io/d/53/projects-health-table?orgId=1

Currently, release information is displayed at the bottom of the Projects Health Table dashboard. This enhancement will:
1. Move release information to the top of the table for better visibility
2. Parse release versions to distinguish between major, minor, and patch releases (following semantic versioning major.minor.patch)
3. Help identify projects in "maintenance mode" (where minor versions haven't changed in years)

## Benefits
- **Enhanced Visibility**: Release information immediately visible without scrolling
- **Maintenance Mode Detection**: Quickly identify projects with stagnant minor versions
- **Better User Experience**: Improved dashboard usability for project health assessment
- **Governance Insights**: Help CNCF understand project maturity and activity levels

## Current Implementation Analysis

### Files Affected
1. **SQL Metrics**: `metrics/shared/projects_health.sql` (2189 lines)
   - Generates health metrics for all CNCF projects
   - Currently includes: `last_release_date`, `last_release_tag`, `last_release_desc`
   - Release metrics appear at bottom (lines 1012-1027)

2. **HTML Template**: `partials/projects_health.html` (855 lines)
   - Generates the visual table with all projects
   - Uses loop structures to dynamically populate data
   - Currently renders release info at the end of the table

3. **Grafana Dashboard**: `grafana/dashboards/all/projects-health-table.json`
   - References the HTML partial for rendering
   - May need update to refresh correctly

### Current Release Metrics (Bottom of Table)
```sql
-- Line 1012-1027 in projects_health.sql
'Releases: Last release' -- Line 1013
'Releases: Last release date' -- Line 1021
```

Current fields:
- `last_release_date`: Date of most recent release
- `last_release_tag`: Version tag (e.g., "v1.28.0", "2.0.5")
- `last_release_desc`: Release description

## Proposed Solution

### Phase 1: Version Parsing Enhancement
Add semantic version parsing to SQL query to extract:
- **Major version**: First number (e.g., "1" from "v1.28.0")
- **Minor version**: Second number (e.g., "28" from "v1.28.0")  
- **Patch version**: Third number (e.g., "0" from "v1.28.0")

#### SQL Enhancement Strategy
```sql
-- New computed columns to add:
release_major: Extract major version number
release_minor: Extract minor version number  
release_patch: Extract patch version number
release_sem_ver: Formatted as "major.minor.patch"
maintenance_mode: Boolean flag (true if minor version unchanged > 2 years)
```

#### Version Parsing Logic
```sql
-- Handle various version formats:
-- v1.28.0, 1.28.0, v1.28, 1.28, etc.
-- Use regex or string functions:
regexp_replace(last_release_tag, '^v?([0-9]+)\.([0-9]+)\.?([0-9]+)?.*$', '\1') as release_major
regexp_replace(last_release_tag, '^v?([0-9]+)\.([0-9]+)\.?([0-9]+)?.*$', '\2') as release_minor
regexp_replace(last_release_tag, '^v?([0-9]+)\.([0-9]+)\.?([0-9]+)?.*$', '\3') as release_patch
```

### Phase 2: HTML Template Reorganization
Move release information rows from bottom to top of table:

**New Row Order** (after project names):
1. Project names (current row 2)
2. **NEW: Release version (major.minor.patch)**
3. **NEW: Last release date**
4. **NEW: Maintenance mode indicator**
5. Activity status (current row 3)
6. ... rest of existing metrics ...

#### Visual Enhancements
- **Color coding for maintenance mode**:
  - 🟢 Green: Active development (minor version changed < 1 year)
  - 🟡 Yellow: Slow updates (minor version unchanged 1-2 years)
  - 🔴 Red: Maintenance mode (minor version unchanged > 2 years)
  
- **Version display format**: 
  - Current: "v1.28.0"
  - Enhanced: "1.28.0" with tooltip showing full tag

### Phase 3: Maintenance Mode Detection Logic
```sql
-- Flag projects where minor version hasn't changed
WITH version_history AS (
  SELECT 
    period as project,
    regexp_replace(title, '^v?([0-9]+)\.([0-9]+)\.?([0-9]+)?.*$', '\1.\2') as major_minor,
    time as release_date
  FROM sannotations_shared
  WHERE title != 'CNCF join date'
),
latest_minor_change AS (
  SELECT 
    project,
    MAX(release_date) as last_minor_change
  FROM version_history
  GROUP BY project, major_minor
)
-- Calculate days since last minor version change
```

## Implementation Steps

### Step 1: Update SQL Query (projects_health.sql)
1. Add version parsing logic to extract major, minor, patch
2. Add maintenance mode detection
3. Move release-related SELECT statements to top of union queries (after activity status)
4. Test query performance with new regex operations

### Step 2: Update HTML Template (projects_health.html)
1. Locate release information rows (search for "Releases: Last release")
2. Cut those row sections
3. Paste them after project name row and activity status row
4. Update loop indices if needed
5. Add CSS styling for maintenance mode colors
6. Add tooltips for version information

### Step 3: CSS Styling
Add new styles to `<style>` section:
```css
td.release-active {
  background-color: #2d5016 !important; /* Dark green */
}
td.release-slow {
  background-color: #665200 !important; /* Dark yellow */
}
td.release-maintenance {
  background-color: #661600 !important; /* Dark red */
}
td.release-version {
  font-weight: bold;
  font-family: 'Courier New', monospace;
}
```

### Step 4: Testing
1. Run SQL query against test database
2. Verify version parsing works for various formats
3. Check maintenance mode detection accuracy
4. Test HTML rendering with sample data
5. Validate all projects display correctly
6. Verify sorting and filtering still works

### Step 5: Documentation Updates
1. Update `DASHBOARDS.md` with new release visibility features
2. Add maintenance mode explanation
3. Document version parsing logic
4. Update screenshots if available

## Edge Cases to Handle

### Version Format Variations
- Standard semantic: `v1.28.0`, `1.28.0`
- Two-part versions: `v1.28`, `1.28`
- Pre-release tags: `v1.28.0-rc1`, `v1.28.0-alpha.1`
- Non-semantic: `release-2024-11-26`, `snapshot-1234`
- Calendar versioning: `2024.11.0`

### Data Quality Issues
- Projects without releases
- Invalid version strings
- Missing annotations
- Archived projects

### Performance Considerations
- Regex operations on large datasets
- Window functions with version history
- Dashboard load time impact

## Rollback Plan
If issues arise:
1. Keep original SQL/HTML as backup files
2. Git branch allows easy reversion
3. Test on staging environment first
4. Gradual rollout per project type (graduated → incubating → sandbox)

## Success Metrics
- ✅ Release info visible at top of table
- ✅ Version parsing accuracy > 95%
- ✅ Maintenance mode detection working
- ✅ No performance degradation
- ✅ Positive user feedback from CNCF community

## Timeline Estimate
- Phase 1 (SQL): 4-6 hours
- Phase 2 (HTML): 3-4 hours  
- Phase 3 (Testing): 2-3 hours
- **Total**: 9-13 hours development time

## Questions for Stakeholders
1. What constitutes "maintenance mode"? (Suggested: 2+ years without minor version change)
2. Should we show previous minor versions for comparison?
3. Should maintenance mode apply to all project types or only graduated/incubating?
4. Is there a preferred color scheme for the dashboard?

## References
- Current dashboard: https://all.devstats.cncf.io/d/53/projects-health-table?orgId=1
- Semantic Versioning: https://semver.org/
- PostgreSQL regex functions: https://www.postgresql.org/docs/current/functions-matching.html
