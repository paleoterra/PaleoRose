//
//  MockGeometryController.swift
//  PaleoRoseTests
//
//  Created by Tom Moore on 06/28/2025.
//  Copyright © 2025 Thomas L. Moore. All rights reserved.
//

import Foundation
@testable import PaleoRose

/// A mock implementation of XRGeometryController for testing purposes.
class MockGeometryController: XRGeometryController {

    // MARK: - Test Configuration

    /// The value to return from `isEqualArea`
    var mockIsEqualArea: Bool = false

    /// The value to return from `isPercent`
    var mockIsPercent: Bool = false

    /// The value to return from `geometryMaxCount`
    var mockGeometryMaxCount: Int32 = 0

    /// The value to return from `geometryMaxPercent`
    var mockGeometryMaxPercent: Float = 100.0

    /// The value to return from `hollowCoreSize`
    var mockHollowCoreSize: Float = 0.0

    /// The value to return from `sectorSize`
    var mockSectorSize: Float = 10.0

    /// The value to return from `startingAngle`
    var mockStartingAngle: Float = 0.0

    /// The value to return from `sectorCount`
    var mockSectorCount: Int32 = 36

    /// The value to return from `relativeSizeOfCircleRect`
    var mockRelativeSizeOfCircleRect: Float = 0.8

    // MARK: - Initialization

    override init() {
        super.init()
    }

    // MARK: - Overridden Methods

    override func isEqualArea() -> Bool {
        mockIsEqualArea
    }

    override func isPercent() -> Bool {
        mockIsPercent
    }

    override func geometryMaxCount() -> Int32 {
        mockGeometryMaxCount
    }

    override func geometryMaxPercent() -> Float {
        mockGeometryMaxPercent
    }

    override func hollowCoreSize() -> Float {
        mockHollowCoreSize
    }

    override func sectorSize() -> Float {
        mockSectorSize
    }

    override func startingAngle() -> Float {
        mockStartingAngle
    }

    override func sectorCount() -> Int32 {
        mockSectorCount
    }

    override func relativeSizeOfCircleRect() -> Float {
        mockRelativeSizeOfCircleRect
    }

    override func circleRect(forPercent percent: Float) -> NSRect {
        NSRect(x: 0, y: 0, width: 100, height: 100)
    }

    override func circleRect(forCount count: Int32) -> NSRect {
        NSRect(x: 0, y: 0, width: 100, height: 100)
    }

    // MARK: - Test Helpers

    /// Configures the mock with test values
    /// - Parameters:
    ///   - isEqualArea: Whether to use equal area projection (default: false)
    ///   - isPercent: Whether to use percentage-based geometry (default: false)
    ///   - maxCount: Maximum count value (default: 100)
    ///   - maxPercent: Maximum percentage value (default: 100.0)
    ///   - hollowCore: Hollow core size (default: 10.0)
    ///   - sectorSize: Sector size in degrees (default: 10.0)
    ///   - startAngle: Starting angle in degrees (default: 0.0)
    ///   - sectorCount: Number of sectors (default: 36)
    ///   - relativeSize: Relative size of circle rect (default: 0.8)
    func configureTestValues(
        isEqualArea: Bool = false,
        isPercent: Bool = false,
        maxCount: Int32 = 100,
        maxPercent: Float = 100.0,
        hollowCore: Float = 10.0,
        sectorSize: Float = 10.0,
        startAngle: Float = 0.0,
        sectorCount: Int32 = 36,
        relativeSize: Double = 0.8
    ) {
        mockIsEqualArea = isEqualArea
        mockIsPercent = isPercent
        mockGeometryMaxCount = maxCount
        mockGeometryMaxPercent = maxPercent
        mockHollowCoreSize = hollowCore
        mockSectorSize = sectorSize
        mockStartingAngle = startAngle
        mockSectorCount = sectorCount
        mockRelativeSizeOfCircleRect = Float(relativeSize)
    }

