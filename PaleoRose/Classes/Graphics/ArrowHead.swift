//
//  ArrowHead.swift
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

class ArrowHead: NSObject {

    // MARK: - Properties

    var arrowColor: NSColor
    var path: NSBezierPath
    var positionTransform: CGAffineTransform
    var scaleTransform: CGAffineTransform

    // MARK: - Initialization

    @objc init(size: Float, color: NSColor, type: Int32) {
        arrowColor = color
        path = NSBezierPath()
        scaleTransform = CGAffineTransform.identity
        positionTransform = CGAffineTransform.identity

        super.init()

        configureScaleTransform(size)
        setType(Int(type))
        position(atLineEndpoint: CGPoint.zero, withAngle: 0.0)
    }

    // MARK: - Public Methods

    @objc(positionAtLineEndpoint:withAngle:)
    func position(atLineEndpoint point: CGPoint, withAngle angle: Float) {
        positionTransform = CGAffineTransform.identity
        positionTransform = positionTransform.translatedBy(x: point.x, y: point.y)
        positionTransform = positionTransform.rotated(by: CGFloat(360.0 - angle) * .pi / 180.0)
    }

    @objc(drawRect:)
    func draw(_: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        if let context = NSGraphicsContext.current?.cgContext {
            context.concatenate(scaleTransform)
            context.concatenate(positionTransform)
        }

        arrowColor.set()

        path.stroke()
        path.fill()

        NSGraphicsContext.restoreGraphicsState()
    }

    // MARK: - Private Methods

    private func configureScaleTransform(_ scale: Float) {
        scaleTransform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
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
        path.move(to: CGPoint.zero)
        path.line(to: CGPoint(x: 5.0, y: -10.0))
        path.line(to: CGPoint(x: -5.0, y: -10.0))
        path.line(to: CGPoint.zero)
    }

    private func flyingArrow() {
        path.move(to: CGPoint.zero)
        path.line(to: CGPoint(x: 5.0, y: -10.0))
        path.line(to: CGPoint(x: 0.0, y: -7.5))
        path.line(to: CGPoint(x: -5.0, y: -10.0))
        path.line(to: CGPoint.zero)
    }

    private func halfArrowLeft() {
        path.move(to: CGPoint.zero)
        path.line(to: CGPoint(x: 0.0, y: -7.5))
        path.line(to: CGPoint(x: -5.0, y: -10.0))
        path.line(to: CGPoint.zero)
    }

    private func halfArrowRight() {
        path.move(to: CGPoint.zero)
        path.line(to: CGPoint(x: 5.0, y: -10.0))
        path.line(to: CGPoint(x: 0.0, y: -7.5))
        path.line(to: CGPoint.zero)
    }
}
