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

class LITMArrowHead: NSObject {
    private var arrowColor: NSColor
    private var path: NSBezierPath
    private var positionTransform: AffineTransform
    private var scaleTransform: AffineTransform
    private var type: Int

    init(size: CGFloat, color: NSColor, type: Int) {
        arrowColor = color
        path = NSBezierPath()
        positionTransform = .identity
        scaleTransform = .identity
        self.type = type

        super.init()

        setColor(color)
        setSize(size)
        setType(type)
        positionAtLineEndpoint(.zero, withAngle: 0.0)
    }

    func setColor(_ color: NSColor) {
        arrowColor = color
    }

    func setSize(_ size: CGFloat) {
        let scale = size
        scaleTransform = AffineTransform.identity.scaledBy(x: scale, y: scale)
    }

    func setType(_ type: Int) {
        self.type = type
        path = NSBezierPath()

        switch type {
        case 0: // standard arrow
            path.move(to: .zero)
            path.line(to: NSPoint(x: 5.0, y: -10.0))
            path.line(to: NSPoint(x: -5.0, y: -10.0))
            path.line(to: .zero)

        case 1: // flying arrow
            path.move(to: .zero)
            path.line(to: NSPoint(x: 5.0, y: -10.0))
            path.line(to: NSPoint(x: 0.0, y: -7.5))
            path.line(to: NSPoint(x: -5.0, y: -10.0))
            path.line(to: .zero)

        case 2: // half arrow left
            path.move(to: .zero)
            path.line(to: NSPoint(x: 0.0, y: -7.5))
            path.line(to: NSPoint(x: -5.0, y: -10.0))
            path.line(to: .zero)

        case 4: // half arrow right
            path.move(to: .zero)
            path.line(to: NSPoint(x: 5.0, y: -10.0))
            path.line(to: NSPoint(x: 0.0, y: -7.5))
            path.line(to: .zero)

        default:
            break
        }
    }

    func positionAtLineEndpoint(_ point: NSPoint, withAngle angle: CGFloat) {
        positionTransform = AffineTransform.identity
            .translatedBy(x: point.x, y: point.y)
            .rotated(by: .pi * (360.0 - angle) / 180.0)
    }

    func draw(in rect: NSRect) {
        let transform = AffineTransform.identity
            .concatenating(scaleTransform)
            .concatenating(positionTransform)

        NSGraphicsContext.saveGraphicsState()

        transform.transform()

        arrowColor.set()
        path.stroke()
        path.fill()

        NSGraphicsContext.restoreGraphicsState()
    }
}
