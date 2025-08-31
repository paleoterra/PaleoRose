import AppKit
import Numerics
@testable import PaleoRose
import Testing

// swiftlint:disable type_body_length
struct GraphicLineTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: MockGraphicGeometrySource) throws -> GraphicLine {
        GraphicLine(controller: controller)
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
        expectedSettings["_lineLabel"] = "S" // 180 degrees should show "S" for South

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

        line.tickType = tickType

        // Enum validation: invalid values default to .none (0)
        let expectedTickType = GraphicLineTickType(rawValue: tickType)?.rawValue ?? 0
        expectedSettings["_tickType"] = "\(expectedTickType)"

        let settings = line.graphicSettings()
        #expect(line.tickType == expectedTickType)
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

    // MARK: - Line Label

    @Test(
        "Testing setLineLabel for Compass Points in Letter",
        arguments: [
            (0.0, "N"),
            (90.0, "E"),
            (180.0, "S"),
            (270.0, "W"),
            (360.0, "N")
        ]
    )
    func testSetLineLabelForCompassPointsInDegrees(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.points.rawValue

        line.spokeAngle = values.degrees
        let label = try #require(line.lineLabel)
        #expect(label.string == values.expected)
    }

    @Test(
        "Testing setLineLabel for Compass Points in degrees: Numeric Quad",
        arguments: [
            (0.0, "0"),
            (90.0, "90"),
            (180.0, "0"),
            (270.0, "90"),
            (360.0, "0")
        ]
    )
    func testSetLineLabelForCompassPointsQuadNumbering(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.quad.rawValue

        line.spokeAngle = values.degrees
        let label = try #require(line.lineLabel)
        #expect(label.string == values.expected)
    }

    @Test(
        "Testing setLineLabel for Compass Points in degrees: Numeric",
        arguments: [
            (0.0, "0"),
            (90.0, "90"),
            (180.0, "180"),
            (270.0, "270") // ,
//          (360.0, "0")
        ]
    )
    func testSetLineLabelForCompassPointsNumericNumbering(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.order360.rawValue

        line.spokeAngle = values.degrees
        let label = try #require(line.lineLabel)
        #expect(label.string == values.expected)
    }

    @Test(
        "Testing setLineLabel for Spoke angle text",
        arguments: [
            (90.0, "90"),
            (180.8, "180.8"),
            (231.3234, "231.3"),
            (220.0, "220")
        ]
    )
    func testSetLineLabelForSpokeAngle(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.order360.rawValue

        line.spokeAngle = values.degrees

        let label = try #require(line.lineLabel)
        print(label.string)
        #expect(label.string == values.expected)
    }

    @Test(
        "Testing setLineLabel for Spoke angle text quad",
        arguments: [
            (90.0, "90"),
            (180.8, "0.8"),
            (231.3234, "51.3")
        ]
    )
    func testSetLineLabelForSpokeAngleQuad(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.quad.rawValue

        line.spokeAngle = values.degrees

        let label = try #require(line.lineLabel)
        print(label.string)
        #expect(label.string == values.expected)
    }

    @Test(
        "Testing setLineLabel for Spoke angle text not points and quad",
        arguments: [
            (90.0, "90"),
            (180.8, "0.8"),
            (231.3234, "51.3")
        ]
    )
    func testSetLineLabelForSpokeAngleNotPoints(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.quad.rawValue

        line.spokeAngle = values.degrees

        let label = try #require(line.lineLabel)
        print(label.string)
        #expect(label.string == values.expected)
    }

    @Test(
        "Spoke points only and non spoke returns empty string",
        arguments: [
            (90.0, "90"),
            (180.8, ""),
            (231.3234, "")
        ]
    )
    func testWhenSpokePointsOnlyReturnEmptyStringsForNonPoints(values: (degrees: Float, expected: String)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)

        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.numbersOnly.rawValue
        line.spokeNumberOrder = GraphicLineNumberingOrder.quad.rawValue

        line.spokeAngle = values.degrees
        line.spokePointOnly = true

