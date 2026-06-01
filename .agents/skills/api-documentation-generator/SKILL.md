---
description: Generate comprehensive API documentation using DocC (Swift-DocC) for your PaleoRose project
---

# API Documentation Generator

Generate comprehensive API documentation using DocC (Swift-DocC) for your PaleoRose project.

## Capabilities

1. **DocC Documentation**
   - Generate DocC catalogs from code
   - Create documentation articles
   - Build tutorials and guides
   - Generate browsable documentation websites

2. **Code Comment Enhancement**
   - Add missing documentation comments
   - Improve existing doc comments
   - Follow Swift API Design Guidelines
   - Add parameter/return descriptions

3. **Documentation Structure**
   - Organize into logical groups
   - Create topic collections
   - Build navigation hierarchies
   - Link related APIs

4. **Rich Content**
   - Add code examples
   - Include diagrams and images
   - Create interactive tutorials
   - Embed rendered graphics examples

5. **Export Formats**
   - Static HTML website
   - Xcode Documentation Browser
   - PDF documentation
   - Markdown files

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan code for documentation gaps
2. **Enhance**: Add/improve doc comments
3. **Structure**: Organize documentation hierarchy
4. **Generate**: Build DocC catalog
5. **Export**: Create browsable documentation

## Usage Instructions

When the user invokes this skill:

1. Ask what to document:
   - Entire project
   - Specific module/framework
   - Public API only
   - Include internal APIs

2. Choose documentation style:
   - **Minimal**: Basic summaries only
   - **Standard**: Summaries + parameters/returns
   - **Comprehensive**: Full examples and explanations

3. Generate documentation structure
4. Build DocC catalog
5. Export to desired format

## Project-Specific Context

Your key documentation targets:
- **CodableSQLiteNonThread**: Database framework
- **Graphics**: Visualization classes (Graphic, GraphicPetal, etc.)
- **Document Model**: DocumentModel, InMemoryStore
- **Layers**: Layer hierarchy and storage
- **Utilities**: Extensions and helpers

## DocC Comment Patterns

### 1. Type Documentation

```swift
/// A petal-shaped graphic element for rose diagrams.
///
/// `GraphicPetal` renders a wedge-shaped petal extending from the center
/// of a rose diagram, with its radius determined by the data value it represents.
///
/// ## Overview
///
/// Petals are the primary visual elements in rose diagrams, showing directional
/// data distribution. Each petal represents a bin of directional measurements,
/// with its length proportional to the frequency or magnitude of measurements
/// in that direction.
///
/// ## Topics
///
/// ### Creating Petals
///
/// - ``init(controller:forIncrement:forValue:)``
///
/// ### Geometry Calculation
///
/// - ``calculateGeometry()``
/// - ``petalIncrement``
/// - ``maxRadius``
/// - ``percent``
///
/// ### Drawing
///
/// - ``drawingPath``
/// - ``lineWidth``
@objc class GraphicPetal: Graphic {
    // ...
}
```

### 2. Method Documentation

