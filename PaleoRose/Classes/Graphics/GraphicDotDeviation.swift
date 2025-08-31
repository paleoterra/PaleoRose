//
//  GraphicDotDeviation.swift
//  PaleoRose
//
//  Created by Cascade on 2025-08-22.
//
//  MIT License
//
//  Copyright (c) 2004 to present Thomas L. Moore.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import AppKit

/// Draws one or more dots at a specific angle to visualize deviation from the mean.
@objc class GraphicDotDeviation: Graphic {

    // MARK: - Public API

    /// The diameter of each dot.
    @objc dynamic var dotSize: Float = 4.0 { didSet { calculateGeometry() } }

    // MARK: - Private State

    private var angleIncrement: Int = 0
    private var totalCount: Int = 0
    private var count: Int = 0
    private var mean: Float = 0.0

    // MARK: - Init

    /// Designated initializer.
    /// - Parameters:
    ///   - controller: Geometry source/controller.
    ///   - increment: Angle increment index for this spoke.
    ///   - count: Observed value count for this spoke.
    ///   - total: Total count for percent calculations.
    ///   - stats: Dictionary containing at least key "mean" as NSNumber/Float.
    @objc init?(controller: GraphicGeometrySource, forIncrement increment: Int32, valueCount count: Int32, totalCount total: Int32, statistics stats: [AnyHashable: Any]) {
        super.init(controller: controller)
        angleIncrement = Int(increment)
        totalCount = Int(total)
        self.count = Int(count)
        if let mean1 = (stats["mean"] as? NSNumber)?.floatValue { mean = mean1 } else { mean = 0 }
        drawsFill = true
        calculateGeometry()
    }

    // MARK: - Geometry

    /// Helper to add a single dot to the path at radius/angle.
    private func addDot(to path: NSBezierPath, dotSize: CGFloat, radius: CGFloat, angle: CGFloat, controller: GraphicGeometrySource) {
        var point = CGPoint(x: 0.0, y: radius)
        point = controller.rotation(of: point, byAngle: Double(angle))
        let rect = CGRect(x: point.x - (dotSize * 0.5), y: point.y - (dotSize * 0.5), width: dotSize, height: dotSize)
        path.appendOval(in: rect)
    }

    /// Recalculate all dot positions based on current state.
    @objc override func calculateGeometry() {
        guard let controller = geometryController else {
            return
        }

        let path = NSBezierPath()
        path.lineWidth = CGFloat(lineWidth)

        let angle = calculateDotAngle(controller: controller)
        let deviationData = calculateDeviationData()

        addDeviationDots(to: path, angle: angle, deviationData: deviationData, controller: controller)

        drawingPath = path
    }

    // MARK: - Private Helper Methods

    private func calculateDotAngle(controller: GraphicGeometrySource) -> CGFloat {
        let startAngle = CGFloat(controller.startingAngle())
        let step = CGFloat(controller.sectorSize())
        return startAngle + step * (CGFloat(angleIncrement) + 0.5)
    }

    private struct DeviationData {
        let excess: Int
        let shortfall: Int
        let isAboveMean: Bool
        let hasDeviation: Bool
    }

    private func calculateDeviationData() -> DeviationData {
        let currentCount = Float(count)
        let excess = Int(ceil(currentCount - mean))
        let shortfall = Int(ceil(mean - currentCount))
        let isAboveMean = currentCount > mean
        let hasDeviation = excess > 0 || shortfall > 0

        return DeviationData(
            excess: excess,
            shortfall: shortfall,
            isAboveMean: isAboveMean,
            hasDeviation: hasDeviation
        )
    }

    private func addDeviationDots(to path: NSBezierPath, angle: CGFloat, deviationData: DeviationData, controller: GraphicGeometrySource) {
        if controller.isPercent() {
            addPercentDeviationDots(to: path, angle: angle, deviationData: deviationData, controller: controller)
        } else {
            addCountDeviationDots(to: path, angle: angle, deviationData: deviationData, controller: controller)
        }
    }

    private func addPercentDeviationDots(to path: NSBezierPath, angle: CGFloat, deviationData: DeviationData, controller: GraphicGeometrySource) {
        if deviationData.isAboveMean {
            addExcessPercentDots(to: path, angle: angle, excess: deviationData.excess, controller: controller)
        } else {
            addShortfallPercentDots(to: path, angle: angle, shortfall: deviationData.shortfall, controller: controller)
        }
    }

    private func addCountDeviationDots(to path: NSBezierPath, angle: CGFloat, deviationData: DeviationData, controller: GraphicGeometrySource) {
        if deviationData.isAboveMean {
            addExcessCountDots(to: path, angle: angle, excess: deviationData.excess, controller: controller)
        } else {
            addShortfallCountDots(to: path, angle: angle, shortfall: deviationData.shortfall, controller: controller)
        }
    }

    private func addExcessPercentDots(to path: NSBezierPath, angle: CGFloat, excess: Int, controller: GraphicGeometrySource) {
        guard excess > 0 else {
            return
        }

        for index in 0 ..< excess {
            let value = Double(Float(index + 1) + floor(mean)) / Double(totalCount)
            let radius = CGFloat(controller.radius(ofPercentValue: value))
            addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
        }
    }

    private func addShortfallPercentDots(to path: NSBezierPath, angle: CGFloat, shortfall: Int, controller: GraphicGeometrySource) {
        if shortfall > 0 {
            for index in 0 ..< shortfall {
                let value = Double(Float(Int(ceil(mean)) - (index + 1))) / Double(totalCount)
                let radius = CGFloat(controller.radius(ofPercentValue: value))
                addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
            }
        } else {
            addSinglePercentDot(to: path, angle: angle, controller: controller)
        }
    }

    private func addExcessCountDots(to path: NSBezierPath, angle: CGFloat, excess: Int, controller: GraphicGeometrySource) {
        guard excess > 0 else {
            return
        }

        for index in 0 ..< excess {
            let radius = CGFloat(controller.radius(ofCount: Int32(Float(index + 1) + floor(mean))))
            addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
        }
    }

    private func addShortfallCountDots(to path: NSBezierPath, angle: CGFloat, shortfall: Int, controller: GraphicGeometrySource) {
        if shortfall > 0 {
            for index in 0 ..< shortfall {
                let value = Int32(Int(ceil(mean)) - (index + 1))
                let radius = CGFloat(controller.radius(ofCount: value))
                addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
            }
        } else {
            // NOTE: Preserving Objective-C behavior that used percent radius call here.
            addSinglePercentDot(to: path, angle: angle, controller: controller)
        }
    }

    private func addSinglePercentDot(to path: NSBezierPath, angle: CGFloat, controller: GraphicGeometrySource) {
        let value = Double(Int(ceil(mean))) / Double(totalCount)
        let radius = CGFloat(controller.radius(ofPercentValue: value))
        addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
    }

    // MARK: - Settings

    /// Returns the graphic's settings merged with superclass settings.
    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var parent = super.graphicSettings()
        let classDict: [AnyHashable: Any] = [
            GraphicKeyGraphicType: "DotDeviation",
            GraphicKeyAngleIncrement: string(from: Int32(angleIncrement)),
            GraphicKeyTotalCount: string(from: Int32(totalCount)),
            GraphicKeyCount: string(from: Int32(count)),
            GraphicKeyDotSize: string(from: dotSize),
            GraphicKeyMean: string(from: mean)
        ]
        parent.merge(classDict) { _, new in new }
        return parent
    }
}
