//
//  GraphicCircleLabelTests.swift
//  PaleoRose
//
//  Created by Thomas Moore on 6/29/25.
//

import AppKit
@testable import PaleoRose
import Testing

// swiftlint:disable file_length type_body_length
struct GraphicCircleLabelTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: GraphicGeometrySource) throws -> GraphicCircleLabel {
        GraphicCircleLabel(controller: controller)
    }

    private func buildCoreTestObject(controller: GraphicGeometrySource) throws -> GraphicCircleLabel {
        let label = try buildTestObject(controller: controller)
        // For core circles, we want to hide the label and mark it as a core circle
        label.showLabel = false
        // Set the private _isCore ivar to true
        label.setValue(true, forKey: "isCore")
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
        let controller = MockGraphicGeometrySource()

        // When
        let label = try buildTestObject(controller: controller)

        // Then
        #expect(label.showLabel == true, "Default showLabel should be true")
        #expect(
            label
                .labelAngle.isApproximatelyEqual(to: 0.0, relativeTolerance: 0.001)
        )
        let currentFont = try #require(label.labelFont)
        #expect(
            currentFont.pointSize.isApproximatelyEqual(to: 12.0, relativeTolerance: 0.001),
            "Default font size should be 12.0"
        )
        #expect(currentFont.fontName.contains("Arial-Black"), "Default font should be Arial-Black")
    }

    @Test("initCoreCircleWithController should initialize core label with default values")
    func testInitCoreCircleWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let label = try #require(GraphicCircleLabel(coreCircleWithController: controller))
        label.labelFont = NSFont(name: "Arial-Black", size: 12)
        label.computeLabelText()
        var expectedSettings = defaultSettings()
        expectedSettings["_showLabel"] = "NO"
        expectedSettings["_isCore"] = "YES"

        let settings = label.graphicSettings()

        // Then
        #expect(label.showLabel == false, "Core label showLabel should be false")
        #expect(
            label.labelAngle.isApproximatelyEqual(to: 0.0, relativeTolerance: 0.001),
            "Default labelAngle should be 0.0"
        )
        #expect(label.countSetting == 0, "Core label countSetting should be 0")

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
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)

        // When - Set to false
        label.showLabel = false

        // Then
        #expect(label.showLabel == false, "showLabel should be false after setting to false")

        // When - Set back to true
        label.showLabel = true

        // Then
        #expect(label.showLabel == true, "showLabel should be true after setting back to true")
    }

    @Test("setLabelAngle should update label angle and trigger geometry update")
    func testSetLabelAngle() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)
        let testAngle: Float = 45.0

        // When
        label.labelAngle = testAngle

        // Then
        #expect(
            label.labelAngle.isApproximatelyEqual(to: 45.0, relativeTolerance: 0.001),
            "labelAngle should be 45.0 after setting"
        )
    }

    @Test("setFont should update font and trigger geometry update")
    func testSetFont() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)
        let newFont = NSFont.systemFont(ofSize: 14.0)

        // When
        label.labelFont = newFont

        // Then
        let currentFont = try #require(label.labelFont)
        #expect(
            currentFont.pointSize.isApproximatelyEqual(to: 14.0, relativeTolerance: 0.001),
            "Font size should be 14.0 after setting"
        )
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should return correct settings dictionary")
    func testGraphicSettings() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)

        // Configure some custom values
        label.showLabel = true
        label.labelAngle = 30.0
        label.labelFont = NSFont.systemFont(ofSize: 14.0)
        label.computeLabelText()

        var expectedSettings = defaultSettings()
        expectedSettings["_labelAngle"] = "30.000000"

        // When
        let settings = label.graphicSettings()

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
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        let label = try buildTestObject(controller: controller)
        label.percentSetting = 0.5 // 50%

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = try #require(label.label)
        #expect(labelText.string.contains("50.0 %"), "Label should contain '50.0%' in percent mode")
    }

    @Test("computeLabelText should generate correct label for count mode")
    func testComputeLabelTextCountMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false
        let label = try buildTestObject(controller: controller)
        label.countSetting = 42

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = try #require(label.label)
        #expect(labelText.string == "42", "Label should be '42' in count mode")
    }

    @Test("computeLabelText should generate correct label for fixed count mode")
    func testComputeLabelTextFixCountMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false
        controller.mockGeometryMaxCount = 100
        let label = try buildTestObject(controller: controller)
        label.isFixedCount = true
        label.percentSetting = 0.30

        // When
        label.computeLabelText()

        // Then - Verify the label text is formatted correctly
        let labelText = try #require(label.label)
        #expect(labelText.string == "30.0", "Label should be '30.0' in fixed count mode")
    }

    // MARK: - Transform Computation Tests

    @Test("computeTransform should create correct transform for label angle")
    func testComputeTransform() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)
        let testAngle: Float = 90.0
        label.labelAngle = testAngle

        // When
        label.computeTransform()

        // Then - Verify the transform is created
        // Note: We can't directly test the transform values, but we can verify the method runs without errors
        // and that the transform is applied during drawing
        let transform = label.theTransform
        #expect(transform != nil, "Transform should be created")
    }

    @Test("Set geometry percent")
    func setGeometryPercent() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockGeometryMaxPercent = 1.0
        let label = try buildTestObject(controller: controller)

        label.setGeometryPercent(0.7)
        var expectedSettings = defaultSettings()
        expectedSettings["_labelAngle"] = "0.000000"
        expectedSettings[GraphicKeyGeometryPercent] = "0.700000"
        expectedSettings[GraphicKeyPercentSetting] = "0.700000"

        let settings = label.graphicSettings()
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    @Test("Show label to NO")
    func testShowLabelToNo() throws {
        let controller = MockGraphicGeometrySource()
        let label = try buildTestObject(controller: controller)

        label.showLabel = false
        var expectedSettings = defaultSettings()
        expectedSettings["_showLabel"] = "NO"
        expectedSettings["_labelAngle"] = "0.000000"
        label.showLabel = false
        label.computeLabelText()
        let settings = label.graphicSettings()
        try CommonUtilities
            .compareGraphicSettings(
                values: settings,
                expected: expectedSettings
            )
    }

    // MARK: - Core Circle Tests

    @Test("Core circle in percent mode should use circleRect(forPercent:)")
    func testCoreCirclePercentMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockCircleRectPercent = CGRect(x: 0, y: 0, width: 100, height: 100)

        let label = try buildCoreTestObject(controller: controller)
        label.showLabel = true

        // When
        label.calculateGeometry()

        // Then

        verifyCalculateGeometryCalls(
            controller: controller,
            circleRectPercent: true
        )

        try verifyDrawingPath(for: label, isCore: true)
    }

    @Test("Core circle in count mode should use circleRect(forCount:)")
    func testCoreCircleCountMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false
        controller.mockCircleRectCount = CGRect(x: 0, y: 0, width: 100, height: 100)

        let label = try buildCoreTestObject(controller: controller)
        label.showLabel = true

        // When
        label.calculateGeometry()

        // Then
        verifyCalculateGeometryCalls(
            controller: controller,
            circleRectForCount: true
        )

        try verifyDrawingPath(for: label, isCore: true)
    }

    // MARK: - Non-Core Circle Tests

    @Test("Non-core circle with showLabel in percent mode should use radius methods")
    func testNonCoreCircleWithLabelPercentMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockGeometryMaxPercent = 1.0

        let label = try buildTestObject(controller: controller)
        label.showLabel = true
        label.isFixedCount = false
        label.percentSetting = 0.7

        // When
        label.calculateGeometry()

        // Then

        verifyCalculateGeometryCalls(
            controller: controller,
            radiusPercentValue: true
        )

        try verifyDrawingPath(for: label, isCore: false)

        // Verify label properties are set
        #expect(
            label.label != nil,
            "Label should be set when showLabel is true"
        )
        #expect(
            label.theTransform != nil,
            "Transform should be set when showLabel is true"
        )
    }

    @Test("Non-core circle with showLabel in count mode should use radius methods")
    func testNonCoreCircleWithLabelCountMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false
        controller.mockGeometryMaxCount = 100

        let label = try buildTestObject(controller: controller)
        label.showLabel = true
        label.isFixedCount = false
        label.countSetting = 25

        // When
        label.calculateGeometry()

        // Then
        verifyCalculateGeometryCalls(
            controller: controller,
            radiusForCount: true
        )

        try verifyDrawingPath(for: label, isCore: false)

        // Verify label properties are set
        #expect(label.label != nil, "Label should be set when showLabel is true")
        #expect(label.theTransform != nil, "Transform should be set when showLabel is true")
    }

    @Test("Non-core circle without showLabel in percent mode should use circleRect")
    func testNonCoreCircleWithoutLabelPercentMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockCircleRectPercent = CGRect(x: 0, y: 0, width: 100, height: 100)

        let label = try buildTestObject(controller: controller)
        label.showLabel = false

        // When
        label.calculateGeometry()

        // Then

        verifyCalculateGeometryCalls(
            controller: controller,
            circleRectPercent: true
        )

        try verifyDrawingPath(for: label, isCore: false)
    }

    @Test("Non-core circle without showLabel in count mode should use circleRect")
    func testNonCoreCircleWithoutLabelCountMode() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false
        controller.mockCircleRectCount = CGRect(x: 0, y: 0, width: 100, height: 100)

        let label = try buildTestObject(controller: controller)
        label.showLabel = false

        // When
        label.calculateGeometry()

        // Then

        verifyCalculateGeometryCalls(
            controller: controller,
            circleRectForCount: true
        )

        try verifyDrawingPath(for: label, isCore: false)
    }

    // MARK: - Fixed Count Tests

    @Test("Non-core circle with fixedCount should use percent methods regardless of isPercent")
    func testNonCoreCircleWithFixedCount() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = false // This should be ignored when isFixedCount is true

        let label = try buildTestObject(controller: controller)
        label.showLabel = true
        label.isFixedCount = true // This makes it use percent methods
        label.percentSetting = 0.7
        // When
        label.calculateGeometry()

        // Then

        verifyCalculateGeometryCalls(
            controller: controller,
            radiusPercentValue: true
        )

        try verifyDrawingPath(for: label, isCore: false)
    }

    // MARK: - Helper Methods

    private func verifyDrawingPath(
        for label: GraphicCircleLabel,
        isCore: Bool,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) throws {
        let sourceLocaton = SourceLocation(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        if isCore {
            let drawingPath = try #require(label.drawingPath)
            #expect(
                !drawingPath.bounds.isEmpty,
                "Drawing path bounds should not be empty for core circle",
                sourceLocation: sourceLocaton
            )
        } else {
            let drawingRect = label.drawingRect()
            #expect(
                !drawingRect.isEmpty,
                "Drawing rect should not be empty for non-core circle", sourceLocation: sourceLocaton
            )
        }
    }

    private func verifyCalculateGeometryCalls(
        controller: MockGraphicGeometrySource,
        radiusPercentValue: Bool = false,
        radiusForCount: Bool = false,
        circleRectPercent: Bool = false,
        circleRectForCount: Bool = false,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let sourceLocaton = SourceLocation(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        #expect(
            controller.wasMethodCalled("radius(ofPercentValue:)") == radiusPercentValue,
            "\(radiusPercentValue ? "Should " : "Should not ")call radius(ofPercentValue:) when isFixedCount is true",
            sourceLocation: sourceLocaton
        )
        #expect(
            controller.wasMethodCalled("radius(ofCount:)") == radiusForCount,
            "\(radiusForCount ? "Should " : "Should not ")call radius(ofCount:) when isFixedCount is true",
            sourceLocation: sourceLocaton
        )
        #expect(
            controller.wasMethodCalled("circleRect(forPercent:)") == circleRectPercent,
            "\(circleRectPercent ? "Should " : "Should not ")call circleRect methods when showLabel isx true",
            sourceLocation: sourceLocaton
        )
        #expect(
            controller.wasMethodCalled("circleRect(forCount:)") == circleRectForCount,
            "\(circleRectForCount ? "Should " : "Should not ")call circleRect methods when showLabel is true",
            sourceLocation: sourceLocaton
        )
    }
}

// swiftlint:enable type_body_length file_length line_length
