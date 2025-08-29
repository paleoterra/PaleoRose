//
//  XRGraphicCircle.swift
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

@objc class XRGraphicCircle: XRGraphic {

    // MARK: - Properties

    @objc dynamic var isFixedCount: Bool = false
    @objc dynamic var countSetting: Int32 = 0 {
        didSet {
            isPercent = false
            isGeometryPercent = false
            calculateGeometry()
        }
    }

    @objc dynamic var percentSetting: Float = 0.0 {
        didSet {
            isPercent = true
            isGeometryPercent = false
            calculateGeometry()
        }
    }

    @objc dynamic var isGeometryPercent: Bool = false
    @objc dynamic var isPercent: Bool = false

    // MARK: - KVO Keys

    private static let kvoKeyCountSetting = "countSetting"
    private static let kvoKeyPercentSetting = "percentSetting"

    // MARK: - Initialization

    @objc override init(controller: GraphicGeometrySource) {
        super.init(controller: controller)
        isPercent = controller.isPercent()
        registerForKVO()

        // Prevent calculating geometry twice for circle labels
        if type(of: self) == XRGraphicCircle.self {
            calculateGeometry()
        }
    }

    @objc(initCoreCircleWithController:) init(coreCircleWithController controller: GraphicGeometrySource) {
        super.init(controller: controller)
        countSetting = 0
        percentSetting = 0.0
        isPercent = controller.isPercent()
        registerForKVO()

        // Prevent calculating geometry twice for circle labels
        if type(of: self) == XRGraphicCircle.self {
            calculateGeometry()
        }
    }

    private func registerForKVO() {
        let keyPaths = [XRGraphicCircle.kvoKeyCountSetting, XRGraphicCircle.kvoKeyPercentSetting]
        for keyPath in keyPaths {
            addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: nil)
        }
    }

    deinit {
        let keyPaths = [XRGraphicCircle.kvoKeyCountSetting, XRGraphicCircle.kvoKeyPercentSetting]
        for keyPath in keyPaths {
            removeObserver(self, forKeyPath: keyPath)
        }
    }

    // MARK: - Geometry

    @objc func setGeometryPercent(_ percent: Float) {
        isGeometryPercent = true
        guard let controller = geometryController else { return }
        let circleRect = controller.circleRect(forGeometryPercent: percent)
        drawingPath = NSBezierPath(ovalIn: circleRect)
    }

    @objc override func calculateGeometry() {
        guard let controller = geometryController else { return }

        var circleRect = NSRect.zero
        if controller.isPercent() {
            circleRect = controller.circleRect(forPercent: percentSetting)
        } else {
            circleRect = controller.circleRect(forCount: countSetting)
        }

        drawingPath = NSBezierPath(ovalIn: circleRect)
        drawingPath?.lineWidth = CGFloat(lineWidth)
    }

    // MARK: - Settings Export

    @objc override func graphicSettings() -> [AnyHashable: Any] {
        var settings = super.graphicSettings()

        settings["GraphicType"] = "Circle"
        settings["_countSetting"] = string(from: countSetting)
        settings["_percentSetting"] = string(from: percentSetting)
        settings["_geometryPercent"] = string(from: percentSetting)
        settings["_isGeometryPercent"] = string(from: isGeometryPercent)
        settings["_isPercent"] = string(from: isPercent)
        settings["_isFixedCount"] = string(from: isFixedCount)

        return settings
    }

    // MARK: - KVO

    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                     change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?)
    {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)

        guard let keyPath else { return }

        if keyPath == XRGraphicCircle.kvoKeyCountSetting {
            isPercent = false
            isGeometryPercent = false
            calculateGeometry()
        } else if keyPath == XRGraphicCircle.kvoKeyPercentSetting {
            isPercent = true
            isGeometryPercent = false
            calculateGeometry()
        }
    }
}
