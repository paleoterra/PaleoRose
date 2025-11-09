---
description: Manage, optimize, and troubleshoot SwiftLint configuration for your project
---

# SwiftLint Helper

Manage, optimize, and troubleshoot SwiftLint configuration for your project.

## Capabilities

1. **Configuration Management**
   - Analyze current `.swiftlint.yml` configuration
   - Suggest enabled/disabled rules based on codebase patterns
   - Identify conflicting or redundant rules
   - Recommend optimal rule settings for project size/type

2. **Violation Resolution**
   - Auto-fix SwiftLint violations where possible
   - Explain violations and suggest manual fixes
   - Batch process multiple violations
   - Prioritize violations by severity

3. **Rule Optimization**
   - Suggest custom rules for project-specific patterns
   - Fine-tune rule parameters (line length, complexity, etc.)
   - Identify noisy rules that should be relaxed
   - Recommend stricter rules for code quality improvements

4. **Exclusion Management**
   - Analyze excluded files/paths
   - Suggest cleanup of excluded legacy files
   - Add new exclusions with justification
   - Track progress on un-excluding migrated files

5. **Integration & Workflow**
   - Set up SwiftLint as Xcode build phase
   - Configure SwiftLint for CI/CD pipelines
   - Create pre-commit hooks
   - Generate reports and metrics

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan `.swiftlint.yml` and project structure
2. **Report**:
   - Current configuration summary
   - Active vs available rules
   - Exclusion list status
   - Violation statistics
3. **Recommend**: Suggest improvements based on:
   - Project type (app, framework, CLI)
   - Team size and practices
   - Existing code patterns
4. **Apply**: Implement approved changes

## Usage Instructions

When the user invokes this skill:

1. Identify the task:
   - Fix violations
   - Optimize configuration
   - Add/remove rules
   - Update exclusions
   - Explain specific violations

2. For **fixing violations**:
   - Run SwiftLint and collect violations
   - Categorize by auto-fixable vs manual
   - Apply auto-fixes with `swiftlint --fix`
   - Provide guidance for manual fixes

3. For **configuration optimization**:
   - Analyze current rules against codebase
   - Suggest additions/removals with rationale
   - Propose parameter tuning
   - Create updated config file

4. For **exclusion management**:
   - Review excluded files list
   - Check if excluded files still exist
   - Identify newly migrated Swift files to un-exclude
   - Update exclusion list

## Configuration Analysis

### Current Project Status

Based on your `.swiftlint.yml`:
- **Enabled Rules**: 200+ (comprehensive coverage)
- **Excluded Files**: 59 Swift files (mostly Obj-C counterparts)
- **Custom Settings**: Line length warnings at 120 chars
- **Analyzer Rules**: 4 enabled (static analysis)

### Optimization Suggestions

1. **Exclusion Cleanup Opportunity**
   - Many excluded files reference deleted Obj-C classes
   - Recommendation: Review and remove obsolete exclusions
   - Some excluded files may be ready for linting (migrated Swift files)

2. **Rule Additions to Consider**
   ```yaml
   # Useful for your graphics-heavy code
   - attributes
   - vertical_whitespace_opening_braces  # Currently disabled
   - type_contents_order  # Enforce consistent type layout
   ```

3. **Custom Rules for Your Project**
   ```yaml
   custom_rules:
     no_xr_prefix_in_swift:
       name: "No XR Prefix in Swift"
       message: "Swift types should not use XR prefix (Obj-C legacy)"
       regex: "\\b(class|struct|enum|protocol) XR"
       severity: warning

     graphics_layer_naming:
       name: "Graphics Layer Naming"
       message: "Graphics layers should use Graphic prefix, not XRGraphic"
       regex: "\\bXRGraphic"
       severity: warning
   ```

## Common Tasks

### Fix All Auto-Fixable Violations
```bash
swiftlint --fix --format
```

### Run SwiftLint on Specific Files
```bash
swiftlint lint --path PaleoRose/Classes/Graphics/
```

### Generate Violation Report
```bash
swiftlint lint --reporter json > swiftlint-report.json
```

### Check Configuration Validity
```bash
swiftlint rules
```

## Exclusion File Tracking

Your project excludes 59 files. Key categories:

1. **Interface Items** (13 files)
   - Property inspectors
   - Panel controllers
   - Accessory views

2. **Graphics** (11 files)
   - XRGraphic* classes being migrated to Graphic*

3. **Document Management** (8 files)
   - View controllers
   - Table controllers

4. **Legacy Code** (12 files)
   - XML parsers (some deleted)
   - File parsers (some deleted)

5. **Layer Control** (6 files)
   - XRLayer* classes

6. **Data & Statistics** (3 files)
   - XRDataSet (deleted)
   - XRStatistic
   - XRMakeDatasetController (deleted)

**Action Items**:
- Remove exclusions for deleted files
- Consider linting migrated Swift versions
- Track progress on Swift migration

## Integration Examples

### Xcode Build Phase Script
```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

FILES=$(git diff --cached --name-only --diff-filter=d | grep ".swift$")

if [ -n "$FILES" ]; then
  swiftlint lint --quiet --strict $FILES
  if [ $? -ne 0 ]; then
    echo "SwiftLint failed. Fix violations before committing."
    exit 1
  fi
fi
```

### GitHub Actions CI
```yaml
- name: SwiftLint
  run: swiftlint lint --reporter github-actions-logging
```

## Configuration Tips

1. **Start Permissive**: Begin with warnings, gradually enforce
2. **Team Consensus**: Only enable rules team agrees on
3. **Document Exceptions**: Use `swiftlint:disable` with comments
4. **Regular Reviews**: Quarterly config audits
5. **Migration Strategy**: Temporarily exclude, fix gradually, re-enable

## Rule Categories

### Code Quality (Enabled)
- Cyclomatic complexity
- Function/type body length
- Nesting levels
- Force unwrapping prevention

### Style & Formatting (Enabled)
- Indentation width
- Line length
- Trailing whitespace
- Comma spacing

### Performance (Enabled)
- Contains over filter
- Reduce into
- First where

### Naming (Enabled)
- Identifier name
- Type name
- Generic type name
- Inclusive language

### Best Practices (Enabled)
- Weak delegate
- Private outlets/actions
- Unused declarations (analyzer)
- Unused imports (analyzer)
