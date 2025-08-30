//
//  XRGraphic.swift
//  PaleoRose
//
//  Created by Migration Assistant on 2025-08-30.
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

// MARK: - String Constants

let XRGraphicKeyGraphicType = "GraphicType"
let XRGraphicKeyStrokeColor = "_strokeColor"
let XRGraphicKeyFillColor = "_fillColor"
let XRGraphicKeyLineWidth = "_lineWidth"

let XRGraphicKeyMaxRadius = "_maxRadius"
let XRGraphicKeyPetalIncrement = "_petalIncrement"
let XRGraphicKeyAngleIncrement = "_angleIncrement"
let XRGraphicKeyHistogramIncrement = "_histIncrement"
let XRGraphicKeyDotSize = "_dotSize"
let XRGraphicKeyPercent = "_percent"
let XRGraphicKeyCount = "_count"
let XRGraphicKeyTotalCount = "_totalCount"
let XRGraphicKeyRelativePercent = "_relativePercent"
let XRGraphicKeyAngleSetting = "_angleSetting"
let XRGraphicKeyTickType = "_tickType"
let XRGraphicKeyShowTick = "_showTick"
let XRGraphicKeySpokeNumberAlignment = "_spokeNumberAlign"
let XRGraphicKeySpokeNumberCompassPoint = "_spokeNumberCompassPoint"
let XRGraphicKeySpokeNumberOrder = "_spokeNumberOrder"
let XRGraphicKeyShowLabel = "_showLabel"
let XRGraphicKeyLineLabel = "_lineLabel"
let XRGraphicKeyCurrentFont = "_currentFont"
let XRGraphicKeyLabelAngle = "_labelAngle"
let XRGraphicKeyLabel = "Label"
let XRGraphicKeyLabelFont = "_labelFont"
let XRGraphicKeyIsCore = "_isCore"
let XRGraphicKeyCountSetting = "_countSetting"
let XRGraphicKeyPercentSetting = "_percentSetting"
let XRGraphicKeyGeometryPercent = "_geometryPercent"
let XRGraphicKeyIsGeometryPercent = "_isGeometryPercent"
let XRGraphicKeyIsPercent = "_isPercent"
let XRGraphicKeyIsFixedCount = "_isFixedCount"
let XRGraphicKeyMean = "_mean"

let GraphicTypeGraphic = "Graphic"
let GraphicTypeCircle = "Circle"
let GraphicTypeLabelCircle = "LabelCircle"
let GraphicTypeLine = "Line"
let GraphicTypeKite = "Kite"
let GraphicTypePetal = "Petal"
let GraphicTypeDot = "Dot"
let GraphicTypeHistogram = "Histogram"
let GraphicTypeDotDeviation = "DotDeviation"

// MARK: - Main Class

@objc class XRGraphic: NSObject {

    // MARK: - Properties

    @objc weak var geometryController: GraphicGeometrySource?
    @objc var drawingPath: NSBezierPath?
    @objc var fillColor: NSColor?
    @objc var strokeColor: NSColor?
    @objc var drawsFill: Bool = false
    @objc var needsDisplay: Bool = true

    @objc var lineWidth: Float = 1.0 {
        didSet {
            drawingPath?.lineWidth = CGFloat(lineWidth)
        }
    }

    // MARK: - Initialization

    @objc init(controller: GraphicGeometrySource) {
        super.init()

        fillColor = NSColor.black
        strokeColor = NSColor.black
        lineWidth = 1.0
        needsDisplay = true
        drawsFill = false
        geometryController = controller
    }

    // MARK: - Geometry Methods

    func geometryDidChange(_: Notification) {
        calculateGeometry()
    }

    func calculateGeometry() {
        // Subclasses must override this method to set up the geometry of the graphic object
    }

    func drawingRect() -> NSRect {
        drawingPath?.bounds ?? NSRect.zero
    }

    @objc(drawRect:) func draw(_ rect: NSRect) {
        guard let path = drawingPath else { return }

        if rect.intersects(path.bounds) {
            NSGraphicsContext.saveGraphicsState()

            strokeColor?.set()
            path.stroke()

            if drawsFill {
                fillColor?.set()
                path.fill()
            }

            NSGraphicsContext.restoreGraphicsState()
            needsDisplay = false
        }
    }

    // MARK: - Hit Testing

    func hitTest(_: NSPoint) -> Bool {
        false
    }

    // MARK: - Color Methods

    func setDefaultStrokeColor() {
        strokeColor = NSColor.black
    }

    func setDefaultFillColor() {
        fillColor = NSColor.black
    }

    func setLineColor(_ lineColor: NSColor?, fill fillColor: NSColor?) {
        strokeColor = lineColor
        self.fillColor = fillColor
    }

    func setTransparency(_ alpha: Float) {
        let clampedAlpha = max(0.0, min(alpha, 1.0))

        if strokeColor == nil {
            setDefaultStrokeColor()
        }
        if let strokeColor {
            self.strokeColor = strokeColor.withAlphaComponent(CGFloat(clampedAlpha))
        }

        if fillColor == nil {
            setDefaultFillColor()
        }
        if let fillColor {
            self.fillColor = fillColor.withAlphaComponent(CGFloat(clampedAlpha))
        }
    }

    // MARK: - Settings Export

    @objc func graphicSettings() -> [AnyHashable: Any] {
        [
            XRGraphicKeyGraphicType: GraphicTypeGraphic,
            XRGraphicKeyFillColor: fillColor as Any,
            XRGraphicKeyStrokeColor: strokeColor as Any,
            XRGraphicKeyLineWidth: string(from: lineWidth)
        ]
    }

    // MARK: - Helper Methods

    func string(from boolValue: Bool) -> String {
        boolValue ? "YES" : "NO"
    }

    func string(from intValue: Int32) -> String {
        String(format: "%i", intValue)
    }

    func string(from floatValue: Float) -> String {
        String(format: "%f", floatValue)
    }

    func restrictAngle(toACircle angle: Float) -> Float {
        let maxAngle: Float = 360.0
        var newAngle = angle
        while newAngle >= maxAngle {
            newAngle = newAngle - maxAngle
        }
        return newAngle
    }
}
