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

class XRGraphicDot: XRGraphic {
    // MARK: - Properties

    private var angleIncrement: Int
    private var totalCount: Int
    private var count: Int
    private var dotSize: CGFloat

    // MARK: - Initialization

    init(controller: XRGeometryController, increment: Int, valueCount: Int, totalCount: Int) {
        angleIncrement = increment
        self.totalCount = totalCount
        count = valueCount
        dotSize = 4.0

        super.init(controller: controller)

        setDrawsFill(true)
        calculateGeometry()
    }

    // MARK: - Geometry Methods

    override func calculateGeometry() {
        guard let controller = geometryController else { return }

        let startAngle = controller.startingAngle
        let step = controller.sectorSize
        let angle = startAngle + (step * (CGFloat(angleIncrement) + 0.5))

        let path = NSBezierPath()
        let dotRect = NSRect(x: 0, y: 0, width: dotSize, height: dotSize)

        if controller.isPercent {
            for index in 0 ..< count {
                let radius = controller.radius(ofPercentValue: CGFloat(index + 1) / CGFloat(totalCount))
                var point = NSPoint(x: 0.0, y: radius)
                point = controller.rotation(ofPoint: point, byAngle: angle)

                let origin = NSPoint(x: point.x - (dotSize * 0.5),
                                     y: point.y - (dotSize * 0.5))
                let rect = NSRect(origin: origin, size: dotRect.size)
                path.appendOval(in: rect)
            }
        } else {
            for index in 0 ..< count {
                let radius = controller.radius(ofCount: index)
                var point = NSPoint(x: 0.0, y: radius)
                point = controller.rotation(ofPoint: point, byAngle: angle)

                let origin = NSPoint(x: point.x - (dotSize * 0.5),
                                     y: point.y - (dotSize * 0.5))
                let rect = NSRect(origin: origin, size: dotRect.size)
                path.appendOval(in: rect)
            }
        }

        drawingPath = path
    }

    // MARK: - Dot Size Methods

    func setDotSize(_ newSize: CGFloat) {
        dotSize = newSize
        calculateGeometry()
    }

    func getDotSize() -> CGFloat {
        dotSize
    }

    // MARK: - Settings Dictionary

    override var graphicSettings: [String: Any] {
        var settings = super.graphicSettings

        settings["_angleIncrement"] = String(format: "%d", angleIncrement)
        settings["_totalCount"] = String(format: "%d", totalCount)
        settings["_count"] = String(format: "%d", count)
        settings["_dotSize"] = String(format: "%f", dotSize)

        return settings
    }
}
