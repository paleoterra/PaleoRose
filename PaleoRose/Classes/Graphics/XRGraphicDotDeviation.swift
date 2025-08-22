//
//  XRGraphicDotDeviation.swift
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
@MainActor
@objc class XRGraphicDotDeviation: XRGraphic {

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
    @objc
    init?(controller: GraphicGeometrySource, forIncrement increment: Int32, valueCount count: Int32, totalCount total: Int32, statistics stats: [AnyHashable: Any]) {
        super.init(controller: controller)
        angleIncrement = Int(increment)
        totalCount = Int(total)
        self.count = Int(count)
        if let m = (stats["mean"] as? NSNumber)?.floatValue { mean = m } else { mean = 0 }
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
        guard let controller = geometryController else { return }

        let startAngle = CGFloat(controller.startingAngle())
        let step = CGFloat(controller.sectorSize())
        let angle = startAngle + step * (CGFloat(angleIncrement) + 0.5)

        let path = NSBezierPath()
        path.lineWidth = CGFloat(lineWidth)

        let m = mean
        let count = Float(count)
        let excess = Int(ceil(count - m))
        let shortfall = Int(ceil(m - count))

        if controller.isPercent() {
            if count > m {
                if excess > 0 {
                    for i in 0 ..< excess {
                        let value = Double(Float(i + 1) + floor(m)) / Double(totalCount)
                        let radius = CGFloat(controller.radius(ofPercentValue: value))
                        addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                    }
                }
            } else {
                if shortfall > 0 {
                    for i in 0 ..< shortfall {
                        let value = Double(Float(Int(ceil(m)) - (i + 1))) / Double(totalCount)
                        let radius = CGFloat(controller.radius(ofPercentValue: value))
                        addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                    }
                } else {
                    let value = Double(Int(ceil(m))) / Double(totalCount)
                    let radius = CGFloat(controller.radius(ofPercentValue: value))
                    addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                }
            }
        } else {
            if count > m {
                if excess > 0 {
                    for i in 0 ..< excess {
                        let radius = CGFloat(controller.radius(ofCount: Int32(Float(i + 1) + floor(m))))
                        addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                    }
                }
            } else {
                if shortfall > 0 {
                    for i in 0 ..< shortfall {
                        let value = Int32(Int(ceil(m)) - (i + 1))
                        let radius = CGFloat(controller.radius(ofCount: value))
                        addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                    }
                } else {
                    // NOTE: Preserving Objective-C behavior that used percent radius call here.
                    let value = Double(Int(ceil(m))) / Double(totalCount)
                    let radius = CGFloat(controller.radius(ofPercentValue: value))
                    addDot(to: path, dotSize: CGFloat(dotSize), radius: radius, angle: angle, controller: controller)
                }
            }
        }

        drawingPath = path
    }

    // MARK: - Settings

    /// Returns the graphic's settings merged with superclass settings.
    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var parent = super.graphicSettings()
        let classDict: [AnyHashable: Any] = [
            "GraphicType": "DotDeviation",
            "_angleIncrement": string(from: Int32(angleIncrement)),
            "_totalCount": string(from: Int32(totalCount)),
            "_count": string(from: Int32(count)),
            "_dotSize": string(from: dotSize),
            "_mean": string(from: mean)
        ]
        parent.merge(classDict) { _, new in new }
        return parent
    }
}
