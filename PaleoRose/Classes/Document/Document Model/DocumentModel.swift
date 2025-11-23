//
// DocumentModel.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2024 to present Thomas L. Moore.
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

import CodableSQLiteNonThread
import Combine
import Foundation

class DocumentModel: NSObject {

    enum DocumentModelError: Error {
        case unknownLayerType
    }

    // MARK: - Properties

    private var inMemoryStore: InMemoryStore
    @objc var windowSize: CGSize = .zero
    @objc var dataSets: [XRDataSet] = []
    @objc var layers: [XRLayer] = []
    @objc weak var document: NSDocument?
    @objc let geometryController: XRGeometryController

    private let tableNamesSubject = CurrentValueSubject<[String], Never>([])
    private let layersSubject = CurrentValueSubject<[XRLayer], Never>([])

    // MARK: - Initialization

    @objc init(inMemoryStore: InMemoryStore, document: NSDocument?) {
        self.inMemoryStore = inMemoryStore
        self.document = document
        geometryController = XRGeometryController()
        super.init()

        // Set undo manager if document is available
        if let document {
            geometryController.setUndoManager(document.undoManager)
        }

        inMemoryStore.delegate = self
    }

    // MARK: - Deprecated Methods

    @available(*, deprecated, message: "This code will become unavailable")
    @objc func memoryStore() -> OpaquePointer? {
        inMemoryStore.store()
    }

    // MARK: - File Management

    @objc func writeToFile(_ file: URL) throws {
        try inMemoryStore.save(to: file.path)
    }

    @objc func openFile(_ file: URL) throws {
        try inMemoryStore.load(from: file.path)
        readFromStore {}
    }

    @objc func fileURL() -> URL? {
        if let document {
            return document.fileURL
        }
        return nil
    }

    // MARK: - General

    @objc func dataTableNames() -> [String] {
        tableNamesSubject.value
    }

    @objc func possibleColumnNames(table: String) throws -> [String] {
        try inMemoryStore.valueColumnNames(for: table)
    }

    @objc func setWindowSize(_ size: CGSize) throws {
        try inMemoryStore.store(windowSize: size)
    }

    @available(*, deprecated, message: "Use TableListControllerDataSource.renameTable(oldName:to:) instead")
    @objc func rename(table: String, toName: String) throws {
        try inMemoryStore.renameTable(from: table, toName: toName)
    }

    @objc func delete(table: String) throws {
        try inMemoryStore.drop(table: table)
    }

    @objc func add(table: String, column: String) throws {
        try inMemoryStore.addColumn(to: table, columnDefinition: column)
    }

    // MARK: - Persistence

    /// Saves the current geometry controller state to the store
    @objc func saveGeometry() throws {
        try inMemoryStore.store(geometryController: geometryController)
    }

    /// Saves the current layers to the store
    @objc func saveLayers() throws {
        try inMemoryStore.store(layers: layers)
    }

    // MARK: - Deprecated Persistence Methods

    @available(*, deprecated, message: "Use saveGeometry() instead - DocumentModel now owns the geometry controller")
    @objc func store(geometryController: XRGeometryController) throws {
        try inMemoryStore.store(geometryController: geometryController)
    }

    @available(*, deprecated, message: "Configuration happens automatically via InMemoryStoreDelegate.update(geometry:)")
    @objc func configure(geometryController: XRGeometryController) throws {
        do {
            try inMemoryStore.configure(geometryController: geometryController)
        } catch {
            return
        }
    }

    @available(*, deprecated, message: "Use saveLayers() instead")
    @objc func store(layers: [XRLayer]) throws {
        try inMemoryStore.store(layers: layers)
    }

    // MARK: - Read From Store

    @objc func readFromStore(completion: @escaping () -> Void) {
        inMemoryStore.readFromStore { _ in
            completion()
        }
    }
}

extension DocumentModel: InMemoryStoreDelegate {

    func update(tableNames: [String]) {
        tableNamesSubject.send(tableNames)
    }

    func update(windowSize: CGSize) {
        self.windowSize = windowSize
    }

    func update(dataSets: [XRDataSet]) {
        self.dataSets = dataSets
    }

