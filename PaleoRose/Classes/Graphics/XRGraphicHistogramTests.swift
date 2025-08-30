import AppKit
import Numerics
@testable import PaleoRose
import Testing

struct XRGraphicHistogramTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: MockGraphicGeometrySource, increment: Int32 = 0, value: Int32 = 1) throws -> XRGraphicHistogram {
        try #require(
            XRGraphicHistogram(
                controller: controller,
                forIncrement: increment,
                forValue: value as NSNumber
            )
        )
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "Histogram",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.black,
            "_lineWidth": "1.000000",
            "_histIncrement": "0",
            "_percent": "0.000000",
            "_count": "0"
        ]
    }

    // MARK: - Initialization Tests

    @Test("correct InitWithController initialization")
    func testInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let histogram = try buildTestObject(controller: controller)

        var expectedSettings = defaultSettings()
        expectedSettings["_histIncrement"] = "0"
        expectedSettings["_percent"] = "1.000000"
        expectedSettings["_count"] = "1"
        expectedSettings["_lineWidth"] = "4.000000"
        let settings = histogram.graphicSettings()

        // Then
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    @Test(
        "Calculate Geometry",
        arguments: [
            (Int32(5), NSRect(x: -2.86788, y: 0.0, width: 2.8678, height: 4.09576)),
            (Int32(20), NSRect(x: -11.471528, y: 0.0, width: 11.47152, height: 16.38304)),
            (Int32(30), NSRect(x: -17.20729, y: 0.0, width: 17.20729, height: 24.57456))
        ]
    )
    func testCalculateGeometry(params: (value: Int32, expectedRect: NSRect)) throws {
        let controller = MockGraphicGeometrySource()
        controller.mockSectorSize = 10.0
        let histogram = try buildTestObject(
            controller: controller,
            increment: 3,
            value: params.value
        )

        let path = try #require(histogram.drawingPath)
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
        "Calculate Geometry Percent",
        arguments: [
            (Int32(5), NSRect(x: -0.02867, y: 0.0, width: 0.0286, height: 0.05)),
            (Int32(20), NSRect(x: -0.11471, y: 0.0, width: 0.11471, height: 0.1638)),
            (Int32(30), NSRect(x: -0.1720, y: 0.0, width: 0.1720, height: 0.2457))
        ]
    )
    func testCalculateGeometryPercent(params: (value: Int32, expectedRect: NSRect)) throws {
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockSectorSize = 10.0
        let histogram = try buildTestObject(
            controller: controller,
            increment: 3,
            value: params.value
        )

        let path = try #require(histogram.drawingPath)
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

    @Test("Calculate Geometry 360 check")
    func testCalculateGeometry360check() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockSectorSize = 10.0
        let histogram = try buildTestObject(
            controller: controller,
            increment: 38,
            value: 10
        )

        let expectedRect = NSRect(x: -4.226, y: 0.0, width: 4.226, height: 9.063)

        let path = try #require(histogram.drawingPath)
        let bounds = path.bounds
        #expect(
            bounds.origin.x.isApproximatelyEqual(
                to: expectedRect.origin.x,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.origin.y.isApproximatelyEqual(
                to: expectedRect.origin.y,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.width.isApproximatelyEqual(
                to: expectedRect.size.width,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.height.isApproximatelyEqual(
                to: expectedRect.size.height,
                absoluteTolerance: 0.01
            )
        )
    }
}
