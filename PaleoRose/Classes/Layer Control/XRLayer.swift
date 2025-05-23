// XRLayer.swift
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

import Cocoa
import SQLite3

// MARK: - Constants

let XRLayerRequiresRedraw = "XRLayerRequiresRedraw"
let XRLayerTableRequiresReload = "XRLayerTableRequiresReload"
let XRLayerInspectorRequiresReload = "XRLayerInspectorRequiresReload"

let XRLayerXMLType = "Layer_Type"
let XRLayerGraphicObjectArray = "Graphics"

@objc class XRLayer: NSObject {
    // MARK: - Properties

    private var graphicalObjects: [XRGraphic] = []
    private var isVisible: Bool = true {
        didSet {
            if oldValue != isVisible {
                NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
                NotificationCenter.default.post(name: NSNotification.Name(XRLayerInspectorRequiresReload), object: self)
            }
        }
    }

    private var isActive: Bool = false
    private var strokeColor: NSColor = .black {
        didSet {
            resetColorImage()
            graphicalObjects.forEach { $0.strokeColor = strokeColor }
            NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
            NotificationCenter.default.post(name: NSNotification.Name(XRLayerInspectorRequiresReload), object: self)
        }
    }

    private var fillColor: NSColor = .black {
        didSet {
            resetColorImage()
            graphicalObjects.forEach { $0.fillColor = fillColor }
            NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
            NotificationCenter.default.post(name: NSNotification.Name(XRLayerInspectorRequiresReload), object: self)
        }
    }

    private var layerName: String = ""
    private var isBiDir: Bool = false
    private var lineWeight: Float = 1.0
    private var maxCount: Int = 0 // Should be set when sector size is set
    private var maxPercent: Float = 0.0
    private var anImage: NSImage?
    private var canFill: Bool = true
    private var canStroke: Bool = true
    private weak var geometryController: XRGeometryController?
    private weak var dataSet: XRDataSet?

    // MARK: - Class Methods

    @objc class func classTag() -> String {
        "Layer"
    }

    // MARK: - Initialization

    @objc override init() {
        super.init()
        setupNotifications()
        setupDefaults()
    }

    @objc init(geometryController: XRGeometryController) {
        super.init()
        self.geometryController = geometryController
        setupNotifications()
        setupDefaults()
    }