```swift
/// Creates a new petal graphic with the specified parameters.
///
/// - Parameters:
///   - controller: The geometry controller providing drawing parameters
///     such as center point, maximum radius, and angular spacing.
///   - increment: The zero-based index of this petal's angular position.
///     For a 16-bin rose diagram, valid values are 0-15.
///   - aNumber: The data value for this petal. Interpreted as either
///     a count or percentage depending on the geometry controller's
///     configuration.
///
/// - Returns: A configured petal graphic, or `nil` if the geometry
///   controller cannot provide valid parameters.
///
/// ## Example
///
/// ```swift
/// let controller = MyGeometryController()
/// let petal = GraphicPetal(
///     controller: controller,
///     forIncrement: 0,  // North direction
///     forValue: NSNumber(value: 25.5)
/// )
/// ```
@objc init?(
    controller: GraphicGeometrySource,
    forIncrement increment: Int32,
    forValue aNumber: NSNumber
) {
    // ...
}
```

### 3. Property Documentation

```swift
/// The line width used when stroking the petal's outline.
///
/// When this property changes, the underlying ``drawingPath`` is automatically
/// updated to use the new line width. The default value is inherited from
/// the ``Graphic`` base class.
///
/// - Note: Line width is measured in points and should typically range
///   from 0.5 to 3.0 for optimal appearance.
override var lineWidth: Float {
    didSet {
        drawingPath?.lineWidth = CGFloat(lineWidth)
    }
}
```

### 4. Protocol Documentation

```swift
/// A type that can be represented as a SQLite database table.
///
/// Conforming types can be automatically encoded to and decoded from
/// SQLite databases using the CodableSQLiteNonThread framework.
///
/// ## Overview
///
/// Types conforming to `TableRepresentable` must:
/// 1. Conform to `Codable` for serialization
/// 2. Provide a unique table name
/// 3. Optionally specify a primary key column
/// 4. Implement query generation methods
///
/// ## Topics
///
/// ### Required Properties
///
/// - ``tableName``
/// - ``primaryKey``
///
/// ### Query Generation
///
/// - ``createTableQuery()``
/// - ``insertQuery()``
/// - ``updateQuery()``
/// - ``deleteQuery()``
/// - ``countQuery()``
///
/// ### Value Binding
///
/// - ``valueBindables(keys:)``
///
/// ## Example
///
/// ```swift
/// struct Layer: TableRepresentable {
///     static var tableName: String { "Layer" }
///     static var primaryKey: String? { "id" }
///
///     let id: UUID
///     let name: String
///     let layerType: Int
/// }
/// ```
public protocol TableRepresentable: Codable {
    static var tableName: String { get }
    static var primaryKey: String? { get }
    // ...
}
```

### 5. Extension Documentation

```swift
/// Angle manipulation utilities.
///
/// These extensions provide common operations for working with angles
/// in both degrees and radians, essential for rose diagram calculations.
extension CGFloat {
    /// Normalizes an angle to the 0-360 degree range.
    ///
    /// This method ensures angles are always positive and within a single
    /// rotation, making comparisons and calculations more reliable.
    ///
    /// - Returns: The normalized angle in degrees.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let angle1 = CGFloat(450).normalizedAngle()  // 90.0
    /// let angle2 = CGFloat(-30).normalizedAngle()  // 330.0
    /// ```
    func normalizedAngle() -> CGFloat {
        var angle = self
        while angle < 0 {
            angle += 360
        }
        while angle >= 360 {
            angle -= 360
        }
        return angle
    }

    /// Converts degrees to radians.
    var radians: CGFloat {
        self * .pi / 180.0
    }

    /// Converts radians to degrees.
    var degrees: CGFloat {
        self * 180.0 / .pi
    }
}
```

## Documentation Catalog Structure

### Create DocC Catalog

```
PaleoRose.docc/
├── PaleoRose.md                    # Root documentation page
├── Resources/
│   ├── rose-diagram-example.png
│   ├── layer-hierarchy.png
│   └── database-schema.png
├── Articles/
│   ├── GettingStarted.md
│   ├── RoseDiagrams.md
│   ├── DatabaseModel.md
│   └── GraphicsArchitecture.md
└── Tutorials/
    ├── PaleoRose.tutorial
    ├── CreatingRoseDiagram.tutorial
    └── WorkingWithLayers.tutorial
```

### Root Page (PaleoRose.md)

```markdown
# ``PaleoRose``

A macOS application for creating and analyzing rose diagrams from paleontological data.

## Overview

PaleoRose provides tools for visualizing directional data using rose diagrams,
circular histograms, and other specialized plots commonly used in geology and
paleontology.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:RoseDiagrams>
- <doc:DatabaseModel>

### Graphics and Visualization

- ``Graphic``
- ``GraphicPetal``
- ``GraphicCircle``
- ``GraphicKite``
- ``GraphicHistogram``

### Data Model

- ``DocumentModel``
- ``InMemoryStore``
- ``Layer``
- ``DataSet``

### Database Framework

- ``TableRepresentable``
- ``SQLiteInterface``
- ``Query``

### Utilities

- <doc:GraphicsArchitecture>
- ``CGFloat`` extensions
- ``NSBezierPath`` extensions
```

### Tutorial Example

```markdown
@Tutorial(time: 20) {
    @Intro(title: "Creating Your First Rose Diagram") {
        Learn how to create and customize a rose diagram to visualize
        directional data.

        @Image(source: "rose-diagram-intro.png", alt: "A completed rose diagram")
    }

    @Section(title: "Setting Up Your Data") {
        @ContentAndMedia {
            First, import your directional measurements into PaleoRose.

            @Image(source: "data-import.png", alt: "Data import dialog")
        }

        @Steps {
            @Step {
                Create a new document.

                @Code(name: "CreateDocument.swift", file: 01-create-document.swift)
            }

            @Step {
                Add your measurements to the dataset.

                @Code(name: "AddData.swift", file: 02-add-data.swift)
            }
        }
    }

    @Section(title: "Creating the Diagram") {
        @ContentAndMedia {
            Configure the rose diagram visualization settings.
        }

        @Steps {
            @Step {
                Create a data layer.

                @Code(name: "CreateLayer.swift", file: 03-create-layer.swift)
            }

            @Step {
                Configure petal graphics.

                @Code(name: "ConfigurePetals.swift", file: 04-configure-petals.swift)
            }
        }
    }

    @Assessments {
        @MultipleChoice {
            What does the length of a petal represent in a rose diagram?

            @Choice(isCorrect: false) {
                The angle of the measurement

                @Justification(isCorrect: false) {
                    The angle is represented by the petal's position, not its length.
                }
            }

            @Choice(isCorrect: true) {
                The frequency of measurements in that direction

                @Justification(isCorrect: true) {
                    Correct! Petal length shows how many measurements fall within
                    that directional bin.
                }
            }
        }
    }
}
```

## Building Documentation

### Using Xcode

```bash
# Build documentation in Xcode
xcodebuild docbuild \
    -scheme PaleoRose \
    -derivedDataPath ./DocBuild

