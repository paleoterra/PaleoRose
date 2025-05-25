// XRLayerLineArrow.swift
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

@objc class XRLayerLineArrow: XRLayer {
    // MARK: - Properties

    private var theSet: XRDataSet?
    private var arrowSize: Float = 10.0
    private var type: Int = 0
    private var headType: Int = 0
    private var showVector: Bool = true
    private var showError: Bool = false

    // MARK: - Class Methods

    override class func classTag() -> String {
        "LineArrow"
    }

    // MARK: - Initialization

    @objc init(geometryController: XRGeometryController, withSet set: XRDataSet) {
        super.init(geometryController: geometryController)
        theSet = set
        setupDefaults()
    }

    @objc init(isVisible: Bool,
               active: Bool,
               biDir: Bool,
               name: String,
               lineWeight: Float,
               maxCount: Int,
               maxPercent: Float,
               strokeColor: NSColor,
               fillColor: NSColor,
               arrowSize: Float,
               vectorType: Int,
               arrowType: Int,
               showVector: Bool,
               showError: Bool)
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

        self.arrowSize = arrowSize
        type = vectorType
        headType = arrowType
        self.showVector = showVector
        self.showError = showError
    }

    required init(geometryController: XRGeometryController) {
        super.init(geometryController: geometryController)
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
        arrowSize = 10.0
        type = 0
        headType = 0
        showVector = true
        showError = false
    }

    private func configureSelf(with dictionary: [String: Any]) {
        if let size = dictionary["Arrow_Size"] as? Float {
            arrowSize = size
        }
        if let vectorType = dictionary["Vector_Type"] as? Int {
            type = vectorType
        }
        if let arrowType = dictionary["Arrow_Type"] as? Int {
            headType = arrowType
        }
        if let showVec = dictionary["Show_Vector"] as? String {
            showVector = (showVec == "YES")
        }
        if let showErr = dictionary["Show_Error"] as? String {
            showError = (showErr == "YES")
        }
    }

    // MARK: - Public Methods

    @objc func configureError(withVector vAngle: Float, error: Float) {
        // Configure error settings for vector and error angles
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getDatasetId() -> Int {
        theSet?.datasetId ?? -1
    }

    @objc func getArrowSize() -> Float {
        arrowSize
    }

    @objc func getVectorType() -> Int {
        type
    }

    @objc func getArrowType() -> Int {
        headType
    }

    @objc func getShowVector() -> Bool {
        showVector
    }

    @objc func getShowError() -> Bool {
        showError
    }

    // MARK: - XML Support

    override func xmlTree(forVersion version: String) -> LITMXMLTree {
        let tree = super.baseXMLTree(forVersion: version)

        tree.addAttribute("Arrow_Size", value: String(format: "%.1f", arrowSize))
        tree.addAttribute("Vector_Type", value: String(type))
        tree.addAttribute("Arrow_Type", value: String(headType))
        tree.addAttribute("Show_Vector", value: showVector ? "YES" : "NO")
        tree.addAttribute("Show_Error", value: showError ? "YES" : "NO")

        if let datasetId = theSet?.datasetId {
            tree.addAttribute("Dataset_ID", value: String(datasetId))
        }

        return tree
    }

    override func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        super.configure(withXMLTree1_0: configureTree)

        if let attributes = configureTree.attributesDictionary() as? [String: String] {
            if let sizeStr = attributes["Arrow_Size"] {
                arrowSize = Float(sizeStr) ?? 10.0
            }
            if let typeStr = attributes["Vector_Type"] {
                type = Int(typeStr) ?? 0
            }
            if let arrowTypeStr = attributes["Arrow_Type"] {
                headType = Int(arrowTypeStr) ?? 0
            }
            showVector = attributes["Show_Vector"] == "YES"
            showError = attributes["Show_Error"] == "YES"
        }
    }

    // MARK: - Drawing

    override func generateGraphics() {
        // Generate line and arrow graphics based on settings
        if showVector {
            generateVectorGraphics()
        }
        if showError {
            generateErrorGraphics()
        }
    }

    private func generateVectorGraphics() {
        // Implement vector graphics generation
    }

    private func generateErrorGraphics() {
        // Implement error graphics generation
    }

    override func draw(_: NSRect) {
        // Draw line and arrow graphics
    }

    // MARK: - Notification Handlers

    override func geometryDidChange(_: Notification) {
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }
}
