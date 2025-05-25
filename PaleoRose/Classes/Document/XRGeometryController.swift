// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

// MARK: - Notifications

extension Notification.Name {
    static let XRGeometryDidChange = Notification.Name("XRGeometryDidChange")
    static let XRGeometryDidChangeIsPercent = Notification.Name("XRGeometryDidChangeIsPercent")
    static let XRGeometryDidChangeSectors = Notification.Name("XRGeometryDidChangeSectors")
}

// MARK: - Default Keys

private enum XRGeometryDefaultKey: String {
    case equalArea = "XRGeometryDefaultKeyEqualArea"
    case percent = "XRGeometryDefaultKeyPercent"
    case sectorSize = "XRGeometryDefaultKeySectorSize"
    case startingAngle = "XRGeometryDefaultKeyStartingAngle"
    case hollowCoreSize = "XRGeometryDefaultKeyHollowCoreSize"

    static let defaults: [String: Any] = [
        equalArea.rawValue: true,
        percent.rawValue: 0.5,
        sectorSize.rawValue: 10.0,
        startingAngle.rawValue: 0.0,
        hollowCoreSize.rawValue: 0.0
    ]
}

@objc class XRGeometryController: NSObject, XRGeometryCalculating, XRGeometryConfiguring {
    // MARK: - Properties

    @IBOutlet private var roseTableController: XRoseTableController?

    private var mainRect: NSRect = .zero {
        didSet { updateCircleRect() }
    }

    private(set) var circleRect: NSRect = .init(x: 146.0, y: 0.0, width: 474.0, height: 393.0)

