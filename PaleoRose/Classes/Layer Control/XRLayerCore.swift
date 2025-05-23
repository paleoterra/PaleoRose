// XRLayerCore.swift
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

let XRLayerCoreTypeOverlay = false
let XRLayerCoreTypeHollow = true

let XRLayerCoreXMLCoreType = "CORE_TYPE"
let XRLayerCoreXMLCoreRadius = "CORE_RADIUS"

@objc class XRLayerCore: XRLayer {
    // MARK: - Properties
    
    private var coreType: Bool = XRLayerCoreTypeOverlay
    private var corePattern: NSImage?
    private var percentRadius: Float = 0.0
    
    // MARK: - Class Methods
    
    override class func classTag() -> String {
        return "Core"
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
               percentRadius: Float,
               type: Bool) {
        super.init()
        
        setIsVisible(isVisible)
        setIsActive(active)
        setBiDirectional(biDir)
        setLayerName(name)
        setLineWeight(lineWeight)
        maxCount = maxCount
        maxPercent = maxPercent
        setStrokeColor(strokeColor)
        setFillColor(fillColor)
        self.percentRadius = percentRadius
        self.coreType = type
    }
    
    required init(geometryController: XRGeometryController) {
        super.init(geometryController: geometryController)
    }
    
    required init(geometryController: XRGeometryController, dictionary: [String: Any]) {
        super.init(geometryController: geometryController, dictionary: dictionary)
        
        if let radiusStr = dictionary["Core_Radius"] as? String {
            percentRadius = Float(radiusStr) ?? 0.0
        }
        
        if let typeStr = dictionary["Core_Type"] as? String {
            coreType = (typeStr == "YES")
        }
    }
    
    required override init() {
        super.init()
    }
    
    // MARK: - Core Properties
    
    @objc func coreRadiusIsEditable() -> Bool {
        return true
    }
    
    @objc func getCoreType() -> Bool {
        return coreType
    }
    
    @objc func getRadius() -> Float {
        return percentRadius
    }
    
    // MARK: - XML Support
    
    override func xmlTree(forVersion version: String) -> LITMXMLTree {
        let tree = super.baseXMLTree(forVersion: version)
        tree.addAttribute(XRLayerCoreXMLCoreType, value: coreType ? "YES" : "NO")
        tree.addAttribute(XRLayerCoreXMLCoreRadius, value: String(format: "%.1f", percentRadius))
        return tree
    }
    
    override func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        if let attributes = configureTree.attributesDictionary() as? [String: String] {
            coreType = attributes[XRLayerCoreXMLCoreType] == "YES"
            if let radiusStr = attributes[XRLayerCoreXMLCoreRadius] {
                percentRadius = Float(radiusStr) ?? 0.0
            }
        }
    }
    
    // MARK: - Drawing
    
    override func generateGraphics() {
        // Implement core-specific graphics generation
    }
    
    override func draw(_ rect: NSRect) {
        // Implement core-specific drawing
    }
    
    // MARK: - Notification Handlers
    
    override func geometryDidChange(_ notification: Notification) {
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }
    
    override func geometryDidChangePercent(_ notification: Notification) {
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }
    
    override func geometryDidChangeSectors(_ notification: Notification) {
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }
}