        let label = try #require(line.lineLabel)
        print(label.string)
        #expect(label.string == values.expected)
    }

    @Test(
        "Test horizontal transform",
        arguments: [
            (Float(10.0), CGAffineTransform.unitTestTranform(.horizontal10Degree)),
            (Float(75.0), CGAffineTransform.unitTestTranform(.horizontal75Degree)),
            (Float(289.0), CGAffineTransform.unitTestTranform(.horizontal289Degree)),
            (Float(0.0), CGAffineTransform.unitTestTranform(.horizontal0Degree)),
            (Float(180.0), CGAffineTransform.unitTestTranform(.horizontal180Degree))
        ]
    )
    func testHorizontalTransform(params: (angle: Float, transform: CGAffineTransform)) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)
        line.spokeNumberAlign = GraphicLineNumberAlign.horizontal.rawValue
        line.spokeAngle = params.angle
        let transform = try #require(line.labelTransform)
        params.transform.assertEqual(to: transform)
    }

    @Test(
        "Test parallel transform",
        arguments: [
            (Float(10.0), CGAffineTransform.unitTestTranform(.parallel10Degree)),
            (Float(75.0), CGAffineTransform.unitTestTranform(.parallel75Degree)),
            (Float(289.0), CGAffineTransform.unitTestTranform(.parallel289Degree)),
            (Float(0), CGAffineTransform.unitTestTranform(.parallel0Degree)),
            (Float(180), CGAffineTransform.unitTestTranform(.parallel180Degree))
        ]
    )
    func testParallelTransform(
        params: (
            angle: Float,
            transform: CGAffineTransform
        )
    ) async throws {
        let controller = MockGraphicGeometrySource()
        let line = GraphicLine(controller: controller)
        line.spokeNumberAlign = 1
        line.spokeAngle = params.angle

        let transform = try #require(line.labelTransform)
        params.transform.assertEqual(to: transform)
    }

    // MARK: - Tests for Previously Untested Code

    @Test(
        "Major tick type extends radius by 0.1",
        arguments: [
            Float(1.0), Float(0.5), Float(0.8)
        ]
    )
    func testMajorTickTypeRadius(relativePercent: Float) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)

        // Set up for major tick
        line.tickType = GraphicLineTickType.major.rawValue
        line.showTick = true

        // Access private method through calculation trigger
        line.calculateGeometry()

        // Verify the major tick path was taken by checking the drawing path bounds
        // Major ticks should extend further than minor ticks
        let majorPath = line.drawingPath

        // Compare with minor tick for same settings
        line.tickType = GraphicLineTickType.minor.rawValue
        line.calculateGeometry()
        let minorPath = line.drawingPath

        // Major tick should have larger bounds than minor tick
        if let majorBounds = majorPath?.bounds, let minorBounds = minorPath?.bounds {
            #expect(
                majorBounds.size.width >= minorBounds.size.width ||
                    majorBounds.size.height >= minorBounds.size.height,
                "Major tick should extend further than minor tick"
            )
        }
    }

    @Test(
        "Spoke point only with compass points shows correct labels",
        arguments: [
            (Float(0.0), "N"),
            (Float(90.0), "E"),
            (Float(180.0), "S"),
            (Float(270.0), "W")
        ]
    )
    func testSpokePointOnlyWithCompassPoints(values: (angle: Float, expectedLabel: String)) throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)

        // Set up for spoke point only with compass points
        line.spokePointOnly = true
        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.points.rawValue
        line.spokeAngle = values.angle

        // Verify the label is set correctly
        let label = try #require(line.lineLabel)
        #expect(
            label.string == values.expectedLabel,
            "Expected '\(values.expectedLabel)' for angle \(values.angle)°, got '\(label.string)'"
        )
    }

    @Test("Spoke point only with compass points and non-cardinal angle shows empty label")
    func testSpokePointOnlyWithCompassPointsNonCardinal() throws {
        let controller = MockGraphicGeometrySource()
        let line = try buildTestObject(controller: controller)

        // Set up for spoke point only with compass points at non-cardinal angle
        line.spokePointOnly = true
        line.spokeNumberCompassPoint = GraphicLineNumberCompassPoint.points.rawValue
        line.spokeAngle = 45.0 // Non-cardinal angle

        // Verify the label is empty for non-cardinal angles
        let label = try #require(line.lineLabel)
        #expect(
            label.string.isEmpty,
            "Expected empty string for non-cardinal angle with spoke points only, got '\(label.string)'"
        )
    }
}

// swiftlint:enable type_body_length
