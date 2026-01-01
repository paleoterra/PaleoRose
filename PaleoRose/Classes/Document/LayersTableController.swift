//
// LayersTableController.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2025 to present Thomas L. Moore.
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
import Combine

// MARK: - Constants

// swiftlint:disable file_length
private let layerDragType = NSPasteboard.PasteboardType("LayerDragType")

/// Controller for managing the layers table view
/// Displays layers from DocumentModel and delegates all data operations back to DocumentModel
@objc class LayersTableController: NSObject {

    // MARK: - Properties

    private var layers: [XRLayer] = []
    private var cancellables = Set<AnyCancellable>()
    private var colorArray: [NSColor] = []
    private var currentColorIndex: Int = 0

    @objc weak var tableView: NSTableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.registerForDraggedTypes([layerDragType])
            tableView?.reloadData()
        }
    }

    weak var dataSource: LayerTableControllerDataSource? {
        didSet {
            setupDataSourceSubscription()
        }
    }

    @objc weak var roseView: NSView?
    @objc weak var rosePlotController: XRGeometryController?
    @objc weak var windowController: NSWindowController?

    // MARK: - Initialization

    @objc init(dataSource: DocumentModel?, geometryController: XRGeometryController?) {
        rosePlotController = geometryController
        super.init()
        self.dataSource = dataSource
        setColorArray()
        setupDataSourceSubscription()
        setupLayerRedrawObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Objective-C compatible method to set data source
    @objc func setDataSource(_ source: DocumentModel) {
        dataSource = source
        // Update geometry controller reference when data source is set
        rosePlotController = source.geometryController
    }

    /// Objective-C compatible method to update geometry controller
    @objc func setGeometryController(_ controller: XRGeometryController) {
        rosePlotController = controller
    }

    // MARK: - Private Methods

    private func setupDataSourceSubscription() {
        cancellables.removeAll()

        guard let dataSource else {
            return
        }

        // Subscribe to layers publisher
        dataSource.layersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedLayers in
                guard let self else {
                    return
                }
                layers = receivedLayers
                tableView?.reloadData()
                roseView?.setNeedsDisplay(roseView?.bounds ?? .zero)
            }
            .store(in: &cancellables)
    }

    private func setupLayerRedrawObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(layerRequiresRedraw(_:)),
            name: Notification.Name(rawValue: "XRLayerRequiresRedraw"),
            object: nil
        )
    }

    @objc private func layerRequiresRedraw(_: Notification) {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            guard let self, let roseView else {
                return
            }
            roseView.setNeedsDisplay(roseView.bounds)
        }
    }

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
        let color = colorArray[currentColorIndex]
        currentColorIndex = (currentColorIndex + 1) % colorArray.count
        return color
    }

    // MARK: - Layer Display & Drawing

    @objc func drawRect(_ rect: NSRect) {
        // Draw layers in reverse order (back to front)
        for layer in layers.reversed() {
            layer.draw(rect)
        }
    }

    @objc func detectLayerHitAtPoint(_: NSPoint) {
        // Deselect all rows when hitting background
        if let tableView {
            for row in 0 ..< layers.count {
                tableView.deselectRow(row)
            }
        }
    }

    @objc func displaySelectedLayerInInspector() {
        guard let tableView else {
            return
        }
        guard let inspector = XRPropertyInspector.defaultInspector() as? XRPropertyInspector else { return }

        let selectedRowCount = tableView.numberOfSelectedRows

        if selectedRowCount == 0 {
            inspector.displayInfo(for: nil)
        } else if selectedRowCount > 1 {
            inspector.displayInfo(for: nil)
        } else {
            let row = tableView.selectedRow
            guard layers.indices.contains(row) else { return }

            // Set active state
            for (index, layer) in layers.enumerated() {
                layer.setIsActive(index == row)
            }

            inspector.displayInfo(for: layers[row])
        }
    }

    @objc func calculateGeometryMaxCount() -> Int {
        var maxCount: Int32 = -1

        for layer in layers where layer.isKind(of: XRLayerData.self) {
            let count = layer.maxCount()
            if count > maxCount {
                maxCount = count
            }
        }

        return Int(maxCount)
    }

    @objc func calculateGeometryMaxPercent() -> Float {
        var maxPercent: Float = -1.0

        for layer in layers where layer.isKind(of: XRLayerData.self) {
            let percent = layer.maxPercent()
            if percent > maxPercent {
                maxPercent = percent
            }
        }

        return maxPercent
    }

    // MARK: - Layer Creation (Pass-Through to DocumentModel)

    @objc func addDataLayer(for set: XRDataSet) {
        guard let dataSource, rosePlotController != nil else { return }

        // Extract dataset name
        let dataSetName = set.tableName()

        // Get next color
        let color = nextColor()

        // Generate unique name if needed
        let baseName = set.name() ?? dataSetName ?? "Layer"
        let uniqueName = layerExists(withName: baseName) ? newLayerName(forBaseName: baseName) : baseName

        // Delegate to DocumentModel
        dataSource.createDataLayer(
            dataSetName: dataSetName ?? "Unknown",
            color: color,
            name: uniqueName
        )
    }

    @objc func addCoreLayer(_: Any?) {
        guard let dataSource else { return }

        let uniqueName = newLayerName(forBaseName: "Core")
        dataSource.createCoreLayer(name: uniqueName)
    }

    @objc func addGridLayer(_: Any?) {
        guard let dataSource else { return }

        let uniqueName = newLayerName(forBaseName: "Grid")
        dataSource.createGridLayer(name: uniqueName)
    }

    @objc func addTextLayer(_: Any?) {
        guard let dataSource, let roseView else { return }

        let uniqueName = newLayerName(forBaseName: "Text")
        dataSource.createTextLayer(name: uniqueName, parentView: roseView)
    }

    @objc func displaySheetForVStatLayer(_: Any?) {
//        guard let dataSource, let rosePlotController, let windowController else { return }
//
//        let layerNames = dataLayerNames()
//        guard !layerNames.isEmpty else { return }

//         Create the panel controller
//         TODO: Re-enable when XRVStatCreatePanelController is accessible from Swift
//         guard let panelController = XRVStatCreatePanelController(array: layerNames) else { return }
//
//         // Show the sheet
//         windowController.window?.beginSheet(panelController.window) { [weak self, weak dataSource, weak panelController] response in
//             guard let self, let dataSource, let panelController else { return }
//
//             if response == .OK {
//                 let selectedName = panelController.selectedName()
//
//                 // Find the dataset name from the selected layer
//                 if let selectedLayer = dataLayer(withName: selectedName) as? XRLayerData {
//                     let dataSetName = selectedLayer.dataSet().tableName()
//                     dataSource.createLineArrowLayer(
//                         dataSetName: dataSetName ?? "Unknown",
//                         name: nil
//                     )
//                 }
//             }
//         }
    }

    // MARK: - Layer Deletion (Pass-Through to DocumentModel)

    @objc func deleteLayers(_: Any?) {
        guard let tableView, let dataSource else { return }

        let selectedIndices = tableView.selectedRowIndexes
        guard !selectedIndices.isEmpty else { return }

        // Convert IndexSet to Array
        let indicesArray = Array(selectedIndices)

        // Delegate to DocumentModel
        dataSource.deleteLayers(at: indicesArray)
    }

    @objc func deleteLayer(_ layer: XRLayer) {
        guard let dataSource else { return }
        dataSource.deleteLayer(layer)
    }

    @objc func deleteLayersForTableName(_ tableName: String) {
        guard let dataSource else { return }
        dataSource.deleteLayersForDataset(named: tableName)
    }

    // MARK: - Layer Utilities (Controller-Local Operations)

    @objc func layerExists(withName name: String) -> Bool {
        layers.contains { $0.layerName() == name }
    }

    @objc func newLayerName(forBaseName name: String) -> String {
        var index = 1
        var newName: String

        repeat {
            newName = "\(name)-\(index)"
            index += 1
        } while layerExists(withName: newName)

        return newName
    }

    @objc func layerSettings() -> [String: Any] {
        let layerSettingsArray = layers.map { $0.layerSettings() }
        return ["layers": layerSettingsArray]
    }

    @objc func dataLayerNames() -> [String] {
        layers.compactMap { layer in
            layer.isKind(of: XRLayerData.self) ? layer.layerName() : nil
        }
    }

    @objc func dataLayer(withName name: String) -> XRLayer? {
        layers.first { layer in
            layer.isKind(of: XRLayerData.self) && layer.layerName() == name
        }
    }

    @objc func lastLayer() -> XRLayer? {
        layers.last
    }

    // MARK: - Mouse & Interaction Handling

    @objc func handleMouseEvent(_ event: NSEvent) {
        guard let tableView else { return }

        // Forward mouse event to selected layers
        for row in 0 ..< layers.count where tableView.isRowSelected(row) {
            let layer = layers[row]
            if layer.handleMouseEvent(event) {
                break
            }
        }
    }

    @objc func activeLayer(with point: NSPoint) -> XRLayer? {
        guard let tableView else { return nil }

        // Find layer at point from selected rows
        for row in 0 ..< layers.count where tableView.isRowSelected(row) {
            let layer = layers[row]
            if layer.hitDetection(point) {
                return layer
            }
        }

        return nil
    }

    // MARK: - Statistics & Reporting

    @objc func generateStatisticsString() -> String {
        var result = ""

        for layer in layers {
            if let dataLayer = layer as? XRLayerData {
                result += "\nData Set: \(String(describing: layer.layerName()))\n"
                result += dataLayer.dataSet().statisticsDescription()
                result += "\n\n"
            }
        }

        return result
    }
}

