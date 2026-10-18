# Testing Rules

## Framework
- Use **Swift Testing** for ALL unit tests (`import Testing`)
- Use XCTest ONLY for UI tests and performance tests
- Never use `XCTestCase`, `XCTAssert*`, or any XCTest assertions in unit tests

## Test Structure
```swift
@Suite("Feature Name Tests")
struct FeatureTests {
    @Test("should do specific thing")
    func specificBehavior() async throws {
        // Arrange
        // Act
        // Assert with #expect
    }

    @Test("handles edge cases", arguments: [(input: 0, expected: 0), (input: 360, expected: 0)])
    func edgeCases(input: Int, expected: Int) { ... }
}
```

## Project Setup
- Import the app: `@testable import PaleoRose`
- Any ObjC file used in tests must be added to `PaleoRose-Bridging-Header.h`
- Tests live in the `Unit Tests` target, under `PaleoRose/Unit Tests/`, mirroring the source path under `PaleoRose/PaleoRose/Classes/` — never alongside the source file. E.g. `Classes/Graphics/GraphicKite.swift` → `Unit Tests/Classes/Graphics/GraphicKiteTests.swift`
- Mocks and `+Testing`/`+Stub` extensions follow the same mirrored structure and also belong to the `Unit Tests` target, not `PaleoRose`
- When adding a new test/mock file, verify it's a member of the `Unit Tests` target (not `PaleoRose`) — folder placement alone doesn't set target membership

## Patterns
- Use `try #require(...)` instead of force-unwrapping or `guard let`
- Use `arguments:` for parameterized tests — never loops or duplicated test functions
- Use the `Numerics` package for floating-point equality with tolerance

## Graphics Tests
- Graphics tests generate PNG output to `logs/`
- Use the `graphics-test-visualizer` skill to verify visual correctness
