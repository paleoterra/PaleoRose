import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicHistogramTests {
    // MARK: - Test Setup

    private func buildController() -> MockGeometryController {
        MockGeometryController()
    }

    private func buildBasicTestObject(controller: XRGeometryController) throws -> XRGraphicHistogram {
        try #require(XRGraphicHistogram(controller: controller))
    }

    private func buildTestObject(controller: XRGeometryController, increment: Int32 = 0, value: Int32 = 1) throws -> XRGraphicHistogram {
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

    @Test("basic initWithController should initialize with default values")
    func testBasicInitWithController() throws {
        // Given
        let controller = buildController()

        // When
        let histogram = try buildBasicTestObject(controller: controller)

        let expectedSettings = defaultSettings()
        let settings = try #require(histogram.graphicSettings())

        // Then
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    @Test("correct InitWithController initialization")
    func testInitWithController() throws {
        // Given
        let controller = buildController()

        // When
        let histogram = try buildTestObject(controller: controller)

        var expectedSettings = defaultSettings()
        expectedSettings["_histIncrement"] = "0"
        expectedSettings["_percent"] = "1.000000"
        expectedSettings["_count"] = "1"
        expectedSettings["_lineWidth"] = "4.000000"
        let settings = try #require(histogram.graphicSettings())

        // Then
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }
}
