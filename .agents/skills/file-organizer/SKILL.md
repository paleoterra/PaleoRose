---
description: Organize project files and sync folder structure with Xcode groups for better maintainability
---

# File Organizer

Organize project files and sync folder structure with Xcode groups for better maintainability.

## Capabilities

1. **Folder Structure Organization**
   - Create logical folder hierarchies
   - Match filesystem to Xcode groups
   - Move files to appropriate directories
   - Consolidate scattered files

2. **Xcode Group Synchronization**
   - Sync Xcode groups with folders
   - Fix mismatched file references
   - Remove missing file references
   - Add new files to correct groups

3. **Naming Conventions**
   - Enforce consistent file naming
   - Suggest renames for clarity
   - Group related files together
   - Apply prefixes/suffixes systematically

4. **Code Organization**
   - Group by feature/module
   - Separate by layer (UI/Model/Services)
   - Organize tests alongside code
   - Create subdirectories for subsystems

5. **Cleanup Operations**
   - Remove orphaned files
   - Delete empty directories
   - Find duplicate files
   - Archive deprecated code

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan current file structure
2. **Compare**: Check Xcode project structure
3. **Plan**: Suggest organization improvements
4. **Execute**: Move files and update project
5. **Verify**: Ensure project builds correctly

## Usage Instructions

When the user invokes this skill:

1. Ask organization goal:
   - Sync folders with Xcode groups
   - Reorganize by feature
   - Clean up orphaned files
   - Apply naming conventions

2. Choose organization style:
   - Feature-based (by functionality)
   - Layer-based (by architecture layer)
   - Type-based (by file type)
   - Module-based (by framework)

3. Review proposed changes
4. Apply reorganization
5. Update Xcode project file

## Project-Specific Context

Your current structure issues:
- Mixed organization styles
- Some Xcode groups don't match folders
- Legacy files scattered across directories
- Test files not consistently grouped

## Organization Patterns

### 1. Feature-Based Organization

```
PaleoRose/
├── Features/
│   ├── RoseDiagram/
│   │   ├── Models/
│   │   │   ├── GraphicPetal.swift
│   │   │   ├── GraphicCircle.swift
│   │   │   └── GraphicKite.swift
│   │   ├── Views/
│   │   │   └── DiagramView.swift
│   │   ├── Controllers/
│   │   │   └── DiagramController.swift
│   │   └── Tests/
│   │       ├── GraphicPetalTests.swift
│   │       └── GraphicCircleTests.swift
│   ├── DataManagement/
│   │   ├── Models/
│   │   │   ├── Layer.swift
│   │   │   ├── LayerCore.swift
│   │   │   └── DataSet.swift
│   │   ├── Storage/
│   │   │   ├── InMemoryStore.swift
│   │   │   └── SQLiteInterface.swift
│   │   └── Tests/
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift
│       │   └── AboutView.swift
│       └── Controllers/
│           └── SettingsWindowController.swift
└── Shared/
    ├── Extensions/
    │   ├── CGFloat+Extensions.swift
    │   └── NSBezierPath+Extensions.swift
    └── Utilities/
        ├── Logger.swift
        └── CommonUtilities.swift
```

### 2. Layer-Based Organization

```
PaleoRose/
├── Presentation/
│   ├── Views/
│   ├── Controllers/
│   └── ViewModels/
├── Domain/
│   ├── Models/
│   ├── Services/
│   └── Protocols/
├── Data/
│   ├── Storage/
│   ├── Repositories/
│   └── DTOs/
├── Infrastructure/
│   ├── Database/
│   ├── FileIO/
│   └── Logging/
└── Tests/
    ├── PresentationTests/
    ├── DomainTests/
    └── DataTests/
```

### 3. Current to Improved Structure

