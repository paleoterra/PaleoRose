import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicLineTests {
    // MARK: - Test Setup

    private func buildController() -> MockGeometryController {
        MockGeometryController()
    }

    private func buildTestObject(controller: XRGeometryController) throws -> XRGraphicLine {
        try #require(XRGraphicLine(controller: controller))
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
        let controller = buildController()

        // When
        let line = try buildTestObject(controller: controller)
        line.setLineLabel() // must be called directly or indirectly
        let expectedSettings = try defaultSettings()

        // Then
        let settings = try #require(line.graphicSettings())
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
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        let testWidth: Float = 2.5

        // When
        line.setLineWidth(testWidth)

        // Then
        #expect(
            line.lineWidth().isApproximatelyEqual(to: testWidth, relativeTolerance: 0.001),
            "lineWidth should be \(testWidth) after setting"
        )
    }

    @Test("Spoke angle accessors")
    func spokeAngleTest() throws {
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        let testAngle: Float = 180.0

        var expectedSettings = try defaultSettings()
        expectedSettings["_angleSetting"] = "180.000000"

        line.setSpokeAngle(testAngle)

        // Then

        #expect(
            line.spokeAngle().isApproximatelyEqual(to: testAngle, relativeTolerance: 0.001),
            "Spoke angle was \(line.spokeAngle()), should be \(testAngle)"
        )

        let settings = try #require(line.graphicSettings())
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
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        line.setLineLabel() // must be called directly or indirectly
        var expectedSettings = try defaultSettings()
        expectedSettings["_tickType"] = "\(tickType)"

        line.setTickType(tickType)
        let settings = try #require(line.graphicSettings())
        #expect(line.tickType() == tickType)
        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test(
        "Show tick",
        arguments: [
            true, false
        ]
    )
    func testShowTick(showTick: Bool) throws {
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        line.setLineLabel() // must be called directly or indirectly
        var expectedSettings = try defaultSettings()
        expectedSettings["_showTick"] = showTick ? "YES" : "NO"

        line.setShowTick(showTick)
        let settings = try #require(line.graphicSettings())

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test(
        "Show show label",
        arguments: [
            true, false
        ]
    )
    func testSetShowLabel(showLabel: Bool) throws {
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        line.setLineLabel() // must be called directly or indirectly
        var expectedSettings = try defaultSettings()
        expectedSettings["_showLabel"] = showLabel ? "YES" : "NO"

        line.setShowlabel(showLabel)
        let settings = try #require(line.graphicSettings())

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
        let controller = buildController()
        let line = try buildTestObject(controller: controller)
        line.setLineLabel() // must be called directly or indirectly
        let expectedSettings = try defaultSettings()
        let font = NSFont(name: fontInfo.name, size: fontInfo.size)

        line.setFont(font)
        #expect(line.font().fontName == fontInfo.name)
        #expect(line.font().pointSize == fontInfo.size)

        let settings = try #require(line.graphicSettings())

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }
}
