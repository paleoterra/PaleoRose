//
//  LITMArrowHead.swift
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
import Foundation

@objc class LITMArrowHead: NSObject {

    // MARK: - Properties

    @objc var arrowColor: NSColor
    @objc var path: NSBezierPath
    @objc var positionTransform: NSAffineTransform
    @objc var scaleTransform: NSAffineTransform

    // MARK: - Initialization

    @objc init(size: Float, color: NSColor, type: Int32) {
        arrowColor = color
        path = NSBezierPath()
        scaleTransform = NSAffineTransform()
        positionTransform = NSAffineTransform()

        super.init()

        configureScaleTransform(size)
        setType(Int(type))
        position(atLineEndpoint: NSPoint(x: 0.0, y: 0.0), withAngle: 0.0)
    }

    // MARK: - Public Methods

    @objc(positionAtLineEndpoint:withAngle:)
    func position(atLineEndpoint point: NSPoint, withAngle angle: Float) {
        positionTransform = NSAffineTransform()
        positionTransform.translateX(by: point.x, yBy: point.y)
        positionTransform.rotate(byDegrees: 360.0 - CGFloat(angle))
    }

    @objc(drawRect:)
    func draw(_: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        scaleTransform.concat()
        positionTransform.concat()

        arrowColor.set()

        path.stroke()
        path.fill()

        NSGraphicsContext.restoreGraphicsState()
    }

    // MARK: - Private Methods

    private func configureScaleTransform(_ scale: Float) {
        scaleTransform.scale(by: CGFloat(scale))
    }

    private func setType(_ type: Int) {
        switch type {
        case 0:
            standardArrow()
        case 1:
            flyingArrow()
        case 2:
            halfArrowLeft()
        case 4:
            halfArrowRight()
        default:
            // Invalid type - leave path empty
            break
        }
    }

    private func standardArrow() {
        path.move(to: NSPoint(x: 0.0, y: 0.0))
        path.line(to: NSPoint(x: 5.0, y: -10.0))
        path.line(to: NSPoint(x: -5.0, y: -10.0))
        path.line(to: NSPoint(x: 0.0, y: 0.0))
    }

    private func flyingArrow() {
        path.move(to: NSPoint(x: 0.0, y: 0.0))
        path.line(to: NSPoint(x: 5.0, y: -10.0))
        path.line(to: NSPoint(x: 0.0, y: -7.5))
        path.line(to: NSPoint(x: -5.0, y: -10.0))
        path.line(to: NSPoint(x: 0.0, y: 0.0))
    }

    private func halfArrowLeft() {
        path.move(to: NSPoint(x: 0.0, y: 0.0))
        path.line(to: NSPoint(x: 0.0, y: -7.5))
        path.line(to: NSPoint(x: -5.0, y: -10.0))
        path.line(to: NSPoint(x: 0.0, y: 0.0))
    }

    private func halfArrowRight() {
        path.move(to: NSPoint(x: 0.0, y: 0.0))
        path.line(to: NSPoint(x: 5.0, y: -10.0))
        path.line(to: NSPoint(x: 0.0, y: -7.5))
        path.line(to: NSPoint(x: 0.0, y: 0.0))
    }
}
