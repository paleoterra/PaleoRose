---
description: Convert AppKit/NSView-based graphics and UI code to modern SwiftUI
---

# SwiftUI Converter

Convert AppKit/NSView-based graphics and UI code to modern SwiftUI.

## Capabilities

1. **View Conversion**
   - Convert NSView subclasses to SwiftUI Views
   - Migrate NSViewController to SwiftUI view hierarchies
   - Transform IBOutlets/IBActions to @State/@Binding
   - Convert NIB/XIB layouts to SwiftUI declarative syntax

2. **Graphics Migration**
   - Convert NSBezierPath to SwiftUI Path
   - Transform custom drawing code to Canvas/Shape
   - Migrate CoreGraphics drawing to SwiftUI primitives
   - Convert CALayer animations to SwiftUI animations

3. **Data Flow Modernization**
   - Replace delegate patterns with @Binding/@Environment
   - Convert KVO to @Published properties
   - Migrate NSNotificationCenter to Combine publishers
   - Transform target-action to SwiftUI button actions

4. **Layout System**
   - Convert Auto Layout constraints to SwiftUI layout
   - Transform frame-based layouts to GeometryReader
   - Migrate NSStackView to HStack/VStack/ZStack
   - Convert NSScrollView to ScrollView

5. **macOS Specific Features**
   - Convert NSWindowController to Window/WindowGroup
   - Migrate NSToolbar to SwiftUI toolbar modifiers
   - Transform NSMenu to SwiftUI CommandGroup
   - Convert NSAlert to SwiftUI alert modifiers

## Workflow

When invoked, this skill will:

1. **Analyze**: Identify AppKit views and controllers to convert
2. **Plan**: Generate conversion strategy with dependencies
3. **Convert**: Transform code to SwiftUI equivalents
4. **Integrate**: Update parent views and data flow
5. **Test**: Verify behavior matches original

## Usage Instructions

When the user invokes this skill:

1. Ask what to convert:
   - Specific view/controller
   - Entire view hierarchy
   - Graphics rendering code only
   - UI controls and layout

2. Ask conversion approach:
   - **Incremental**: Wrap AppKit views in NSViewRepresentable
   - **Full Rewrite**: Pure SwiftUI implementation
   - **Hybrid**: SwiftUI shell with AppKit components

3. Analyze dependencies and order
4. Generate SwiftUI code
5. Update data flow and bindings

## Project-Specific Context

### Your Graphics Classes

Based on your codebase:
- `Graphic` base class with NSBezierPath rendering
- `GraphicPetal`, `GraphicCircle`, `GraphicKite`, etc.
- Custom geometry calculations
- AppKit-based drawing

### Example Conversion

#### Before: AppKit Graphics (GraphicPetal)
```swift
@objc class GraphicPetal: Graphic {
    override var lineWidth: Float {
        didSet { drawingPath?.lineWidth = CGFloat(lineWidth) }
    }

    override var drawingPath: NSBezierPath? {
        didSet { drawingPath?.lineWidth = CGFloat(lineWidth) }
    }

    private var petalIncrement: Int = 0
    private var maxRadius: Float = 0.0
    private var percent: Float = 0.0

    @objc override func calculateGeometry() {
        // Complex geometry calculation
        let path = NSBezierPath()
        // ... drawing code
        drawingPath = path
    }

    @objc func draw() {
        strokeColor.setStroke()
        fillColor.setFill()
        drawingPath?.stroke()
        if drawsFill {
            drawingPath?.fill()
        }
    }
}
```

#### After: SwiftUI Graphics
```swift
struct PetalShape: Shape {
    let petalIncrement: Int
    let maxRadius: CGFloat
    let percent: CGFloat
    let geometryController: GraphicGeometrySource

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Translate geometry calculation to Path
        let angles = calculateAngles(
            petalIncrement: petalIncrement,
            size: geometryController.petalSize,
            start: geometryController.startAngle
        )

        // Build path using SwiftUI Path API
        path.move(to: center)
        path.addLine(to: outerPoint)
        path.addArc(...)

        return path
    }

    private func calculateAngles(...) -> [CGFloat] {
        // Same geometry logic, adapted
    }
}

// Usage
struct PetalView: View {
    let petalIncrement: Int
    let maxRadius: CGFloat
    let percent: CGFloat
    let strokeColor: Color
    let fillColor: Color
    let lineWidth: CGFloat

    var body: some View {
        PetalShape(
            petalIncrement: petalIncrement,
            maxRadius: maxRadius,
            percent: percent,
            geometryController: geometryController
        )
        .stroke(strokeColor, lineWidth: lineWidth)
        .background(
            PetalShape(...)
                .fill(fillColor)
        )
    }
}
```

## Common Conversion Patterns

### 1. NSBezierPath → SwiftUI Path

```swift
// AppKit
let bezierPath = NSBezierPath()
bezierPath.move(to: NSPoint(x: 10, y: 10))
bezierPath.line(to: NSPoint(x: 100, y: 100))
bezierPath.close()

// SwiftUI
var path = Path()
path.move(to: CGPoint(x: 10, y: 10))
path.addLine(to: CGPoint(x: 100, y: 100))
path.closeSubpath()
```

### 2. Custom NSView Drawing → Canvas

