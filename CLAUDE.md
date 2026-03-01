# PaleoRose Development Guidelines

## Project Overview

PaleoRose is a macOS application for creating and visualizing rose diagrams used in geological data analysis. The application allows users to import directional/vector data (azimuths, strikes, etc.) and visualize it using various plot types including rose petals, kites, dots, histograms, and statistical vectors.

### Key Technologies
- **Language**: Swift 5.9+ with legacy Objective-C being actively refactored
- **Platform**: macOS 13.0+ (Ventura and later)
- **UI Framework**: Mix of AppKit (legacy) and SwiftUI (modern)
- **Database**: SQLite via custom CodableSQLiteNonThread framework
- **Testing**: Swift Testing framework for unit tests, XCTest for UI/performance tests
- **Build System**: Xcode with Swift Package Manager for dependencies

### File Format
PaleoRose documents use the `.XRose` extension, which are SQLite database files containing:
- Configuration tables (prefixed with `_`) for geometry, layers, colors, and datasets
- User data tables containing measurement data (azimuths, dips, etc.)
- Detailed specification: `docs/XRose-File-Format.md`

## Architecture

### Design Patterns
- **MVVM**: Used for all SwiftUI views with proper separation of concerns
- **Document-Based Application**: NSDocument architecture for file handling
- **Layer System**: Composable layers for different visualization types (data, text, arrows, grid, core)
- **Repository Pattern**: DocumentModel + InMemoryStore for data persistence

### Core Components

#### 1. Document Model (`DocumentModel.swift`)
- Central data management for XRose documents
- Handles file I/O through `InMemoryStore`
- Methods: `writeToFile(_:)`, `openFile(_:)`, `store(layers:)`, `readFromStore(completion:)`
- **IMPORTANT**: All file operations MUST go through DocumentModel, not direct SQL

#### 2. Layer System (`Classes/Layer Control/`)
- Base: `XRLayer` and layer-specific subclasses
- Types: Data, Text, Arrow, Grid, Core
- Each layer has SQL storage models in `Classes/Document/Document Model/SQL Models/`

#### 3. Graphics Engine (`Classes/Graphics/`)
- CoreGraphics-based rendering for plots
- Classes: `GraphicPetal`, `GraphicKite`, `GraphicDot`, `GraphicHistogram`, etc.
- All graphics classes have corresponding test files with visualization output

#### 4. CodableSQLiteNonThread Framework
- Custom SQLite wrapper using Swift's Codable protocol
- Provides type-safe database operations
- Non-threaded design (all operations on main thread)

## Code Style & Standards

### Swift Guidelines
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use Swift's official style guide
- `camelCase` for variables/functions, `PascalCase` for types
- Prefer value types (structs) over reference types (classes)
- Use protocols for clear interfaces between components
- Swiftlint for code style enforcement with rules defined in `.swiftlint.yml`
- Swiftformat for code formatting with rules defined in `.swiftformat`

### Documentation Requirements
```swift
/// Brief description of what this does.
///
/// More detailed explanation if needed. Explain the "why" not just the "what".
///
/// - Parameters:
///   - parameterName: What this parameter represents
/// - Returns: What this returns
/// - Throws: What errors this might throw
func exampleFunction(parameterName: Type) throws -> ReturnType {
    // Implementation
}
```

- Document all non-private APIs using `///` style
- Add `// MARK: -` comments to organize code sections
- Include standard open source preamble in new Swift files

### File Organization
- Keep files under 500 lines when possible
- Split large files into logical extensions
- Use `// MARK: - Section Name` for organization
- Group related functionality together

## Testing Strategy

### Unit Testing (Swift Testing Framework)
```swift
import Testing
@testable import PaleoRose

@Suite("Feature Name Tests")
struct FeatureTests {
    @Test("Should do specific thing")
    func testSpecificBehavior() async throws {
        // Arrange
        let input = createInput()

        // Act
        let result = performAction(input)

        // Assert
        #expect(result == expectedValue)
    }

    @Test("Should handle edge cases", arguments: [
        (input: 0, expected: 0),
        (input: 180, expected: 180),
        (input: 360, expected: 0)
    ])
    func testEdgeCases(input: Int, expected: Int) {
        #expect(normalizeAngle(input) == expected)
    }
}
```

**Requirements**:
- Use Swift Testing for ALL unit tests
- Structure with clear Arrange-Act-Assert sections
- Mock all external dependencies
- Use parameterization (`arguments:`) for testing multiple cases
- Test files should be in same directory as implementation files

### UI & Performance Testing (XCTest)
- Use XCTest ONLY for UI tests and performance tests
- UI tests for critical user flows
- Performance tests for time-sensitive operations
- Accessibility tests for VoiceOver compliance

### Graphics Testing
- Graphics test files generate visual output (PNG files in `logs/`)
- Use `graphics-test-visualizer` skill to verify visual correctness
- Example: `GraphicPetalTests.swift` generates `GraphicPetal_test.png`

## Critical Constraints

### File Management
- **DO NOT** modify XIB, NIB, or Storyboard files
- **DO NOT** modify Xcode project files directly (.xcodeproj)
- **DO NOT** use direct SQLite operations in layer classes
- **ALWAYS** use `DocumentModel` for file I/O operations

