//
//  XRGraphicTests.swift
//  PaleoRoseTests
//
//  Created by Tom Moore on 06/21/2025.
//  Copyright © 2025 Thomas L. Moore. All rights reserved.
//

import AppKit
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicTests {

    private var geometryController: XRGeometryController = .init()

    @Test("Test initialization with controller")
    func testInitialization() async throws {
        // Given
        let controller = XRGeometryController()

        // When
        let testGraphic = try #require(XRGraphic(controller: controller))

        // Then
        #expect(testGraphic.isSelected() == false)
        #expect(testGraphic.drawsFill() == false)
        #expect(testGraphic.lineWidth() == 1.0, "Default line width should be 1.0")
        #expect(testGraphic.needsDisplay() == true, "Graphic should need display after initialization")
    }

    @Test("Test color properties")
    func testColorProperties() async throws {
        // Given
        let color = NSColor.red
        let graphic = try #require(XRGraphic(controller: geometryController))
        // When
        graphic.setFill(color)
        graphic.setStroke(color)

        // Then
        #expect(graphic.fillColor() == color, "Fill color should be set")
        #expect(graphic.strokeColor() == color, "Stroke color should be set")
    }

    @Test("Test line width")
    func testLineWidth() async throws {
        // Given
        let graphic = try #require(XRGraphic(controller: geometryController))
        let testWidth: Float = 2.5

        // When
        graphic.setLineWidth(testWidth)

        // Then
        #expect(graphic.lineWidth() == testWidth, "Line width should be updated")
    }

    @Test("Test draw settings")
    func testDrawSettings() async throws {
        // When
        let graphic = try #require(XRGraphic(controller: geometryController))
        graphic.setDrawsFill(true)

        // Then
        #expect(graphic.drawsFill(), "Should draw fill when set to true")

        // When
        graphic.setDrawsFill(false)

        // Then
        #expect(graphic.drawsFill() == false, "Should not draw fill when set to false")
    }

    @Test("Test needs display flag")
    func testNeedsDisplay() async throws {
        // When
        let graphic = try #require(XRGraphic(controller: geometryController))
        graphic.setNeedsDisplay(true)

        // Then
        #expect(graphic.needsDisplay() == true, "Needs display should be true after setting")

        // When
        graphic.setNeedsDisplay(false)

        // Then
        #expect(graphic.needsDisplay() == false, "Needs display should be false after clearing")
    }

    @Test("Test transparency")
    func testTransparency() async throws {
        // Given
        let graphic = try #require(XRGraphic(controller: geometryController))
        let alpha: CGFloat = 0.5

        // When
        graphic.setTransparency(Float(alpha))

        // Then
        #expect(graphic.fillColor().alphaComponent == alpha, "Fill color alpha should be set")
        #expect(graphic.strokeColor().alphaComponent == alpha, "Stroke color alpha should be set")
    }

    @Test("Test color comparison")
    func testColorComparison() async throws {
        // Given
        let graphic = try #require(XRGraphic(controller: geometryController))
        let color1 = NSColor.red
        let color2 = NSColor.red
        let color3 = NSColor.blue

        // When/Then
        #expect(
            graphic.compare(color1, with: color2) == true,
            "Identical colors should compare equal"
        )
        #expect(
            graphic.compare(color1, with: color3) == false,
            "Different colors should not compare equal"
        )
    }

    @Test("Test graphic settings")
    func testGraphicSettings() async throws {
        // When
        let graphic = try #require(XRGraphic(controller: geometryController))
        let settings = try #require(graphic.graphicSettings() as? [String: Any])

        // Then
        let graphicType = try #require(settings["GraphicType"] as? String)
        _ = try #require(settings["_fillColor"] as? NSColor)
        _ = try #require(settings["_strokeColor"] as? NSColor)
        #expect(graphicType == "Graphic", "Should return !correct graphic type")
    }
}
