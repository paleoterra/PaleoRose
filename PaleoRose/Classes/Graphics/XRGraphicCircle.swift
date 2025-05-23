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

// import Cocoa
//
// class XRGraphicCircle: XRGraphic {
//    // MARK: - Types
//
//    enum CircleMode {
//        case count(countValue: Int)
//        case percent(percentValue: CGFloat)
//        case geometry(geometryValue: CGFloat)
//
//        var isPercent: Bool {
//            switch self {
//            case .percent, .geometry: return true
//            case .count: return false
//            }
//        }
//    }
//
//    // MARK: - Properties
//
//    private var circleMode: CircleMode {
//        didSet {
//            guard case .geometry = circleMode else {
//            guard case .geometry = mode else {
//                calculateGeometry()
//                return
//            }
//            updateGeometryPath()
//        }
//    }
//
//    private var isFixedCount: Bool = false {
//        didSet { setNeedsDisplay(true) }
//    }
//
//    // MARK: - Initialization
//
//    convenience init(coreCircleWithController controller: XRGeometryController) {
//        self.init(controller: controller)
//        mode = controller.isPercent ? .percent(0.0) : .count(0)
//
//        if type(of: self) == XRGraphicCircle.self {
//            calculateGeometry()
//        }
//    }
//
//    // MARK: - Public API
//
//    var count: Int {
//        get {
//            if case let .count(value) = mode { return value }
//            return 0
//        }
//        set { mode = .count(newValue) }
//    }
//
//    var percent: CGFloat {
//        get {
//            if case let .percent(value) = mode { return value }
//            return 0.0
//        }
//        set { mode = .percent(newValue) }
//    }
//
//    var geometryPercentage: CGFloat {
//        get {
//            if case let .geometry(value) = mode { return value }
//            return 0.0
//        }
//        set { mode = .geometry(newValue) }
//    }
//
//    var isFixed: Bool {
//        get { isFixedCount }
//        set { isFixedCount = newValue }
//    }
//
//    // MARK: - Private Methods
//
//    private func updateGeometryPath() {
//        guard let controller = geometryController,
//              case let .geometry(percent) = mode else { return }
//        drawingPath = NSBezierPath(ovalIn: controller.circleRect(forGeometryPercent: percent))
//    }
//
//    // MARK: - Overrides
//
//    override func calculateGeometry() {
//        guard let controller = geometryController else { return }
//
//        let rect: NSRect
//        switch mode {
//        case .count(let value):
//            rect = controller.circleRect(forCount: value)
//        case .percent(let value):
//            rect = controller.circleRect(forPercent: value)
//        case .geometry(let value):
//            rect = controller.circleRect(forGeometryPercent: value)
//        }
//
//        drawingPath = NSBezierPath(ovalIn: rect)
//    }
//
//    override var graphicSettings: [String: Any] {
//        var settings = super.graphicSettings
//
//        switch mode {
//        case .count(let value):
//            settings["_countSetting"] = String(describing: value)
//            settings["_percentSetting"] = "0.000000"
//            settings["_geometryPercent"] = "0.000000"
//            settings["_isGeometryPercent"] = "NO"
//            settings["_isPercent"] = "NO"
//        case .percent(let value):
//            settings["_countSetting"] = "0"
//            settings["_percentSetting"] = String(format: "%.6f", value)
//            settings["_geometryPercent"] = "0.000000"
//            settings["_isGeometryPercent"] = "NO"
//            settings["_isPercent"] = "YES"
//        case .geometry(let value):
//            settings["_countSetting"] = "0"
//            settings["_percentSetting"] = "0.000000"
//            settings["_geometryPercent"] = String(format: "%.6f", value)
//            settings["_isGeometryPercent"] = "YES"
//            settings["_isPercent"] = "YES"
//        }
//
//        settings["_isFixedCount"] = isFixedCount ? "YES" : "NO"
//
//        return settings
//    }
// }
