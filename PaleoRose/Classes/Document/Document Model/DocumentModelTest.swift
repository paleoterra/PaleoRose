//
// DocumentModelTest.swift
// Unit Tests
//
// MIT License
//
// Copyright (c) 2026 to present Thomas L. Moore.
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
@testable import PaleoRose
import Testing

// swiftlint:disable type_body_length
@MainActor
struct DocumentModelTest {

    @Test("Initialization Sets Expected Values")
    func initialization() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        #expect(inMemoryStore.delegate === sut)
    }

    // MARK: File Management

    @Test("Write to file propagates store error")
    func writeToFileError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let documentURL = URL(fileURLWithPath: "/test/path")
        inMemoryStore.saveToError = NSError(domain: "test", code: 1, userInfo: nil)

        #expect(throws: NSError.self) {
            try sut.writeToFile(documentURL)
        }
        #expect(inMemoryStore.saveToFileCalled)
        #expect(sut.url == nil)
    }

    @Test("Write to file")
    func writeToFile() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let documentURL = URL(fileURLWithPath: "/test/path")
        try sut.writeToFile(documentURL)
        #expect(inMemoryStore.saveToFileCalled)
        #expect(inMemoryStore.saveToFileArguments.first == documentURL.path)
        #expect(sut.url == documentURL)
    }

    // MARK: - Open File

    @Test("Open file calls load with correct path")
    func openFile() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let documentURL = URL(fileURLWithPath: "/test/path")

        try sut.openFile(documentURL)

        #expect(inMemoryStore.loadFromFileCalled)
        #expect(inMemoryStore.loadFromFileArguments.first == documentURL.path)
        #expect(inMemoryStore.readFromStoreCalled)
        #expect(sut.url == documentURL)
    }

    @Test("Open file propagates store error")
    func openFileError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let documentURL = URL(fileURLWithPath: "/test/path")
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)

        #expect(throws: NSError.self) {
            try sut.openFile(documentURL)
        }
        #expect(inMemoryStore.loadFromFileCalled)
        #expect(!inMemoryStore.readFromStoreCalled)
        #expect(sut.url == nil)
    }

    // MARK: - File URL

    @Test("File URL returns nil when document is nil")
    func fileURLNilDocument() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        #expect(sut.fileURL() == nil)
    }

    @Test("File URL delegates to document")
    func fileURLWithDocument() {
        let document = NSDocument()
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        #expect(sut.fileURL() == document.fileURL)
    }

    // MARK: - General

    @Test("Data table names is empty by default")
    func dataTableNamesEmpty() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        #expect(sut.dataTableNames().isEmpty)
    }

    @Test("Data table names reflects delegate update")
    func dataTableNamesUpdated() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(tableNames: ["table1", "table2"])
        #expect(sut.dataTableNames() == ["table1", "table2"])
    }

    @Test("Possible column names returns store values with correct argument")
    func possibleColumnNames() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.stubbedValueColumnNames = ["azimuth", "dip"]
        let names = try sut.possibleColumnNames(table: "strikes")
        #expect(names == ["azimuth", "dip"])
        #expect(inMemoryStore.valueColumnNamesArguments.first == "strikes")
    }

    @Test("Possible column names propagates store error")
    func possibleColumnNamesError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.possibleColumnNames(table: "strikes")
        }
    }

    @Test("Set window size calls store with correct size")
    func setWindowSize() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let size = CGSize(width: 800, height: 600)
        try sut.setWindowSize(size)
        #expect(inMemoryStore.storeWindowSizeCalled)
        #expect(inMemoryStore.storeWindowSizeArguments.first == size)
    }

    @Test("Set window size propagates store error")
    func setWindowSizeError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.setWindowSize(CGSize(width: 800, height: 600))
        }
    }

    @Test("Delete table calls store with correct name")
    func deleteTable() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        try sut.delete(table: "measurements")
        #expect(inMemoryStore.dropTableCalled)
        #expect(inMemoryStore.dropTableArguments.first == "measurements")
    }

    @Test("Delete table propagates store error")
    func deleteTableError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.delete(table: "measurements")
        }
    }

    @Test("DataSet returns nil when no datasets loaded")
    func dataSetReturnsNilWhenEmpty() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        #expect(sut.dataSet(name: "strikes") == nil)
    }

    // MARK: - Persistence

    @Test("Create dataset calls store with correct arguments")
    func createDataSet() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let expected = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        inMemoryStore.stubbedDataSet = expected

        let result = try sut.createDataSet(tableName: "my_table", columnName: "azimuth", name: "strikes")

        #expect(inMemoryStore.storeDataSetCalled)
        #expect(inMemoryStore.storeDataSetArguments.first?.name == "strikes")
        #expect(inMemoryStore.storeDataSetArguments.first?.tableName == "my_table")
        #expect(inMemoryStore.storeDataSetArguments.first?.columnName == "azimuth")
        #expect(result === expected)
    }

    @Test("Create dataset makes it accessible by name")
    func createDataSetAddsToModel() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let expected = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        inMemoryStore.stubbedDataSet = expected

        _ = try sut.createDataSet(tableName: "my_table", columnName: "azimuth", name: "strikes")

        #expect(sut.dataSet(name: "strikes") === expected)
    }

    @Test("Create dataset propagates store error")
    func createDataSetError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.createDataSet(tableName: "my_table", columnName: "azimuth", name: "strikes")
        }
    }

    @Test("Save geometry calls store with geometry controller")
    func saveGeometry() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)

        try sut.saveGeometry()

        #expect(inMemoryStore.storeGeometryControllerCalled)
        #expect(inMemoryStore.storeGeometryControllerArguments.first === sut.geometryController)
    }

    @Test("Save geometry propagates store error")
    func saveGeometryError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.storeGeometryError = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.saveGeometry()
        }
    }

    @Test("Save layers calls store with current layers")
    func saveLayers() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)

        try sut.saveLayers()

        #expect(inMemoryStore.storeLayersCalled)
        #expect(inMemoryStore.storeLayersArguments.first?.isEmpty == true)
    }

    @Test("Save layers propagates store error")
    func saveLayersError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.storeLayersError = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.saveLayers()
        }
    }

    // MARK: - DataSet lookup

    @Test("DataSet returns matching dataset by name")
    func dataSetByName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        #expect(sut.dataSet(name: "strikes") === dataSet)
    }

    // MARK: - Read From Store

    @Test("Read from store calls store and invokes completion")
    func readFromStore() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        var completionCalled = false
        sut.readFromStore { _ in completionCalled = true }
        #expect(inMemoryStore.readFromStoreCalled)
        #expect(completionCalled)
    }

    // MARK: - Refresh Table Names

    @Test("Refresh table names updates data table names from store")
    func refreshTableNamesUpdates() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let box = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer { box.deallocate() }
        inMemoryStore.stubbedSqlitePointer = OpaquePointer(box)
        inMemoryStore.stubbedTableNames = ["table1", "table2"]
        sut.refreshTableNames()
        #expect(sut.dataTableNames() == ["table1", "table2"])
    }

    @Test("Refresh table names silently handles store error")
    func refreshTableNamesError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.refreshTableNames()
        #expect(sut.dataTableNames().isEmpty)
    }

    // MARK: - Delegate Updates

    @Test("Update window size sets window size property")
    func updateWindowSize() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let size = CGSize(width: 400, height: 300)
        sut.update(windowSize: size)
        #expect(sut.windowSize == size)
    }

    @Test("Update geometry configures geometry controller")
    func updateGeometry() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let geometry = Geometry(
            isEqualArea: true,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.1,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        )
        sut.update(geometry: geometry)
        #expect(sut.geometryController.isEqualArea())
        #expect(!sut.geometryController.isPercent())
        #expect(sut.geometryController.sectorCount() == 36)
    }

    // MARK: - Table Management

    @Test("Rename table calls store with correct arguments")
    func renameTable() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.renameTable(oldName: "old", to: "new")
        #expect(inMemoryStore.renameTableCalled)
        #expect(inMemoryStore.renameTableArguments.first?.from == "old")
        #expect(inMemoryStore.renameTableArguments.first?.toName == "new")
    }

    @Test("Rename table updates matching dataset table name")
    func renameTableUpdatesDataSet() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "old_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.renameTable(oldName: "old_table", to: "new_table")
        #expect(dataSet.tableName() == "new_table")
    }

    @Test("Rename table silently handles store error")
    func renameTableError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        sut.renameTable(oldName: "old", to: "new")
        #expect(inMemoryStore.renameTableCalled)
    }

    // MARK: - Publisher

    @Test("Data set records publisher emits updated table names")
    func dataSetRecordsPublisher() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        var received: [String] = []
        let cancellable = sut.dataSetRecordsPublisher.sink { received = $0 }
        sut.update(tableNames: ["a", "b"])
        #expect(received == ["a", "b"])
        cancellable.cancel()
    }

    // MARK: - Copy Tables

    @Test("Copy tables calls store with correct arguments")
    func copyTables() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let sourceURL = URL(fileURLWithPath: "/source/path.XRose")
        let tables = [(original: "t1", destination: "t1_copy")]
        try sut.copyTables(from: sourceURL, selecting: tables)
        #expect(inMemoryStore.copyTablesCalled)
        #expect(inMemoryStore.copyTablesArguments.first?.sourceURL == sourceURL)
        #expect(inMemoryStore.copyTablesArguments.first?.tables.count == 1)
    }

    @Test("Copy tables propagates store error")
    func copyTablesError() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        inMemoryStore.errorToThrow = NSError(domain: "test", code: 1, userInfo: nil)
        #expect(throws: NSError.self) {
            try sut.copyTables(from: URL(fileURLWithPath: "/src"), selecting: [])
        }
    }

    // MARK: - Layer Creation

    @Test("Create core layer adds layer with correct name")
    func createCoreLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: "Core")
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Core")
    }

    @Test("Create core layer with nil name uses default")
    func createCoreLayerNilName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
    }

    @Test("Create grid layer adds layer with correct name")
    func createGridLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: "Grid")
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Grid")
    }

    @Test("Create text layer adds layer with correct name")
    func createTextLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createTextLayer(name: "Text", parentView: NSView())
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Text")
    }

    @Test("Create data layer adds layer when dataset found")
    func createDataLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Data Layer")
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Data Layer")
    }

    @Test("Create data layer does nothing when dataset not found")
    func createDataLayerNotFound() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createDataLayer(dataSetName: "nonexistent", color: .red, name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.isEmpty)
    }

    @Test("Create line arrow layer adds layer when dataset found")
    func createLineArrowLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createLineArrowLayer(dataSetName: "my_table", name: "Arrow Layer")
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Stat_Arrow Layer")
    }

    // MARK: - Layer Deletion

    @Test("Delete layer removes it from layers")
    func deleteLayer() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: "Core")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        sut.deleteLayer(layer)
        try sut.saveLayers()
        #expect(inMemoryStore.storeLayersArguments.last?.isEmpty == true)
    }

    @Test("Delete layers at indices removes correct layers")
    func deleteLayersAtIndices() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: "Grid")
        sut.createCoreLayer(name: "Core")
        // layers = [Core, Grid] (both inserted at index 0)
        sut.deleteLayers(at: [0])
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.count == 1)
        #expect(layers.first?.layerName() == "Grid")
    }

    @Test("Delete layers for dataset removes matching layers")
    func deleteLayersForDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: nil)
        sut.deleteLayersForDataset(named: "my_table")
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.isEmpty)
    }

    // MARK: - Layer Modification

    @Test("Move layers reorders layers correctly")
    func moveLayers() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: "Grid")
        sut.createCoreLayer(name: "Core")
        // layers = [Core, Grid]; move index 1 (Grid) to position 0 → [Grid, Core]
        sut.moveLayers(from: [1], to: 0)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.first?.layerName() == "Grid")
    }

    @Test("Update layer name changes the layer name")
    func updateLayerName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: "OldName")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        sut.updateLayerName(layer, newName: "NewName")
        #expect(layer.layerName() == "NewName")
    }

    @Test("Update layer visibility changes layer visibility")
    func updateLayerVisibility() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: "Core")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        sut.updateLayerVisibility(layer, isVisible: false)
        #expect(!layer.isVisible())
    }

    // MARK: - Layers Publisher

    @Test("Layers publisher emits when layers change")
    func layersPublisherEmits() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        var received: [XRLayer] = []
        let cancellable = sut.layersPublisher.sink { received = $0 }
        sut.createCoreLayer(name: "Core")
        #expect(received.count == 1)
        #expect(received.first?.layerName() == "Core")
        cancellable.cancel()
    }

    // MARK: - Update Layers Delegate

    @Test("Update layers sets geometry controller on non-data layers")
    func updateLayersNonDataLayerGetsGeometry() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let layer = try #require(XRLayerCore(geometryController: XRGeometryController()))
        sut.update(layers: [layer])
        #expect(layer.geometryController() === sut.geometryController)
    }

    @Test("Update layers wires data layer to matching dataset")
    func updateLayersWiresDataLayerToDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        let layer = XRLayerData.stub(datasetId: 1)
        sut.update(layers: [layer])
        #expect(layer.geometryController() === sut.geometryController)
        #expect(layer.dataSet() === dataSet)
    }

    @Test("Update layers sets geometry only when data layer has no matching dataset")
    func updateLayersDataLayerNoMatchingDataset() {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        let layer = XRLayerData.stub(datasetId: 99)
        sut.update(layers: [layer])
        #expect(layer.geometryController() === sut.geometryController)
        #expect(layer.dataSet() == nil)
    }

    @Test("Update layers wires arrow layer to matching dataset")
    func updateLayersWiresArrowLayerToDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        let layer = XRLayerLineArrow.stub(datasetId: 1)
        sut.update(layers: [layer])
        #expect(layer.geometryController() === sut.geometryController)
        #expect(layer.dataSet() === dataSet)
    }

    // MARK: - Layer Creation (additional)

    @Test("Create data layer with nil name still creates layer")
    func createDataLayerNilName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.count == 1)
    }

    @Test("Create data layer sets stroke and fill color")
    func createDataLayerSetsColors() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Layer")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        #expect(layer.strokeColor() == .red)
        #expect(layer.fillColor() == .red)
    }

    @Test("Create grid layer with nil name still creates layer")
    func createGridLayerNilName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
    }

    @Test("Create text layer with nil name still creates layer")
    func createTextLayerNilName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createTextLayer(name: nil, parentView: NSView())
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.count == 1)
    }

    @Test("Create line arrow layer with nil name still creates layer when dataset found")
    func createLineArrowLayerNilName() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createLineArrowLayer(dataSetName: "my_table", name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.count == 1)
    }

    @Test("Core and grid layers insert at front; data layer appends to back")
    func layerInsertionOrdering() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Data")
        sut.createCoreLayer(name: "Core")
        // layers = [Core, Data] — Core inserted at 0, Data appended before that
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.count == 2)
        #expect(layers.first?.layerName() == "Core")
        #expect(layers.last?.layerName() == "Data")
    }

    @Test("Create line arrow layer does nothing when dataset not found")
    func createLineArrowLayerNotFound() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createLineArrowLayer(dataSetName: "nonexistent", name: nil)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.first)
        #expect(layers.isEmpty)
    }

    // MARK: - Dataset Cleanup on Layer Deletion

    @Test("Delete data layer removes its dataset when it is the last user")
    func deleteDataLayerRemovesUnusedDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Layer")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        #expect(sut.dataSet(name: "strikes") != nil)
        sut.deleteLayer(layer)
        #expect(sut.dataSet(name: "strikes") == nil)
    }

    @Test("Delete data layer keeps dataset when another layer still uses it")
    func deleteDataLayerKeepsDatasetIfStillUsed() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Layer 1")
        sut.createDataLayer(dataSetName: "my_table", color: .blue, name: "Layer 2")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        sut.deleteLayer(layer)
        #expect(sut.dataSet(name: "strikes") != nil)
    }

    @Test("Delete layers at indices removes dataset when its data layer is deleted")
    func deleteLayersAtIndicesRemovesDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        // layers = [DataLayer] after append
        sut.createDataLayer(dataSetName: "my_table", color: .red, name: "Data Layer")
        // layers = [Core, DataLayer] after insert at 0
        sut.createCoreLayer(name: "Core")
        sut.deleteLayers(at: [1])
        #expect(sut.dataSet(name: "strikes") == nil)
    }

    @Test("Delete arrow layer removes its dataset when it is the last user")
    func deleteArrowLayerRemovesUnusedDataset() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.update(geometry: Geometry(
            isEqualArea: false,
            isPercent: false,
            MAXCOUNT: 100,
            MAXPERCENT: 50.0,
            HOLLOWCORE: 0.0,
            SECTORSIZE: 10.0,
            STARTINGANGLE: 0.0,
            SECTORCOUNT: 36,
            RELATIVESIZE: 1.0
        ))
        let dataSet = try #require(XRDataSet(
            id: 1,
            name: "strikes",
            tableName: "my_table",
            column: "azimuth",
            predicate: "",
            comments: NSMutableAttributedString(),
            data: Data()
        ))
        sut.update(dataSets: [dataSet])
        sut.createLineArrowLayer(dataSetName: "my_table", name: "Arrow")
        try sut.saveLayers()
        let layer = try #require(inMemoryStore.storeLayersArguments.last?.first)
        #expect(sut.dataSet(name: "strikes") != nil)
        sut.deleteLayer(layer)
        #expect(sut.dataSet(name: "strikes") == nil)
    }

    @Test("Delete layers at indices ignores out-of-bounds indices")
    func deleteLayersAtIndicesIgnoresOutOfBounds() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createCoreLayer(name: "Core")
        // valid index 0, invalid index 99
        sut.deleteLayers(at: [0, 99])
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.isEmpty)
    }

    // MARK: - Layer Modification (additional)

    @Test("Move layers clamps destination to layer count")
    func moveLayersDestinationClamped() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: "Grid")
        sut.createCoreLayer(name: "Core")
        // layers = [Core, Grid]; move index 0 (Core) to position 99 → appends to end
        sut.moveLayers(from: [0], to: 99)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.first?.layerName() == "Grid")
        #expect(layers.last?.layerName() == "Core")
    }

    @Test("Move layers with multiple indices preserves relative order")
    func moveLayersMultipleIndices() throws {
        let inMemoryStore = MockInMemoryStore()
        let sut = DocumentModel(inMemoryStore: inMemoryStore, undoManager: nil)
        sut.createGridLayer(name: "Grid")
        sut.createCoreLayer(name: "Core")
        sut.createTextLayer(name: "Text", parentView: NSView())
        // layers = [Text, Core, Grid]; move indices [0, 2] (Text, Grid) to position 1
        // After removal of Grid (index 2) and Text (index 0), remaining = [Core]
        // Insert Text at 1 → [Core, Text]; insert Grid at 2 → [Core, Text, Grid]
        sut.moveLayers(from: [0, 2], to: 1)
        try sut.saveLayers()
        let layers = try #require(inMemoryStore.storeLayersArguments.last)
        #expect(layers.count == 3)
        #expect(layers[0].layerName() == "Core")
        #expect(layers[1].layerName() == "Text")
        #expect(layers[2].layerName() == "Grid")
    }
}

// swiftlint:enable type_body_length
