//
//  GraphicHistogram.swift
//  PaleoRose
//
//  Created by Migration Assistant on 2025-08-29.
//
// MIT License
//
// Copyright (c) 2004 to present Thomas L. Moore.
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

import AppKit

@objc class GraphicHistogram: Graphic {

    // MARK: - Properties

    @objc dynamic var histIncrement: Int32
    @objc dynamic var percent: Float
    @objc dynamic var count: Int32

    // MARK: - Initialization

    @available(*, unavailable, message: "Use init(controller:forIncrement:forValue:) instead")
    @objc override init(controller: GraphicGeometrySource) {
        fatalError("Use init(controller:forIncrement:forValue:) instead")
    }

    @objc init(controller: GraphicGeometrySource, forIncrement increment: Int32, forValue value: NSNumber) {
        histIncrement = increment
        percent = value.floatValue
        count = value.int32Value

        super.init(controller: controller)

        lineWidth = 4.0
        drawsFill = true
        calculateGeometry()
    }

    // MARK: - Geometry Calculation

    @objc override func calculateGeometry() {
        guard let controller = geometryController else {
            return
        }

        let size = Float(controller.sectorSize())
        let start = Float(controller.startingAngle())
        let isPercent = controller.isPercent()

        var angle1 = (Float(histIncrement) * size) + (0.5 * size) + start
        angle1 = restrictAngle(toACircle: angle1)

        drawingPath = NSBezierPath()

        // Calculate start point (center)
        let startRadius = isPercent ?
            CGFloat(controller.radius(ofPercentValue: 0.0)) :
            CGFloat(controller.radius(ofCount: 0))
        let startPoint = CGPoint(x: 0.0, y: startRadius)
        let startTargetPoint = controller.rotation(of: startPoint, byAngle: Double(angle1))
        drawingPath?.move(to: startTargetPoint)

        // Calculate end point (data value)
        let endRadius = isPercent ?
            CGFloat(controller.radius(ofPercentValue: Double(percent))) :
            CGFloat(controller.radius(ofCount: Int32(count)))
        let endPoint = CGPoint(x: 0.0, y: endRadius)
        let endTargetPoint = controller.rotation(of: endPoint, byAngle: Double(angle1))
        drawingPath?.line(to: endTargetPoint)

        drawingPath?.lineWidth = CGFloat(lineWidth)
    }

    // MARK: - Settings Export

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var settings = super.graphicSettings()

        settings[GraphicKeyGraphicType] = "Histogram"
        settings[GraphicKeyHistogramIncrement] = string(from: histIncrement)
        settings[GraphicKeyPercent] = string(from: percent)
        settings[GraphicKeyCount] = string(from: count)

        return settings
    }
}
