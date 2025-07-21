import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicLineTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: MockGraphicGeometrySource) throws -> XRGraphicLine {
        XRGraphicLine(controller: controller)
    }

    private func defaultSettings() throws -> [AnyHashable: Any] {
        try [
            "GraphicType": "Line",
            "_tickType": "0",
            "_spokeNumberCompassPoint": "1",
            "_showLabel": "YES",
            "_lineWidth": "1.000000",
            "_relativePercent": "1.000000",
            "_showTick": "NO",
            "_spokeNumberOrder": "1",
            "_lineLabel": "N",
            "_fillColor": NSColor.black,
            "_angleSetting": "0.000000",
            "_spokeNumberAlign": "0",
            "_strokeColor": NSColor.black,
            "_currentFont": #require(NSFont(name: "Arial-Black", size: 12))
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController should initialize with default values")
    func testInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let line = try buildTestObject(controller: controller)
        let expectedSettings = try defaultSettings()

        // Then
        let settings = line.graphicSettings()
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    // MARK: - Property Tests

    @Test("setLineWidth should update the line width")
    func testSetLineWidth() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        let testWidth: Float = 2.5

        // When
        line.lineWidth = testWidth

        // Then
        #expect(
            line.lineWidth.isApproximatelyEqual(to: testWidth, relativeTolerance: 0.001),
            "lineWidth should be \(testWidth) after setting"
        )
    }

    @Test("Spoke angle accessors")
    func spokeAngleTest() throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        let testAngle: Float = 180.0

        var expectedSettings = try defaultSettings()
        expectedSettings["_angleSetting"] = "180.000000"

        line.spokeAngle = testAngle

        // Then

        #expect(
            line.spokeAngle.isApproximatelyEqual(to: testAngle, relativeTolerance: 0.001),
            "Spoke angle was \(line.spokeAngle), should be \(testAngle)"
        )

        let settings = line.graphicSettings()
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    @Test(
        "Setting tick type",
        arguments: [
            0, 1, 2, -1, 3
        ]
    )
    func testSetTickType(tickType: Int32) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        var expectedSettings = try defaultSettings()
        expectedSettings["_tickType"] = "\(tickType)"

        line.tickType = tickType
        let settings = line.graphicSettings()
        #expect(line.tickType == tickType)
        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test(
        "Show tick",
        arguments: [
            true, false
        ]
    )
    func testShowTick(showTick: Bool) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        var expectedSettings = try defaultSettings()
        expectedSettings["_showTick"] = showTick ? "YES" : "NO"

        line.showTick = showTick
        let settings = line.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test(
        "Show show label",
        arguments: [
            true, false
        ]
    )
    func testSetShowLabel(showLabel: Bool) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        var expectedSettings = try defaultSettings()
        expectedSettings["_showLabel"] = showLabel ? "YES" : "NO"

        line.showLabel = showLabel
        let settings = line.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @MainActor
    @Test(
        "SetFont",
        arguments: [
            (name: "Arial-Black", size: 42),
            (name: "Arial-Black", size: 24)
        ]
    )
    func testSetShowLabel(fontInfo: (name: String, size: CGFloat)) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)
        let expectedSettings = try defaultSettings()
        let font = try #require(NSFont(name: fontInfo.name, size: fontInfo.size))

        line.font = font
        #expect(line.font?.fontName == fontInfo.name)
        #expect(line.font?.pointSize == fontInfo.size)

        let settings = line.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }
}