```swift
// AppKit
class CustomView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.red.setFill()
        dirtyRect.fill()

        let path = NSBezierPath(ovalIn: bounds)
        NSColor.blue.setStroke()
        path.stroke()
    }
}

// SwiftUI
struct CustomView: View {
    var body: some View {
        Canvas { context, size in
            // Fill background
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.red)
            )

            // Draw circle
            let circlePath = Path(
                ellipseIn: CGRect(origin: .zero, size: size)
            )
            context.stroke(
                circlePath,
                with: .color(.blue)
            )
        }
    }
}
```

### 3. NSViewController → SwiftUI View

```swift
// AppKit
class SettingsViewController: NSViewController {
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!

    @IBAction func saveSettings(_ sender: Any) {
        UserDefaults.standard.set(nameField.stringValue, forKey: "name")
        UserDefaults.standard.set(
            enabledCheckbox.state == .on,
            forKey: "enabled"
        )
    }
}

// SwiftUI
struct SettingsView: View {
    @AppStorage("name") private var name = ""
    @AppStorage("enabled") private var enabled = false

    var body: some View {
        Form {
            TextField("Name", text: $name)
            Toggle("Enabled", isOn: $enabled)
        }
        .formStyle(.grouped)
    }
}
```

### 4. Delegate Pattern → @Binding

```swift
// AppKit
protocol ColorPickerDelegate: AnyObject {
    func colorPicker(_ picker: ColorPicker, didSelect color: NSColor)
}

class ColorPicker: NSView {
    weak var delegate: ColorPickerDelegate?

    func selectColor(_ color: NSColor) {
        delegate?.colorPicker(self, didSelect: color)
    }
}

// SwiftUI
struct ColorPicker: View {
    @Binding var selectedColor: Color

    var body: some View {
        ColorPicker("Color", selection: $selectedColor)
            .onChange(of: selectedColor) { newColor in
                // Handle change if needed
            }
    }
}
```

### 5. NSWindowController → WindowGroup

```swift
// AppKit
class DocumentWindowController: NSWindowController {
    static func create() -> DocumentWindowController {
        let controller = DocumentWindowController(
            windowNibName: "DocumentWindow"
        )
        controller.showWindow(nil)
        return controller
    }
}

// SwiftUI
@main
struct PaleoRoseApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PaleoRoseDocument()) { file in
            DocumentView(document: file.$document)
        }
        .commands {
            // Custom menu commands
        }
    }
}
```

## Graphics Migration Strategy

### For Your Rose Diagram Graphics

Your project has specialized graphics (petals, kites, histograms). Recommended approach:

1. **Keep Geometry Logic**
   - Extract calculation methods
   - Make them pure functions
   - Reuse in SwiftUI Shapes

2. **Create Shape Protocols**
```swift
protocol RoseDiagramShape {
    var geometryController: GraphicGeometrySource { get }
    func calculatePath() -> Path
}
```

3. **Incremental Migration**
   - Start with simple shapes (Circle, Line)
   - Move to complex shapes (Petal, Kite)
   - Keep AppKit version until verified

4. **Hybrid Approach**
```swift
// Wrap AppKit view temporarily
struct LegacyGraphicView: NSViewRepresentable {
    let graphic: Graphic

    func makeNSView(context: Context) -> NSView {
        let view = GraphicHostView()
        view.graphic = graphic
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? GraphicHostView)?.graphic = graphic
    }
}
```

## AppKit-to-SwiftUI Equivalents

| AppKit | SwiftUI |
|--------|---------|
| NSView | View |
| NSViewController | View |
| NSWindowController | Window/WindowGroup |
| NSButton | Button |
| NSTextField | TextField |
| NSTextView | TextEditor |
| NSImageView | Image |
| NSScrollView | ScrollView |
| NSStackView | HStack/VStack |
| NSTableView | List/Table |
| NSOutlineView | OutlineGroup |
| NSMenu | Menu |
| NSToolbar | .toolbar { } |
| NSAlert | .alert { } |
| NSColorWell | ColorPicker |
| NSSlider | Slider |
| NSProgressIndicator | ProgressView |
| NSBezierPath | Path |
| CALayer | Canvas/Shape |

## Data Flow Migration

### Observable Pattern
```swift
// AppKit (KVO)
@objc dynamic var name: String = ""

// SwiftUI
@Observable
class Model {
    var name: String = ""
}
```

### Notification Center
```swift
// AppKit
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleChange),
    name: .didChangeValue,
    object: nil
)

// SwiftUI
struct MyView: View {
    var body: some View {
        Text("Hello")
            .onReceive(NotificationCenter.default.publisher(
                for: .didChangeValue
            )) { _ in
                handleChange()
            }
    }
}
```

## Testing Strategy

1. **Visual Comparison**
   - Screenshot AppKit version
   - Render SwiftUI version
   - Compare pixel-by-pixel

2. **Behavioral Tests**
   - Same user interactions
   - Same state changes
   - Same data updates

3. **Performance Benchmarks**
   - Measure rendering time
   - Check memory usage
   - Profile animation smoothness

## Incremental Adoption Path

For PaleoRose migration:

1. **Phase 1: New Windows**
   - Settings window (already SwiftUI)
   - About window (already SwiftUI)

2. **Phase 2: Simple Views**
   - Inspector panels
   - Toolbars

3. **Phase 3: Complex Graphics**
   - Rose diagram rendering
   - Interactive layers

4. **Phase 4: Main Document**
   - Full document window
   - Integration with existing model

## Configuration

Store conversion preferences in `.swiftui-converter.json`:
```json
{
  "targetMinimumOS": "macOS 14.0",
  "conversionStyle": "incremental",
  "keepAppKitFallbacks": true,
  "generatePreviews": true,
  "useNewObservablePattern": true
}
```
