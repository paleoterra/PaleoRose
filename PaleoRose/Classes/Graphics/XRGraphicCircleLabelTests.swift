//
//  XRGraphicCircleLabelTests.swift
//  PaleoRose
//
//  Created by Thomas Moore on 6/29/25.
//

import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicCircleLabelTests {
    // MARK: - Test Setup

    private func buildController() -> MockGeometryController {
        let controller = MockGeometryController()
        controller.configureTestValues()
        return controller
    }

    private func buildTestObject(controller: MockGeometryController) throws -> XRGraphicCircleLabel {
        try #require(
            XRGraphicCircleLabel(controller: controller),
            "Graphic circle label should be initialized"
        )
    }

    private func buildCoreTestObject(controller: MockGeometryController) throws -> XRGraphicCircleLabel {
        let label = try buildTestObject(controller: controller)
        label.setShow(false)
        return label
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "LabelCircle",
            "Label": "0",
            "_isGeometryPercent": "NO",
            "_isPercent": "NO",
            "_percentSetting": "0.000000",
            "_labelFont": ".AppleSystemUIFont 14.00 pt. P [] (0x141f06450) fobj=0x141f06450, spc=3.79",
            "_lineWidth": "1.000000",
            "_countSetting": "0",
            "_labelAngle": "0.000000",
            "_isFixedCount": "NO",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.black,
            "_showLabel": "YES",
            "_isCore": "NO",
            "_geometryPercent": "0.000000"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController should initialize with default values")
    func testInitWithController() throws {
        // Given
        let controller = buildController()

        // When
        let label = try buildTestObject(controller: controller)

        // Then
        #expect(label.show() == true, "Default showLabel should be true")
        #expect(
            label
                .labelAngle().isApproximatelyEqual(to: 0.0, relativeTolerance: 0.001)
        )
        #expect(label.font() != nil, "Default font should not be nil")
        #expect(
            label.font().pointSize.isApproximatelyEqual(to: 12.0, relativeTolerance: 0.001),
            "Default font size should be 12.0"
        )
        #expect(label.font().fontName.contains("Arial-Black"), "Default font should be Arial-Black")
    }

    @Test("initCoreCircleWithController should initialize core label with default values")
    func testInitCoreCircleWithController() throws {
        // Given
        let controller = buildController()

        // When
        let label = try #require(XRGraphicCircleLabel(coreCircleWith: controller))
        label.setFont(NSFont(name: "Arial-Black", size: 12))
        label.computeLabelText()
        var expectedSettings = defaultSettings()
        expectedSettings["_showLabel"] = "NO"
        expectedSettings["_isCore"] = "YES"

        let settings = try #require(label.graphicSettings())

        // Then
        #expect(label.show() == false, "Core label showLabel should be false")
        #expect(
            label.labelAngle().isApproximatelyEqual(to: 0.0, relativeTolerance: 0.001),
            "Default labelAngle should be 0.0"
        )
        #expect(label.countSetting() == 0, "Core label countSetting should be 0")

        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    // MARK: - Property Tests

    @Test("setShow should update showLabel value")
    func testSetShow() throws {
        // Given
        let controller = buildController()
        let label = try buildTestObject(controller: controller)

        // When - Set to false
        label.setShow(false)

        // Then
        #expect(label.show() == false, "showLabel should be false after setting to false")

        // When - Set back to true
        label.setShow(true)

        // Then
        #expect(label.show() == true, "showLabel should be true after setting back to true")
    }

    @Test("setLabelAngle should update label angle and trigger geometry update")
    func testSetLabelAngle() throws {
        // Given
        let controller = buildController()
        let label = try buildTestObject(controller: controller)
        let testAngle: Float = 45.0

        // When
        label.setLabelAngle(testAngle)

        // Then
        #expect(
            label.labelAngle().isApproximatelyEqual(to: 45.0, relativeTolerance: 0.001),
            "labelAngle should be 45.0 after setting"
        )
    }

    @Test("setFont should update font and trigger geometry update")
    func testSetFont() throws {
        // Given
        let controller = buildController()
        let label = try buildTestObject(controller: controller)
        let newFont = NSFont.systemFont(ofSize: 14.0)

        // When
        label.setFont(newFont)

        // Then
        let currentFont = label.font()
        #expect(
            label.font().pointSize.isApproximatelyEqual(to: 14.0, relativeTolerance: 0.001),
            "Font size should be 14.0 after setting"
        )
    }

    // MARK: - Geometry Calculation Tests