```
# Before (mixed organization)
PaleoRose/
├── Classes/
│   ├── Graphics/
│   │   ├── GraphicPetal.swift
│   │   ├── XRGraphicPetal.m  # Legacy Obj-C
│   │   ├── GraphicCircle.swift
│   ├── Document/
│   │   ├── DocumentModel.swift
│   │   ├── XRoseDocument.m
│   │   └── Table Work/
│   │       └── XRTableAddColumnController.swift
│   └── Layer Control/
│       ├── XRLayer.m
│       └── XRLayerData.swift
├── Unit Tests/
│   ├── GraphicPetalTests.swift  # Separate from source
│   └── AffineTransform+extensions.swift
└── PaleoRose/
    └── AppDelegate.swift

# After (organized)
PaleoRose/
├── Graphics/
│   ├── Models/
│   │   ├── Graphic.swift
│   │   ├── GraphicPetal.swift
│   │   ├── GraphicCircle.swift
│   │   └── GraphicKite.swift
│   ├── Legacy/
│   │   ├── XRGraphicPetal.m
│   │   └── XRGraphicPetal.h
│   └── Tests/
│       ├── GraphicPetalTests.swift
│       └── GraphicCircleTests.swift
├── Document/
│   ├── Models/
│   │   ├── DocumentModel.swift
│   │   └── InMemoryStore.swift
│   ├── Storage/
│   │   ├── Layer.swift
│   │   ├── LayerCore.swift
│   │   └── DataSet.swift
│   ├── ViewControllers/
│   │   ├── XRoseWindowController.m
│   │   └── DataTableController.swift
│   ├── Legacy/
│   │   └── XRoseDocument.m
│   └── Tests/
│       └── DocumentModelTests.swift
├── Shared/
│   ├── Extensions/
│   │   ├── CGFloat+Extensions.swift
│   │   ├── AffineTransform+Extensions.swift
│   │   └── NSBezierPath+Extensions.swift
│   └── Utilities/
│       ├── Logger.swift
│       └── CommonUtilities.swift
└── App/
    └── AppDelegate.swift
```

## File Organization Script

```swift
#!/usr/bin/swift

import Foundation

struct FileOrganizer {
    let projectPath: String
    let dryRun: Bool

    struct MoveOperation {
        let from: String
        let to: String
        let reason: String
    }

    func organize() {
        print("📁 Analyzing project structure...")

        let operations = planOrganization()

        print("\nProposed changes:")
        for (index, op) in operations.enumerated() {
            print("\(index + 1). Move: \(op.from)")
            print("   To: \(op.to)")
            print("   Reason: \(op.reason)\n")
        }

        if dryRun {
            print("🔍 Dry run mode - no changes made")
            return
        }

        print("\nApply changes? (y/n): ", terminator: "")
        guard let response = readLine(), response.lowercased() == "y" else {
            print("Cancelled")
            return
        }

        applyOperations(operations)
    }

    func planOrganization() -> [MoveOperation] {
        var operations: [MoveOperation] = []

        // Find all Swift files
        let swiftFiles = findSwiftFiles(at: projectPath)

        for file in swiftFiles {
            if let newLocation = suggestLocation(for: file) {
                if newLocation != file {
                    operations.append(MoveOperation(
                        from: file,
                        to: newLocation,
                        reason: determineReason(file, newLocation)
                    ))
                }
            }
        }

        return operations
    }

    func suggestLocation(for file: String) -> String? {
        let fileName = URL(fileURLWithPath: file).lastPathComponent

        // Test files
        if fileName.hasSuffix("Tests.swift") {
            let baseName = fileName.replacingOccurrences(of: "Tests.swift", with: ".swift")
            // Move next to source file in Tests/ subdirectory
            if let sourceFile = findFile(named: baseName) {
                let sourceDir = URL(fileURLWithPath: sourceFile).deletingLastPathComponent()
                return sourceDir.appendingPathComponent("Tests").appendingPathComponent(fileName).path
            }
        }

        // Extensions
        if fileName.contains("+") {
            return "\(projectPath)/Shared/Extensions/\(fileName)"
        }

        // Utilities
        if fileName.contains("Utilities") || fileName.contains("Helper") {
            return "\(projectPath)/Shared/Utilities/\(fileName)"
        }

        // Graphics
        if fileName.hasPrefix("Graphic") {
            return "\(projectPath)/Graphics/Models/\(fileName)"
        }

        // Layers
        if fileName.hasPrefix("Layer") && !fileName.contains("Tests") {
            return "\(projectPath)/Document/Storage/\(fileName)"
        }

        return nil
    }

    func determineReason(_ from: String, _ to: String) -> String {
        if from.contains("Unit Tests") && to.contains("/Tests/") {
            return "Move test next to source"
        }
        if from.contains("+") {
            return "Group extensions together"
        }
        if to.contains("/Utilities/") {
            return "Consolidate utilities"
        }
        if to.contains("/Graphics/") {
            return "Group graphics classes"
        }
        return "Improve organization"
    }

    func applyOperations(_ operations: [MoveOperation]) {
        for op in operations {
            let toURL = URL(fileURLWithPath: op.to)
            let toDir = toURL.deletingLastPathComponent()

            // Create destination directory
            try? FileManager.default.createDirectory(
                at: toDir,
                withIntermediateDirectories: true
            )

            // Move file
            do {
                try FileManager.default.moveItem(
                    atPath: op.from,
                    toPath: op.to
                )
                print("✓ Moved: \(URL(fileURLWithPath: op.from).lastPathComponent)")
            } catch {
                print("✗ Failed to move \(op.from): \(error)")
            }
        }

        print("\n✅ Organization complete!")
        print("⚠️  Remember to:")
        print("   1. Update Xcode project file")
        print("   2. Verify build succeeds")
        print("   3. Commit changes")
    }

    func findSwiftFiles(at path: String) -> [String] {
        var files: [String] = []

        let enumerator = FileManager.default.enumerator(atPath: path)
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".swift") {
                files.append("\(path)/\(file)")
            }
        }

        return files
    }

    func findFile(named: String) -> String? {
        let files = findSwiftFiles(at: projectPath)
        return files.first { $0.hasSuffix(named) }
    }
}

// Usage
let organizer = FileOrganizer(
    projectPath: "./PaleoRose",
    dryRun: true  // Set to false to apply changes
)

organizer.organize()
```

