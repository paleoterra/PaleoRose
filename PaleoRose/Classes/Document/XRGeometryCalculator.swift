// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

/// Protocol for objects that can provide geometry calculations
protocol XRGeometryCalculating { /// Calculate circle rect for a given percentage
    func circleRect(forPercent percent: CGFloat) -> NSRect

    /// Calculate circle rect for a geometry percentage
    func circleRect(forGeometryPercent percent: CGFloat) -> NSRect

    /// Calculate circle rect for a count value
    func circleRect(forCount count: Int) -> NSRect

    /// Calculate circle rect for hollow core
    func circleRectForHollowCore() -> NSRect

    /// Calculate radius for a relative percentage
    func radiusOfRelativePercent(_ percent: CGFloat) -> CGFloat

    /// Check if an angle is valid for a spoke
    func angleIsValid(forSpoke angle: CGFloat) -> Bool

    /// Calculate relative position for a point
    func calculateRelativePosition(withPoint point: NSPoint) -> (radius: CGFloat, angle: CGFloat)
}

/// Protocol for objects that can provide geometry settings
protocol XRGeometryConfiguring {
    /// Whether the calculations should be area-based
    var isEqualArea: Bool { get set }

    /// Whether counting should be done by percents or actual counts
    var isPercent: Bool { get set }

    /// Maximum scale for current geometry in counts
    var geometryMaxCount: Int { get set }

    /// Maximum scale for current geometry in percent
    var geometryMaxPercent: CGFloat { get set }

    /// Size in percent of max circle size for hollow core
    var hollowCoreSize: CGFloat { get set }

    /// Sector size in degrees
    var sectorSize: CGFloat { get set }

    /// Starting angle in degrees
    var startingAngle: CGFloat { get set }

    /// Number of sectors
    var sectorCount: Int { get set }
}

/// Struct for managing geometry calculations
enum XRGeometryCalculator {
    // MARK: - Types

    struct CircleParameters {
        let center: NSPoint
        let maxRadius: CGFloat
        let hollowRadius: CGFloat
        let isEqualArea: Bool
    }

    // MARK: - Geometry Calculations

    static func radiusOfCount(_ count: Int, maxCount: Int, parameters: CircleParameters) -> CGFloat {
        guard maxCount > 0 else { return 0 }
        let percent = CGFloat(count) / CGFloat(maxCount)
        return radiusOfRelativePercent(percent, parameters: parameters)
    }

    static func radiusOfPercentValue(_ percent: CGFloat, maxPercent: CGFloat, parameters: CircleParameters) -> CGFloat {
        guard maxPercent > 0 else { return 0 }
        let relativePercent = percent / maxPercent
        return radiusOfRelativePercent(relativePercent, parameters: parameters)
    }

    static func radiusOfRelativePercent(_ percent: CGFloat, parameters: CircleParameters) -> CGFloat {
        let effectiveRadius = parameters.maxRadius - parameters.hollowRadius

        if parameters.isEqualArea {
            let area = percent * (.pi * pow(effectiveRadius, 2))
            return sqrt(area / .pi) + parameters.hollowRadius
        } else {
            return parameters.hollowRadius + effectiveRadius * percent
        }
    }

    static func circleRect(forRadius radius: CGFloat, center: NSPoint) -> NSRect {
        NSRect(x: center.x - radius,
               y: center.y - radius,
               width: radius * 2,
               height: radius * 2)
    }

    // MARK: - Angle Calculations

    static func radians(from degrees: CGFloat) -> CGFloat {
        degrees * .pi / 180.0
    }

    static func degrees(from radians: CGFloat) -> CGFloat {
        radians * 180.0 / .pi
    }

    static func rotationOfPoint(_ point: NSPoint, byAngle angle: CGFloat) -> NSPoint {
        let radians = radians(from: angle)
        let cosAngle = cos(radians)
        let sinAngle = sin(radians)

        return NSPoint(x: point.x * cosAngle - point.y * sinAngle,
                       y: point.x * sinAngle + point.y * cosAngle)
    }

    static func angleIsValid(forSpoke angle: CGFloat, startingAngle: CGFloat, sectorSize: CGFloat) -> Bool {
        let normalizedAngle = (angle - startingAngle).truncatingRemainder(dividingBy: 360.0)
        return normalizedAngle.truncatingRemainder(dividingBy: sectorSize) == 0
    }

    static func calculateRelativePosition(forPoint point: NSPoint, center: NSPoint) -> (radius: CGFloat, angle: CGFloat) {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        let angle = degrees(from: atan2(dy, dx))
        return (radius, angle)
    }
}
