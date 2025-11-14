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

    @objc init(dataSource: DocumentModel, geometryController: XRGeometryController) {
        self.rosePlotController = geometryController
        super.init()
        self.dataSource = dataSource
        setColorArray()
        setupDataSourceSubscription()
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
            layer.drawRect(rect)
        }
    }

    @objc func detectLayerHitAtPoint(_ point: NSPoint) {
        // Deselect all rows when hitting background
        if let tableView {
            for row in 0..<layers.count {
                tableView.deselectRow(row)
            }
        }
    }

    @objc func displaySelectedLayerInInspector() {
        guard let tableView else { return }

        let selectedRowCount = tableView.numberOfSelectedRows

        if selectedRowCount == 0 {
            XRPropertyInspector.default().displayInfo(for: nil)
        } else if selectedRowCount > 1 {
            XRPropertyInspector.default().displayInfo(for: nil)
        } else {
            let row = tableView.selectedRow
            guard layers.indices.contains(row) else { return }

            // Set active state
            for (index, layer) in layers.enumerated() {
                layer.setIsActive(index == row)
            }

            XRPropertyInspector.default().displayInfo(for: layers[row])
        }
    }

    @objc func calculateGeometryMaxCount() -> Int {
        var maxCount = -1

        for layer in layers {
            if layer.isKind(of: XRLayerData.self) {
                let count = layer.maxCount()
                if count > maxCount {
                    maxCount = count
                }
            }
        }

        return maxCount
    }

    @objc func calculateGeometryMaxPercent() -> Float {
        var maxPercent: Float = -1.0

        for layer in layers {
            if layer.isKind(of: XRLayerData.self) {
                let percent = layer.maxPercent()
                if percent > maxPercent {
                    maxPercent = percent
                }
            }
        }

        return maxPercent
    }

    // MARK: - Layer Creation (Pass-Through to DocumentModel)

    @objc func addDataLayer(for set: XRDataSet) {
        guard let dataSource, let rosePlotController else { return }

        // Extract dataset name
        let dataSetName = set.tableName()

        // Get next color
        let color = nextColor()

        // Generate unique name if needed
        let baseName = set.name() ?? dataSetName
        let uniqueName = layerExists(withName: baseName) ? newLayerName(forBaseName: baseName) : baseName

        // Delegate to DocumentModel
        dataSource.createDataLayer(
            dataSetName: dataSetName,
            color: color,
            name: uniqueName,
            geometryController: rosePlotController
        )
    }

    @objc func addCoreLayer(_ sender: Any?) {
        guard let dataSource, let rosePlotController else { return }

        let uniqueName = newLayerName(forBaseName: "Core")
        dataSource.createCoreLayer(name: uniqueName, geometryController: rosePlotController)
    }

    @objc func addGridLayer(_ sender: Any?) {
        guard let dataSource, let rosePlotController else { return }

        let uniqueName = newLayerName(forBaseName: "Grid")
        dataSource.createGridLayer(name: uniqueName, geometryController: rosePlotController)
    }

    @objc func addTextLayer(_ sender: Any?) {
        guard let dataSource, let rosePlotController, let roseView else { return }

        let uniqueName = newLayerName(forBaseName: "Text")
        dataSource.createTextLayer(name: uniqueName, parentView: roseView, geometryController: rosePlotController)
    }

    @objc func displaySheetForVStatLayer(_ sender: Any?) {
        guard let dataSource, let rosePlotController, let windowController else { return }

        let layerNames = dataLayerNames()
        guard !layerNames.isEmpty else { return }

        // Create the panel controller
        let panelController = XRVStatCreatePanelController(array: layerNames)

        // Show the sheet
        windowController.window?.beginSheet(panelController.window) { [weak self, weak dataSource, weak panelController] response in
            guard let self, let dataSource, let panelController else { return }

            if response == .OK {
                let selectedName = panelController.selectedName()

                // Find the dataset name from the selected layer
                if let selectedLayer = self.dataLayer(withName: selectedName) as? XRLayerData {
                    let dataSetName = selectedLayer.dataSet().tableName()
                    dataSource.createLineArrowLayer(
                        dataSetName: dataSetName,
                        name: nil,
                        geometryController: rosePlotController
                    )
                }
            }
        }
    }

    // MARK: - Layer Deletion (Pass-Through to DocumentModel)

    @objc func deleteLayers(_ sender: Any?) {
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
}

// MARK: - NSTableViewDelegate

extension LayersTableController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        displaySelectedLayerInInspector()
    }
}

// MARK: - NSTableViewDataSource

extension LayersTableController: NSTableViewDataSource {

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
            return layer.isVisible() ? NSNumber(value: NSControl.StateValue.on.rawValue) : NSNumber(value: NSControl.StateValue.off.rawValue)
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
        guard layers.indices.contains(row),
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
            if let number = object as? NSNumber {
                let isVisible = number.intValue == NSControl.StateValue.on.rawValue
                dataSource.updateLayerVisibility(layer, isVisible: isVisible)
            }
        default:
            break
        }
    }
}