## Xcode Project Synchronization

### Update Xcode Project File

```ruby
# Install xcodeproj gem
# gem install xcodeproj

require 'xcodeproj'

project_path = 'PaleoRose.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Remove missing references
project.files.each do |file_ref|
  unless File.exist?(file_ref.real_path)
    puts "Removing missing reference: #{file_ref.path}"
    file_ref.remove_from_project
  end
end

# Add new files
Dir.glob('PaleoRose/**/*.swift').each do |file|
  relative_path = file.sub('PaleoRose/', '')

  # Check if already in project
  unless project.files.find { |f| f.path == relative_path }
    puts "Adding: #{relative_path}"

    # Add to appropriate group
    group_name = File.dirname(relative_path)
    group = project.main_group.find_subpath(group_name, true)

    file_ref = group.new_reference(File.basename(file))
    file_ref.set_source_tree('<group>')

    # Add to target if needed
    target = project.targets.first
    target.add_file_references([file_ref]) if file.end_with?('.swift')
  end
end

project.save
puts "✅ Xcode project updated"
```

### Swift Script Alternative

```swift
#!/usr/bin/swift

import Foundation

struct XcodeProjectUpdater {
    let projectPath: String

    func syncWithFilesystem() {
        print("🔄 Syncing Xcode project with filesystem...")

        // This is complex - consider using XcodeGen instead
        // https://github.com/yonaskolb/XcodeGen

        generateProjectYML()
        regenerateProject()
    }

    func generateProjectYML() {
        // Create project.yml for XcodeGen
        let yml = """
        name: PaleoRose
        options:
          bundleIdPrefix: com.paleoterra

        targets:
          PaleoRose:
            type: application
            platform: macOS
            sources:
              - path: PaleoRose
                excludes:
                  - "**/*Tests.swift"
            settings:
              base:
                PRODUCT_BUNDLE_IDENTIFIER: com.paleoterra.PaleoRose

          PaleoRoseTests:
            type: bundle.unit-test
            platform: macOS
            sources:
              - path: PaleoRose
                includes:
                  - "**/*Tests.swift"
            dependencies:
              - target: PaleoRose
        """

        try? yml.write(toFile: "project.yml", atomically: true, encoding: .utf8)
    }

    func regenerateProject() {
        // Run XcodeGen
        shell("xcodegen generate")
    }

    func shell(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
        task.waitUntilExit()
    }
}
```

