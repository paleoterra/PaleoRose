# PaleoRose Development Guidelines

## Project Overview
macOS app for creating and visualizing geological rose diagrams. Users import directional data (azimuths, strikes) and visualize it with rose petals, kites, dots, histograms, and statistical vectors.

**Stack:** Swift 5.9+ / Objective-C (active refactor) · AppKit + SwiftUI · SQLite (CodableSQLiteNonThread) · macOS 13+

## Commands
```bash
# Build
xcodebuild -workspace PaleoRose.xcworkspace -scheme PaleoRose build

# Test (prefer the Xcode MCP tool over shell)
xcodebuild test -workspace PaleoRose.xcworkspace -scheme PaleoRose -testPlan PaleoRose.xctestplan
```

## File Format
`.XRose` files are SQLite databases. Configuration tables are prefixed with `_`; user data tables are unprefixed. See `docs/XRose-File-Format.md`.

## Architecture

```
PaleoRose/Classes/
├── Layer Control/      XRLayer + subclasses (ObjC — active refactor target)
├── Graphics/           CoreGraphics rendering: GraphicPetal, GraphicKite, etc.
├── Geometry Controller/ XRGeometryController (.swift + .m ObjC category)
├── Document/           XRoseView.m, XRoseWindowController.m, LayersTableController.swift
│   └── Document Model/ DocumentModel.swift, InMemoryStore.swift
│       └── SQL Models/ StorageModelFactory, typed Codable layer structs
└── Data/               XRDataSet (ObjC)
```

**Key components:**
- `DocumentModel` — central data owner; all file I/O goes through here, not layer classes
- `InMemoryStore` — SQLite abstraction layer; handles document persistence
- `LayersTableController` — Swift bridge between layer model and UI table view
- `XRoseView` — NSView subclass that renders the rose diagram

## Critical Constraints

- **Never** modify XIB, NIB, or Storyboard files
- **Never** edit `.xcodeproj` directly
- **Never** use direct SQLite operations in layer classes — always use `DocumentModel`

```swift
// ❌ Wrong — direct SQL in layer
layer.saveToSQLDB(database, layerID: id)

// ✅ Correct — through DocumentModel
documentModel.store(layers: layers)
documentModel.writeToFile(fileURL)
```

## Architecture Gotchas

**XRoseView coordinate system**
`computeDrawingFrames` calls `[self setBounds:]` to center the system — after this, `(0,0)` is the **view center**, not top-left. All graphics draw relative to origin. Must complete before graphics are generated.

**Layer Color Persistence**
`StorageModelFactory.defaultFillColor` is **white**. If a color ID lookup fails on load, fill is white-on-white = invisible. Always call `storageLayerFactory.clearColors()` then `storeColors()` after `store(layers:)`.

**readFromStore Delegate Order**
`update(geometry:)` → `update(dataSets:)` (wait) → `update(layers:)` (wait). Colors are loaded inside `readLayers()` via `storageLayerFactory.set(colors:)` before layer objects are constructed.

**XRLayer Notification Registration**
DB-loaded layers register `XRGeometryDidChange` with `object:nil` at init (geometryController is nil then). `setGeometryController:` only removes the `object:previousController` observer — the `object:nil` registration persists as a second observer after `setGeometryController:` is called.

**Layer Naming Pattern**
Check existence before appending index — same pattern used by `addGridLayer`:
```swift
let uniqueName = layerExists(withName: baseName) ? newLayerName(forBaseName: baseName) : baseName
```

**ObjC/Swift Bridge**
- Some classes have both `.swift` and `.m` — the `.m` is an ObjC category on the Swift class
- ObjC property setters **do** trigger Swift `didSet` observers
- SourceKit errors often don't reflect actual build failures; trust the build output

**DB-loaded vs. new layers**
DB-loaded layers use a different init path than newly created layers — check both when debugging layer behavior.

## Active Refactoring
ObjC → Swift migration is ongoing. Prefer Swift for new code; migrate ObjC only when asked. See `file-handling-migration-plan.md` for scope.

## MCP Servers
- `xcode` — Build, run, and test operations (prefer over shell `xcodebuild`)

## Agents & Skills
See `.claude/AGENTS_AND_SKILLS.md` for the full list of project agents and skills.

## Rules
@.claude/rules/testing.md
@.claude/rules/swift-style.md
@.claude/rules/objc-refactoring.md
