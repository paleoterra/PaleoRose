//
//  MockGraphicGeometrySource.swift
//  PaleoRoseTests
//
//  Created by Tom Moore on 7/16/25.
//

import AppKit
import Foundation
@testable import PaleoRose

@objc
class MockGraphicGeometrySource: NSObject, GraphicGeometrySource {

    // MARK: - Mock Properties

    var mockDrawingBounds: NSRect = .zero
    var mockIsPercent: Bool = false
    var mockIsEqualArea: Bool = false
    var mockStartingAngle: Float = 0.0
    var mockSectorSize: Float = 0.0
    var mockGeometryMaxCount: Int32 = 0
    var mockGeometryMaxPercent: Float = 0.0
    var mockHollowCoreSize: Float = 0.0

    // MARK: - GraphicGeometrySource Protocol Conformance

    @objc
    var drawingBounds: NSRect {
        mockDrawingBounds
    }

    @objc
    func isPercent() -> Bool {
        mockIsPercent
    }

    @objc
    func isEqualArea() -> Bool {
        mockIsEqualArea
    }

    @objc
    func startingAngle() -> Float {
        mockStartingAngle
    }

    @objc
    func sectorSize() -> Float {
        mockSectorSize
    }

    @objc
    func geometryMaxCount() -> Int32 {
        mockGeometryMaxCount
    }

    @objc
    func geometryMaxPercent() -> Float {
        mockGeometryMaxPercent
    }

    func hollowCoreSize() -> Float {
        mockHollowCoreSize
    }

    // MARK: - Geometry Calculations

    @objc
    func radius(ofCount count: Int32) -> Double {
        // Simple linear scaling for testing
        Double(count) / Double(max(1, mockGeometryMaxCount))
    }

    @objc
    func circleRect(forCount count: Int32) -> NSRect {
        let radius = radius(ofCount: count)
        let size = radius * 2.0
        return NSRect(x: 0, y: 0, width: size, height: size)
    }

    @objc
    func circleRect(forPercent percent: Float) -> NSRect {
        let radius = radius(ofRelativePercent: Double(percent))
        let size = radius * 2.0
        return NSRect(x: 0, y: 0, width: size, height: size)
    }

    @objc
    func circleRect(forGeometryPercent percent: Float) -> NSRect {
        circleRect(forPercent: percent)
    }

    @objc
    func rotation(of thePoint: NSPoint, byAngle angle: Double) -> NSPoint {
        let radians = angle * .pi / 180.0
        let cosA = cos(radians)
        let sinA = sin(radians)
        let xValue = thePoint.x * cosA - thePoint.y * sinA
        let yValue = thePoint.x * sinA + thePoint.y * cosA
        return NSPoint(x: xValue, y: yValue)
    }

    @objc
    func degrees(fromRadians radians: Double) -> Double {
        radians * 180.0 / .pi
    }

    @objc
    func radius(ofRelativePercent percent: Double) -> Double {
        Double(percent) / 100.0
    }

    @objc func radius(ofPercentValue percent: Double) -> Double {
        Double(percent) / 100.0
    }

    @objc
    func unrestrictedRadius(ofRelativePercent percent: Double) -> CGFloat {
        CGFloat(radius(ofRelativePercent: percent))
    }

    // MARK: - Convenience Initializer

    override convenience init() {
        self.init(drawingBounds: .zero)
    }

    @objc
    convenience init(
        drawingBounds: NSRect = .zero,
        isPercent: Bool = false,
        isEqualArea: Bool = false,
        startingAngle: Float = 0.0,
        sectorSize: Float = 0.0,
        maxCount: Int32 = 0,
        maxPercent: Float = 0.0,
        hollowCore: Float = 0.0
    ) {
        self.init()
        mockDrawingBounds = drawingBounds
        mockIsPercent = isPercent
        mockIsEqualArea = isEqualArea
        mockStartingAngle = startingAngle
        mockSectorSize = sectorSize
        mockGeometryMaxCount = maxCount
        mockGeometryMaxPercent = maxPercent
        mockHollowCoreSize = hollowCore
    }

    // MARK: - Debug Description

    override var debugDescription: String {
        """
        MockGraphicGeometrySource(
            drawingBounds: \(mockDrawingBounds),
            isPercent: \(mockIsPercent),
            isEqualArea: \(mockIsEqualArea),
            startingAngle: \(mockStartingAngle),
            sectorSize: \(mockSectorSize),
            maxCount: \(mockGeometryMaxCount),
            maxPercent: \(mockGeometryMaxPercent),
            hollowCore: \(mockHollowCoreSize)
        )
        """
    }
}
