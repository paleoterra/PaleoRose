// XRLayerData.swift
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

enum XRLayerDataPlotType: Int {
    case petal = 0
    case histogram = 1
    case dot = 2
    case dotDeviation = 3
    case kite = 4
}

let XRLayerDataDefaultKeyType = "XRLayerDataDefaultKeyType"
let XRLayerDataStatisticsDidChange = "XRLayerDataStatisticsDidChange"

@objc class XRLayerData: XRLayer {
    // MARK: - Properties

    private var theSet: XRDataSet?
    private var plotType: XRLayerDataPlotType = .petal
    private var totalCount: Int = 0
    private var dotRadius: Float = 0.0

    private var sectorValues: [Float] = []
    private var sectorValuesCount: [Int] = []
    private var statistics: [Any] = []

    // MARK: - Class Methods

    override class func classTag() -> String {
        "Data"
    }

    // MARK: - Initialization

    @objc init(geometryController: XRGeometryController, withSet set: XRDataSet) {
        super.init(geometryController: geometryController)
        theSet = set
        setupDefaults()
    }

    @objc init(geometryController: XRGeometryController, withSet set: XRDataSet, dictionary: [String: Any]) {
        super.init(geometryController: geometryController, dictionary: dictionary)
        theSet = set
        configureSelf(with: dictionary)
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
               plotType: Int,
               totalCount: Int,
               dotRadius: Float)
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
        self.plotType = XRLayerDataPlotType(rawValue: plotType) ?? .petal
        self.totalCount = totalCount
        self.dotRadius = dotRadius
    }

    required init(geometryController: XRGeometryController) {
        super.init(geometryController: geometryController)
    }

    required init(geometryController: XRGeometryController, dictionary: [String: Any]) {
        super.init(geometryController: geometryController, dictionary: dictionary)
    }

    override required init() {
        super.init()
    }

    // MARK: - Setup Methods

    private func setupDefaults() {
        plotType = .petal
        dotRadius = 3.0
        calculateSectorValues()
    }

    private func configureSelf(with dictionary: [String: Any]) {
        if let plotTypeInt = dictionary["Plot_Type"] as? Int {
            plotType = XRLayerDataPlotType(rawValue: plotTypeInt) ?? .petal
        }

        if let radius = dictionary["Dot_Radius"] as? String {
            dotRadius = Float(radius) ?? 3.0
        }

        calculateSectorValues()
    }

    // MARK: - Public Methods

    @objc func setPlotType(_ newType: Int) {
        guard let type = XRLayerDataPlotType(rawValue: newType) else { return }
        plotType = type
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getPlotType() -> Int {
        plotType.rawValue
    }

    @objc func calculateSectorValues() {
        sectorValues.removeAll()
        sectorValuesCount.removeAll()

        // Calculate sector values based on dataset
        // Implementation depends on data structure

        setStatisticsArray()
    }

    @objc func getTotalCount() -> Int {
        totalCount
    }

    @objc func setDotRadius(_ radius: Float) {
        dotRadius = radius
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getDotRadius() -> Float {
        dotRadius
    }

    @objc func getDatasetId() -> Int {
        theSet?.datasetId ?? -1
    }

    // MARK: - Statistics

    @objc func setStatisticsArray() {
        statistics.removeAll()
        // Calculate statistics based on sector values
        // Implementation depends on statistics requirements

        NotificationCenter.default.post(name: NSNotification.Name(XRLayerDataStatisticsDidChange), object: self)
    }

    @objc func statisticsArray() -> [Any] {
        statistics
    }

    @objc override func getDataSet() -> XRDataSet? {
        theSet
    }

    // MARK: - XML Support

    @objc func xmlTree1_0() -> LITMXMLTree {
        let tree = super.baseXMLTree(forVersion: "1.0")
        tree.addAttribute("Plot_Type", value: String(plotType.rawValue))
        tree.addAttribute("Dot_Radius", value: String(format: "%.1f", dotRadius))

        if let datasetId = theSet?.datasetId {
            tree.addAttribute("Dataset_ID", value: String(datasetId))
        }

        return tree
    }

    override func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        super.configure(withXMLTree1_0: configureTree)

        if let attributes = configureTree.attributesDictionary() as? [String: String] {
            if let plotTypeStr = attributes["Plot_Type"],
               let plotTypeInt = Int(plotTypeStr),
               let type = XRLayerDataPlotType(rawValue: plotTypeInt)
            {
                plotType = type
            }

            if let radiusStr = attributes["Dot_Radius"] {
                dotRadius = Float(radiusStr) ?? 3.0
            }
        }
    }

    // MARK: - Drawing

    override func generateGraphics() {
        // Generate graphics based on plot type
        switch plotType {
        case .petal:
            generatePetalGraphics()
        case .histogram:
            generateHistogramGraphics()
        case .dot:
            generateDotGraphics()
        case .dotDeviation:
            generateDotDeviationGraphics()
        case .kite:
            generateKiteGraphics()
        }
    }

    private func generatePetalGraphics() {
        // Implement petal graphics generation
    }

    private func generateHistogramGraphics() {
        // Implement histogram graphics generation
    }

    private func generateDotGraphics() {
        // Implement dot graphics generation
    }

    private func generateDotDeviationGraphics() {
        // Implement dot deviation graphics generation
    }

    private func generateKiteGraphics() {
        // Implement kite graphics generation
    }

    override func draw(_: NSRect) {
        // Draw graphics based on plot type
    }

    // MARK: - Notification Handlers

    override func geometryDidChange(_: Notification) {
        calculateSectorValues()
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    override func geometryDidChangePercent(_: Notification) {
        calculateSectorValues()
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }
}
