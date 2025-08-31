//
//  GraphicKite.swift
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

@objc class GraphicKite: Graphic {

    private var angles: [Double] = []
    private var values: [Double] = []

    @objc
    init?(controller: GraphicGeometrySource, angles: [Double], values: [Double]) {
        super.init(controller: controller)
        self.angles = angles
        self.values = values
        drawsFill = true
        fillColor = NSColor(calibratedWhite: 1.0, alpha: 1.0)
        calculateGeometry()
    }

    /// ObjC compatibility: match `-initWithController:withAngles:forValues:`
    @objc(initWithController:withAngles:forValues:)
    convenience init?(controller: GraphicGeometrySource, withAngles angles: [NSNumber], forValues values: [NSNumber]) {
        self.init(
            controller: controller,
            angles: angles.map(\.doubleValue),
            values: values.map(\.doubleValue)
        )
    }

    // MARK: - Geometry

    @objc override func calculateGeometry() {
        precondition(angles.count == values.count, "angles and values must match")
        let path = NSBezierPath()
        drawingPath = path
        drawKiteOutline()
        drawHollowCoreIfNeeded()
    }

    private func drawKiteOutline() {
        guard !angles.isEmpty, !values.isEmpty else { return }
        var radius = radiusForValue(values.last!)
        var lastAngle = angles.last!
        let startPoint = point(radius: radius, atAngle: lastAngle)
        drawingPath?.move(to: startPoint)
        for index in 0 ..< angles.count {
            radius = radiusForValue(values[index])
            let point = point(radius: radius, atAngle: angles[index])
            drawingPath?.line(to: point)
        }
    }

    private func drawHollowCoreIfNeeded() {
        guard let controller = geometryController else { return }
        if controller.hollowCoreSize() <= 0.0 { return }
        let radius = radiusForValue(0.0)
        let centroid = CGPoint.zero
        let coreRect = CGRect(x: centroid.x - radius, y: centroid.y - radius, width: radius * 2.0, height: radius * 2.0)
        drawingPath?.appendOval(in: coreRect)
    }

    private func point(radius: Double, atAngle angle: Double) -> CGPoint {
        guard let controller = geometryController else { return .zero }
        var point = CGPoint(x: 0.0, y: radius)
        point = controller.rotation(of: point, byAngle: angle)
        return point
    }

    private func radiusForValue(_ value: Double) -> CGFloat {
        guard let controller = geometryController else { return 0 }
        if controller.isPercent() {
            return CGFloat(controller.radius(ofPercentValue: value))
        } else {
            return CGFloat(controller.radius(ofCount: Int32(value)))
        }
    }

    // MARK: - Settings

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var parent = super.graphicSettings()
        parent[GraphicKeyGraphicType] = "Kite"
        return parent
    }
}
