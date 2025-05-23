// XRLayerGrid.swift
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

// MARK: - Constants

let XRLayerGridDefaultRingCount = "XRLayerGridDefaultRingCount"
let XRLayerGridDefaultSpokeCount = "XRLayerGridDefaultSpokeCount"
let XRLayerGridDefaultSpokeAngle = "XRLayerGridDefaultSpokeAngle"
let XRLayerGridDefaultRingPercent = "XRLayerGridDefaultRingPercent"
let XRLayerGridDefaultRingFixedCount = "XRLayerGridDefaultRingFixedCount"
let XRLayerGridDefaultSectorLock = "XRLayerGridDefaultSectorLock"
let XRLayerGridDefaultRingFixed = "XRLayerGridDefaultRingFixed"
let XRLayerGridDefaultLineWidth = "XRLayerGridDefaultLineWidth"

@objc class XRLayerGrid: XRLayer {
    // MARK: - Properties

    private var spokeCount: Int = 0
    private var spokeAngle: Float = 0.0

    // Ring properties
    private var fixedCount: Bool = false
    private var ringsVisible: Bool = true
    private var fixedRingCount: Int = 0
    private var ringCountIncrement: Int = 0
    private var ringPercentIncrement: Float = 0.0
    private var showRingLabels: Bool = true
    private var labelAngle: Float = 0.0
    private var ringFont: NSFont?

    // Spoke properties
    private var spokeSectorLock: Bool = false
    private var spokesVisible: Bool = true
    private var isPercent: Bool = false

    // Tick mark properties
    private var showTicks: Bool = true
    private var minorTicks: Bool = false

    // Line label properties
    private var showLabels: Bool = true
    private var pointsOnly: Bool = false
    private var spokeNumberAlign: Int = 0
    private var spokeNumberCompassPoint: Int = 0
    private var spokeNumberOrder: Int = 0
    private var spokeFont: NSFont?

    // MARK: - Class Methods

    override class func classTag() -> String {
        "Grid"
    }

    // MARK: - Initialization

    @objc init(isVisible: Bool,
               active: Bool,
               biDir: Bool,
               name: String,
               lineWeight: Float,
               maxCount: Int,
               maxPercent: Float,
               strokeColor: NSColor,
               fillColor: NSColor,
               isFixedCount: Bool,
               ringsVisible: Bool,
               fixedRingCount: Int,
               ringCountIncrement: Int,
               ringPercentIncrement: Float,
               showRingLabels: Bool,
               labelAngle: Float,
               ringFont: NSFont,
               radialsCount: Int,
               radialsAngle: Float,
               radialsLabelAlignment: Int,
               radialsCompassPoint: Int,
               radialsOrder: Int,
               radialFont: NSFont,
               radialsSectorLock: Bool,
               radialsVisible: Bool)
    {
        super.init()

        setIsVisible(isVisible)
        setIsActive(active)
        setBiDirectional(biDir)
        setLayerName(name)
        setLineWeight(lineWeight)
        self.maxCount = maxCount
        self.maxPercent = maxPercent
        setStrokeColor(strokeColor)
        setFillColor(fillColor)

        fixedCount = isFixedCount
        self.ringsVisible = ringsVisible
        self.fixedRingCount = fixedRingCount
        self.ringCountIncrement = ringCountIncrement
        self.ringPercentIncrement = ringPercentIncrement
        self.showRingLabels = showRingLabels
        self.labelAngle = labelAngle
        self.ringFont = ringFont

        spokeCount = radialsCount
        spokeAngle = radialsAngle
        spokeNumberAlign = radialsLabelAlignment
        spokeNumberCompassPoint = radialsCompassPoint
        spokeNumberOrder = radialsOrder
        spokeFont = radialFont
        spokeSectorLock = radialsSectorLock
        spokesVisible = radialsVisible
    }

    required init(geometryController: XRGeometryController) {
        super.init(geometryController: geometryController)
        setupDefaults()
    }

    required init(geometryController: XRGeometryController, dictionary: [String: Any]) {
        super.init(geometryController: geometryController, dictionary: dictionary)
        configureSelf(with: dictionary)
    }

    override required init() {
        super.init()
        setupDefaults()
    }

    // MARK: - Setup Methods

    private func setupDefaults() {
        // Set default values from user defaults or constants
        let defaults = UserDefaults.standard
        spokeCount = defaults.integer(forKey: XRLayerGridDefaultSpokeCount)
        spokeAngle = defaults.float(forKey: XRLayerGridDefaultSpokeAngle)
        fixedCount = defaults.bool(forKey: XRLayerGridDefaultRingFixed)
        fixedRingCount = defaults.integer(forKey: XRLayerGridDefaultRingFixedCount)
        spokeSectorLock = defaults.bool(forKey: XRLayerGridDefaultSectorLock)
    }

