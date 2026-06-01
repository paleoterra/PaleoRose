---
description: Automatically clean up code by removing dead code, organizing imports, standardizing formatting, and applying best practices
---

# Code Cleanup Assistant

Automatically clean up code by removing dead code, organizing imports, standardizing formatting, and applying best practices.

## Capabilities

1. **Dead Code Removal**
   - Remove unused imports
   - Delete unused variables and functions
   - Identify unreachable code
   - Clean up commented-out code

2. **Import Organization**
   - Sort imports alphabetically
   - Remove duplicate imports
   - Group imports by module type
   - Use @testable import only in tests

3. **Code Formatting**
   - Apply consistent spacing and indentation
   - Standardize brace placement
   - Align property declarations
   - Format multi-line function signatures

4. **Swift Idioms**
   - Replace verbose patterns with concise equivalents
   - Use trailing closures where appropriate
   - Apply shorthand argument names
   - Simplify type inference

5. **Code Quality**
   - Extract magic numbers to constants
   - Replace force-unwrapping with safe alternatives
   - Improve naming conventions
   - Add missing access modifiers

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan codebase for cleanup opportunities
2. **Categorize**: Group issues by type and severity
3. **Prioritize**: Suggest fixes in order of importance
4. **Apply**: Make approved changes
5. **Verify**: Run tests to ensure nothing broke

## Usage Instructions

When the user invokes this skill:

1. Ask scope of cleanup:
   - Entire project
   - Specific directory
   - Modified files only
   - Files matching pattern

2. Choose cleanup level:
   - **Safe**: Only non-breaking, obvious improvements
   - **Standard**: Include style improvements
   - **Aggressive**: Apply all recommended changes

3. Select categories:
   - Unused code removal
   - Import organization
   - Formatting fixes
   - Idiom improvements

4. Review and apply changes

## Project-Specific Context

Your codebase has:
- Mixed Swift/Objective-C (in migration)
- SwiftLint configuration
- Legacy code marked for deletion
- Test files with specific patterns

## Cleanup Patterns

### 1. Remove Unused Imports

```swift
// Before
import Foundation
import AppKit
import CoreGraphics
import UniformTypeIdentifiers

class MyView: NSView {
    // Only uses NSView (from AppKit) and CGFloat (from CoreGraphics)
}

// After
import AppKit

class MyView: NSView {
    // Cleaner, faster compilation
}
```

### 2. Dead Code Removal

```swift
// Before
class GraphicPetal: Graphic {
    private var oldProperty: Float = 0  // Never used

    func calculateGeometry() {
        let unusedValue = computeSomething()  // Result never used
        // ... actual calculation
    }

    // Commented out old implementation
    // func oldCalculateGeometry() {
    //     // Old code...
    // }
}

// After
class GraphicPetal: Graphic {
    func calculateGeometry() {
        // ... actual calculation only
    }
}
```

### 3. Organize Imports

```swift
// Before
import AppKit
import Foundation
@testable import PaleoRose
import CoreGraphics

// After
import AppKit
import CoreGraphics
import Foundation

@testable import PaleoRose
```

### 4. Extract Magic Numbers

```swift
// Before
func createPetalPath() {
    let path = NSBezierPath()
    let radius = controller.maxRadius * 0.8
    let angle = Float(increment) * 22.5
    // ...
}

// After
private enum Constants {
    static let radiusMultiplier: Float = 0.8
    static let degreesPerBin: Float = 22.5
}

func createPetalPath() {
    let path = NSBezierPath()
    let radius = controller.maxRadius * Constants.radiusMultiplier
    let angle = Float(increment) * Constants.degreesPerBin
    // ...
}
```

### 5. Simplify Type Inference

```swift
// Before
let center: CGPoint = CGPoint(x: 200, y: 200)
let radius: CGFloat = CGFloat(100)
let colors: [NSColor] = [NSColor.red, NSColor.blue]

// After
let center = CGPoint(x: 200, y: 200)
let radius: CGFloat = 100
let colors: [NSColor] = [.red, .blue]
```

### 6. Use Trailing Closures

```swift
// Before
layers.filter({ $0.isVisible })
    .map({ $0.name })
    .forEach({ print($0) })

// After
layers
    .filter { $0.isVisible }
    .map { $0.name }
    .forEach { print($0) }
```

### 7. Replace Force Unwrapping

```swift
// Before
func processLayer() {
    let layer = findLayer()!
    let data = layer.data!
    updateView(with: data)
}

// After
func processLayer() {
    guard let layer = findLayer(),
          let data = layer.data else {
        return
    }
    updateView(with: data)
}
```