    func update(layers: [XRLayer]) {
        // Set datasets and geometry controller on all loaded layers
        // IMPORTANT: Set geometry controller FIRST, then dataset
        // because setDataSet calls generateGraphics which needs the geometry controller
        for layer in layers {
            // First, set the dataset for data and line arrow layers
            if let dataLayer = layer as? XRLayerData {
                let datasetId = dataLayer.datasetId()
                if let dataset = dataSets.first(where: { $0.setId() == datasetId }) {
                    // Set geometry controller first (without generating graphics)
                    layer.setGeometryController(geometryController)
                    // Then set dataset (which will call generateGraphics with everything ready)
                    dataLayer.setDataSet(dataset)
                } else {
                    layer.setGeometryController(geometryController)
                }
            } else if let arrowLayer = layer as? XRLayerLineArrow {
                let datasetId = arrowLayer.datasetId()
                if let dataset = dataSets.first(where: { $0.setId() == datasetId }) {
                    // Set geometry controller first (without generating graphics)
                    layer.setGeometryController(geometryController)
                    // Then set dataset (which will call generateGraphics with everything ready)
                    arrowLayer.setDataSet(dataset)
                } else {
                    layer.setGeometryController(geometryController)
                }
            } else {
                // For non-data layers (grid, core, text), just set geometry controller
                layer.setGeometryController(geometryController)
            }
        }

        self.layers = layers
        layersSubject.send(layers)
    }

    func update(geometry: Geometry) {
        geometryController.configureIsEqualArea(
            geometry.isEqualArea,
            isPercent: geometry.isPercent,
            maxCount: Int32(geometry.MAXCOUNT),
            maxPercent: geometry.MAXPERCENT,
            hollowCore: geometry.HOLLOWCORE,
            sectorSize: geometry.SECTORSIZE,
            startingAngle: geometry.STARTINGANGLE,
            sectorCount: Int32(geometry.SECTORCOUNT),
            relativeSize: geometry.RELATIVESIZE
        )
    }
}

extension DocumentModel: TableListControllerDataSource {

    var dataSetRecordsPublisher: AnyPublisher<[String], Never> {
        tableNamesSubject.eraseToAnyPublisher()
    }

    func renameTable(oldName: String, to newName: String) {
        do {
            try inMemoryStore.renameTable(from: oldName, toName: newName)

            // Update all datasets that reference the renamed table
            for dataSet in dataSets where dataSet.tableName() == oldName {
                dataSet.setTableName(newName)
            }
        } catch {
            print("Failed to rename table from '\(oldName)' to '\(newName)': \(error)")
        }
    }
}

// MARK: - LayerTableControllerDataSource

extension DocumentModel: LayerTableControllerDataSource {

    var layersPublisher: AnyPublisher<[XRLayer], Never> {
        layersSubject.eraseToAnyPublisher()
    }

    // MARK: - Layer Creation

    func createDataLayer(
        dataSetName: String,
        color: NSColor,
        name: String?
    ) {
        // Find the dataset by name
        guard let dataSet = dataSets.first(where: { $0.tableName() == dataSetName }) else {
            print("Failed to create data layer: dataset '\(dataSetName)' not found")
            return
        }

        // Create the layer using our geometry controller
        guard let layer = XRLayerData(geometryController: geometryController, with: dataSet) else {
            print("Failed to create data layer")
            return
        }

        // Set colors
        layer.setStroke(color)
        layer.setFill(color)

        // Set name if provided
        if let name {
            layer.setLayerName(name)
        }

        // Add to layers array
        layers.append(layer)

        // Publish update
        layersSubject.send(layers)
    }

    func createCoreLayer(name: String?) {
        guard let layer = XRLayerCore(geometryController: geometryController) else {
            print("Failed to create core layer")
            return
        }

        if let name {
            layer.setLayerName(name)
        }

        layers.insert(layer, at: 0)
        layersSubject.send(layers)
    }

    func createGridLayer(name: String?) {
        guard let layer = XRLayerGrid(geometryController: geometryController) else {
            print("Failed to create grid layer")
            return
        }

        if let name {
            layer.setLayerName(name)
        }

        layers.insert(layer, at: 0)
        layersSubject.send(layers)
    }

    func createTextLayer(name: String?, parentView: NSView) {
        guard let layer = XRLayerText(geometryController: geometryController, parentView: parentView) else {
            print("Failed to create text layer")
            return
        }

        if let name {
            layer.setLayerName(name)
        }

        layers.insert(layer, at: 0)
        layersSubject.send(layers)
    }

