---
description: Automatically generate comprehensive unit tests using Swift Testing framework, with XCTest reserved for performance tests and UI tests only
---

# Test Generator

Automatically generate comprehensive unit tests using Swift Testing framework, with XCTest reserved for performance tests and UI tests only.

## Capabilities

1. **Swift Testing Unit Tests**
   - Generate `@Test` functions for Swift types
   - Create parameterized tests with `@Test(arguments:)`
   - Generate edge case tests (nil, empty, boundary values)
   - Use `@Suite` for organizing related tests
   - Leverage tags for test categorization

2. **Mock Generation**
   - Auto-generate mock implementations from protocols
   - Create spy objects to verify method calls
   - Generate stub implementations with configurable return values
   - Use `@Test` expectations for async validation

3. **Test Fixtures & Factories**
   - Create factory methods for test data
   - Generate builders for complex object graphs
   - Create reusable test fixtures

4. **Assertion Patterns**
   - Use Swift Testing's `#expect()` and `#require()`
   - Generate custom validation helpers
   - Create snapshot testing helpers
   - Use XCTest only for performance benchmarks

5. **Coverage Analysis**
   - Identify untested code paths
   - Suggest missing test scenarios
   - Report on test coverage gaps

## Workflow

When invoked, this skill will:

1. **Analyze**: Parse the target Swift file/class
2. **Plan**: Generate test outline showing:
   - Methods to test
   - Required mocks/stubs
   - Test data needed
   - Edge cases identified
3. **Generate**: Create test file with:
   - `@Suite` for test organization
   - `@Test` functions for each test case
   - Mock objects as needed
   - Swift Testing assertions
4. **Verify**: Ensure tests compile and run

## Usage Instructions

When the user invokes this skill:

1. Ask what to test:
   - Specific file/class
   - All files in a directory
   - Untested code (scan for missing tests)

2. Ask test generation style:
   - **Minimal**: Happy path only
   - **Standard**: Happy path + basic edge cases
   - **Comprehensive**: All paths, edge cases, error conditions

3. Ask test framework preference:
   - **Swift Testing** (default for unit tests)
   - **XCTest** (only for performance/UI tests)

4. Check if mocks are needed and generate them
5. Generate test file(s)
6. Run tests to verify they work

## Test Framework Selection

### Use Swift Testing For:
- ✅ Unit tests
- ✅ Integration tests
- ✅ Parameterized tests
- ✅ Async/await tests
- ✅ Standard assertions

### Use XCTest Only For:
- ⚠️ Performance tests (`measure` blocks)
- ⚠️ UI tests (XCUIApplication)
- ⚠️ Legacy test compatibility (if needed)

## Example Generation

### Source Code
```swift
// DataSet.swift
struct DataSet {
    let name: String
    let values: [Double]

    func mean() -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func filter(greaterThan threshold: Double) -> DataSet {
        DataSet(name: name, values: values.filter { $0 > threshold })
    }
}
```

### Generated Tests (Swift Testing)
```swift
// DataSetTests.swift
import Testing
@testable import PaleoRose

@Suite("DataSet Tests")
struct DataSetTests {

    // MARK: - Test Data

    func makeDataSet(
        name: String = "Test Dataset",
        values: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
    ) -> DataSet {
        DataSet(name: name, values: values)
    }

    // MARK: - Mean Calculation Tests

    @Test("Mean calculation with valid values")
    func meanWithValidValues() {
        let dataSet = makeDataSet(values: [1.0, 2.0, 3.0])

        let mean = dataSet.mean()

        #expect(mean == 2.0)
    }

    @Test("Mean calculation with empty values returns nil")
    func meanWithEmptyValues() {
        let dataSet = makeDataSet(values: [])

        let mean = dataSet.mean()

        #expect(mean == nil)
    }

    @Test("Mean calculation with single value")
    func meanWithSingleValue() {
        let dataSet = makeDataSet(values: [42.0])

        let mean = try #require(dataSet.mean())

        #expect(mean == 42.0)
    }

    @Test(
        "Mean calculation with various datasets",
        arguments: [
            ([1.0, 2.0, 3.0], 2.0),
            ([10.0, 20.0, 30.0], 20.0),
            ([-1.0, -2.0, -3.0], -2.0),
            ([100.0], 100.0)
        ]
    )
    func meanCalculation(values: [Double], expected: Double) {
        let dataSet = makeDataSet(values: values)

        let mean = try #require(dataSet.mean())

        #expect(mean == expected)
    }

    // MARK: - Filter Tests

    @Test("Filter removes values below threshold")
    func filterRemovesLowerValues() {
        let dataSet = makeDataSet(values: [1.0, 2.0, 3.0, 4.0, 5.0])

        let filtered = dataSet.filter(greaterThan: 3.0)

        #expect(filtered.values == [4.0, 5.0])
        #expect(filtered.name == "Test Dataset")
    }

    @Test("Filter with all values below threshold returns empty")
    func filterAllValuesBelow() {
        let dataSet = makeDataSet(values: [1.0, 2.0, 3.0])

        let filtered = dataSet.filter(greaterThan: 10.0)

        #expect(filtered.values.isEmpty)
    }

    @Test("Filter with empty dataset returns empty")
    func filterEmptyDataSet() {
        let dataSet = makeDataSet(values: [])

        let filtered = dataSet.filter(greaterThan: 1.0)

        #expect(filtered.values.isEmpty)
    }

    @Test(
        "Filter with various thresholds",
        arguments: [
            (0.0, [1.0, 2.0, 3.0, 4.0, 5.0]),
            (2.5, [3.0, 4.0, 5.0]),
            (5.0, [] as [Double]),
            (100.0, [] as [Double])
        ]
    )
    func filterWithThreshold(threshold: Double, expected: [Double]) {
        let dataSet = makeDataSet(values: [1.0, 2.0, 3.0, 4.0, 5.0])

        let filtered = dataSet.filter(greaterThan: threshold)

        #expect(filtered.values == expected)
    }
}
```

