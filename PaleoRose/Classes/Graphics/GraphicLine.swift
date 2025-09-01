//
//  GraphicLine.swift
//  PaleoRose
//
//  Created by Migration Assistant on 2025-08-28.
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

// MARK: - Swift Enums with Objective-C compatibility

// swiftlint:disable type_body_length file_length
@objc public enum GraphicLineTickType: Int32 {
    case major = 2
    case minor = 1
    case noTick = 0
}

@objc public enum GraphicLineNumberAlign: Int32 {
    case angle = 1
    case horizontal = 0
}

@objc public enum GraphicLineNumberCompassPoint: Int32 {
    case numbersOnly = 0
    case points = 1
}

@objc public enum GraphicLineNumberingOrder: Int32 {
    case order360 = 0
    case quad = 1
}

// MARK: - Main Class

@objc class GraphicLine: Graphic {

    // MARK: - Properties (Swift enum-based)

    // Private enum storage
    private var tickTypeEnum: GraphicLineTickType = .noTick
    private var spokeNumberAlignEnum: GraphicLineNumberAlign = .horizontal
    private var spokeNumberCompassPointEnum: GraphicLineNumberCompassPoint = .points
    private var spokeNumberOrderEnum: GraphicLineNumberingOrder = .quad

    // Objective-C compatible Int32 computed properties
    @objc dynamic var tickType: Int32 {
        get { tickTypeEnum.rawValue }
        set {
            tickTypeEnum = GraphicLineTickType(rawValue: newValue) ?? .noTick
            calculateGeometry()
        }
    }

    @objc dynamic var spokeNumberAlign: Int32 {
        get { spokeNumberAlignEnum.rawValue }
        set {
            spokeNumberAlignEnum = GraphicLineNumberAlign(rawValue: newValue) ?? .horizontal
            setLineLabel()
            calculateGeometry()
        }
    }

    @objc dynamic var spokeNumberCompassPoint: Int32 {
        get { spokeNumberCompassPointEnum.rawValue }
        set {
            spokeNumberCompassPointEnum = GraphicLineNumberCompassPoint(rawValue: newValue) ?? .points
            setLineLabel()
            calculateGeometry()
        }
    }

    @objc dynamic var spokeNumberOrder: Int32 {
        get { spokeNumberOrderEnum.rawValue }
        set {
            spokeNumberOrderEnum = GraphicLineNumberingOrder(rawValue: newValue) ?? .quad
            setLineLabel()
            calculateGeometry()
        }
    }

    // Other properties
    @objc dynamic var showTick: Bool = false {
        didSet { calculateGeometry() }
    }

    @objc dynamic var spokePointOnly: Bool = false {
        didSet {
            setLineLabel()
            calculateGeometry()
        }
    }

    @objc dynamic var showLabel: Bool = true {
        didSet {
            setLineLabel()
            calculateGeometry()
        }
    }

    @objc dynamic var spokeAngle: Float = 0.0 {
        didSet {
            setLineLabel()
            calculateGeometry()
        }
    }

    @objc dynamic var font: NSFont? = NSFont(name: "Arial-Black", size: 12) {
        didSet {
            setLineLabel()
            calculateGeometry()
        }
    }

    private var relativePercent: Float = 1.0
    @objc var lineLabel: NSMutableAttributedString?
    var labelTransform: CGAffineTransform?

    // MARK: - Initialization

    @objc override init(controller: GraphicGeometrySource) {
        super.init(controller: controller)
        setupInitialValues()
        setLineLabel()
        calculateGeometry()
    }

    private func setupInitialValues() {
        tickTypeEnum = .noTick
        showTick = false
        spokePointOnly = false
        spokeNumberAlignEnum = .horizontal
        showLabel = true
        spokeNumberCompassPointEnum = .points
        spokeNumberOrderEnum = .quad
        spokeAngle = 0.0
        font = NSFont(name: "Arial-Black", size: 12)
        relativePercent = 1.0
    }

    // MARK: - Geometry Calculation