    // MARK: - Geometry Calculations

    override func radius(ofRelativePercent percent: Double) -> Double {
        // Simple linear scaling for testing
        let maxRadius = 100.0
        return (percent / 100.0) * maxRadius
    }

    override func rotation(of thePoint: NSPoint, byAngle angle: Double) -> NSPoint {
        let radians = angle * .pi / 180.0
        let cosAngle = cos(radians)
        let sinAngle = sin(radians)

        return NSPoint(
            x: thePoint.x * cosAngle - thePoint.y * sinAngle,
            y: thePoint.x * sinAngle + thePoint.y * cosAngle
        )
    }

    override func radians(fromDegrees degrees: Double) -> Double {
        degrees * .pi / 180.0
    }

    override func degrees(fromRadians radians: Double) -> Double {
        radians * 180.0 / .pi
    }

    // MARK: - Drawing

    override func drawingBounds() -> NSRect {
        NSRect(x: 0, y: 0, width: 1000, height: 1000)
    }

    // MARK: - Test Helpers

    /// Sets up the mock for equal area projection testing
    /// - Parameter enabled: Whether equal area projection is enabled
    func mockEqualArea(_ enabled: Bool) {
        mockIsEqualArea = enabled
    }

    /// Sets up the mock for percentage-based geometry
    /// - Parameter enabled: Whether percentage-based geometry is enabled
    func mockPercentageMode(_ enabled: Bool) {
        mockIsPercent = enabled
    }

    /// Configures the mock with specific geometry values for testing
    /// - Parameters:
    ///   - maxCount: Maximum count value
    ///   - maxPercent: Maximum percentage value
    ///   - hollowCore: Hollow core size
    ///   - sectorSize: Sector size in degrees
    ///   - startAngle: Starting angle in degrees
    ///   - sectorCount: Number of sectors
    ///   - relativeSize: Relative size of circle rect (0.0-1.0)
    func configureMock(
        maxCount: Int32 = 100,
        maxPercent: Float = 100.0,
        hollowCore: Float = 10.0,
        sectorSize: Float = 10.0,
        startAngle: Float = 0.0,
        sectorCount: Int32 = 36,
        relativeSize: Float = 0.8
    ) {
        mockGeometryMaxCount = maxCount
        mockGeometryMaxPercent = maxPercent
        mockHollowCoreSize = hollowCore
        mockSectorSize = sectorSize
        mockStartingAngle = startAngle
        mockSectorCount = sectorCount
        mockRelativeSizeOfCircleRect = relativeSize
    }

    // MARK: - Overridden Methods

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return mockIsEqualArea == other.mockIsEqualArea &&
            mockIsPercent == other.mockIsPercent &&
            mockGeometryMaxCount == other.mockGeometryMaxCount &&
            abs(mockGeometryMaxPercent - other.mockGeometryMaxPercent) < 0.001 &&
            abs(mockHollowCoreSize - other.mockHollowCoreSize) < 0.001 &&
            abs(mockSectorSize - other.mockSectorSize) < 0.001 &&
            abs(mockStartingAngle - other.mockStartingAngle) < 0.001 &&
            mockSectorCount == other.mockSectorCount &&
            abs(mockRelativeSizeOfCircleRect - other.mockRelativeSizeOfCircleRect) < 0.001
    }

    // MARK: - Debug Description

    override var debugDescription: String {
        """
        MockGeometryController(
          isEqualArea: \(mockIsEqualArea),
          isPercent: \(mockIsPercent),
          maxCount: \(mockGeometryMaxCount),
          maxPercent: \(mockGeometryMaxPercent),
          hollowCore: \(mockHollowCoreSize),
          sectorSize: \(mockSectorSize),
          startAngle: \(mockStartingAngle),
          sectorCount: \(mockSectorCount),
          relativeSize: \(mockRelativeSizeOfCircleRect)
        )
        """
    }
}
