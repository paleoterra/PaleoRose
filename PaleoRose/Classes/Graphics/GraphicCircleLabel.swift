//
//  GraphicCircleLabel.swift
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

@objc class GraphicCircleLabel: Graphic {

    // MARK: - Properties

    // Properties that were inherited from GraphicCircle
    @objc dynamic var isFixedCount: Bool = false
    @objc dynamic var countSetting: Int32 = 0
    @objc dynamic var percentSetting: Float = 0.0
    @objc dynamic var isGeometryPercent: Bool = false
    @objc dynamic var isPercent: Bool = false

    // GraphicCircleLabel specific properties
    @objc dynamic var showLabel: Bool = false
    @objc dynamic var labelAngle: Float = 0.0 {
        didSet {
            calculateGeometry()
        }
    }

    @objc dynamic var labelFont: NSFont? {
        didSet {
            calculateGeometry()
        }
    }

    // Private properties (some exposed for testing)
    @objc dynamic var label: NSMutableAttributedString?
    @objc dynamic var theTransform: NSAffineTransform?
    @objc dynamic var isCore: Bool = false
    private var labelPoint: CGPoint = .zero
    private var labelSize: CGSize = .zero

    // MARK: - Initialization

    @objc(initCoreCircleWithController:) init(coreCircleWithController controller: GraphicGeometrySource) {
        super.init(controller: controller)

        showLabel = false
        labelPoint = CGPoint.zero
        isPercent = controller.isPercent()
        isCore = true
        percentSetting = 0.0
        countSetting = 0

        calculateGeometry()
    }

    @objc override init(controller: GraphicGeometrySource) {
        super.init(controller: controller)

        showLabel = true
        isCore = false
        labelFont = NSFont(name: "Arial-Black", size: 12)
        labelPoint = CGPoint.zero
    }

    // MARK: - Label String Methods

    private func labelString(forPercent percent: Float) -> String {
        String(format: "%3.1f %%", percent * 100.0)
    }

    private func labelString(forFixedCount percent: Float, geometryMaxCount maxCount: Int32) -> String {
        String(format: "%3.1f", percent * Float(maxCount))
    }

    private func labelString(forCount count: Int32) -> String {
        String(format: "%i", count)
    }

    // MARK: - Label and Transform Computation

    @objc func computeLabelText() {
        guard let controller = geometryController else { return }

        isPercent = controller.isPercent()

        let labelText: String = if isPercent {
            labelString(forPercent: percentSetting)
        } else if isFixedCount {
            labelString(forFixedCount: percentSetting, geometryMaxCount: controller.geometryMaxCount())
        } else {
            labelString(forCount: countSetting)
        }

        label = NSMutableAttributedString(string: labelText)

        if let font = labelFont, let label {
            let range = NSRange(location: 0, length: label.length)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: strokeColor as Any
            ]
            label.setAttributes(attributes, range: range)
        }
    }

    @objc func computeTransform() {
        theTransform = NSAffineTransform()
        theTransform?.rotate(byDegrees: 360.0 - CGFloat(labelAngle))
    }

    // MARK: - Helper Methods

    private func drawClosedCircle() -> Bool {
        !showLabel || isCore
    }

    private func circleBasedOnPercent() -> Bool {
        guard let controller = geometryController else { return false }
        return controller.isPercent() || isFixedCount
    }

    // MARK: - Geometry

    @objc override func calculateGeometry() {
        guard let controller = geometryController else { return }

        computeLabelText()
        computeTransform()

        if drawClosedCircle() {
            var drawRect = CGRect.zero
            if circleBasedOnPercent() {
                drawRect = controller.circleRect(forPercent: percentSetting)
            } else {
                drawRect = controller.circleRect(forCount: countSetting)
            }
            drawingPath = NSBezierPath(ovalIn: drawRect)
        } else {
            let radius = if circleBasedOnPercent() {
                Float(controller.radius(ofPercentValue: Double(percentSetting)))
            } else {
                Float(controller.radius(ofCount: countSetting))
            }

            let labelWidth = label?.size().width ?? 0.0
            let angle = controller.degrees(fromRadians: atan((0.52 * labelWidth) / CGFloat(radius)))

            drawingPath = NSBezierPath()
            drawingPath?.appendArc(withCenter: CGPoint.zero,
                                   radius: CGFloat(radius),
                                   startAngle: 90 + angle,
                                   endAngle: 90 - angle)

            let labelHeight = label?.size().height ?? 0.0
            labelPoint = CGPoint(x: -(labelWidth * 0.5),
                                 y: CGFloat(radius) - (labelHeight * 0.5))
        }

        drawingPath?.lineWidth = CGFloat(lineWidth)
    }

    @objc func setGeometryPercent(_ percent: Float) {
        guard let controller = geometryController else { return }
        percentSetting = percent * controller.geometryMaxPercent()
        calculateGeometry()
    }

    // MARK: - Drawing

    @objc override func draw(_ rect: CGRect) {
        computeLabelText()

        guard let path = drawingPath, NSIntersectsRect(rect, path.bounds) else { return }

        NSGraphicsContext.saveGraphicsState()

        strokeColor?.set()
        theTransform?.concat()
        path.stroke()

        if drawsFill {
            fillColor?.set()
            path.fill()
        }

        if showLabel, !isCore, let label {
            label.draw(at: labelPoint)
        }

        NSGraphicsContext.restoreGraphicsState()
        needsDisplay = false
    }

    // MARK: - Settings Export

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var settings = super.graphicSettings()

        settings[GraphicKeyGraphicType] = "LabelCircle"
        settings[GraphicKeyShowLabel] = string(from: showLabel)
        settings[GraphicKeyLabelAngle] = string(from: labelAngle)
        settings[GraphicKeyLabel] = label?.string ?? ""
        settings[GraphicKeyLabelFont] = labelFont
        settings[GraphicKeyIsCore] = string(from: isCore)
        settings[GraphicKeyCountSetting] = string(from: countSetting)
        settings[GraphicKeyPercentSetting] = string(from: percentSetting)
        settings[GraphicKeyGeometryPercent] = string(from: percentSetting)
        settings[GraphicKeyIsGeometryPercent] = string(from: isGeometryPercent)
        settings[GraphicKeyIsPercent] = string(from: isPercent)
        settings[GraphicKeyIsFixedCount] = string(from: isFixedCount)

        return settings
    }
}
