//
//  XRGraphicPetal.swift
//  PaleoRose
//
//  Created by Cascade on 2025-08-18.
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

/// A petal graphic drawn using the provided geometry controller.
@MainActor
@objc class XRGraphicPetal: XRGraphic {

    /// Keep the NSBezierPath's line width synced when the lineWidth changes.
    override var lineWidth: Float {
        didSet { drawingPath?.lineWidth = CGFloat(lineWidth) }
    }

    /// Ensure newly assigned paths get the current line width.
    override var drawingPath: NSBezierPath? {
        didSet { drawingPath?.lineWidth = CGFloat(lineWidth) }
    }

    // MARK: - Private State

    private var petalIncrement: Int = 0
    private var maxRadius: Float = 0.0
    private var percent: Float = 0.0
    private var count: Int32 = 0

    // MARK: - Public API

    // No default init; use designated initializer below.

    /// Designated initializer.
    /// - Parameters:
    ///   - controller: The geometry controller used to compute drawing geometry.
    ///   - forIncrement: The petal increment index.
    ///   - forValue: The value for this petal (interpreted as count or percent by the controller).
    @objc
    init?(controller: GraphicGeometrySource, forIncrement increment: Int32, forValue aNumber: NSNumber) {
        super.init(controller: controller)
        petalIncrement = Int(increment)
        percent = aNumber.floatValue
        count = aNumber.int32Value
        drawsFill = true
        calculateGeometry()
    }

    private func calculateAngles(petalIncrement: Int32, size: CGFloat, start: CGFloat) -> [CGFloat] {
        [
            CGFloat(
                restrictAngle(
                    toACircle: Float(CGFloat(petalIncrement) * size + start)
                )
            ),
        ]
    }

    /// Recalculate geometry when external changes require it.
    @objc override func calculateGeometry() {
        guard let controller = geometryController else { return }

        // step 1. find the angles
        let size = CGFloat(controller.sectorSize())
        let start = CGFloat(controller.startingAngle())

        let angle1Polar = (CGFloat(petalIncrement) * size + start).normalizePositiveAngle()
        let angle2Polar = (angle1Polar + size).normalizePositiveAngle()

        let angle1Canvas = angle1Polar.cgAngleFromPolar().normalizePositiveAngle()
        let angle2Canvas = angle2Polar.cgAngleFromPolar().normalizePositiveAngle()

        let isPercent = controller.isPercent()

        let radius1: CGFloat = isPercent ? CGFloat(controller.radius(ofPercentValue: 0.0)) : CGFloat(
            controller.radius(ofCount: 0)
        )
        let radius2: CGFloat = isPercent ? CGFloat(controller.radius(ofPercentValue: Double(percent))) : CGFloat(
            controller.radius(ofCount: count)
        )

        let pivotPoint = CGPoint(x: 0, y: 0)
        let startPoint = CGPoint(x: 0.0, y: radius1)
        let outerPoint = CGPoint(x: 0.0, y: radius2)

        let path = NSBezierPath()
        path.lineWidth = CGFloat(lineWidth)
        path
            .move(
                to: controller.rotation(of: startPoint, byAngle: Double(angle1Polar))
            )
        path
            .line(
                to: controller.rotation(of: outerPoint, byAngle: Double(angle1Polar))
            )
        path.appendArc(withCenter: pivotPoint, radius: radius2, startAngle: angle1Canvas, endAngle: angle2Canvas, clockwise: true)
        path
            .line(
                to: controller.rotation(of: startPoint, byAngle: Double(angle2Polar))
            )
        path.appendArc(withCenter: pivotPoint, radius: radius1, startAngle: angle2Canvas, endAngle: angle1Canvas, clockwise: false)

        drawingPath = path
    }

    /// Returns the graphic's settings merged with superclass settings.
    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var parent = super.graphicSettings()
        // Keys match those used throughout the ObjC code and tests.
        let classDict: [AnyHashable: Any] = [
            "GraphicType": "Petal",
            "_petalIncrement": string(from: Int32(petalIncrement)),
            "_maxRadius": string(from: maxRadius),
            "_percent": string(from: percent),
            "_count": string(from: Int32(count))
        ]
        parent.merge(classDict) { _, new in new }
        return parent
    }
}
