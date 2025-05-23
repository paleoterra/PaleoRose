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

class XRGraphicKite: XRGraphic {
    // MARK: - Properties

    private var angles: [NSNumber]
    private var values: [NSNumber]

    // MARK: - Initialization

    init(controller: XRGeometryController, angles: [NSNumber], values: [NSNumber]) {
        self.angles = angles
        self.values = values

        super.init(controller: controller)

        setDrawsFill(true)
        setFillColor(.white)
        calculateGeometry()
    }

    // MARK: - Geometry Methods

    override func calculateGeometry() {
        guard let controller = geometryController else { return }

        let path = NSBezierPath()

        if let lastValue = values.last, let lastAngle = angles.last {
            // Initial point setup
            let radius: CGFloat = if controller.isPercent {
                controller.radius(ofPercentValue: lastValue.doubleValue)
            } else {
                controller.radius(ofCount: lastValue.intValue)
            }

            var point = NSPoint(x: 0.0, y: radius)
            var targetPoint = controller.rotation(ofPoint: point, byAngle: lastAngle.doubleValue)
            path.move(to: targetPoint)

            // Draw lines to each point
            for index in 0 ..< angles.count {
                let radius: CGFloat = if controller.isPercent {
                    controller.radius(ofPercentValue: values[index].doubleValue)
                } else {
                    controller.radius(ofCount: values[index].intValue)
                }

                point = NSPoint(x: 0.0, y: radius)
                targetPoint = controller.rotation(ofPoint: point, byAngle: angles[i].doubleValue)
                path.line(to: targetPoint)
            }

            // Add hollow core if needed
            if controller.hollowCoreSize > 0.0 {
                let centroid = NSPoint(x: 0.0, y: 0.0)
                let coreRadius: CGFloat = if controller.isPercent {
                    controller.radius(ofPercentValue: 0.0)
                } else {
                    controller.radius(ofCount: 0)
                }

                let coreRect = NSRect(x: centroid.x - coreRadius,
                                      y: centroid.y - coreRadius,
                                      width: 2 * coreRadius,
                                      height: 2 * coreRadius)
                path.appendOval(in: coreRect)
            }
        }

        drawingPath = path
    }
}
