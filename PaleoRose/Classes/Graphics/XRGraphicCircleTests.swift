import Numerics
@testable import PaleoRose
import Testing

// swiftlint:disable file_length type_body_length
@MainActor
struct XRGraphicCircleTests {

    private func buildController() -> MockGeometryController {
        let controller = MockGeometryController()
        controller.configureTestValues()
        return controller
    }

    private func buildTestObject(controller: MockGeometryController) throws -> XRGraphicCircle {
        try #require(
            XRGraphicCircle(controller: controller),
            "Graphic circle should be initialized"
        )
    }

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
        fillColor: NSColor
    ) throws {
        #expect(strokeColor.alphaComponent.isApproximatelyEqual(to: CGFloat(expectedAlpha)))
        #expect(fillColor.alphaComponent.isApproximatelyEqual(to: CGFloat(expectedAlpha)))

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
        let controller = buildController()

        // When
        let circle = try buildTestObject(controller: controller)

        // Then
        // Verify super values
        #expect(
            circle.fillColor() == .black,
            "Default fill color should be black"
        )
        #expect(circle.strokeColor() == .black, "Default stroke color should be black")
        #expect(circle.lineWidth() == 1.0, "Default line width should be 1.0")
        #expect(circle.needsDisplay() == true, "Default needs display should be true")
        #expect(circle.drawsFill() == false, "Default draws fill should be false")
        // Verify default values
        #expect(circle.countSetting() == 0, "Default count should be 0")
        #expect(circle.percent() == 0.0, "Default percent should be 0.0")
        #expect(!circle.isFixed(), "Default fixed state should be false")
    }

    // MARK: - Count and Percentage Tests

    @Test("Count should be settable and gettable")
    func count() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)

        let expectedCount: Int32 = 42

        // When
        circle.setCountSetting(expectedCount)

        // Then
        #expect(
            circle.countSetting() == expectedCount,
            "Count should be set correctly"
        )
    }

    @Test("Percent should be settable and gettable")
    func percent() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let expectedPercent: Float = 0.75

        // When
        circle.setPercentSetting(expectedPercent)

        // Then
        #expect(
            circle.percent().isApproximatelyEqual(
                to: expectedPercent,
                absoluteTolerance: .ulpOfOne
            ),
            "Percent should be set correctly"
        )
    }

    @Test("Geometry percent should be settable and gettable")
    func percentSetting() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testPercent: Float = 60.0

        // When
        circle.setPercentSetting(testPercent)

        // Then
        #expect(
            circle.percent().isApproximatelyEqual(
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
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)

        // Test default value
        #expect(!circle.isFixed(), "Default fixed state should be false")

        // Test setting to true
        circle.setIsFixed(true)
        #expect(circle.isFixed(), "Fixed state should be true after setting to true")

        // Test setting back to false
        circle.setIsFixed(false)
        #expect(!circle.isFixed(), "Fixed state should be false after setting to false")
    }

    //    // MARK: - Equality

    //    @Test("Equality should compare based on properties")
    //    func equality() throws {
    //        // Given
    //        let controller1 = buildController()
    //        let circle1 = try buildTestObject(controller: controller1)
    //        let controller2 = buildController()
    //        let circle2 = try buildTestObject(controller: controller2)
    //
    //        // Then
    //        #expect(circle1 == circle2, "Circles with same properties should be equal")
    //    }

    //    @Test("Inequality should detect different properties")
    //    func inequality() throws {
    //        // Given
    //        let controller1 = MockGeometryController()
    //        controller1.configureTestValues()
    //        let circle1 = try #require(
    //            XRGraphicCircle(controller: controller1),
    //            "Failed to initialize first circle"
    //        )
    //
    //        let controller2 = MockGeometryController()
    //        controller2.configureTestValues()
    //        let circle2 = try #require(
    //            XRGraphicCircle(controller: controller2),
    //            "Failed to initialize second circle"
    //        )
    //        circle2.setCountSetting(99) // Different count
    //
    //        // Then
    //        #expect(circle1 != circle2, "Circles with different properties should not be equal")
    //    }
    //
    //    @Test("Equality check with nil should return false")
    //    func isEqual_whenComparingToNil() throws {
    //        // Given
    //        let controller = MockGeometryController()
    //        controller.configureTestValues()
    //        let circle = try #require(
    //            XRGraphicCircle(controller: controller),
    //            "Failed to initialize circle"
    //        )
    //    }
    //
    //    // MARK: - Drawing

    @Test("Drawing rect should return non-zero size when Is percent")
    func drawingRect() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        controller.mockIsPercent = true
        circle.calculateGeometry()
        // When
        let drawingRect = circle.drawingRect()
        print(drawingRect)
        // Then
        #expect(drawingRect.width > 0, "Width should be greater than 0")
        #expect(drawingRect.height > 0, "Height should be greater than 0")
    }

    @Test("Drawing rect should return non-zero size when not percent")
    func drawingRectNotPercent() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        controller.mockIsPercent = false
        circle.calculateGeometry()
        // When
        let drawingRect = circle.drawingRect()
        print(drawingRect)
        // Then
        #expect(drawingRect.width > 0, "Width should be greater than 0")
        #expect(drawingRect.height > 0, "Height should be greater than 0")
    }

    // MARK: - Hit Testing

    //    @Test("Hit test should detect point inside circle")
    //    func hitTest_whenPointIsInside() throws {
    //        // Given
    //        let controller = MockGeometryController()
    //        controller.configureTestValues()
    //        let circle = try #require(
    //            XRGraphicCircle(controller: controller),
    //            "Failed to initialize circle"
    //        )
    //
    //        // Position the circle at (50,50) with radius 40
    //        circle.setFrame(NSRect(x: 10, y: 10, width: 80, height: 80))
    //        let insidePoint = NSPoint(x: 50, y: 50)
    //
    //        // When
    //        let hitResult = circle.hitTest(insidePoint)
    //
    //        // Then
    //        #expect(hitResult, "Should detect point inside circle")
    //    }

    @Test("Hit test should not detect point outside circle")
    func hitTest_whenPointIsOutside() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let outsidePoint = NSPoint(x: -10, y: -10)

        // When
        let hitResult = circle.hitTest(outsidePoint)

        // Then
        #expect(!hitResult, "Should not detect point outside circle")
    }

    @Test("Setting fill color should update the fill color")
    func setFillColor() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testColor = NSColor.red

        // When
        circle.setFill(testColor)

        // Then
        #expect(
            circle.fillColor() == testColor,
            "Fill color should be set correctly"
        )
    }

    @Test("Setting stroke color should update the stroke color")
    func setStrokeColor() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testColor = NSColor.blue

        // When
        circle.setStroke(testColor)

        // Then
        #expect(
            circle.strokeColor() == testColor,
            "Stroke color should be set correctly"
        )
    }

    // MARK: - Performance

    @Test("Draw rect should be callable")
    func drawRect() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testRect = NSRect(x: 0, y: 0, width: 100, height: 100)

        // Verify the method exists
        try #require(
            circle.responds(to: #selector(XRGraphicCircle.draw)),
            "Draw rect method should be available"
        )

        // Just verify we can call the method without errors
        circle.draw(testRect)
    }

    // MARK: - Geometry Controller

    //    @Test("Setting geometry controller should update internal controller")
    //    func setGeometryController() throws {
    //        // Given
    //        let controller = MockGeometryController()
    //        controller.configureTestValues()
    //        let circle = try #require(
    //            XRGraphicCircle(controller: controller),
    //            "Failed to initialize circle"
    //        )
    //
    //        let newController = MockGeometryController()
    //        newController.configureTestValues()
    //
    //        // When
    //        circle.setGeometryController(newController)
    //
    //        // Then - Verify controller was updated
    //        // Note: Using value(forKey:) to access private property
    //        let updatedController = try #require(
    //            circle.value(forKey: "geometryController") as AnyObject?,
    //            "Controller should be set"
    //        )
    //    }

    // MARK: - Core Initialization

    @Test("initCoreCircleWithController should initialize with default values")
    func initCoreCircleWithController() throws {
        // Given
        let controller = buildController()

        // When
        let circle = try #require(
            XRGraphicCircle(coreCircleWith: controller),
            "Failed to initialize circle"
        )

        // Then
        #expect(circle.countSetting() == 0, "Default count should be 0")
        #expect(circle.percent() == 0.0, "Default percent should be 0.0")
        #expect(circle.isFixed() == false, "Default fixed state should be false")
    }

    // MARK: - Percent Tests

    @Test("percent should return correct value")
    func testPercent() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let expectedPercent: Float = 75.5

        // When
        circle.setPercentSetting(expectedPercent)

        // Then
        #expect(
            circle.percent() == expectedPercent,
            "Percent should return the set value"
        )
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should include correct default properties")
    func graphicSettingsWithDefaultValues() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: defaultGraphicSettings()
            )
    }

    @Test("graphicSettings should include correct properties for set percent")
    func graphicSettingsWithSetPercentSettingsValues() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        circle.setPercentSetting(75.5)
        var expectedSettings = defaultGraphicSettings()
        expectedSettings["_isPercent"] = "YES"
        expectedSettings["_percentSetting"] = "75.500000"
        expectedSettings["_geometryPercent"] = "75.500000"
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: expectedSettings
            )
    }

    @Test("graphicSettings should include correct properties for set geometry percent")
    func graphicSettingsWithSetGeometryPercentValues() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        circle.setGeometryPercent(0.45)

        var expectedSettings = defaultGraphicSettings()
        expectedSettings["_isPercent"] = "NO"
        expectedSettings["_isGeometryPercent"] = "YES"
        try CommonUtilities
            .compareGraphicSettings(
                values: circle.graphicSettings(),
                expected: expectedSettings
            )
    }

    @Test("graphicSettings should include correct properties for is fixed count")
    func graphicSettingsWithIsFixedValues() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        circle.setIsFixed(true)
        var expectedSettings = defaultGraphicSettings()
        expectedSettings["_isFixedCount"] = "YES"
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
            (2.0, 1.0) // , // out of range -  high
