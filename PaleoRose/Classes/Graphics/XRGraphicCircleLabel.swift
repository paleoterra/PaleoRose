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

class XRGraphicCircleLabel: XRGraphicCircle {
    // MARK: - Properties

    private var showLabel: Bool = false
    private var labelAngle: CGFloat = 0.0
    private var label: NSMutableAttributedString?
    private var labelFont: NSFont?
    private var transform: AffineTransform?
    private var labelPoint: NSPoint = .zero
    private var labelSize: NSSize = .zero
    private var isCore: Bool = false

    // MARK: - Initialization

    override init(controller: XRGeometryController) {
        super.init(controller: controller)
        showLabel = true
        isCore = false
        labelFont = NSFont(name: "Arial-Black", size: 12)
        labelPoint = .zero
    }

    override convenience init(coreCircleWithController controller: XRGeometryController) {
        self.init(controller: controller)
        showLabel = false
        labelPoint = .zero
        isCore = true
        percentSetting = 0.0
        setCountSetting(0)
        calculateGeometry()
    }

    // MARK: - Font Methods

    func setFont(_ newFont: NSFont) {
        labelFont = newFont
        calculateGeometry()
    }

    func getFont() -> NSFont? {
        labelFont
    }

    // MARK: - Label Methods

    func setShowLabel(_ show: Bool) {
        showLabel = show
    }

    func getShowLabel() -> Bool {
        showLabel
    }

    func setLabelAngle(_ newAngle: CGFloat) {
        labelAngle = newAngle
        calculateGeometry()
    }

    func getLabelAngle() -> CGFloat {
        labelAngle
    }

    private func computeLabelText() {
        guard let controller = geometryController else { return }

        isPercent = controller.isPercent

        let labelText = if isPercent {
            String(format: "%3.1f %c", percentSetting * 100.0, "%")
        } else if getIsFixed() {
            String(format: "%3.1f", percentSetting * CGFloat(controller.geometryMaxCount))
        } else {
            String(format: "%d", getCountSetting())
        }

        label = NSMutableAttributedString(string: labelText)

        if let font = labelFont {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: getStrokeColor()
            ]
            label?.setAttributes(attributes, range: NSRange(location: 0, length: label?.length ?? 0))
        }
    }

    private func computeTransform() {
        transform = AffineTransform.identity.rotated(by: .pi * (360.0 - labelAngle) / 180.0)
    }

    override func calculateGeometry() {
        computeLabelText()
        computeTransform()

        guard let controller = geometryController else { return }

        if !showLabel || isCore {
            if (controller.isPercent || getIsFixed()) || (!controller.isPercent && getIsFixed()) {
                drawingPath = NSBezierPath(ovalIn: controller.circleRect(forPercent: percentSetting))
            } else {
                drawingPath = NSBezierPath(ovalIn: controller.circleRect(forCount: getCountSetting()))
            }
        } else {
            let radius: CGFloat = if (controller.isPercent || getIsFixed()) || (!controller.isPercent && getIsFixed()) {
                controller.radius(ofPercentValue: percentSetting)
            } else {
                controller.radius(ofCount: getCountSetting())
            }

            if let labelSize = label?.size() {
                let angle = controller.degrees(fromRadians: atan((0.52 * labelSize.width) / radius))
                drawingPath = NSBezierPath()
                drawingPath?.appendArc(withCenter: .zero,
                                       radius: radius,
                                       startAngle: 90 + angle,
                                       endAngle: 90 - angle)
                labelPoint = NSPoint(x: 0 - (0.5 * labelSize.width),
                                     y: radius - (0.5 * labelSize.height))
            }
        }

        drawingPath?.lineWidth = getLineWidth()
    }

    override func draw(in rect: NSRect) {
        computeLabelText()

        guard let path = drawingPath,
              NSIntersectsRect(rect, path.bounds) else { return }

        NSGraphicsContext.saveGraphicsState()

        getStrokeColor().set()

        transform?.transform()
        path.stroke()

        if getDrawsFill() {
            getFillColor().set()
            path.fill()
        }

        if showLabel, !isCore {
            label?.draw(at: labelPoint)
        }

        NSGraphicsContext.restoreGraphicsState()
        setNeedsDisplay(false)
    }
}