    @objc init(geometryController: XRGeometryController, dictionary: [String: Any]) {
        super.init()
        self.geometryController = geometryController
        setupNotifications()
        configureSelf(with: dictionary)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(geometryDidChange(_:)),
                                               name: NSNotification.Name("XRGeometryDidChange"),
                                               object: geometryController)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(geometryDidChangePercent(_:)),
                                               name: NSNotification.Name("XRGeometryDidChangeIsPercent"),
                                               object: geometryController)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(geometryDidChangeSectors(_:)),
                                               name: NSNotification.Name("XRGeometryDidChangeSectors"),
                                               object: geometryController)
    }

    private func setupDefaults() {
        strokeColor = .black
        fillColor = .black
        isVisible = true
        isActive = false
        canFill = true
        canStroke = true
    }

    private func configureSelf(with dictionary: [String: Any]) {
        if let color = dictionary["Stroke_Color"] as? NSColor {
            strokeColor = color
        }
        if let color = dictionary["Fill_Color"] as? NSColor {
            fillColor = color
        }
        if let visibleStr = dictionary["Visible"] as? String {
            isVisible = (visibleStr == "YES")
        }
        if let activeStr = dictionary["Active"] as? String {
            isActive = (activeStr == "YES")
        }
        if let bidirStr = dictionary["BIDIR"] as? String {
            isBiDir = (bidirStr == "YES")
        }
        if let name = dictionary["Layer_Name"] as? String {
            layerName = name
        }
        if let weight = dictionary["Line_Weight"] as? String {
            lineWeight = Float(weight) ?? 1.0
        }
        if let count = dictionary["Max_Count"] as? String {
            maxCount = Int(count) ?? 0
        }
        if let percent = dictionary["Max_Percent"] as? String {
            maxPercent = Float(percent) ?? 0.0
        }
    }

    // MARK: - Public Methods

    @objc func getIsVisible() -> Bool {
        isVisible
    }

    @objc func setIsVisible(_ visible: Bool) {
        isVisible = visible
    }

    @objc func getIsActive() -> Bool {
        isActive
    }

    @objc func setIsActive(_ active: Bool) {
        isActive = active
    }

    @objc func getStrokeColor() -> NSColor {
        strokeColor
    }

    @objc func setStrokeColor(_ color: NSColor) {
        strokeColor = color
    }

    @objc func getFillColor() -> NSColor {
        fillColor
    }

    @objc func setFillColor(_ color: NSColor) {
        fillColor = color
    }

    @objc func getLayerName() -> String {
        layerName
    }

    @objc func setLayerName(_ name: String) {
        layerName = name
    }

    @objc func getIsBiDirectional() -> Bool {
        isBiDir
    }

    @objc func setBiDirectional(_ biDir: Bool) {
        isBiDir = biDir
    }

    @objc func resetColorImage() {
        let imageRect = NSRect(x: 0, y: 0, width: 16, height: 16)
        anImage = NSImage(size: imageRect.size)

        anImage?.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high

        let path = NSBezierPath(rect: imageRect)
        fillColor.setFill()
        path.fill()

        strokeColor.setStroke()
        path.stroke()

        anImage?.unlockFocus()
    }

    @objc func colorImage() -> NSImage? {
        if anImage == nil {
            resetColorImage()
        }
        return anImage
    }

    @objc func generateGraphics() {
        // To be implemented by subclasses
    }

    @objc func draw(_: NSRect) {
        // To be implemented by subclasses
    }

    // MARK: - Notification Handlers

    @objc func geometryDidChange(_: Notification) {
        // To be implemented by subclasses
    }

    @objc func geometryDidChangePercent(_: Notification) {
        // To be implemented by subclasses
    }

    @objc func geometryDidChangeSectors(_: Notification) {
        // To be implemented by subclasses
    }

    // MARK: - Properties

    @objc func getMaxCount() -> Int {
        maxCount
    }

    @objc func getMaxPercent() -> Float {
        maxPercent
    }

    @objc func setLineWeight(_ weight: Float) {
        lineWeight = weight
    }

    @objc func getLineWeight() -> Float {
        lineWeight
    }

    @objc func setDataSet(_ set: XRDataSet?) {
        dataSet = set
    }

    @objc func getDataSet() -> XRDataSet? {
        dataSet
    }

    // MARK: - Layer Settings

    @objc func layerSettings() -> [String: Any] {
        var settings: [String: Any] = [:]
        settings["TYPE"] = Self.classTag()
        settings["VISIBLE"] = isVisible ? "YES" : "NO"
        settings["ACTIVE"] = isActive ? "YES" : "NO"
        settings["BIDIR"] = isBiDir ? "YES" : "NO"
        settings["Layer_Name"] = layerName
        settings["Line_Weight"] = String(format: "%.1f", lineWeight)
        settings["Max_Count"] = String(format: "%d", maxCount)
        settings["Max_Percent"] = String(format: "%.1f", maxPercent)
        return settings
    }

    // MARK: - XML Support

    @objc func baseXMLTree(forVersion version: String) -> LITMXMLTree {
        switch version {
        case "1.0":
            baseXMLTree1_0()
        default:
            LITMXMLTree()
        }
    }

    @objc func baseXMLTree1_0() -> LITMXMLTree {
        let tree = LITMXMLTree()
        let settings = layerSettings()
        let attributeOrder = ["TYPE", "VISIBLE", "ACTIVE", "BIDIR"]

        for key in attributeOrder {
            if let value = settings[key] as? String {
                tree.addAttribute(key, value: value)
            }
        }

        return tree
    }

    @objc class func layer(withGeometryController controller: XRGeometryController,
                           xmlTree configureTree: LITMXMLTree,
                           forVersion version: String,
                           withParentView parentView: NSView) -> XRLayer?
    {
        guard let attributes = configureTree.attributesDictionary() as? [String: String],
              let type = attributes["TYPE"]
        else {
            return nil
        }

        let layer: XRLayer?

        switch type {
        case XRLayerCore.classTag():
            layer = XRLayerCore(geometryController: controller)
        case XRLayerGrid.classTag():
            layer = XRLayerGrid(geometryController: controller)
        case XRLayerData.classTag():
            layer = XRLayerData(geometryController: controller)
        case XRLayerText.classTag():
            layer = XRLayerText(geometryController: controller)
        case XRLayerLineArrow.classTag():
            layer = XRLayerLineArrow(geometryController: controller)
        default:
            return nil
        }

        layer?.configureBase(withXMLTree: configureTree, version: version)
        layer?.configure(withXMLTree: configureTree, version: version)

        return layer
    }

    @objc func configureBase(withXMLTree configureTree: LITMXMLTree, version: String) {
        switch version {
        case "1.0":
            configureBase(withXMLTree1_0: configureTree)
        default:
            break
        }
    }

    @objc func configureBase(withXMLTree1_0 configureTree: LITMXMLTree) {
        if let attributes = configureTree.attributesDictionary() as? [String: String] {
            isVisible = attributes["VISIBLE"] == "YES"
            isActive = attributes["ACTIVE"] == "YES"
            isBiDir = attributes["BIDIR"] == "YES"
        }
    }

    @objc func configure(withXMLTree configureTree: LITMXMLTree, version: String) {
        // To be implemented by subclasses
    }

    @objc func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        // To be implemented by subclasses
    }

    @objc func xmlTree(forVersion version: String) -> LITMXMLTree {
        // To be implemented by subclasses
        LITMXMLTree()
    }
}