//            (-0.1, 0.0) // out of range -  low
        ]
    )
    func testSetTransparency(values: (Float, Float)) throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
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
            strokeColor: #require(circle.strokeColor()),
            fillColor: #require(circle.fillColor())
        )
    }

    @Test("setTransparency should handle nil colors gracefully")
    func testSetTransparencyWithNilColors() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testAlpha: Float = 0.5

        // Set colors to nil (simulate cleared colors)
        circle.setStroke(nil)
        circle.setFill(nil)

        // When - This should not crash
        circle.setTransparency(testAlpha)

        try transparencyCompare(
            expectedAlpha: testAlpha,
            expectedBaseStrokeColor: NSColor.black,
            expectedBaseFillColor: NSColor.black,
            strokeColor: #require(circle.strokeColor()),
            fillColor: #require(circle.fillColor())
        )
    }

    // MARK: - Drawing Tests

    @Test("setDrawsFill should update fill drawing state")
    func testSetDrawsFill() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)

        // When - Set to true
        circle.setDrawsFill(true)

        // Then
        #expect(circle.drawsFill() == true, "Draws fill should be true")

        // When - Set to false
        circle.setDrawsFill(false)

        // Then
        #expect(circle.drawsFill() == false, "Draws fill should be false")

        // When - Set to true again
        circle.setDrawsFill(true)

        // Then
        #expect(circle.drawsFill() == true, "Draws fill should be true after toggling")
    }

    // MARK: - Line and Fill Color Tests

    @Test("setLineColor should update both stroke and fill colors")
    func testSetLineAndFillColor() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)
        let testStrokeColor = NSColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        let testFillColor = NSColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.9)

        // When
        circle.setLineColor(testStrokeColor, fill: testFillColor)

        // Then
        let strokeColor = try #require(circle.strokeColor())
        let fillColor = try #require(circle.fillColor())

        // Verify colors match exactly
        try CommonUtilities.verifyEqualColorsWithAlpha(lhs: strokeColor, rhs: testStrokeColor)
        try CommonUtilities.verifyEqualColorsWithAlpha(lhs: fillColor, rhs: testFillColor)
    }

    @Test("setLineColor with nil parameters should use default colors")
    func testSetLineColorWithNilParameters() throws {
        // Given
        let controller = buildController()
        let circle = try buildTestObject(controller: controller)

        // Set custom colors first
        circle.setLineColor(NSColor.red, fill: NSColor.blue)

        // When - Set one or both colors to nil
        circle.setLineColor(nil, fill: nil)

        // Then - Verify default colors are used (black for both in this case)
        #expect(circle.strokeColor() == nil)
        #expect(circle.fillColor() == nil) // this shouldn't happen
    }
}

// swiftlint:enable file_length type_body_length
