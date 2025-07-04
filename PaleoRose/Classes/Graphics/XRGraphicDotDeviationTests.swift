import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicDotDeviationTests {
    // MARK: - Test Setup

    private func buildController() -> MockGeometryController {
        MockGeometryController()
    }

    private func buildBasicTestObject(controller: XRGeometryController) throws -> XRGraphicDotDeviation {
        try #require(XRGraphicDotDeviation(controller: controller))
    }

    private func buildTestObject(controller: XRGeometryController, forIncrement: Int = 0, totalCount: Int = 0) throws -> XRGraphicDotDeviation {
        try #require(
            XRGraphicDotDeviation(
                controller: controller,
                forIncrement: 3,
                valueCount: 0,
                totalCount: 32,
                statistics: ["mean": 0.0]
            )
        )
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "DotDeviation",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.black,
            "_lineWidth": "1.000000",
            "_angleIncrement": "0",
            "_totalCount": "0",
            "_count": "0",
            "_dotSize": "0.000000",
            "_mean": "0.000000"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController should initialize with default values")
    func testInitWithController() throws {
        // Given
        let controller = buildController()

        // When
        let dotDeviation = try buildBasicTestObject(controller: controller)

        let expectedSettings = defaultSettings()
        let settings = try #require(dotDeviation.graphicSettings())

        // Then
        #expect(dotDeviation.lineWidth() == 1.0, "Default lineWidth should be 1.0")
        #expect(dotDeviation.strokeColor() == .black, "Default strokeColor should be black")

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test("initWithController:ForIncrement:valueCount:statics should initialize with correct values")
    func testInitWithControllerfoeIncrement() throws {
        // Given
        let controller = buildController()

        // When
        let dotDeviation = try buildTestObject(controller: controller)

        var expectedSettings = defaultSettings()
        expectedSettings["_angleIncrement"] = "3"
        expectedSettings["_totalCount"] = "32"
        expectedSettings["_dotSize"] = "4.000000"
        let settings = try #require(dotDeviation.graphicSettings())

        // Then
        #expect(dotDeviation.lineWidth() == 1.0, "Default lineWidth should be 1.0")
        #expect(dotDeviation.strokeColor() == .black, "Default strokeColor should be black")

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    // MARK: - Property Tests

    @Test("setLineWidth should update line width")
    func testSetLineWidth() throws {
        // Given
        let controller = buildController()
        let dotDeviation = try buildTestObject(controller: controller)
        let testWidth: Float = 2.5

        // When
        dotDeviation.setLineWidth(testWidth)

        // Then
        #expect(
            dotDeviation.lineWidth().isApproximatelyEqual(to: testWidth, relativeTolerance: 0.001),
            "lineWidth should be \(testWidth) after setting"
        )
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should return correct settings dictionary")
    func testGraphicSettings() throws {
        // Given
        let controller = buildController()
        let dotDeviation = try buildTestObject(controller: controller)

        // Configure some custom values
        dotDeviation.setLineWidth(2.0)
        dotDeviation.setStroke(.red)
        var expectedSettings = defaultSettings()
        expectedSettings["_angleIncrement"] = "3"
        expectedSettings["_totalCount"] = "32"
        expectedSettings["_dotSize"] = "4.000000"
        expectedSettings["_lineWidth"] = "2.000000"
        expectedSettings["_strokeColor"] = NSColor.red
        // When
        let settings = try #require(dotDeviation.graphicSettings())

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    // MARK: - Set dot size

    @Test(
        "Set dot size accessor",
        arguments: [
            10.0,
            1000.0,
            -3.0 // Should this happen?
        ]
    )
    func testSetDotSize(dotSize: Float) throws {
        let controller = buildController()
        let dotDeviation = try buildTestObject(controller: controller)

        dotDeviation.setDotSize(dotSize)

        #expect(dotDeviation.dotSize().isApproximatelyEqual(to: dotSize, relativeTolerance: 0.001))
    }
}