### 8. Improve Access Control

```swift
// Before
class DocumentModel {
    var store: InMemoryStore  // Should be private
    var layers: [Layer]       // Should have explicit access level

    func internalHelper() {   // Should be private
        // ...
    }
}

// After
class DocumentModel {
    private let store: InMemoryStore
    public private(set) var layers: [Layer]

    private func internalHelper() {
        // ...
    }
}
```

### 9. Clean Up Commented Code

```swift
// Before
func calculateGeometry() {
    // Old calculation method
    // let oldRadius = maxRadius * 2
    // let oldAngle = startAngle + 90
    // path.move(to: NSPoint(x: oldRadius, y: 0))

    // New calculation
    let radius = maxRadius
    let angle = startAngle
    path.move(to: NSPoint(x: radius, y: 0))
}

// After
func calculateGeometry() {
    let radius = maxRadius
    let angle = startAngle
    path.move(to: NSPoint(x: radius, y: 0))
}
```

### 10. Standardize Formatting

```swift
// Before
func createGraphic(type:GraphicType,value:Float,controller:GraphicGeometrySource)->Graphic?{
    switch type{
        case .petal:return GraphicPetal(controller:controller,forIncrement:0,forValue:NSNumber(value:value))
        case .circle:return GraphicCircle(controller:controller,radius:value)
        default:return nil}}

// After
func createGraphic(
    type: GraphicType,
    value: Float,
    controller: GraphicGeometrySource
) -> Graphic? {
    switch type {
    case .petal:
        return GraphicPetal(
            controller: controller,
            forIncrement: 0,
            forValue: NSNumber(value: value)
        )
    case .circle:
        return GraphicCircle(controller: controller, radius: value)
    default:
        return nil
    }
}
```

## Automated Cleanup Script

```swift
#!/usr/bin/swift

import Foundation

struct CodeCleanupTool {
    let projectPath: String
    let excludedPaths: [String]

    func cleanup() {
        print("🧹 Starting code cleanup...")

        let swiftFiles = findSwiftFiles()
        var totalChanges = 0

        for file in swiftFiles {
            print("Processing: \(file)")

            var changes = 0
            changes += removeUnusedImports(file)
            changes += organizeImports(file)
            changes += removeCommentedCode(file)
            changes += applySwiftFormat(file)

            if changes > 0 {
                print("  ✓ Made \(changes) changes")
                totalChanges += changes
            }
        }

        print("✅ Cleanup complete: \(totalChanges) total changes across \(swiftFiles.count) files")
    }

    private func findSwiftFiles() -> [String] {
        // Recursively find .swift files
        // Exclude paths in excludedPaths
        []
    }

    private func removeUnusedImports(_ file: String) -> Int {
        // Parse file
        // Analyze symbol usage
        // Remove unused imports
        0
    }

    private func organizeImports(_ file: String) -> Int {
        // Sort imports
        // Group by type
        // Remove duplicates
        0
    }

    private func removeCommentedCode(_ file: String) -> Int {
        // Identify commented-out code blocks
        // Remove (with confirmation)
        0
    }

    private func applySwiftFormat(_ file: String) -> Int {
        // Run SwiftFormat
        0
    }
}

// Usage
let cleanup = CodeCleanupTool(
    projectPath: "./PaleoRose",
    excludedPaths: [
        "build/",
        ".build/",
        "Pods/"
    ]
)

cleanup.cleanup()
```

## Integration with SwiftFormat

### .swiftformat Configuration

```swift
# .swiftformat

--swiftversion 5.9

# Indentation
--indent 4
--tabwidth 4
--indentcase false
--smarttabs enabled

# Spacing
--trimwhitespace always
--commas inline
--semicolons inline

# Wrapping
--wraparguments before-first
--wrapparameters before-first
--wrapcollections before-first
--maxwidth 120

# Organization
--importgrouping testable-bottom
--organizetypes class,struct,enum,extension
--structthreshold 0

# Enabled rules
--enable isEmpty
--enable sortedImports
--enable redundantReturn
--enable redundantSelf
--enable redundantNilInit
--enable redundantParens
--enable trailingCommas
--enable unusedArguments
--enable void

# Disabled rules
--disable blankLinesAroundMark
--disable blankLinesAtStartOfScope
```

### Run SwiftFormat

```bash
# Format entire project
swiftformat .

# Format specific directory
swiftformat ./PaleoRose/Classes/Graphics

# Check without modifying
swiftformat --lint .

# Fix specific rules only
swiftformat --enable sortedImports,isEmpty .
```