    @objc override func calculateGeometry() {
        guard let controller = geometryController else {
            return
        }

        drawingPath = NSBezierPath()

        // Calculate line from center to outer point
        let innerRadius = CGFloat(controller.radius(ofRelativePercent: 0.0))
        let outerRadius = calculateOuterRadius()

        let innerPoint = pointAtRadius(innerRadius, angle: CGFloat(spokeAngle))
        let outerPoint = pointAtRadius(outerRadius, angle: CGFloat(spokeAngle))

        drawingPath?.move(to: innerPoint)
        drawingPath?.line(to: outerPoint)
        drawingPath?.lineWidth = CGFloat(lineWidth)

        calculateLabelTransform()
    }

    private func calculateOuterRadius() -> CGFloat {
        guard let controller = geometryController else {
            return 0
        }
        if !showTick {
            return CGFloat(controller.radius(ofRelativePercent: Double(relativePercent)))
        }
        switch tickTypeEnum {
        case .noTick:
            return CGFloat(controller.radius(ofRelativePercent: Double(relativePercent)))

        case .minor:
            return CGFloat(controller.radius(ofRelativePercent: Double(relativePercent + 0.05)))

        case .major:
            return CGFloat(controller.unrestrictedRadius(ofRelativePercent: Double(relativePercent + 0.1)))
        }
    }

    private func pointAtRadius(_ radius: CGFloat, angle: CGFloat) -> CGPoint {
        guard let controller = geometryController else {
            return CGPoint.zero
        }
        let point = CGPoint(x: 0.0, y: radius)
        return controller.rotation(of: point, byAngle: Double(angle))
    }

    // MARK: - Label Handling

    private func setLineLabel() {
        if spokePointOnly {
            handleSpokePointOnlyLabel()
        } else if spokeNumberCompassPointEnum == .points, isCardinalAngle(spokeAngle) {
            setCompassPointLabel()
        } else if spokeNumberOrderEnum == .quad {
            setQuadrantBasedLabel()
        } else {
            setAngleBasedLabel()
        }
        calculateLabelTransform()
    }

    private func handleSpokePointOnlyLabel() {
        if spokeNumberCompassPointEnum == .points {
            if isCardinalAngle(spokeAngle) {
                setCompassPointLabel()
                return
            }
        } else if isCardinalAngle(spokeAngle) {
            setAngleBasedLabel()
            return
        }

        // For non-cardinal angles in spokePointOnly mode, just set empty label
        // Don't modify showLabel here to avoid recursion
        lineLabel = NSMutableAttributedString(string: "")
    }

    private func isCardinalAngle(_ angle: Float) -> Bool {
        let cardinalAngles: [Float] = [0.0, 90.0, 180.0, 270.0, 360.0]
        return cardinalAngles.contains(angle)
    }

    private func setCompassPointLabel() {
        let compassPoint = switch spokeAngle {
        case 0.0, 360.0:
            "N"

        case 90.0:
            "E"

        case 180.0:
            "S"

        case 270.0:
            "W"

        default:
            "N"
        }
        lineLabel = NSMutableAttributedString(string: compassPoint)
    }

    private func setQuadrantBasedLabel() {
        let angle = Double(spokeAngle)
        let quadrantAngle: Double = if angle <= 90.0 {
            angle
        } else if angle <= 180.0 {
            180.0 - angle
        } else if angle <= 270.0 {
            angle - 180.0
        } else {
            360.0 - angle
        }

        setLabelForAngle(quadrantAngle)
    }

    private func setAngleBasedLabel() {
        setLabelForAngle(Double(spokeAngle))
    }

    private func setLabelForAngle(_ angle: Double) {
        let labelString = if angle == floor(angle) {
            String(format: "%.0f", angle)
        } else {
            String(format: "%.1f", angle)
        }
        lineLabel = NSMutableAttributedString(string: labelString)
    }

    // MARK: - Label Transform

    private func calculateLabelTransform() {
        guard let label = lineLabel, let font else {
            return
        }

        // Apply font and color attributes
        let range = NSRange(location: 0, length: label.length)
        label.setAttributes([
            .font: font,
            .foregroundColor: strokeColor ?? NSColor.black
        ], range: range)

        labelTransform = CGAffineTransform.identity

        if spokeNumberAlignEnum == .horizontal {
            calculateHorizontalTransform()
        } else {
            calculateParallelTransform()
        }
    }