### Async Testing Example

```swift
// StorageTests.swift
import Testing
@testable import PaleoRose

@Suite("InMemoryStore Tests")
struct InMemoryStoreTests {

    @Test("Save and load layer")
    func saveAndLoadLayer() async throws {
        let store = InMemoryStore()
        let layer = Layer(id: UUID(), name: "Test Layer", layerType: 1)

        try await store.save(layer)
        let loaded = try await store.loadLayer(id: layer.id)

        #expect(loaded?.name == "Test Layer")
        #expect(loaded?.layerType == 1)
    }

    @Test("Load nonexistent layer returns nil")
    func loadNonexistentLayer() async throws {
        let store = InMemoryStore()

        let loaded = try await store.loadLayer(id: UUID())

        #expect(loaded == nil)
    }
}
```

### Using Tags for Organization

```swift
import Testing
@testable import PaleoRose

extension Tag {
    @Tag static var graphics: Self
    @Tag static var storage: Self
    @Tag static var integration: Self
}

@Suite("Graphics Tests", .tags(.graphics))
struct GraphicsTests {

    @Test("Petal creation", .tags(.graphics))
    func petalCreation() {
        let controller = MockGeometryController()

        let petal = GraphicPetal(
            controller: controller,
            forIncrement: 0,
            forValue: NSNumber(value: 50.0)
        )

        #expect(petal != nil)
    }

    @Test("Petal geometry calculation", .tags(.graphics, .integration))
    func petalGeometry() throws {
        let controller = MockGeometryController()
        let petal = try #require(
            GraphicPetal(
                controller: controller,
                forIncrement: 0,
                forValue: NSNumber(value: 50.0)
            )
        )

        let path = try #require(petal.drawingPath)

        #expect(!path.isEmpty)
    }
}
```

## Mock Generation with Swift Testing

### Protocol
```swift
protocol DataStore {
    func save(_ data: DataSet) async throws
    func load(named: String) async throws -> DataSet
}
```

### Generated Mock (Swift Testing Compatible)
```swift
import Testing

final class MockDataStore: DataStore {
    // Tracking
    var saveCalled = false
    var saveCallCount = 0
    var saveReceivedData: [DataSet] = []

    var loadCalled = false
    var loadCallCount = 0
    var loadReceivedNames: [String] = []

    // Stubbed responses
    var saveThrowsError: Error?
    var loadStubbedResult: DataSet?
    var loadThrowsError: Error?

    func save(_ data: DataSet) async throws {
        saveCalled = true
        saveCallCount += 1
        saveReceivedData.append(data)

        if let error = saveThrowsError {
            throw error
        }
    }

    func load(named: String) async throws -> DataSet {
        loadCalled = true
        loadCallCount += 1
        loadReceivedNames.append(named)

        if let error = loadThrowsError {
            throw error
        }

        guard let result = loadStubbedResult else {
            Issue.record("loadStubbedResult not configured")
            throw TestError.notConfigured
        }

        return result
    }

    enum TestError: Error {
        case notConfigured
    }
}

// Usage in tests
@Test("Save data to store")
func saveData() async throws {
    let mock = MockDataStore()
    let dataSet = DataSet(name: "Test", values: [1.0, 2.0])

    try await mock.save(dataSet)

    #expect(mock.saveCalled)
    #expect(mock.saveCallCount == 1)
    #expect(mock.saveReceivedData.count == 1)
    #expect(mock.saveReceivedData[0].name == "Test")
}
```

