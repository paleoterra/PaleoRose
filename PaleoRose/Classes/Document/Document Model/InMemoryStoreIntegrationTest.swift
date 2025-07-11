//
// InMemoryStoreIntegrationTest.swift
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
@testable import PaleoRose
import Testing

// swiftlint:disable indentation_width file_length type_body_length type_contents_order
@Suite(
    "InMemory Store Integration Test",
    .tags(.integration)
)
struct InMemoryStoreIntegrationTest {
    private func sampleFilePath() throws -> String {
        guard let bundle = Bundle(identifier: "PaleoTerra.Unit-Tests"),
              let path = bundle.path(
                  forResource: "rtest1",
                  ofType: "XRose"
              )
        else {
            Issue.record("Could not find test file")
            throw SQLiteError.failedToOpen
        }
        return path
    }

    private func backupFromSampleFileToInMemoryStore(_ store: InMemoryStore) throws {
        let filePath = try sampleFilePath()
        try store.load(from: filePath)
    }

    private func openTemporaryFile(directory: URL, name: String) throws -> OpaquePointer {
        try SQLiteInterface().openDatabase(path: directory.appendingPathComponent(name).path)
    }

    @Test(
        "Given an in-memory store, when it is initialized, then it should successfully create tables",
        arguments: zip(
            [
                WindowControllerSize.tableName,
                Geometry.tableName,
                Layer.tableName,
                Color.tableName,
                DataSet.tableName,
                LayerText.tableName,
                LayerLineArrow.tableName,
                LayerCore.tableName,
                LayerGrid.tableName,
                LayerData.tableName
            ],
            [
                WindowControllerSize.createTableQuery(),
                Geometry.createTableQuery(),
                Layer.createTableQuery(),
                Color.createTableQuery(),
                DataSet.createTableQuery(),
                LayerText.createTableQuery(),
                LayerLineArrow.createTableQuery(),
                LayerCore.createTableQuery(),
                LayerGrid.createTableQuery(),
                LayerData.createTableQuery()
            ]
        )
    )
    func createStoreShouldCreateTables(execptedTable: String, sql: any QueryProtocol) throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)
        let dbPointer = try #require(store.store())
        let result: [TableSchema] = try interface.executeCodableQuery(
            sqlite: dbPointer,
            query: TableSchema.storedValues()
        )
        let table = try #require(result.first { $0.name == execptedTable })
        let caputedSql = table.sql.replacingOccurrences(of: "IF NOT EXISTS ", with: "")
        #expect(table.sql == caputedSql)
    }

    private func assertDatabaseContentMatchesSampleFile(database: OpaquePointer) throws {
        let tables: [TableSchema] = try SQLiteInterface().executeCodableQuery(sqlite: database, query: TableSchema.storedValues())
        let tableNames = tables.map(\.name)
        let expectedTableNames = [
            "_windowController",
            "_geometryController",
            "_layers",
            "_colors",
            "_datasets",
            "_layerText",
            "_layerLineArrow",
            "_layerCore",
            "_layerGrid",
            "_layerData",
            "rtest"
        ]
        #expect(tableNames == expectedTableNames)

        let colors: [Color] = try SQLiteInterface().executeCodableQuery(sqlite: database, query: Color.storedValues())
        #expect(colors.count == 4)
    }

    @Test("Given sample file, then loading the file will populate the in-memory store")
    func readFileShouldPopulateStore() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())

        try backupFromSampleFileToInMemoryStore(store)

        let storePointer = try #require(store.store())

        try assertDatabaseContentMatchesSampleFile(database: storePointer)
    }

    @Test("Given a populated in-memory store, when backing up to new file, then backup successfully")
    func backupToNewFile() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try store.save(to: fileURL.path())

        let tempFile = try SQLiteInterface().openDatabase(path: fileURL.path())
        defer {
            do {
                try SQLiteInterface().close(store: tempFile)
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                Issue.record("Failed to remove database \(error)")
            }
        }
        try assertDatabaseContentMatchesSampleFile(database: tempFile)
    }

    @Test("Given document with no data, when requesting data tables, then return an empty array")
    func returnEmptyTableListWhenNoData() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        let tables = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(tables.isEmpty)
    }

    @Test("Given document with data, when requesting data tables, then return array")
    func returnPopulatedTableListWhenNoData() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)

        let tables = try store.tableNames(sqliteStore: store.sqlitePointer())
        print(tables)
        #expect(tables.count == 1, "Expected 1 table, got \(tables.count)")
        #expect(tables.first == "rtest")
    }

    // MARK: - Data Sets

    @Test("Given document with data, when requesting datasets then return expected array with 2 records")
    func returnPopulatedDatasets() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)

        let datasets = try store.tableNames(sqliteStore: store.sqlitePointer())

        try #require(datasets == ["rtest"])
    }

    @Test("Given document with data, when requesting data for dataset, then return correct Float array")
    func returnPopulatedDataForDataset() throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)
        let dataSet = DataSet(
            _id: 1,
            NAME: "Test",
            TABLENAME: "rtest",
            COLUMNNAME: "_id",
            PREDICATE: nil,
            COMMENTS: nil
        )
        let dataValues = try store.dataSetValues(for: dataSet)
        #expect(dataValues.count == 63, "Expected 63 records, got \(dataValues.count)")
    }

    // MARK: - Window Size

    @Test("Given a window size and empty database, then store the window size and retrieve the same")
    func storeWindowSize() throws {
        let expectedWidth: CGFloat = 54
        let expectedHeight: CGFloat = 90

        let store = try InMemoryStore(interface: SQLiteInterface())
        let size = CGSize(width: expectedWidth, height: expectedHeight)
        try store.store(windowSize: size)
        let windowSize = try store.windowSize(sqliteStore: store.sqlitePointer())
        #expect(windowSize.width == expectedWidth)
        #expect(windowSize.height == expectedHeight)
    }

    @Test("When storing multiple sizes, then store only contains one record matching the last save")
    func storeMultipleWindowSizes() throws {
        let expectedWidth: CGFloat = 54
        let expectedHeight: CGFloat = 90

        let store = try InMemoryStore(interface: SQLiteInterface())
        var size = CGSize(width: expectedWidth - 10, height: expectedHeight - 10)
        try store.store(windowSize: size)

        size = CGSize(width: expectedWidth - 5, height: expectedHeight - 5)
        try store.store(windowSize: size)

        size = CGSize(width: expectedWidth + 5, height: expectedHeight + 5)
        try store.store(windowSize: size)

        size = CGSize(width: expectedWidth, height: expectedHeight)
        try store.store(windowSize: size)

        let windowSize = try store.windowSize(sqliteStore: store.sqlitePointer())
        #expect(windowSize.width == expectedWidth)
        #expect(windowSize.height == expectedHeight)
    }

    // MARK: - Rename Table

    @Test("When renaming the table, then the database is updated")
    func renameTable() throws {
        let startTable = "rtest"
        let endTable = "rtest2"
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)
        let startTableNames = try store.tableNames(sqliteStore: store.sqlitePointer())

        #expect(startTableNames.contains(startTable))
        #expect(!startTableNames.contains(endTable))
        try store.renameTable(from: startTable, toName: endTable)
        let tableNames = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(!tableNames.contains(startTable))
        #expect(tableNames.contains(endTable))
    }

    // MARK: - Add Column

    @Test("when attempting to add a column, then the table is successfully changed")
    func addColumn() throws {
        let table = "rtest"
        let column = "newColumn TEXT"
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)
        try store.addColumn(to: table, columnDefinition: column)
        let schemas: [TableSchema] = try store.interface.executeCodableQuery(
            sqlite: store.sqlitePointer(),
            query: TableSchema.storedValues()
        )
        let schema = try #require(schemas.first { $0.name == "rtest" })
        print(schema.sql)
        #expect(schema.sql.contains("newColumn"))
    }

    // MARK: - Drop Table

    @Test("When dropping table, the table is no longer available")
    func dropTable() throws {
        let table = "rtest"
        let store = try InMemoryStore(interface: SQLiteInterface())
        try backupFromSampleFileToInMemoryStore(store)
        try store.drop(table: table)
        let tableNames = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(tableNames.isEmpty)
    }

    // MARK: - Geometry

    @Test("When storing geometry called, then the database is updated")
    func storeGeometry() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)
        try backupFromSampleFileToInMemoryStore(store)
        let controller = XRGeometryController.stub(
            isEqualArea: true,
            maxCount: 1,
            maxPercent: 14.5,
            hollowCore: 2.1,
            sectorSize: 23.2,
            startingAngle: 12.0,
            sectorCount: 6,
            relativeSize: 0.2
        )
        try store.store(geometryController: controller)
        let resultController = XRGeometryController.stub()
        try store.configure(geometryController: resultController)
        #expect(resultController == controller)
    }

    @Test("When storing geometry called multiple times, then the database has only the latest")
    func storeGeometryManyTimes() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)
        try backupFromSampleFileToInMemoryStore(store)
        let controller = XRGeometryController.stub(
            isEqualArea: true,
            maxCount: 1,
            maxPercent: 14.5,
            hollowCore: 2.1,
            sectorSize: 23.2,
            startingAngle: 12.0,
            sectorCount: 6,
            relativeSize: 0.2
        )
        try store.store(geometryController: controller)

        controller.setGeomentryMaxCount(9)
        controller.setGeomentryMaxPercent(32)
        controller.setHollowCoreSize(93)
        controller.setSectorSize(3)
        controller.setStartingAngle(9)
        controller.setSectorCount(15)
        controller.setRelativeSizeOfCircleRect(0.9)

        try store.store(geometryController: controller)
        controller.setEqualArea(false)
        controller.setPercent(true)
        controller.setGeomentryMaxCount(23)
        controller.setGeomentryMaxPercent(34)
        controller.setHollowCoreSize(96)
        controller.setSectorSize(60)
        controller.setStartingAngle(12)
        controller.setSectorCount(8)
        controller.setRelativeSizeOfCircleRect(0.9)

        try store.store(geometryController: controller)

        let newController = XRGeometryController.stub()

        try store.configure(geometryController: newController)

        #expect(newController == controller)

        let countResult: [RecordCount] = try interface.executeCodableQuery(
            sqlite: store.sqlitePointer(),
            query: Geometry.countQuery()
        )
        let count = try #require(countResult.first)
        #expect(count.count == 1)
    }

    // MARK: - Layers

    @Test("When reading layers from the test file, then all the expected layers are returned")
    func readLayersInTestFile() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)

        try backupFromSampleFileToInMemoryStore(store)

        let layers = try store.readLayers(sqliteStore: store.sqlitePointer())
        #expect(layers.count == 3)
        #expect(layers[0] is XRLayerGrid)
        #expect(layers[1] is XRLayerData)
        #expect(layers[2] is XRLayerLineArrow)
    }

    @Test("When reading layers from the test file, ensure the grid layer correctly reads data")
    func readGridLayerInTestFile() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)

        try backupFromSampleFileToInMemoryStore(store)

        let layers = try store.readLayers(sqliteStore: store.sqlitePointer())
        guard let layer = layers[0] as? XRLayerGrid else {
            Issue.record("Layer is not XRLayerGrid")
            return
        }
        #expect(layers.count == 3)
        if !layer.radianIsPercent() {
            print("fail")
        }
        layer.verify(
            isVisible: true,
            active: false,
            biDir: false,
            name: "Default Grid",
            lineWeight: 3.388646,
            maxCount: 0,
            maxPercent: 0.0,
            isFixedCount: true,
            ringsVisible: true,
            fixedRingCount: 4,
            ringCountIncrement: 2,
            ringPercentIncrement: 0.11,
            showRingLabels: true,
            labelAngle: 77.616188,
            // swiftlint:disable:next force_unwrapping
            ringFont: NSFont(name: "ArialMT", size: 24.0)!,
            radialsCount: 32,
            radialsAngle: 11.25,
            radialsLabelAlignment: 0,
            radialsCompassPoint: 1,
            radialsOrder: 0,
            // swiftlint:disable:next force_unwrapping
            radialFont: NSFont(name: "AurulentSansMonoNerdFontComplete-Regular", size: 12.0)!,
            radialsSectorLock: false,
            radialsVisible: true,
            radialsIsPercent: true,
            radialsTicks: true,
            radialsMinorTicks: true,
            radialLabels: true
        )
        // stroke id
        // fill id
    }

    @Test("When reading layers from the test file, ensure the data layer correctly reads data")
    func readDataLayerInTestFile() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)

        try backupFromSampleFileToInMemoryStore(store)

        let layers = try store.readLayers(sqliteStore: store.sqlitePointer())
        guard let layer = layers[1] as? XRLayerData else {
            Issue.record("Layer is not XRLayerGrid")
            return
        }
        #expect(layers.count == 3)
        #expect(layer.isVisible())
        #expect(!layer.isActive())
        #expect(layer.isBiDirectional())
        #expect(layer.layerName() == "Test")
        #expect(layer.lineWeight() == 7)
        #expect(layer.maxCount() == 11)
        #expect(layer.maxPercent() == 0.087302)
        // stroke id
        // fill id
        #expect(layer.datasetId() == 0)
        #expect(layer.plotType() == 4)
        #expect(layer.totalCount() == 126)
        #expect(layer.dotRadius() == 8.5)
    }

    @Test("When reading layers from the test file, ensure the line arrow layer correctly reads data")
    func readLineArrowInTestFile() throws {
        let interface = SQLiteInterface()
        let store = try InMemoryStore(interface: interface)

        try backupFromSampleFileToInMemoryStore(store)

        let layers = try store.readLayers(sqliteStore: store.sqlitePointer())
        guard let layer = layers[2] as? XRLayerLineArrow else {
            Issue.record("Layer is not XRLayerLineArrow")
            return
        }
        #expect(layers.count == 3)
        #expect(layer.isVisible())
        #expect(layer.isActive())
        #expect(!layer.isBiDirectional())
        #expect(layer.layerName() == "Stat_Test")
        #expect(layer.lineWeight() == 4.698694)
        #expect(layer.maxCount() == 0)
        #expect(layer.maxPercent() == 0)
        // stroke id
        // fill id
        #expect(layer.datasetId() == 0)
        #expect(layer.arrowSize() == 2.546645)
        #expect(layer.vectorType() == 0)
        #expect(layer.arrowType() == 1)
        #expect(layer.showVector())
        #expect(layer.showError())
    }

    @Test("When storing layers, then the database is updated")
    func storeLayers() throws {
        let layers: [XRLayer] = [
            XRLayerGrid.stub(),
            XRLayerCore.stub(),
            XRLayerData.stub(),
            XRLayerLineArrow.stub(),
            XRLayerText.stub()
        ]
        let store = try InMemoryStore(interface: SQLiteInterface())

        try store.store(layers: layers)
    }

    // MARK: - Read From Store

    // swiftlint:disable object_literal
    let rTestColors: [NSColor] = [
        .init(red: 0, green: 0, blue: 0, alpha: 1),
        NSColor(red: 0.843035, green: 0.429802, blue: 0.584504, alpha: 1),
        NSColor(red: 1, green: 0.423844, blue: 0.347773, alpha: 1),
        NSColor(red: 0.724256, green: 0.28904, blue: 0.169853, alpha: 1)
    ]
    // swiftlint:enable object_literal

    private func rTestColorItem(atIndex: Int) throws -> NSColor {
        try #require(atIndex > 0 && atIndex <= rTestColors.count)
        return rTestColors[atIndex - 1]
    }

    private func readRtestFromStore(store: InMemoryStore) async throws -> Bool {
        try backupFromSampleFileToInMemoryStore(store)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            store.readFromStore { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: Bool(value))

                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @Test("When ReadFromStore called, call completion handler")
    func readFromStoreCompletion() async throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        let delegate = MockInMemoryStoreDelegate()
        store.delegate = delegate

        let result = try await readRtestFromStore(store: store)
        #expect(result)
    }

    @Test("When ReadFromStore called for rtest, expect 3 layers")
    func readFromStore3layers() async throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        let delegate = MockInMemoryStoreDelegate()
        store.delegate = delegate

        _ = try await readRtestFromStore(store: store)
        try #require(delegate.layers.count == 3)
        #expect(delegate.layers[0] is XRLayerGrid)
        #expect(delegate.layers[1] is XRLayerData)
        #expect(delegate.layers[2] is XRLayerLineArrow)
    }

    @Test("When ReadFromStore called for rtest, expect correct Layer portions")
    func readFromStoreGridLayer() async throws {
        let store = try InMemoryStore(interface: SQLiteInterface())
        let delegate = MockInMemoryStoreDelegate()
        store.delegate = delegate

        _ = try await readRtestFromStore(store: store)
        print("Layer count: \(delegate.layers.count)")
        try #require(delegate.layers.count == 3)
        let grid = delegate.layers[0]
        // Grid  Table

        try CommonUtilities.assertXRLayerHasCorrectValues(
            layer: grid,
            isVisible: true,
            isActive: false,
            isBiDirectional: false,
            name: "Default Grid",
            lineWeight: 3.388646,
            maxCount: 0,
            maxPercent: 0.0,
            strokeColor: rTestColorItem(atIndex: 1), // not correct
            fillColor: rTestColorItem(atIndex: 1) // not correct
        )

        let data = delegate.layers[1]

        try CommonUtilities.assertXRLayerHasCorrectValues(
            layer: data,
            isVisible: true,
            isActive: false,
            isBiDirectional: true,
            name: "Test",
            lineWeight: 7,
            maxCount: 11,
            maxPercent: 0.087302,
            strokeColor: rTestColorItem(atIndex: 3), // not correct
            fillColor: rTestColorItem(atIndex: 2) // not correct
        )

        let lineArrow = delegate.layers[2]

        try CommonUtilities.assertXRLayerHasCorrectValues(
            layer: lineArrow,
            isVisible: true,
            isActive: true, // not being read correctly
            isBiDirectional: false,
            name: "Stat_Test",
            lineWeight: 4.698694,
            maxCount: 0,
            maxPercent: 0.0,
            strokeColor: rTestColorItem(atIndex: 4),
            fillColor: rTestColorItem(atIndex: 1)
        )
    }

    @Test("Validate grid layer")
    func validateGridLayer() async throws {
        let store = try InMemoryStore(interface: SQLiteInterface())

        let delegate = MockInMemoryStoreDelegate()
        store.delegate = delegate

        _ = try await readRtestFromStore(store: store)
        print("Layer count: \(delegate.layers.count)")
        try #require(delegate.layers.count == 3)
        let grid = try #require(delegate.layers[0] as? XRLayerGrid)

        #expect(grid.fixedCount())
        #expect(grid.ringsVisible())
        #expect(grid.fixedRingCount() == 4)
        #expect(grid.ringCountIncrement() == 2)
        #expect(grid.ringPercentIncrement() == 0.11)
        #expect(grid.showLabels())
        #expect(grid.ringLabelAngle() == 77.616188)
        #expect(grid.ringFont().fontName == "ArialMT")
        #expect(grid.ringFontSize() == 24)
        #expect(grid.radialsCount() == 32)
        #expect(grid.radialsAngle() == 11.25)
        #expect(grid.radialsLabelAlign() == 0)
        #expect(grid.radialsCompassPoint() == 1)
        #expect(grid.radiansOrder() == 0)
        #expect(grid.spokeFont().fontName == "AurulentSansMonoNerdFontComplete-Regular")
        #expect(grid.radianFontSize() == 12.0)
        #expect(!grid.radianSectorLock())
        #expect(grid.radianVisible())
        #expect(grid.radianIsPercent())
        #expect(grid.radianTicks())
        #expect(grid.radianMinorTicks())
        #expect(grid.radianLabels())
    }
}