    private func calculateHorizontalTransform() {
        guard
            let controller = geometryController,
            let label = lineLabel,
            let transform = labelTransform
        else {
            return
        }

        let labelSize = label.size()
        let displacement = CGFloat(controller.unrestrictedRadius(ofRelativePercent: Double(relativePercent + 0.2)))
        let rotationAngle = CGFloat(spokeAngle - 90.0)

        labelTransform = transform.translatedBy(x: -0.5 * labelSize.width, y: -0.5 * labelSize.height)
        labelTransform = labelTransform?.rotated(by: -rotationAngle * .pi / 180.0)
        labelTransform = labelTransform?.translatedBy(x: displacement, y: 0.0)
        labelTransform = labelTransform?.rotated(by: rotationAngle * .pi / 180.0)
    }

    private func calculateParallelTransform() {
        guard
            let controller = geometryController,
            let label = lineLabel,
            let transform = labelTransform
        else {
            return
        }

        let labelSize = label.size()
        let displacement = CGFloat(controller.unrestrictedRadius(ofRelativePercent: Double(relativePercent + 0.1)))
        let rotationAngle = CGFloat(90.0 - spokeAngle)

        if spokeAngle == 0.0 {
            labelTransform = transform.translatedBy(x: -0.5 * labelSize.width, y: displacement)
        } else if spokeAngle == 180.0 {
            labelTransform = transform.translatedBy(x: -0.5 * labelSize.width, y: -(displacement + labelSize.height))
        } else {
            if spokeAngle > 180.0 {
                labelTransform = transform.rotated(by: (rotationAngle - 180.0) * .pi / 180.0)
                labelTransform = labelTransform?.translatedBy(x: -(displacement + labelSize.width), y: 0.0)
                labelTransform = labelTransform?.translatedBy(x: 0.0, y: -0.5 * labelSize.height)
            } else {
                labelTransform = transform.rotated(by: rotationAngle * .pi / 180.0)
                labelTransform = labelTransform?.translatedBy(x: displacement, y: 0.0)
                labelTransform = labelTransform?.translatedBy(x: 0.0, y: -0.5 * labelSize.height)
            }
        }
    }

    // MARK: - Drawing

    @objc override func draw(_ rect: CGRect) {
        guard let path = drawingPath else {
            return
        }

        if rect.intersects(path.bounds) {
            NSGraphicsContext.saveGraphicsState()

            strokeColor?.set()
            path.stroke()

            if drawsFill {
                fillColor?.set()
                path.fill()
            }

            if showLabel, let transform = labelTransform, let label = lineLabel {
                if let context = NSGraphicsContext.current?.cgContext {
                    context.concatenate(transform)
                }
                label.draw(at: CGPoint.zero)
            }

            NSGraphicsContext.restoreGraphicsState()
            needsDisplay = false
        }
    }

    // MARK: - Settings Export

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var settings = super.graphicSettings()

        settings[GraphicKeyGraphicType] = "Line"
        settings[GraphicKeyTickType] = string(from: tickType)
        settings[GraphicKeySpokeNumberCompassPoint] = string(from: spokeNumberCompassPoint)
        settings[GraphicKeyShowLabel] = string(from: showLabel)
        settings[GraphicKeyLineWidth] = string(from: lineWidth)
        settings[GraphicKeyRelativePercent] = string(from: relativePercent)
        settings[GraphicKeyShowTick] = string(from: showTick)
        settings[GraphicKeySpokeNumberOrder] = string(from: spokeNumberOrder)
        settings[GraphicKeyLineLabel] = lineLabel?.string ?? "N"
        settings[GraphicKeyFillColor] = fillColor ?? NSColor.black
        settings[GraphicKeyAngleSetting] = string(from: spokeAngle)
        settings[GraphicKeySpokeNumberAlignment] = string(from: spokeNumberAlign)
        settings[GraphicKeyStrokeColor] = strokeColor ?? NSColor.black
        settings[GraphicKeyCurrentFont] = font ?? NSFont(name: "Arial-Black", size: 12)!

        return settings
    }
}

// swiftlint:enable type_body_length file_length
