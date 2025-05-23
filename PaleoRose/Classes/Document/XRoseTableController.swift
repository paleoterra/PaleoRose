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
import SQLite3

// MARK: - Constants

let XRLayerDragType = "XRLayerDragType"

extension Notification.Name {
    static let XRLayerTableRequiresReload = Notification.Name("XRLayerTableRequiresReload")
    static let XRLayerRequiresRedraw = Notification.Name("XRLayerRequiresRedraw")
    static let XRLayerSelectionDidChange = Notification.Name("XRLayerSelectionDidChange")
    static let XRLayerSelectionIsChanging = Notification.Name("XRLayerSelectionIsChanging")
}

// swiftlint:disable:next type_body_length
class XRoseTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Private Constants

    private enum ColumnIdentifier: String {
        case layerName = "name"
        case layerColors = "colors"
        case isVisible = "visible"

        var tooltip: String {
            switch self {
            case .layerName: "Layer name (double-click to edit)"
            case .layerColors: "Layer colors"
            case .isVisible: "Toggle layer visibility"
            }
        }
    }

    @IBOutlet private var rosePlotController: XRGeometryController!
    @IBOutlet private var roseTableView: NSTableView!
    @IBOutlet private var roseView: XRoseView!
    @IBOutlet private var windowController: NSWindowController!

    // MARK: - Properties

    private var colorArray: [NSColor] = []
    private var theLayers: [XRLayer] = [] {
        didSet {
            roseTableView?.reloadData()
            roseView?.display()
        }
    }

    private var timer: Timer?
    private var vStatController: XRVStatCreatePanelController?

    private var nextColorIndex: Int = 0 {
        didSet {
            if nextColorIndex >= colorArray.count {
                nextColorIndex = 0
            }
        }
    }

    // MARK: - Lifecycle

    override init() {
        super.init()
        setColorArray()
    }

    deinit {
        cleanup()
    }

    private func cleanup() {
        // Stop any running timer
        timer?.invalidate()
        timer = nil

        // Remove all observers and clear layers
        for layer in theLayers {
            unregisterNotifications(for: layer)
        }
        theLayers.removeAll()

        // Clear controller references
        vStatController = nil
    }

    func addDataLayer(for set: XRDataSet) {
        let dataLayer = XRLayerData(geometryController: rosePlotController, set: set)

        if layerExists(withName: dataLayer.layerName) {
            dataLayer.layerName = newLayerName(forBaseName: dataLayer.layerName)
        }

        applyColors(to: dataLayer)
        registerNotifications(for: dataLayer)
        theLayers.append(dataLayer)
    }

    // MARK: - Notification Handling

    private func registerNotifications(for layer: XRLayer) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(layerRequestsReload(_:)),
            name: .XRLayerTableRequiresReload,
            object: layer
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(layerRequestsRedraw(_:)),
            name: .XRLayerRequiresRedraw,
            object: layer
        )
    }

    private func unregisterNotifications(for layer: XRLayer) {
        NotificationCenter.default.removeObserver(
            self,
            name: .XRLayerTableRequiresReload,
            object: layer
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .XRLayerRequiresRedraw,
            object: layer
        )
    }

    @objc private func layerRequestsReload(_: Notification) {
        roseTableView.reloadData()
    }

    @objc private func layerRequestsRedraw(_: Notification) {
        roseView.display()
    }

    @objc private func triggerDrawing(_: Timer) {
        timer = nil
        roseView.display()
    }

    func draw(_ rect: NSRect) {
        for layer in theLayers.reversed() {
            layer.draw(rect)
        }
    }

    func calculateGeometryMaxCount() -> Int {
        theLayers.compactMap { layer -> Int? in
            guard let dataLayer = layer as? XRLayerData else { return nil }
            return dataLayer.maxCount
        }.max() ?? -1
    }

    func calculateGeometryMaxPercent() -> Float {
        theLayers.compactMap { layer -> Float? in
            guard let dataLayer = layer as? XRLayerData else { return nil }
            return dataLayer.maxPercent
        }.max() ?? -1.0
    }

    func displaySelectedLayerInInspector() {
        if roseTableView.selectedRow == -1 || roseTableView.selectedRowIndexes.count > 1 {
            XRPropertyInspector.defaultInspector().displayInfo(for: nil)
            return
        }

        let row = roseTableView.selectedRow
        for (index, layer) in theLayers.enumerated() {
            layer.isActive = index == row
            if index == row {
                XRPropertyInspector.defaultInspector().displayInfo(for: layer)
            }
        }
    }

    // MARK: - Drag and Drop

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        guard info.draggingSource as? NSTableView === tableView else { return false }

        if let rows = info.draggingPasteboard.propertyList(forType: .init(rawValue: XRLayerDragType)) as? [Int] {
            moveLayers(rows, toRow: row)
            return true
        }
        return false
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation {
        info.draggingSource as? NSTableView === tableView ? .move : []
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        pboard.declareTypes([.init(rawValue: XRLayerDragType)], owner: self)
        pboard.setPropertyList(Array(rowIndexes), forType: .init(rawValue: XRLayerDragType))
        return true
    }

    private func moveLayers(_ layerNumbers: [Int], toRow row: Int) {
        var movedLayers: [XRLayer] = []
        for number in layerNumbers.reversed() {
            movedLayers.insert(theLayers.remove(at: number), at: 0)
        }

        for (index, layer) in movedLayers.enumerated() {
            let targetRow = row + index
            if targetRow >= theLayers.count {
                theLayers.append(layer)
            } else {
                theLayers.insert(layer, at: targetRow)
            }
        }

        roseTableView.reloadData()
        roseTableView.deselectAll(nil)
        roseView.display()
    }

    // MARK: - Color Management

    private func setColorArray() {
        colorArray = [
            .black,
            .blue,
            .brown,
            .cyan,
            .darkGray,
            .gray,
            .green,
            .lightGray,
            .magenta,
            .orange,
            .purple,
            .red,
            .yellow
        ]
    }

    private func nextColor() -> NSColor {
        let color = colorArray[nextColorIndex]
        nextColorIndex += 1
        return color
    }

    private func applyColors(to layer: XRLayerData) {
        let color = nextColor()
        layer.strokeColor = color
        layer.fillColor = color
    }

    // MARK: - Layer Management

    @IBAction func addCoreLayer(_: Any) {
        let core = XRLayerCore(geometryController: rosePlotController)
        if layerExists(withName: core.layerName) {
            core.layerName = newLayerName(forBaseName: core.layerName)
        }

        registerNotifications(for: core)
        theLayers.insert(core, at: 0)
    }

    @IBAction func addGridLayer(_: Any) {
        let grid = XRLayerGrid(geometryController: rosePlotController)
        if layerExists(withName: grid.layerName) {
            grid.layerName = newLayerName(forBaseName: grid.layerName)
        }

        registerNotifications(for: grid)
        theLayers.insert(grid, at: 0)
    }

    @IBAction func addTextLayer(_: Any) {
        let text = XRLayerText(geometryController: rosePlotController, parentView: roseTableView)
        if layerExists(withName: text.layerName) {
            text.layerName = newLayerName(forBaseName: text.layerName)
        }

        registerNotifications(for: text)
        theLayers.insert(text, at: 0)
    }

    @IBAction func deleteLayers(_: Any) {
        let selectedRows = roseTableView.selectedRowIndexes
        var dataSets: [XRDataSet] = []

        // First pass: collect data sets and remove selected layers
        for index in (0 ..< theLayers.count).reversed() where selectedRows.contains(index) {
            let layer = theLayers[index]
            unregisterNotifications(for: layer)

            if let dataLayer = layer as? XRLayerData {
                dataSets.append(dataLayer.dataSet)
            }
            theLayers.remove(at: index)
        }

        // Second pass: remove dependent layers
        let dependentLayers = theLayers.enumerated().filter { _, layer in
            guard let dataLayer = layer as? XRLayerData else { return false }
            return dataSets.contains(dataLayer.dataSet)
        }

        for (index, layer) in dependentLayers.reversed() {
            unregisterNotifications(for: layer)
            theLayers.remove(at: index)
        }

        // Remove data sets from document
        if let document = windowController.document as? XRoseDocument {
            dataSets.forEach { document.removeDataSet($0) }
        }

        roseTableView.reloadData()
        roseTableView.deselectAll(nil)
        roseView.display()
    }

    func deleteLayer(_ layer: XRLayer) {
        theLayers.removeAll { $0 === layer }
        unregisterNotifications(for: layer)

        if let document = windowController.document as? XRoseDocument {
            document.removeDataSet(layer.dataSet)
        }

        roseTableView.reloadData()
        roseView.display()
    }

    func deleteLayersForTableName(_ tableName: String) {
        let layersToDelete = theLayers.filter {
            $0.dataSet?.tableName == tableName
        }
        layersToDelete.forEach { deleteLayer($0) }
    }

    var lastLayer: XRLayer? {
        theLayers.last
    }

    func layerExists(withName name: String) -> Bool {
        theLayers.contains { $0.layerName == name }
    }

    func newLayerName(forBaseName name: String) -> String {
        var index = 1
        var newName: String
        repeat {
            newName = "\(name)-\(index)"
            index += 1
        } while layerExists(withName: newName)
        return newName
    }

    // MARK: - Layer Settings

    var layersSettings: [String: Any] {
        ["layers": theLayers.map(\.layerSettings)]
    }

    // MARK: - Configuration

    func configureController(_ settings: [String: Any]) {
        guard let layerSettings = settings["layers"] as? [[String: Any]] else { return }
        theLayers.removeAll()

        for settings in layerSettings {
            guard let layerType = settings["Layer_Type"] as? String else { continue }

            if let layer = createLayer(ofType: layerType, withSettings: settings) {
                registerNotifications(for: layer)
                theLayers.append(layer)
            }
        }
    }

    private func createLayer(ofType type: String, withSettings settings: [String: Any]) -> XRLayer? {
        switch type {
        case "Grid_Layer":
            return XRLayerGrid(geometryController: rosePlotController, dictionary: settings)

        case "Data_Layer":
            guard let data = settings["values"] as? Data,
                  let name = settings["Layer_Name"] as? String,
                  let document = windowController.document as? XRoseDocument
            else {
                return nil
            }

            let dataSet = XRDataSet(data: data, name: name)
            document.addDataSet(dataSet)
            return XRLayerData(geometryController: rosePlotController,
                               set: dataSet,
                               dictionary: settings)

        case "Core_Layer":
            return XRLayerCore(geometryController: rosePlotController, dictionary: settings)

        default:
            return nil
        }
    }

    private func addObservers(for layer: XRLayer) {
        registerNotifications(for: layer)
    }

    // MARK: - Data Layer Management

    var dataLayerNames: [String] {
        theLayers.compactMap { layer -> String? in
            guard layer is XRLayerData else { return nil }
            return layer.layerName
        }
    }

    private func dataLayer(withName name: String) -> XRLayer? {
        theLayers.first { layer in
            guard layer is XRLayerData else { return false }
            return layer.layerName == name
        }
    }

    @IBAction func displaySheetForVStatLayer(_: Any) {
        let names = dataLayerNames
        guard !names.isEmpty else { return }

        vStatController = XRVStatCreatePanelController(array: names)
        windowController.window?.beginSheet(vStatController!.window!) { response in
            if response == .OK,
               let selectedName = self.vStatController?.selectedName,
               let targetLayer = self.dataLayer(withName: selectedName) as? XRLayerData
            {
                let arrowLayer = XRLayerLineArrow(geometryController: self.rosePlotController,
                                                  set: targetLayer.dataSet)
                self.theLayers.append(arrowLayer)
                self.addObservers(for: arrowLayer)
                self.roseTableView.reloadData()
                self.roseView.display()
            }
            self.vStatController = nil
        }
    }

    // MARK: - XML Support

    func xmlTree(forVersion version: String) -> LITMXMLTree {
        let root = LITMXMLTree(elementTag: "LAYERS")
        for layer in theLayers {
            if let xmlTree = layer.xmlTree(forVersion: version) {
                root.addChild(xmlTree)
            }
        }
        return root
    }

    func configureController(withXMLTree tree: LITMXMLTree, version: String, dataSets: [XRDataSet]) {
        theLayers.removeAll()

        for index in 0 ..< tree.childCount {
            guard let childTree = tree.child(at: index),
                  let layer = XRLayer.layer(withGeometryController: rosePlotController,
                                            xmlTree: childTree,
                                            version: version,
                                            parentView: roseTableView) else { continue }

            if configureDataLayer(layer, withXMLTree: childTree, dataSets: dataSets) {
                registerNotifications(for: layer)
                theLayers.append(layer)
            }
        }
    }

    private func configureDataLayer(_ layer: XRLayer, withXMLTree tree: LITMXMLTree, dataSets: [XRDataSet]) -> Bool {
        // For non-data layers, just return true
        guard layer is XRLayerData || layer is XRLayerLineArrow else { return true }

        // For data layers, we need to find and set the dataset
        guard let name = tree.findXMLTreeElement("PARENTDATA")?.contentsString,
              let dataSet = dataSets.first(where: { $0.name == name }) else { return false }

        layer.dataSet = dataSet
        return true
    }

    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        theLayers.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < theLayers.count,
              let columnId = ColumnIdentifier(rawValue: tableColumn?.identifier.rawValue ?? "") else { return nil }

        let layer = theLayers[row]
        switch columnId {
        case .layerName: return layer.layerName
        case .layerColors: return layer.colorImage
        case .isVisible: return layer.isVisible ? NSControl.StateValue.on : NSControl.StateValue.off
        }
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard row < theLayers.count,
              let columnId = ColumnIdentifier(rawValue: tableColumn?.identifier.rawValue ?? "") else { return }

        let layer = theLayers[row]
        switch columnId {
        case .layerName:
            guard let name = object as? String else { return }
            layer.layerName = name

        case .isVisible:
            guard let state = object as? NSNumber else { return }
            layer.isVisible = state.intValue == NSControl.StateValue.on.rawValue
            roseView.display()

        case .layerColors: break
        }
    }

    // MARK: - NSTableViewDelegate

    func tableViewSelectionDidChange(_: Notification) {
        displaySelectedLayerInInspector()
        NotificationCenter.default.post(name: .XRLayerSelectionDidChange, object: self)
    }

    func tableViewSelectionIsChanging(_: Notification) {
        NotificationCenter.default.post(name: .XRLayerSelectionIsChanging, object: self)
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        row < theLayers.count
    }

    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        guard row < theLayers.count,
              let columnId = ColumnIdentifier(rawValue: tableColumn?.identifier.rawValue ?? "") else { return "" }

        let layer = theLayers[row]
        return "\(columnId.tooltip)\n\(layer.layerName)"
    }

    // MARK: - Mouse Event Handling

    func handleMouseEvent(_ event: NSEvent) {
        for (index, layer) in theLayers.enumerated() where roseTableView.isRowSelected(index) {
            if layer.handleMouseEvent(event) {
                break
            }
        }
    }

    func activeLayer(withPoint point: NSPoint) -> XRLayer? {
        for (index, layer) in theLayers.enumerated() where roseTableView.isRowSelected(index) {
            if layer.hitDetection(point) {
                return layer
            }
        }
        return nil
    }

    // MARK: - Statistics

    private func selectedDataLayers() -> [XRLayerData] {
        let selectedIndexes = roseTableView.selectedRowIndexes
        return theLayers.enumerated()
            .filter { selectedIndexes.contains($0.offset) }
            .compactMap { $0.element as? XRLayerData }
    }

    func generateStatisticsString() -> String {
        selectedDataLayers()
            .map(\.statisticsString)
            .joined(separator: "\n")
    }

    @IBAction func showStatistics(_: Any) {
        vStatController = vStatController ?? XRVStatCreatePanelController()
        vStatController?.statisticsString = generateStatisticsString()
        vStatController?.showWindow(nil)
    }

    // MARK: - SQLite Support

    @available(*, deprecated, message: "Use modern persistence methods instead")
    private enum SQLiteError: Error {
        case prepareFailed(String)
        case stepFailed(String)
        case invalidData(String)
    }

    @available(*, deprecated, message: "Use modern persistence methods instead")
    func saveToSQLite(_ db: OpaquePointer?, tableName: String) {
        theLayers
            .compactMap { $0 as? XRLayerData }
            .forEach { $0.saveToSQLite(db, tableName: tableName) }
    }

    @available(*, deprecated, message: "Use modern persistence methods instead")
    func configureFromSQLite(_ db: OpaquePointer?, tableName: String) {
        let query = "SELECT * FROM \(tableName)"
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing SQLite statement: \(String(cString: sqlite3_errmsg(db)))")
            return
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let dataLayer = XRLayerData(geometryController: rosePlotController)
            dataLayer.configureFromSQLite(statement)
            registerNotifications(for: dataLayer)
            theLayers.append(dataLayer)
        }
    }

    @available(*, deprecated, message: "Use modern persistence methods instead")
    func deleteLayersForTableName(_ tableName: String) {
        theLayers.removeAll { layer in
            guard let dataLayer = layer as? XRLayerData,
                  dataLayer.dataSet.name == tableName else { return false }

            unregisterNotifications(for: layer)
            return true
        }
    }
}