## Naming Convention Enforcer

```swift
struct NamingConventionChecker {
    func checkFileNaming(at path: String) -> [Issue] {
        var issues: [Issue] = []

        let files = findSwiftFiles(at: path)

        for file in files {
            let fileName = URL(fileURLWithPath: file).lastPathComponent

            // Check naming conventions
            if fileName.hasPrefix("XR") && !file.contains("/Legacy/") {
                issues.append(Issue(
                    file: file,
                    type: .legacyPrefix,
                    suggestion: "Remove XR prefix or move to Legacy/"
                ))
            }

            if fileName.contains(" ") {
                issues.append(Issue(
                    file: file,
                    type: .spaceInName,
                    suggestion: "Replace spaces with underscores or CamelCase"
                ))
            }

            if !fileName.first?.isUppercase ?? false {
                issues.append(Issue(
                    file: file,
                    type: .lowercaseStart,
                    suggestion: "File should start with uppercase letter"
                ))
            }
        }

        return issues
    }

    struct Issue {
        let file: String
        let type: IssueType
        let suggestion: String

        enum IssueType {
            case legacyPrefix
            case spaceInName
            case lowercaseStart
            case inconsistentNaming
        }
    }

    func findSwiftFiles(at path: String) -> [String] {
        // Implementation...
        []
    }
}
```

## Quick Organization Commands

```bash
#!/bin/bash
# quick-organize.sh

# Group all test files
find PaleoRose -name "*Tests.swift" -not -path "*/Tests/*" | while read file; do
    dir=$(dirname "$file")
    mkdir -p "$dir/Tests"
    git mv "$file" "$dir/Tests/"
done

# Group all extensions
find PaleoRose -name "*+*.swift" -not -path "*/Extensions/*" | while read file; do
    mkdir -p "PaleoRose/Shared/Extensions"
    git mv "$file" "PaleoRose/Shared/Extensions/"
done

# Move legacy Obj-C files
find PaleoRose -name "XR*.m" -o -name "XR*.h" | while read file; do
    dir=$(dirname "$file")
    mkdir -p "$dir/Legacy"
    git mv "$file" "$dir/Legacy/"
done

echo "✅ Quick organization complete"
```

## Best Practices

1. **Keep Tests Near Code**
   ```
   Graphics/
   ├── Models/
   │   ├── GraphicPetal.swift
   │   └── Tests/
   │       └── GraphicPetalTests.swift
   ```

2. **Group Related Files**
   ```
   Settings/
   ├── SettingsView.swift
   ├── SettingsWindowController.swift
   └── SettingsViewModel.swift
   ```

3. **Separate Legacy Code**
   ```
   Graphics/
   ├── Models/          # New Swift code
   └── Legacy/          # Old Obj-C code
   ```

4. **Use Descriptive Folder Names**
   ```
   ✓ Document/Storage/
   ✗ Document/DB/

   ✓ Shared/Extensions/
   ✗ Shared/Ext/
   ```

## Configuration

Store organization rules in `.file-organizer.json`:
```json
{
  "organizationStyle": "feature-based",
  "rules": {
    "testFiles": {
      "pattern": "*Tests.swift",
      "location": "{source}/Tests/"
    },
    "extensions": {
      "pattern": "*+*.swift",
      "location": "Shared/Extensions/"
    },
    "utilities": {
      "pattern": "*{Utilities,Helper,Utils}.swift",
      "location": "Shared/Utilities/"
    },
    "legacy": {
      "pattern": "XR*.{m,h}",
      "location": "{current}/Legacy/"
    }
  },
  "excludedPaths": [
    "build/",
    ".build/",
    "Pods/"
  ]
}
```