    func createLineArrowLayer(
        dataSetName: String,
        name: String?
    ) {
        // Find the dataset by name
        guard let dataSet = dataSets.first(where: { $0.tableName() == dataSetName }) else {
            print("Failed to create line arrow layer: dataset '\(dataSetName)' not found")
            return
        }

        guard let layer = XRLayerLineArrow(geometryController: geometryController, with: dataSet) else {
            print("Failed to create line arrow layer")
            return
        }

        if let name {
            layer.setLayerName(name)
        }

        layers.append(layer)
        layersSubject.send(layers)
    }

    // MARK: - Layer Deletion

    func deleteLayer(_ layer: XRLayer) {
        // Remove the layer
        layers.removeAll { $0 === layer }

        // Remove associated dataset if this was a data layer
        if let dataLayer = layer as? XRLayerData {
            removeDataSetIfUnused(dataLayer.dataSet())
        } else if let arrowLayer = layer as? XRLayerLineArrow {
            removeDataSetIfUnused(arrowLayer.dataSet())
        }

        layersSubject.send(layers)
    }

    func deleteLayers(at indices: [Int]) {
        // Collect layers to delete
        var layersToDelete: [XRLayer] = []
        var dataSetsToCheck: [XRDataSet] = []

        for index in indices where layers.indices.contains(index) {
            let layer = layers[index]
            layersToDelete.append(layer)

            // Track datasets that might need removal
            if let dataLayer = layer as? XRLayerData {
                dataSetsToCheck.append(dataLayer.dataSet())
            } else if let arrowLayer = layer as? XRLayerLineArrow {
                dataSetsToCheck.append(arrowLayer.dataSet())
            }
        }

        // Remove layers
        for layer in layersToDelete {
            layers.removeAll { $0 === layer }
        }

        // Check if any datasets are now unused
        for dataSet in dataSetsToCheck {
            removeDataSetIfUnused(dataSet)
        }

        layersSubject.send(layers)
    }

    func deleteLayersForDataset(named tableName: String) {
        var layersToDelete: [XRLayer] = []

        // Find all layers associated with this dataset
        for layer in layers {
            if
                let dataLayer = layer as? XRLayerData,
                dataLayer.dataSet().tableName() == tableName {
                layersToDelete.append(layer)
            } else if
                let arrowLayer = layer as? XRLayerLineArrow,
                arrowLayer.dataSet().tableName() == tableName {
                layersToDelete.append(layer)
            }
        }

        // Remove the layers
        for layer in layersToDelete {
            layers.removeAll { $0 === layer }
        }

        layersSubject.send(layers)
    }

    // MARK: - Layer Modification

    func moveLayers(from indices: [Int], to destination: Int) {
        // Collect layers to move (in reverse order to preserve indices)
        var layersToMove: [XRLayer] = []
        for index in indices.sorted(by: >) where layers.indices.contains(index) {
            layersToMove.insert(layers[index], at: 0)
            layers.remove(at: index)
        }

        // Insert at destination
        let insertIndex = min(destination, layers.count)
        for (offset, layer) in layersToMove.enumerated() {
            layers.insert(layer, at: insertIndex + offset)
        }

        layersSubject.send(layers)
    }

    func updateLayerName(_ layer: XRLayer, newName: String) {
        layer.setLayerName(newName)
        layersSubject.send(layers)
    }

    func updateLayerVisibility(_ layer: XRLayer, isVisible: Bool) {
        layer.setIsVisible(isVisible)
        layersSubject.send(layers)
    }

    // MARK: - Private Helpers

    private func removeDataSetIfUnused(_ dataSet: XRDataSet?) {
        guard let dataSet else { return }

        // Check if any remaining layers use this dataset
        let isUsed = layers.contains { layer in
            if let dataLayer = layer as? XRLayerData {
                return dataLayer.dataSet() === dataSet
            } else if let arrowLayer = layer as? XRLayerLineArrow {
                return arrowLayer.dataSet() === dataSet
            }
            return false
        }

        // Remove dataset if unused
        if !isUsed {
            dataSets.removeAll { $0 === dataSet }
        }
    }
}
