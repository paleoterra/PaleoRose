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

    private func buildBasicTestObject(controller: MockGraphicGeometrySource) throws -> XRGraphicDot {
        XRGraphicDot(controller: controller)
    }

    private func buildTestObject(controller: MockGraphicGeometrySource, forIncrement: Int32 = 0, valueCount: Int32 = 0, totalCount: Int32 = 0) throws -> XRGraphicDot {
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
        let controller = MockGraphicGeometrySource()

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
        let controller = MockGraphicGeometrySource()

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
        let controller = MockGraphicGeometrySource()
        let dot = try buildTestObject(controller: controller)
        let newDotSize: Float = 10
        dot.dotSize = newDotSize

        #expect(dot.dotSize == newDotSize)
    }

    @Test(
        "calculate geometry standard",
        arguments: [
            (Int32(10), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 13.0)),
            (Int32(30), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 33.0)),
            (Int32(70), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 73.0))
        ]
    )
    func calculateGeometryStandard(params: (count: Int32, expectedRect: NSRect)) throws {
        let controller = MockGraphicGeometrySource()
        let dot = try buildTestObject(
            controller: controller,
            forIncrement: 3,
            valueCount: params.count,
            totalCount: 100
        )

        let path = try #require(dot.drawingPath)
        let bounds = path.bounds
        #expect(
            bounds.origin.x.isApproximatelyEqual(
                to: params.expectedRect.origin.x,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.origin.y.isApproximatelyEqual(
                to: params.expectedRect.origin.y,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.width.isApproximatelyEqual(
                to: params.expectedRect.size.width,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.height.isApproximatelyEqual(
                to: params.expectedRect.size.height,
                absoluteTolerance: 0.01
            )
        )
    }

    @Test(
        "calculate geometry standard Percent",
        arguments: [
            (Int32(10), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)),
            (Int32(30), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)),
            (Int32(70), NSRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0))
        ]
    )
    func calculateGeometryStandardPercent(params: (count: Int32, expectedRect: NSRect)) throws {
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        let dot = try buildTestObject(
            controller: controller,
            forIncrement: 3,
            valueCount: params.count,
            totalCount: 100
        )

        let path = try #require(dot.drawingPath)
        let bounds = path.bounds
        #expect(
            bounds.origin.x.isApproximatelyEqual(
                to: params.expectedRect.origin.x,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.origin.y.isApproximatelyEqual(
                to: params.expectedRect.origin.y,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.width.isApproximatelyEqual(
                to: params.expectedRect.size.width,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.height.isApproximatelyEqual(
                to: params.expectedRect.size.height,
                absoluteTolerance: 0.01
            )
        )
    }
}
