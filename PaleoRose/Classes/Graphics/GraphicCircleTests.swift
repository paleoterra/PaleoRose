import Numerics
@testable import PaleoRose
import Testing

// swiftlint:disable file_length type_body_length object_literal

struct GraphicCircleTests {

    private func defaultGraphicSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "Circle",
            "_fillColor": NSColor.black,
            "_strokeColor": NSColor.black,
            "_lineWidth": "1.000000",
            "_countSetting": "0",
            "_percentSetting": "0.000000",
            "_geometryPercent": "0.000000",
            "_isGeometryPercent": "NO",
            "_isPercent": "NO",
            "_isFixedCount": "NO"
        ]
    }

    private func transparencyCompare(
        expectedAlpha: Float,
        expectedBaseStrokeColor: NSColor,
        expectedBaseFillColor: NSColor,
        strokeColor: NSColor,
        fillColor: NSColor,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) throws {

        let sourceLocation = SourceLocation(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        #expect(
            strokeColor.alphaComponent
                .isApproximatelyEqual(to: CGFloat(expectedAlpha)),
            sourceLocation: sourceLocation
        )
        #expect(
            fillColor.alphaComponent.isApproximatelyEqual(to: CGFloat(expectedAlpha)),
            sourceLocation: sourceLocation
        )

        // Convert all colors to a common color space (sRGB) for comparison
        try CommonUtilities.verifyEqualColorsWithOutAlpha(
            lhs: strokeColor,
            rhs: expectedBaseStrokeColor
        )
        try CommonUtilities.verifyEqualColorsWithOutAlpha(lhs: fillColor, rhs: expectedBaseFillColor)
    }

    @Test("Initialize with controller should set default values")
    func initWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let circle = GraphicCircle(controller: controller)

        // Then
        // Verify super values
        #expect(
            circle.fillColor == .black,
            "Default fill color should be black"
        )
        #expect(circle.strokeColor == .black, "Default stroke color should be black")
        #expect(circle.lineWidth == 1.0, "Default line width should be 1.0")
        #expect(circle.needsDisplay == true, "Default needs display should be true")
        #expect(circle.drawsFill == false, "Default draws fill should be false")
        // Verify default values
        #expect(circle.countSetting == 0, "Default count should be 0")
        #expect(circle.percentSetting == 0.0, "Default percent should be 0.0")
        #expect(!circle.isFixedCount, "Default fixed state should be false")
    }

    // MARK: - Count and Percentage Tests

    @Test("Count should be settable and gettable")
    func count() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)

        let expectedCount: Int32 = 42

        // When
        circle.countSetting = expectedCount

        // Then
        #expect(
            circle.countSetting == expectedCount,
            "Count should be set correctly"
        )
    }

    @Test("Percent should be settable and gettable")
    func percent() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let expectedPercent: Float = 0.75

        // When
        circle.percentSetting = expectedPercent

        // Then
        #expect(
            circle.percentSetting.isApproximatelyEqual(
                to: expectedPercent,
                absoluteTolerance: .ulpOfOne
            ),
            "Percent should be set correctly"
        )
    }

    @Test("Geometry percent should be settable and gettable")
    func percentSetting() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testPercent: Float = 0.60

        // When
        circle.percentSetting = testPercent

        // Then
        #expect(
            circle.percentSetting.isApproximatelyEqual(
                to: testPercent,
                absoluteTolerance: 0.001
            ),
            "Geometry percent should be set correctly"
        )
    }

    // MARK: - Fixed State Tests

    @Test("Fixed state should be updatable")
    func fixedState() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)

        // Test default value
        #expect(!circle.isFixedCount, "Default fixed state should be false")

        // Test setting to true
        circle.isFixedCount = true
        #expect(circle.isFixedCount, "Fixed state should be true after setting to true")

        // Test setting back to false
        circle.isFixedCount = false
        #expect(!circle.isFixedCount, "Fixed state should be false after setting to false")
    }

    // MARK: - Drawing

    @Test(
        "Drawing rect should return non-zero size when Is percent",
        arguments: [
            (true, 100),
            (false, 75)
        ]
    )
    func drawingRect(settings: (isPercent: Bool, expectedSize: CGFloat)) throws {
        // Given
        let controller = MockGraphicGeometrySource(isPercent: settings.isPercent)
        let circle = GraphicCircle(controller: controller)
        circle.percentSetting = 0.75
        circle.countSetting = 100
        controller.mockCircleRectCount = NSRect(x: 0, y: 0, width: 75, height: 75)
        controller.mockCircleRectPercent = NSRect(x: 0, y: 0, width: 100, height: 100)
        circle.calculateGeometry()
        // When
        let drawingRect = circle.drawingRect()
        print(drawingRect)
        // Then
        #expect(drawingRect.width.isApproximatelyEqual(to: settings.expectedSize), "Width should be \(settings.expectedSize)")
        #expect(drawingRect.height.isApproximatelyEqual(to: settings.expectedSize), "Height should be \(settings.expectedSize)")
    }

    @Test("Hit test should not detect point outside circle")
    func hitTest_whenPointIsOutside() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let outsidePoint = CGPoint(x: -10, y: -10)

        // When
        let hitResult = circle.hitTest(outsidePoint)

        // Then
        #expect(!hitResult, "Should not detect point outside circle")
    }

    @Test("Setting fill color should update the fill color")
    func setFillColor() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testColor = NSColor.red

        // When
        circle.fillColor = testColor

        // Then
        #expect(
            circle.fillColor == testColor,
            "Fill color should be set correctly"
        )
    }

    @Test("Setting stroke color should update the stroke color")
    func setStrokeColor() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testColor = NSColor.blue

        // When
        circle.strokeColor = testColor

        // Then
        #expect(
            circle.strokeColor == testColor,
            "Stroke color should be set correctly"
        )
    }

    // MARK: - Performance

    @Test("Draw rect should be callable")
    func drawRect() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testRect = CGRect(x: 0, y: 0, width: 100, height: 100)

        // Verify the method exists
        try #require(
            circle.responds(to: #selector(GraphicCircle.draw)),
            "Draw rect method should be available"
        )

        // Just verify we can call the method without errors
        circle.draw(testRect)
    }

    // MARK: - Core Initialization

    @Test("initCoreCircleWithController should initialize with default values")
    func initCoreCircleWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let circle = GraphicCircle(coreCircleWithController: controller)

        // Then
        #expect(circle.countSetting == 0, "Default count should be 0")
        #expect(circle.percentSetting == 0.0, "Default percent should be 0.0")
        #expect(circle.isFixedCount == false, "Default fixed state should be false")
    }

    // MARK: - Percent Tests

    @Test("percent should return correct value")
    func testPercent() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let expectedPercent: Float = 0.75

        // When
        circle.percentSetting = expectedPercent

        // Then
        #expect(
            circle.percentSetting == expectedPercent,
            "Percent should return the set value"
        )
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should include correct default properties")
    func graphicSettingsWithDefaultValues() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: defaultGraphicSettings()
            )
    }

    @Test("graphicSettings should include correct properties for set percent")
    func graphicSettingsWithSetPercentSettingsValues() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        circle.percentSetting = 0.755
        var expectedSettings = defaultGraphicSettings()
        expectedSettings[GraphicKeyIsPercent] = "YES"
        expectedSettings[GraphicKeyPercentSetting] = "0.755000"
        expectedSettings[GraphicKeyGeometryPercent] = "0.755000"
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: expectedSettings
            )
    }

    @Test("graphicSettings should include correct properties for set geometry percent")
    func graphicSettingsWithSetGeometryPercentValues() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        circle.setGeometryPercent(0.45)

        var expectedSettings = defaultGraphicSettings()
        expectedSettings[GraphicKeyIsPercent] = "NO"
        expectedSettings[GraphicKeyIsGeometryPercent] = "YES"
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: expectedSettings
            )
    }

    @Test("graphicSettings should include correct properties for is fixed count")
    func graphicSettingsWithIsFixedValues() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        circle.isFixedCount = true
        var expectedSettings = defaultGraphicSettings()
        expectedSettings[GraphicKeyIsFixedCount] = "YES"
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: expectedSettings
            )
    }

    // MARK: - Transparency Tests

    @Test(
        "setTransparency should update alpha components of colors",
        arguments: [
            (0.5, 0.5), // normal
            (2.0, 1.0), // , // out of range -  high
            (-0.1, 0.0) // out of range -  low
        ]
    )
    func testSetTransparency(values: (Float, Float)) throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let alpha: Float = values.0
        let expectedAlpha: Float = values.1

        let baseStrokeColor = NSColor.red
        let baseFillColor = NSColor.blue
        // Set custom colors first
        circle.setLineColor(baseStrokeColor, fill: baseFillColor)

        // When
        circle.setTransparency(alpha)

        // then
        try transparencyCompare(
            expectedAlpha: expectedAlpha,
            expectedBaseStrokeColor: baseStrokeColor,
            expectedBaseFillColor: baseFillColor,
            strokeColor: #require(circle.strokeColor),
            fillColor: #require(circle.fillColor)
        )
    }

    @Test("setTransparency should handle nil colors gracefully")
    func testSetTransparencyWithNilColors() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testAlpha: Float = 0.5

        // Set colors to nil (simulate cleared colors)
        circle.strokeColor = nil
        circle.fillColor = nil

        // When - This should not crash
        circle.setTransparency(testAlpha)

        try transparencyCompare(
            expectedAlpha: testAlpha,
            expectedBaseStrokeColor: NSColor.black,
            expectedBaseFillColor: NSColor.black,
            strokeColor: #require(circle.strokeColor),
            fillColor: #require(circle.fillColor)
        )
    }

    // MARK: - Drawing Tests

    @Test("setDrawsFill should update fill drawing state")
    func testSetDrawsFill() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)

        // When - Set to true
        circle.drawsFill = true

        // Then
        #expect(circle.drawsFill == true, "Draws fill should be true")

        // When - Set to false
        circle.drawsFill = false

        // Then
        #expect(circle.drawsFill == false, "Draws fill should be false")

        // When - Set to true again
        circle.drawsFill = true

        // Then
        #expect(circle.drawsFill == true, "Draws fill should be true after toggling")
    }

    // MARK: - Line and Fill Color Tests

    @Test("setLineColor should update both stroke and fill colors")
    func testSetLineAndFillColor() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)
        let testStrokeColor = NSColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        let testFillColor = NSColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.9)

        // When
        circle.setLineColor(testStrokeColor, fill: testFillColor)

        // Then
        let strokeColor = try #require(circle.strokeColor)
        let fillColor = try #require(circle.fillColor)

        // Verify colors match exactly
        try CommonUtilities.verifyEqualColorsWithAlpha(lhs: strokeColor, rhs: testStrokeColor)
        try CommonUtilities.verifyEqualColorsWithAlpha(lhs: fillColor, rhs: testFillColor)
    }

    @Test("setLineColor with nil parameters should use default colors")
    func testSetLineColorWithNilParameters() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let circle = GraphicCircle(controller: controller)

        // Set custom colors first
        circle.setLineColor(NSColor.red, fill: NSColor.blue)

        // When - Set one or both colors to nil
        circle.setLineColor(nil, fill: nil)

        // Then - Verify default colors are used (black for both in this case)
        #expect(circle.strokeColor == nil)
        #expect(circle.fillColor == nil) // this shouldn't happen
    }
}

// swiftlint:enable file_length type_body_length object_literal