// MARK: - NSTableViewDelegate

extension LayersTableController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_: Notification) {
        displaySelectedLayerInInspector()
    }
}

// MARK: - NSTableViewDataSource

extension LayersTableController: NSTableViewDataSource {

    // Helper to parse various representations into Bool
    private func parseBool(_ value: Any?) -> Bool {
        switch value {
        case let bValue as Bool:
            return bValue

        case let sValue as String:
            let lower = sValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if ["1", "true", "yes", "on"].contains(lower) { return true }
            if ["0", "false", "no", "off"].contains(lower) { return false }
            return false

        case let iValue as Int:
            return iValue != 0

        case let dValue as Double:
            return dValue != 0

        default:
            return false
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        layers.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard layers.indices.contains(row) else {
            return nil
        }

        let layer = layers[row]
        let identifier = tableColumn?.identifier.rawValue ?? ""

        switch identifier {
        case "layerName":
            return layer.layerName()

        case "layerColors":
            return layer.colorImage()

        case "isVisible":
            return layer.isVisible()

        default:
            return nil
        }
    }

    func tableView(
        _ tableView: NSTableView,
        setObjectValue object: Any?,
        for tableColumn: NSTableColumn?,
        row: Int
    ) {
        guard
            layers.indices.contains(row),
            let dataSource else {
            return
        }

        let layer = layers[row]
        let identifier = tableColumn?.identifier.rawValue ?? ""

        switch identifier {
        case "layerName":
            if let newName = object as? String, !newName.isEmpty {
                dataSource.updateLayerName(layer, newName: newName)
            }

        case "isVisible":
            dataSource.updateLayerVisibility(layer, isVisible: parseBool(object))

        default:
            break
        }
    }

    // MARK: - Drag & Drop

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(String(row), forType: layerDragType)
        return pasteboardItem
    }