# Find generated .doccarchive
find ./DocBuild -name "*.doccarchive"
```

### Using Swift-DocC CLI

```bash
# Install swift-docc-plugin
swift package plugin generate-documentation \
    --target PaleoRose \
    --output-path ./docs

# Preview documentation
swift package plugin preview-documentation \
    --target PaleoRose
```

### Export Static Website

```bash
# Generate static HTML site
swift package plugin generate-documentation \
    --target PaleoRose \
    --hosting-base-path /PaleoRose \
    --output-path ./docs

# Serve locally
python3 -m http.server --directory ./docs 8000
```

## Documentation Comments Checklist

Generate documentation for:

- [ ] All public types
- [ ] All public methods
- [ ] All public properties
- [ ] Protocol requirements
- [ ] Complex internal APIs
- [ ] Framework modules

Each should have:

- [ ] Summary line (one sentence)
- [ ] Overview (detailed description)
- [ ] Parameters (with types and meanings)
- [ ] Returns (what and when)
- [ ] Throws (error conditions)
- [ ] Examples (realistic usage)
- [ ] Notes/Warnings (edge cases)
- [ ] Related APIs (see also links)

## Automated Documentation Audit

```swift
#!/usr/bin/swift

import Foundation

// Scan Swift files for missing documentation
let fileManager = FileManager.default
let projectPath = "./PaleoRose"

func auditDocumentation(in directory: String) {
    // Find all Swift files
    // Parse for public declarations
    // Check for doc comments
    // Report missing documentation
}

struct DocumentationGap {
    let file: String
    let line: Int
    let declaration: String
    let type: DeclarationType

    enum DeclarationType {
        case `class`, `struct`, `enum`, `protocol`
        case method, property, initializer
    }
}

// Generate report
print("Documentation Coverage Report")
print("==============================")
print("")
print("Missing Documentation:")
// ... output gaps

print("")
print("Coverage: \(coveredCount)/\(totalCount) (\(percentage)%)")
```

## Documentation Best Practices

1. **Write for Your Audience**
   - External users: Focus on how to use
   - Internal developers: Include why and how

2. **Use Active Voice**
   - "Creates a petal" not "A petal is created"
   - "Calculates the angle" not "The angle is calculated"

3. **Be Concise**
   - Summary: One sentence
   - Overview: 2-3 paragraphs max
   - Details: As needed

4. **Provide Context**
   - Why does this exist?
   - When should it be used?
   - What are the alternatives?

5. **Include Examples**
   - Realistic use cases
   - Common patterns
   - Edge cases

6. **Link Related Items**
   - Use ``Type`` for symbols
   - Use <doc:Article> for articles
   - Cross-reference related APIs

7. **Keep It Updated**
   - Update docs with code changes
   - Review during PR process
   - Audit periodically

## Integration with CI/CD

### GitHub Actions

```yaml
name: Documentation

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build-docs:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Build Documentation
        run: |
          swift package plugin generate-documentation \
            --target PaleoRose \
            --output-path ./docs

      - name: Deploy to GitHub Pages
        if: github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

## Configuration

Store documentation settings in `.docc-config.json`:
```json
{
  "hostingBasePath": "/PaleoRose",
  "targets": ["PaleoRose", "CodableSQLiteNonThread"],
  "outputPath": "./docs",
  "theme": {
    "color": "#007AFF",
    "iconPath": "./Resources/icon.png"
  },
  "excludedPaths": [
    "*/Tests/*",
    "*/Mocks/*"
  ],
  "generateTutorials": true,
  "generateArticles": true
}
```