//    @Test("calculateGeometry should compute correct geometry for non-core label")
//    func testCalculateGeometryNonCore() throws {
//        // Given
//        let controller = buildController()
//        let label = try buildTestObject(controller: controller)
//
//        // When
//        label.calculateGeometry()
//
//        // Then - Verify the drawing path is created
//        // Note: We can't directly access _drawingPath, but we can verify side effects
//        let drawingRect = label.drawingRect()
//        #expect(drawingRect.width > 0, "Drawing rect width should be greater than 0")
//        #expect(drawingRect.height > 0, "Drawing rect height should be greater than 0")
//    }

    @Test("calculateGeometry should compute correct geometry for core label")
    func testCalculateGeometryCore() throws {
        // Given
        let controller = buildController()
        let label = try buildCoreTestObject(controller: controller)

        // When
        label.calculateGeometry()

        // Then - Verify the drawing path is created
        let drawingRect = label.drawingRect()
        #expect(drawingRect.width > 0, "Drawing rect width should be greater than 0")
        #expect(drawingRect.height > 0, "Drawing rect height should be greater than 0")
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should return correct settings dictionary")
    func testGraphicSettings() throws {
        // Given
        let controller = buildController()
        let label = try buildTestObject(controller: controller)

        // Configure some custom values
        label.setShow(true)
        label.setLabelAngle(30.0)
        label.setFont(NSFont.systemFont(ofSize: 14.0))
        label.computeLabelText()

        var expectedSettings = defaultSettings()
        expectedSettings["_labelAngle"] = "30.000000"

        // When
        let settings = try #require(label.graphicSettings())

        // then
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    // MARK: - Label Text Computation Tests

    @Test("computeLabelText should generate correct label for percent mode")
    func testComputeLabelTextPercentMode() throws {
        // Given
        let controller = buildController()
        controller.mockIsPercent = true
        let label = try buildTestObject(controller: controller)
        label.setPercentSetting(0.5) // 50%

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = try #require(label.value(forKey: "_label") as? NSAttributedString)
        #expect(labelText.string.contains("50.0 %"), "Label should contain '50.0%' in percent mode")
    }

    @Test("computeLabelText should generate correct label for count mode")
    func testComputeLabelTextCountMode() throws {
        // Given
        let controller = buildController()
        controller.mockIsPercent = false
        let label = try buildTestObject(controller: controller)
        label.setCountSetting(42)

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = label.value(forKey: "_label") as? NSAttributedString
        #expect(labelText?.string == "42", "Label should be '42' in count mode")
    }

    @Test("computeLabelText should generate correct label for fixed count mode")
    func testComputeLabelTextFixCountMode() throws {
        // Given
        let controller = buildController()
        controller.mockIsPercent = false
        controller.mockGeometryMaxCount = 100
        let label = try buildTestObject(controller: controller)
        label.setIsFixed(true)
        label.setPercentSetting(0.30)

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = label.value(forKey: "_label") as? NSAttributedString
        #expect(labelText?.string == "30.0", "Label should be '42' in count mode")
    }

    // MARK: - Transform Computation Tests

    @Test("computeTransform should create correct transform for label angle")
    func testComputeTransform() throws {
        // Given
        let controller = buildController()
        let label = try buildTestObject(controller: controller)
        let testAngle: Float = 90.0
        label.setLabelAngle(testAngle)

        // When
        label.computeTransform()

        // Then - Verify the transform is created
        // Note: We can't directly test the transform values, but we can verify the method runs without errors
        // and that the transform is applied during drawing
        let transform = label.value(forKey: "theTransform") as? AffineTransform
        #expect(transform != nil, "Transform should be created")
    }

    @Test("Set geometry percent")
    func setGeometryPercent() throws {
        let controller = buildController()
        let label = try buildTestObject(controller: controller)

        label.setGeometryPercent(0.7)
        var expectedSettings = defaultSettings()
        expectedSettings["_labelAngle"] = "0.000000"
        expectedSettings["_geometryPercent"] = "70.000000"
        expectedSettings["_percentSetting"] = "70.000000"

        let settings = try #require(label.graphicSettings())
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    @Test("Show label to NO")
    func testShowLabelToNo() throws {
        let controller = buildController()
        let label = try buildTestObject(controller: controller)

        label.setShow(false)
        var expectedSettings = defaultSettings()
        expectedSettings["_showLabel"] = "NO"
        expectedSettings["_labelAngle"] = "0.000000"
        label.setShow(false)
        label.computeLabelText()
        let settings = try #require(label.graphicSettings())
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