    private var relativeSizeOfCircleRect: CGFloat = 0.9 {
        didSet {
            guard relativeSizeOfCircleRect != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.relativeSizeOfCircleRect = oldValue }
            undoManager?.setActionName("Plot Size")
            updateCircleRect()
        }
    }

    // MARK: Geometry Settings

    @objc var isEqualArea: Bool {
        didSet {
            guard isEqualArea != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.isEqualArea = oldValue }
            undoManager?.setActionName(isEqualArea ? "Equal Area Rose" : "Linear Rose")
            notifyGeometryChange()
        }
    }

    @objc var isPercent: Bool {
        didSet {
            guard isPercent != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.isPercent = oldValue }
            undoManager?.setActionName(isPercent ? "Percent Count" : "Number Count")
            NotificationCenter.default.post(name: .XRGeometryDidChangeIsPercent, object: self)
        }
    }

    @objc var geometryMaxCount: Int = 10 {
        didSet {
            guard geometryMaxCount != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.geometryMaxCount = oldValue }
            undoManager?.setActionName("Max Count")
            notifyGeometryChange()
        }
    }

    @objc var geometryMaxPercent: CGFloat = 0.3 {
        didSet {
            guard geometryMaxPercent != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.geometryMaxPercent = oldValue }
            undoManager?.setActionName("Max Percent")
            notifyGeometryChange()
        }
    }

    @objc var hollowCoreSize: CGFloat = 0.0 {
        didSet {
            guard hollowCoreSize != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.hollowCoreSize = oldValue }
            undoManager?.setActionName("Hollow Core")
            notifyGeometryChange()
        }
    }

    @objc var sectorSize: CGFloat = 10.0 {
        didSet {
            guard sectorSize != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.sectorSize = oldValue }
            undoManager?.setActionName("Sector Size")
            notifyGeometryChange()
        }
    }

    @objc var startingAngle: CGFloat = 0.0 {
        didSet {
            guard startingAngle != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.startingAngle = oldValue }
            undoManager?.setActionName("Starting Angle")
            notifyGeometryChange()
        }
    }

    @objc var sectorCount: Int = 36 {
        didSet {
            guard sectorCount != oldValue else { return }
            undoManager?.registerUndo(withTarget: self) { $0.sectorCount = oldValue }
            undoManager?.setActionName("Sector Count")
            sectorSize = 360.0 / CGFloat(sectorCount)
            notifyGeometryChange()
        }
    }

    private var circleParameters: XRGeometryCalculator.CircleParameters {
        let maxRadius = min(circleRect.width, circleRect.height) / 2.0
        return XRGeometryCalculator.CircleParameters(
            center: NSPoint(x: circleRect.midX, y: circleRect.midY),
            maxRadius: maxRadius,
            hollowRadius: maxRadius * hollowCoreSize,
            isEqualArea: isEqualArea
        )
    }

    private weak var undoManager: UndoManager?

    // MARK: - Initialization

    override init() {
        let defaults = UserDefaults.standard
        isEqualArea = defaults.bool(forKey: XRGeometryDefaultKey.equalArea.rawValue)
        isPercent = defaults.bool(forKey: XRGeometryDefaultKey.percent.rawValue)
        sectorSize = defaults.float(forKey: XRGeometryDefaultKey.sectorSize.rawValue)
        startingAngle = defaults.float(forKey: XRGeometryDefaultKey.startingAngle.rawValue)
        super.init()
    }

    override class func initialize() {
        UserDefaults.standard.register(defaults: XRGeometryDefaultKey.defaults)
    }

    // MARK: - Configuration

    // swiftlint:disable:next function_parameter_count
    func configure(isEqualArea: Bool,
                   isPercent: Bool,
                   maxCount: Int,
                   maxPercent: CGFloat,
                   hollowCore: CGFloat,
                   sectorSize: CGFloat,
                   startingAngle: CGFloat,
                   sectorCount: Int,
                   relativeSize: CGFloat)
    {
        self.isPercent = isPercent
        self.isEqualArea = isEqualArea
        geometryMaxCount = maxCount
        geometryMaxPercent = maxPercent
        hollowCoreSize = hollowCore
        self.sectorSize = sectorSize
        self.startingAngle = startingAngle
        self.sectorCount = sectorCount
        relativeSizeOfCircleRect = relativeSize
        notifyGeometryChange()
    }

    // MARK: - Geometry Updates

    private func updateCircleRect() {
        guard relativeSizeOfCircleRect <= 1.0, relativeSizeOfCircleRect > 0.0 else { return }
        let inset = mainRect.size.width * (1.0 - relativeSizeOfCircleRect)
        circleRect = mainRect.insetBy(dx: inset, dy: inset)
        notifyGeometryChange()
    }

    private func notifyGeometryChange() {
        NotificationCenter.default.post(name: .XRGeometryDidChange, object: self)
    }

    // MARK: - Public API

    func resetGeometry(withBounds newBounds: NSRect) {
        mainRect = newBounds
        updateCircleRect()
    }

    // MARK: - Geometry Calculations

    func circleRect(forPercent percent: CGFloat) -> NSRect {
        let radius = XRGeometryCalculator.radiusOfPercentValue(
            percent,
            maxPercent: geometryMaxPercent,
            parameters: circleParameters
        )
        return XRGeometryCalculator.circleRect(
            forRadius: radius,
            center: circleParameters.center
        )
    }

    func circleRect(forGeometryPercent percent: CGFloat) -> NSRect {
        let radius = XRGeometryCalculator.radiusOfRelativePercent(
            percent,
            parameters: circleParameters
        )
        return XRGeometryCalculator.circleRect(
            forRadius: radius,
            center: circleParameters.center
        )
    }

    func circleRect(forCount count: Int) -> NSRect {
        let radius = XRGeometryCalculator.radiusOfCount(
            count,
            maxCount: geometryMaxCount,
            parameters: circleParameters
        )
        return XRGeometryCalculator.circleRect(
            forRadius: radius,
            center: circleParameters.center
        )
    }

    func circleRectForHollowCore() -> NSRect {
        let radius = XRGeometryCalculator.radiusOfRelativePercent(
            hollowCoreSize,
            parameters: circleParameters
        )
        return XRGeometryCalculator.circleRect(
            forRadius: radius,
            center: circleParameters.center
        )
    }

    func angleIsValid(forSpoke angle: CGFloat) -> Bool {
        XRGeometryCalculator.angleIsValid(
            forSpoke: angle,
            startingAngle: startingAngle,
            sectorSize: sectorSize
        )
    }

    func calculateRelativePosition(withPoint target: NSPoint) -> (radius: CGFloat, angle: CGFloat) {
        XRGeometryCalculator.calculateRelativePosition(
            forPoint: target,
            center: circleParameters.center
        )
    }

    // MARK: - Auto Calculations

    func calculateGeometryMaxCount() {
        if let maxCount = roseTableController?.calculateGeometryMaxCount(), maxCount > 0 {
            geometryMaxCount = maxCount
        }
    }

    func calculateGeometryMaxPercent() {
        if let percent = roseTableController?.calculateGeometryMaxPercent(), percent > 0 {
            geometryMaxPercent = percent
        }
    }

    // MARK: - Accessors

    var drawingBounds: NSRect { circleRect }
}

// MARK: - XML Support

extension XRGeometryController {
    func xmlTree(forVersion version: String) -> LITMXMLTree {
        switch version {
        case "1.0": xmlTreeForVersion1_0()
        default: xmlTreeForVersion1_0()
        }
    }

    private func xmlTreeForVersion1_0() -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.name = "geometry"

        let settings: [String: String] = [
            "EQUAL": isEqualArea ? "YES" : "NO",
            "ISPERCENT": isPercent ? "YES" : "NO"
        ]

        for (key, value) in settings {
            let node = LITMXMLTree()
            node.name = key
            node.content = value
            tree.addChild(node)
        }

        return tree
    }

    func configureController(_ settings: LITMXMLTree, forVersion version: String) {
        switch version {
        case "1.0": configureControllerForVersion1_0(settings)
        default: configureControllerForVersion1_0(settings)
        }
    }

    private func configureControllerForVersion1_0(_ settings: LITMXMLTree) {
        guard let children = settings.children as? [LITMXMLTree] else { return }

        for child in children {
            switch child.name {
            case "EQUAL":
                isEqualArea = child.content == "YES"
            case "ISPERCENT":
                isPercent = child.content == "YES"
            default:
                break
            }
        }
    }
}