## Performance Testing (XCTest Only)

For performance tests, still use XCTest:

```swift
import XCTest
@testable import PaleoRose

final class GraphicPerformanceTests: XCTestCase {

    func testPetalCreationPerformance() {
        let controller = MockGeometryController()

        measure {
            for i in 0..<100 {
                _ = GraphicPetal(
                    controller: controller,
                    forIncrement: Int32(i % 16),
                    forValue: NSNumber(value: Double(i))
                )
            }
        }
    }

    func testRoseDiagramRenderingPerformance() {
        let controller = MockGeometryController()
        let petals = (0..<16).compactMap { i in
            GraphicPetal(
                controller: controller,
                forIncrement: Int32(i),
                forValue: NSNumber(value: 50.0)
            )
        }

        measure {
            for petal in petals {
                petal.calculateGeometry()
                _ = petal.drawingPath
            }
        }
    }
}
```

## UI Testing (XCTest Only)

For UI tests, use XCTest:

```swift
import XCTest

final class PaleoRoseUITests: XCTestCase {

    func testCreateNewDocument() {
        let app = XCUIApplication()
        app.launch()

        app.menuBars.menuItems["New"].click()

        XCTAssertTrue(app.windows.count > 0)
    }

    func testAddLayer() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Add Layer"].click()

        let layerTable = app.tables["LayersTable"]
        XCTAssertEqual(layerTable.tableRows.count, 1)
    }
}
```

## Test Organization Patterns

### Suite Hierarchy

```swift
@Suite("PaleoRose Core Tests")
struct CoreTests {

    @Suite("Data Model Tests")
    struct DataModelTests {

        @Suite("Layer Tests")
        struct LayerTests {
            @Test func layerCreation() { }
            @Test func layerSerialization() { }
        }

        @Suite("DataSet Tests")
        struct DataSetTests {
            @Test func dataSetCreation() { }
            @Test func dataSetOperations() { }
        }
    }

    @Suite("Graphics Tests")
    struct GraphicsTests {
        @Test func graphicCreation() { }
        @Test func graphicRendering() { }
    }
}
```

### Lifecycle Hooks

```swift
@Suite("Database Tests")
struct DatabaseTests {
    var store: InMemoryStore

    init() async throws {
        // Suite-level setup
        store = InMemoryStore()
        try await store.initialize()
    }

    deinit {
        // Suite-level teardown
        // Clean up resources
    }

    @Test func saveLayer() async throws {
        // Test uses the initialized store
        let layer = Layer(id: UUID(), name: "Test", layerType: 1)
        try await store.save(layer)

        #expect(try await store.count() == 1)
    }
}
```

## Migration from XCTest

### XCTest Pattern
```swift
import XCTest

final class DataSetTests: XCTestCase {
    func testMeanCalculation() {
        let dataSet = DataSet(name: "Test", values: [1.0, 2.0, 3.0])

        XCTAssertEqual(dataSet.mean(), 2.0)
    }
}
```

### Swift Testing Pattern
```swift
import Testing

@Suite("DataSet Tests")
struct DataSetTests {
    @Test("Mean calculation")
    func meanCalculation() {
        let dataSet = DataSet(name: "Test", values: [1.0, 2.0, 3.0])

        #expect(dataSet.mean() == 2.0)
    }
}
```

### Assertion Mapping

| XCTest | Swift Testing |
|--------|---------------|
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertNotEqual(a, b)` | `#expect(a != b)` |
| `XCTAssertNil(value)` | `#expect(value == nil)` |
| `XCTAssertNotNil(value)` | `#expect(value != nil)` |
| `XCTAssertTrue(condition)` | `#expect(condition)` |
| `XCTAssertFalse(condition)` | `#expect(!condition)` |
| `XCTUnwrap(optional)` | `try #require(optional)` |
| `XCTAssertThrowsError(expr)` | `#expect(throws: Error.self) { expr }` |
| `XCTAssertNoThrow(expr)` | `#expect(throws: Never.self) { expr }` |

## Configuration

Store test generation settings in `.test-generator.json`:
```json
{
  "defaultFramework": "swift-testing",
  "testFileNaming": "{FileName}Tests.swift",
  "testLocation": "{source}/Tests/",
  "generateMocks": true,
  "mockPrefix": "Mock",
  "testStyle": "standard",
  "useTags": true,
  "defaultTags": ["unit"],
  "generateSuites": true,
  "xctest": {
    "onlyFor": ["performance", "ui"],
    "performancePrefix": "test",
    "uiPrefix": "test"
  },
  "swiftTesting": {
    "useParameterizedTests": true,
    "generateAsyncTests": true,
    "useSuiteHierarchy": true
  }
}
```