## Unused Code Detection

### Using SwiftLint Analyzer Rules

```yaml
# .swiftlint.yml
analyzer_rules:
  - unused_declaration
  - unused_import
```

```bash
# Run SwiftLint with analyzer
swiftlint analyze --compiler-log-path build.log
```

### Manual Detection Script

```swift
#!/usr/bin/swift

import Foundation

struct UnusedCodeDetector {
    func findUnusedDeclarations(in directory: String) -> [UnusedItem] {
        var unused: [UnusedItem] = []

        // Parse all Swift files
        // Build symbol table
        // Find declarations never referenced
        // Report unused items

        return unused
    }

    func findUnreachableCode(in directory: String) -> [UnreachableCode] {
        var unreachable: [UnreachableCode] = []

        // Parse Swift files
        // Analyze control flow
        // Find code after return/throw/break/continue
        // Find switch cases that can never match

        return unreachable
    }
}

struct UnusedItem {
    let file: String
    let line: Int
    let name: String
    let type: DeclarationType

    enum DeclarationType {
        case function, property, type, parameter
    }
}

struct UnreachableCode {
    let file: String
    let line: Int
    let reason: String
}
```

## Cleanup Checklist

When running cleanup assistant:

### Pre-Cleanup
- [ ] Commit current changes
- [ ] Run tests to establish baseline
- [ ] Create backup branch
- [ ] Note current SwiftLint violations count

### Cleanup Steps
- [ ] Remove unused imports
- [ ] Delete commented-out code
- [ ] Remove unused variables/functions
- [ ] Organize imports
- [ ] Apply consistent formatting
- [ ] Extract magic numbers
- [ ] Improve access control
- [ ] Replace force unwrapping
- [ ] Apply Swift idioms

### Post-Cleanup
- [ ] Run SwiftFormat
- [ ] Run SwiftLint
- [ ] Run all tests
- [ ] Build project
- [ ] Compare test results
- [ ] Review diff
- [ ] Commit changes

## Project-Specific Cleanup Targets

### 1. Legacy Obj-C Bridging

Clean up files transitioning from Objective-C:

```swift
// Remove unnecessary @objc attributes
// Before
@objc class GraphicPetal: Graphic {
    @objc var lineWidth: Float  // Only needed if called from Obj-C
}

// After (if no Obj-C callers)
class GraphicPetal: Graphic {
    var lineWidth: Float
}
```

### 2. SwiftLint Exclusions

Your `.swiftlint.yml` excludes 59 files. Clean these up:

```bash
# Find excluded files that no longer exist
for file in $(grep "excluded:" -A 100 .swiftlint.yml | grep "  -" | cut -d'-' -f2); do
    if [ ! -f "$file" ]; then
        echo "Excluded file doesn't exist: $file"
    fi
done
```

### 3. Test File Organization

```swift
// Before: Mixed test helpers and tests
class GraphicPetalTests: XCTestCase {
    func testPetalCreation() { }
    func makeTestController() -> GraphicGeometrySource { }
    func testPetalGeometry() { }
    func makeTestPetal() -> GraphicPetal { }
}

// After: Organized with MARK comments
class GraphicPetalTests: XCTestCase {

    // MARK: - Test Helpers

    private func makeTestController() -> GraphicGeometrySource { }
    private func makeTestPetal() -> GraphicPetal { }

    // MARK: - Creation Tests

    func testPetalCreation() { }

    // MARK: - Geometry Tests

    func testPetalGeometry() { }
}
```

## Batch Operations

### Clean All Graphics Files

```bash
#!/bin/bash

GRAPHICS_DIR="./PaleoRose/Classes/Graphics"

echo "Cleaning Graphics files..."

# Remove unused imports
swiftlint --fix --path "$GRAPHICS_DIR" --enable unused_import

# Format code
swiftformat "$GRAPHICS_DIR"

# Organize with MARK comments
swift run CodeOrganizer --input "$GRAPHICS_DIR" --add-marks

echo "✅ Graphics cleanup complete"
```

## Configuration

Store cleanup settings in `.code-cleanup.json`:
```json
{
  "removeUnusedImports": true,
  "removeCommentedCode": true,
  "organizeImports": true,
  "applySwiftFormat": true,
  "extractMagicNumbers": false,
  "improveAccessControl": true,
  "replaceForceUnwrapping": false,
  "excludedPaths": [
    "*/Tests/*",
    "*/Build/*",
    "*/.build/*"
  ],
  "swiftFormatConfig": ".swiftformat",
  "confirmBeforeDelete": true
}
```
