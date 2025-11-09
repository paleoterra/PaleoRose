# PaleoRose Agents and Skills

Complete reference for all project agents and skills.

## Agents (7)

Agents are autonomous helpers that can make decisions, edit files, and perform complex multi-step tasks.

### 1. **test-runner**
Run, analyze, and debug Xcode tests
- Execute all tests or specific suites
- Parse test output and identify failures
- Re-run failed tests
- Measure test performance
- Help debug test failures

**Use:** `Run all tests` or `Run TableListControllerTests`

### 2. **code-reviewer**
Comprehensive code review before commits/PRs
- Review changed files for bugs and issues
- Check security vulnerabilities
- Verify best practices and style
- Suggest improvements
- Categorize issues by severity

**Use:** `Review my changes` or `Review before commit`

### 3. **performance-profiler**
Profile app performance and identify bottlenecks
- Launch Instruments for profiling
- Analyze Time Profiler traces
- Check for memory leaks
- Identify slow methods
- Suggest optimizations

**Use:** `Profile app performance` or `Find performance bottlenecks`

### 4. **ui-snapshot-tester**
Generate and manage UI snapshot tests
- Create reference images
- Detect visual regressions
- Test Dark/Light modes
- Update reference snapshots

**Use:** `Create snapshot tests for XRoseView`

### 5. **package-manager**
Manage Swift Package dependencies
- Add/update SPM packages
- Resolve version conflicts
- Check for security updates
- Analyze dependency tree

**Use:** `Update Swift packages` or `Add dependency for X`

### 6. **objc-swift-bridge-helper**
Improve Objective-C/Swift interoperability
- Generate bridging headers
- Add @objc annotations
- Convert ObjC to Swift
- Handle nullability properly

**Use:** `Help bridge this Objective-C code to Swift`

### 7. **swift-linting-formatter**
Manage and troubleshoot SwiftLint configuration
- Configure SwiftLint rules
- Fix linting violations
- Optimize configuration
- Resolve rule conflicts

**Use:** `Configure SwiftLint` or `Fix linting errors`

---

## Skills (18)

Skills are tools and scripts for specific read-only or data-processing tasks.

### Code Quality & Analysis

#### **api-documentation-generator**
Generate DocC documentation for your codebase

#### **architecture-diagram-generator**
Create visual diagrams of class relationships and dependencies

#### **build-time-optimizer**
Analyze and optimize Xcode build times

#### **code-cleanup-assistant**
Auto-clean code: remove dead code, organize imports, format

#### **code-metrics-analyzer** ⭐ NEW
Calculate code complexity, coverage, and quality metrics
- Cyclomatic complexity
- Lines of code analysis
- Find refactoring candidates

**Use:** `./code_metrics.py analyze --source-dir PaleoRose`

#### **dependency-analyzer**
Analyze module dependencies and detect circular refs

#### **swift-modernizer**
Modernize Swift code to latest language features

### Testing & Debugging

#### **test-generator**
Generate comprehensive unit tests using Swift Testing

#### **crash-log-analyzer** ⭐ NEW
Parse macOS crash logs and symbolicate stack traces
- Identify crash causes
- Extract debugging info
- Find crash patterns

**Use:** `./crash_analyzer.py crash.crash`

#### **graphics-test-visualizer**
Visualize graphics output from unit tests

#### **sqlite-test-validator** ⭐ NEW
Test database migrations and validate schema changes
- Test migration scripts
- Compare schemas
- Verify data integrity

**Use:** `./sqlite_validator.py test-migration --from old.db --to new.db`

### Database & Data

#### **database-migration-helper**
Generate SQLite migration scripts

#### **xrose-database-reader** ⭐ NEW (Enhanced)
Read and analyze XRose database files with Python tools
- List tables and datasets
- Read data tables
- Find orphaned tables
- Export CSV/JSON

**Use:** `./xrose_reader.py database.XRose summary`

### UI & Assets

#### **asset-catalog-optimizer** ⭐ NEW
Optimize asset catalogs and find unused images
- Find unused assets
- Check missing resolutions
- Compress images
- Calculate savings

**Use:** `./asset_optimizer.py Assets.xcassets analyze`

#### **interface-builder-validator** ⭐ NEW
Validate XIB/Storyboard files
- Find broken outlets
- Check accessibility
- Detect Auto Layout issues

**Use:** `./ib_validator.py validate --path "**/*.xib"`

#### **swiftui-converter**
Convert AppKit/NSView code to SwiftUI

### Project Management

#### **file-organizer**
Organize project files and sync with Xcode groups

#### **git-manager**
Comprehensive git workflow manager

#### **xcodeproj-analyzer** ⭐ NEW
Parse and analyze Xcode project files
- List targets and configs
- Find missing files
- Analyze build settings

**Use:** `./xcodeproj_reader.py PaleoRose.xcodeproj summary`

### Graphics & Performance

#### **coregraphics-helper**
Generate CoreGraphics/AppKit drawing code

#### **performance-profiler-tools** ⭐ NEW
Analyze Instruments trace files with Python
- Parse .trace files
- Compare performance
- Find hot paths

**Use:** `./instruments_analyzer.py analyze app.trace`

### Localization & Deployment

#### **localization-manager** ⭐ NEW
Manage localization strings and translations
- Find missing translations
- Extract strings from code
- Generate reports

**Use:** `./localization_manager.py find-missing --base-lang en`

#### **ci-cd-helper** ⭐ NEW
Generate CI/CD configurations
- GitHub Actions workflows
- Fastlane setup
- Build automation

**Use:** `./generate_github_workflow.sh --platform macos`

### Documentation

#### **videocast-script-writer**
Create video scripts from code changes

---

## Quick Reference

### By Use Case

**Before Committing:**
1. `code-reviewer` - Review changes
2. `test-runner` - Run tests
3. `swift-linting-formatter` - Fix lint issues

**Debugging:**
1. `crash-log-analyzer` - Parse crash logs
2. `test-runner` - Debug test failures
3. `performance-profiler` - Find bottlenecks

**Optimization:**
1. `build-time-optimizer` - Speed up builds
2. `asset-catalog-optimizer` - Reduce app size
3. `code-metrics-analyzer` - Find complex code
4. `performance-profiler-tools` - Analyze traces

**Database Work:**
1. `xrose-database-reader` - Inspect XRose files
2. `database-migration-helper` - Create migrations
3. `sqlite-test-validator` - Test migrations

**Project Maintenance:**
1. `file-organizer` - Organize files
2. `xcodeproj-analyzer` - Check project health
3. `dependency-analyzer` - Review dependencies
4. `package-manager` - Update packages

**UI/UX:**
1. `ui-snapshot-tester` - Visual regression testing
2. `interface-builder-validator` - Check XIBs
3. `asset-catalog-optimizer` - Optimize assets

---

## Newly Added (15)

⭐ **Agents (5):**
- test-runner
- code-reviewer
- performance-profiler
- ui-snapshot-tester
- package-manager
- objc-swift-bridge-helper

⭐ **Skills (10):**
- xcodeproj-analyzer
- crash-log-analyzer
- asset-catalog-optimizer
- code-metrics-analyzer
- interface-builder-validator
- sqlite-test-validator
- localization-manager
- ci-cd-helper
- performance-profiler-tools

All existing agents and skills remain unchanged and conflict-free!
