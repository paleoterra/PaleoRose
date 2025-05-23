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

import Cocoa

class XRGraphicHistogram: XRGraphic {
    // MARK: - Properties

    private var histIncrement: Int
    private var percent: CGFloat
    private var count: Int

    // MARK: - Initialization

    init(controller: XRGeometryController, increment: Int, value: NSNumber) {
        histIncrement = increment
        percent = CGFloat(value.floatValue)
        count = value.intValue

        super.init(controller: controller)

        setLineWidth(4.0)
        setDrawsFill(true)
        calculateGeometry()
    }

    // MARK: - Geometry Methods

    override func calculateGeometry() {
        guard let controller = geometryController else { return }

        let size = controller.sectorSize
        let start = controller.startingAngle

        // Calculate angles
        var angle1 = (CGFloat(histIncrement) * size) + (0.5 * size) + start
        if angle1 > 360.0 {
            angle1 -= 360.0
        }

        let path = NSBezierPath()

        if controller.isPercent {
            // Start point
            var radius = controller.radius(ofPercentValue: 0.0)
            var point = NSPoint(x: 0.0, y: radius)
            var targetPoint = controller.rotation(ofPoint: point, byAngle: angle1)
            path.move(to: targetPoint)

            // End point
            radius = controller.radius(ofPercentValue: percent)
            point = NSPoint(x: 0.0, y: radius)
            targetPoint = controller.rotation(ofPoint: point, byAngle: angle1)
            path.line(to: targetPoint)
        } else {
            // Start point
            var radius = controller.radius(ofCount: 0)
            var point = NSPoint(x: 0.0, y: radius)
            var targetPoint = controller.rotation(ofPoint: point, byAngle: angle1)
            path.move(to: targetPoint)

            // End point
            radius = controller.radius(ofCount: count)
            point = NSPoint(x: 0.0, y: radius)
            targetPoint = controller.rotation(ofPoint: point, byAngle: angle1)
            path.line(to: targetPoint)
        }

        path.lineWidth = getLineWidth()
        drawingPath = path
    }

    // MARK: - Settings Dictionary

    override var graphicSettings: [String: Any] {
        var settings = super.graphicSettings

        settings["_histIncrement"] = String(format: "%d", histIncrement)
        settings["_percent"] = String(format: "%f", percent)
        settings["_count"] = String(format: "%d", count)

        return settings
    }
}