### Data Persistence
```swift
// ❌ WRONG - Direct SQL (deprecated pattern)
layer.saveToSQLDB(database, layerID: id)

// ✅ CORRECT - Through DocumentModel
documentModel.store(layers: layers)
documentModel.writeToFile(fileURL)
```

**Migration in Progress**: Legacy Objective-C code has direct SQL operations being phased out. See `file-handling-migration-plan.md` for details.

### Build Requirements
- Project must build without warnings
- Use Swift Package Manager for dependencies
- Pin dependencies to exact versions
- Use `#if DEBUG` for development-only code

## Common Patterns

### Error Handling
```swift
// Use Result type or throws
func performOperation() throws -> ResultType {
    guard condition else {
        throw PaleoRoseError.invalidInput("Description")
    }
    // Implementation
}

// Or Result type for async operations
func asyncOperation() async -> Result<Data, Error> {
    // Implementation
}
```

- Provide meaningful error messages
- Use Swift's `Result` type or `throws`
- Implement proper error recovery
- Show user-friendly messages in UI

### Dependency Injection
```swift
protocol DataStoreProtocol {
    func fetch() async throws -> [Layer]
}

class ViewModel: ObservableObject {
    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol = InMemoryStore()) {
        self.dataStore = dataStore
    }
}
```

### SwiftUI Best Practices
```swift
struct ContentView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        // Implementation
    }
}
```

- Use `@StateObject` for view model lifecycle
- Use `@Environment` for system-wide dependencies
- Implement proper loading and error states
- Support both light and dark mode

## Performance

### Optimization Guidelines
- Profile with Instruments regularly
- Use background queues for expensive operations
- Implement lazy loading for heavy resources
- Optimize for older hardware

### Memory Management
- Swift uses ARC, but watch for retain cycles
- Use `[weak self]` in closures when appropriate
- Release resources in `deinit` when needed

## Localization

- Use `LocalizedStringKey` for all user-facing strings
- Support right-to-left languages
- Use `formatted()` for numbers, dates, measurements
- Test with different locale settings

## Security

- Use `SecureField` for password inputs
- Store sensitive data in Keychain
- Validate all user inputs
- Use HTTPS for network requests
- Follow Apple security best practices

## Development Workflow

### Before Making Changes
1. Read the relevant files first - understand before modifying
2. Check for existing patterns in the codebase
3. Review related test files
4. Consider impact on legacy Objective-C interop

### Making Changes
1. Write tests first (TDD approach preferred)
2. Implement the minimal change needed
3. Ensure all tests pass
4. Run SwiftLint if configured
5. Build without warnings

### After Changes
1. Update documentation if APIs changed
2. Update tests to cover new behavior
3. Check for retain cycles in new code
4. Consider performance implications

## Common Tasks

### Adding a New Layer Type
1. Create storage model struct in `SQL Models/` (Codable)
2. Create layer class (if needed, prefer Swift)
3. Add to `StorageModelFactory`
4. Update `DocumentModel` to handle new type
5. Create comprehensive tests
6. Update `XRose-File-Format.md` if schema changes

### Refactoring Objective-C to Swift
See `.windsurf/rules/refactorobjc.md` for detailed guidelines.

Key points:
- Replace direct SQL with DocumentModel operations
- Use Swift structs instead of NSObject subclasses
- Convert to value types where appropriate
- Use Swift Testing for new tests
- Maintain Objective-C bridge where needed

### Working with Graphics
1. Create graphic class extending `Graphic` protocol
2. Implement `draw(in:)` method using CoreGraphics
3. Create test file that generates visual output
4. Use `graphics-test-visualizer` skill to verify rendering
5. Check `logs/` directory for generated images

## Available Tools

### Custom Skills (use with `/skill-name`)
- `/build-time-optimizer` - Analyze build performance
- `/test-generator` - Generate Swift Testing tests
- `/swift-modernizer` - Modernize Swift code
- `/database-migration-helper` - Manage SQLite schema migrations
- `/graphics-test-visualizer` - Visualize graphics test output
- `/xrose-database-reader` - Inspect XRose database files
- `/swiftlint-helper` - Manage SwiftLint configuration
- `/code-cleanup-assistant` - Automated code cleanup

See `.claude/AGENTS_AND_SKILLS.md` for full list.

## References

- [XRose File Format Specification](docs/XRose-File-Format.md)
- [File Handling Migration Plan](../file-handling-migration-plan.md)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

## Project-Specific Notes

### Active Refactoring
This project is actively being refactored from Objective-C to Swift. When working on the codebase:
- Prefer Swift for new code
- Migrate Objective-C code to Swift only when asked
- Remove deprecated SQL methods when safe
- Maintain backward compatibility with existing .XRose files

### Testing Philosophy
- Every graphics class has visual test output
- Use parameterized tests for multiple scenarios
- Mock external dependencies (databases, file systems)
- Integration tests for DocumentModel file operations

### Code Review Focus
- Ensure no direct SQLite operations in layers
- Verify proper error handling
- Check for retain cycles in closures
- Confirm tests are comprehensive
- Validate accessibility support
