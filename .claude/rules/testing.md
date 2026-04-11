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
- Keep test files alongside the files they test

## Patterns
- Use `try #require(...)` instead of force-unwrapping or `guard let`
- Use `arguments:` for parameterized tests — never loops or duplicated test functions
- Use the `Numerics` package for floating-point equality with tolerance

## Graphics Tests
- Graphics tests generate PNG output to `logs/`
- Use the `graphics-test-visualizer` skill to verify visual correctness