    func tableView(
        _ tableView: NSTableView,
        validateDrop info: NSDraggingInfo,
        proposedRow row: Int,
        proposedDropOperation dropOperation: NSTableView.DropOperation
    ) -> NSDragOperation {
        // Only accept drops from this table view
        guard info.draggingSource as? NSTableView === tableView else {
            return []
        }

        // Only accept drops above rows
        guard dropOperation == .above else {
            return []
        }

        return .move
    }

    func tableView(
        _ tableView: NSTableView,
        acceptDrop info: NSDraggingInfo,
        row: Int,
        dropOperation: NSTableView.DropOperation
    ) -> Bool {
        // Only accept drops from this table view
        guard
            info.draggingSource as? NSTableView === tableView,
            let dataSource else {
            return false
        }

        // Extract dragged row indices from pasteboard
        var draggedRows: [Int] = []
        info.draggingPasteboard.pasteboardItems?.forEach { item in
            if
                let rowString = item.string(forType: layerDragType),
                let rowIndex = Int(rowString) {
                draggedRows.append(rowIndex)
            }
        }

        guard !draggedRows.isEmpty else {
            return false
        }

        // Sort in descending order to maintain correct indices
        draggedRows.sort(by: >)

        // Delegate to DocumentModel
        dataSource.moveLayers(from: draggedRows, to: row)

        return true
    }
}

// swiftlint:enable file_length