    private func configureSelf(with dictionary: [String: Any]) {
        if let count = dictionary["Spoke_Count"] as? Int {
            spokeCount = count
        }
        if let angle = dictionary["Spoke_Angle"] as? Float {
            spokeAngle = angle
        }
        // Configure other properties from dictionary
    }

    // MARK: - Public Methods

    @objc func setSpokeCount(_ count: Int) {
        spokeCount = count
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getSpokeCount() -> Int {
        spokeCount
    }

    @objc func setSpokeAngle(_ angle: Float) {
        spokeAngle = angle
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getSpokeAngle() -> Float {
        spokeAngle
    }

    // MARK: - Ring Methods

    @objc func setFixedCount(_ fixed: Bool) {
        fixedCount = fixed
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getFixedCount() -> Bool {
        fixedCount
    }

    // MARK: - XML Support

    @objc func xmlTree1_0Rings() -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "rings"

        // Add ring-specific attributes
        tree.addAttribute("fixed_count", value: fixedCount ? "YES" : "NO")
        tree.addAttribute("visible", value: ringsVisible ? "YES" : "NO")
        tree.addAttribute("fixed_ring_count", value: String(fixedRingCount))
        tree.addAttribute("ring_count_increment", value: String(ringCountIncrement))
        tree.addAttribute("ring_percent_increment", value: String(format: "%.1f", ringPercentIncrement))
        tree.addAttribute("show_labels", value: showRingLabels ? "YES" : "NO")
        tree.addAttribute("label_angle", value: String(format: "%.1f", labelAngle))

        return tree
    }

    @objc func xmlTree1_0Radials() -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "radials"

        // Add radial-specific attributes
        tree.addAttribute("count", value: String(spokeCount))
        tree.addAttribute("angle", value: String(format: "%.1f", spokeAngle))
        tree.addAttribute("sector_lock", value: spokeSectorLock ? "YES" : "NO")
        tree.addAttribute("visible", value: spokesVisible ? "YES" : "NO")
        tree.addAttribute("show_labels", value: showLabels ? "YES" : "NO")
        tree.addAttribute("points_only", value: pointsOnly ? "YES" : "NO")
        tree.addAttribute("label_align", value: String(spokeNumberAlign))
        tree.addAttribute("compass_point", value: String(spokeNumberCompassPoint))
        tree.addAttribute("order", value: String(spokeNumberOrder))

        return tree
    }

    override func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        super.configure(withXMLTree1_0: configureTree)

        for child in configureTree.children() {
            switch child.elementName {
            case "rings":
                configureRings(from: child)
            case "radials":
                configureRadials(from: child)
            default:
                break
            }
        }
    }

    private func configureRings(from tree: LITMXMLTree) {
        if let attributes = tree.attributesDictionary() as? [String: String] {
            fixedCount = attributes["fixed_count"] == "YES"
            ringsVisible = attributes["visible"] == "YES"
            fixedRingCount = Int(attributes["fixed_ring_count"] ?? "0") ?? 0
            ringCountIncrement = Int(attributes["ring_count_increment"] ?? "0") ?? 0
            ringPercentIncrement = Float(attributes["ring_percent_increment"] ?? "0.0") ?? 0.0
            showRingLabels = attributes["show_labels"] == "YES"
            labelAngle = Float(attributes["label_angle"] ?? "0.0") ?? 0.0
        }
    }

    private func configureRadials(from tree: LITMXMLTree) {
        if let attributes = tree.attributesDictionary() as? [String: String] {
            spokeCount = Int(attributes["count"] ?? "0") ?? 0
            spokeAngle = Float(attributes["angle"] ?? "0.0") ?? 0.0
            spokeSectorLock = attributes["sector_lock"] == "YES"
            spokesVisible = attributes["visible"] == "YES"
            showLabels = attributes["show_labels"] == "YES"
            pointsOnly = attributes["points_only"] == "YES"
            spokeNumberAlign = Int(attributes["label_align"] ?? "0") ?? 0
            spokeNumberCompassPoint = Int(attributes["compass_point"] ?? "0") ?? 0
            spokeNumberOrder = Int(attributes["order"] ?? "0") ?? 0
        }
    }

    // MARK: - Drawing

    override func generateGraphics() {
        if spokesVisible {
            generateSpokes()
        }
        if ringsVisible {
            generateRings()
        }
    }

    private func generateSpokes() {
        // Implement spoke graphics generation
    }

    private func generateRings() {
        // Implement ring graphics generation
    }

    override func draw(_: NSRect) {
        // Draw grid graphics
    }
}
