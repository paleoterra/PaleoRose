//
//  XRGraphicDot.swift
//  PaleoRose
//
//  Created by Cascade on 2025-08-22.
//
//  MIT License
//
//  Copyright (c) 2004 to present Thomas L. Moore.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import AppKit

@objc class XRGraphicDot: XRGraphic {

    // MARK: - Public API

    /// Diameter of each dot.
    @objc dynamic var dotSize: Float = 4.0 { didSet { calculateGeometry() } }

    // MARK: - Private State

    private var angleIncrement: Int = 0
    private var totalCount: Int = 0
    private var count: Int = 0

    // MARK: - Init

    @objc
    init?(controller: GraphicGeometrySource, forIncrement increment: Int32, valueCount count: Int32, totalCount total: Int32) {
        super.init(controller: controller)
        angleIncrement = Int(increment)
        totalCount = Int(total)
        self.count = Int(count)
        drawsFill = true
        calculateGeometry()
    }

    // MARK: - Geometry Helpers

    private func centerAngleForSector() -> CGFloat {
        guard let controller = geometryController else { return 0 }
        let startAngle = CGFloat(controller.startingAngle())
        let sectorSize = CGFloat(controller.sectorSize())
        return startAngle + sectorSize * (CGFloat(angleIncrement) + 0.5)
    }

    private func radiusForDot(index: Int, isPercentMode: Bool) -> CGFloat {
        guard let controller = geometryController else { return 0 }
        if isPercentMode {
            let percentValue = CGFloat(index + 1) / CGFloat(totalCount)
            return CGFloat(controller.radius(ofPercentValue: Double(percentValue)))
        } else {
            return CGFloat(controller.radius(ofCount: Int32(index)))
        }
    }

    private func addDot(atRadius radius: CGFloat, angle: CGFloat) {
        guard let controller = geometryController else { return }
        var centerPoint = CGPoint(x: 0.0, y: radius)
        centerPoint = controller.rotation(of: centerPoint, byAngle: Double(angle))
        let half = CGFloat(dotSize) * 0.5
        let rect = CGRect(x: centerPoint.x - half, y: centerPoint.y - half, width: CGFloat(dotSize), height: CGFloat(dotSize))
        drawingPath?.appendOval(in: rect)
    }

    // MARK: - Geometry

    @objc override func calculateGeometry() {
        guard let controller = geometryController else { return }
        let path = NSBezierPath()
        let isPercentMode = controller.isPercent()
        let centerAngle = centerAngleForSector()
        for i in 0 ..< count {
            let radius = radiusForDot(index: i, isPercentMode: isPercentMode)
            var point = CGPoint(x: 0.0, y: radius)
            point = controller.rotation(of: point, byAngle: Double(centerAngle))
            let half = CGFloat(dotSize) * 0.5
            let rect = CGRect(x: point.x - half, y: point.y - half, width: CGFloat(dotSize), height: CGFloat(dotSize))
            path.appendOval(in: rect)
        }
        drawingPath = path
    }

    // MARK: - Settings

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var parent = super.graphicSettings()
        let classDict: [AnyHashable: Any] = [
            XRGraphicKeyGraphicType: "Dot",
            XRGraphicKeyAngleIncrement: string(from: Int32(angleIncrement)),
            XRGraphicKeyTotalCount: string(from: Int32(totalCount)),
            XRGraphicKeyCount: string(from: Int32(count)),
            XRGraphicKeyDotSize: string(from: dotSize)
        ]
        parent.merge(classDict) { _, new in new }
        return parent
    }
}
