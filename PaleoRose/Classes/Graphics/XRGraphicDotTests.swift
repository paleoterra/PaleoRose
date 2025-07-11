import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicDotTests {
    // MARK: - Test Setup

    struct TestConfiguration {
        let dotSize: Float
        let increment: Int32
        let valueCount: Int32
        let totalCount: Int32
    }

    private func buildController() -> MockGeometryController {
        MockGeometryController()
    }

    private func buildBasicTestObject(controller: XRGeometryController) throws -> XRGraphicDot {
        XRGraphicDot(controller: controller)
    }

    private func buildTestObject(controller: XRGeometryController, forIncrement: Int32 = 0, valueCount: Int32 = 0, totalCount: Int32 = 0) throws -> XRGraphicDot {
        try #require(XRGraphicDot(
            controller: controller,
            forIncrement: forIncrement,
            valueCount: valueCount,
            totalCount: totalCount
        ))
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "Dot",
            "_fillColor": NSColor.black,
            "_strokeColor": NSColor.black,
            "_dotSize": "0.000000",
            "_count": "0",
            "_totalCount": "0",
            "_lineWidth": "1.000000",
            "_angleIncrement": "0"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController basic version should initialize with default values")
    func testBasicInitWithController() throws {
        // Given
        let controller = buildController()

        // When
        let dot = try buildBasicTestObject(controller: controller)

        let settings = dot.graphicSettings()
        let expectedSettings = defaultSettings()

        // Then

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test("initWithController should initialize with default values",
          arguments: [
              TestConfiguration(dotSize: 4, increment: 0, valueCount: 0, totalCount: 0),
              TestConfiguration(dotSize: 4, increment: 0, valueCount: 1, totalCount: 1),
              TestConfiguration(dotSize: 4, increment: 0, valueCount: 10, totalCount: 10)
          ])
    func testInitWithController(params: TestConfiguration) throws {
        // Given
        let controller = buildController()

        // When
        let dot = try buildTestObject(
            controller: controller,
            forIncrement: params.increment,
            valueCount: params.valueCount,
            totalCount: params.totalCount
        )

        let settings = dot.graphicSettings()
        var expectedSettings = defaultSettings()
        expectedSettings["_dotSize"] = String(format: "%.6f", params.dotSize)
        expectedSettings["_angleIncrement"] = "\(params.increment)"
        expectedSettings["_count"] = "\(params.valueCount)"
        expectedSettings["_totalCount"] = "\(params.totalCount)"

        // Then

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test("Test setting and getting dot size")
    func testDotSize() throws {
        let controller = buildController()
        let dot = try buildBasicTestObject(controller: controller)
        let newDotSize: Float = 10
        dot.setDotSize(newDotSize)

        #expect(dot.dotSize() == newDotSize)
    }
}
