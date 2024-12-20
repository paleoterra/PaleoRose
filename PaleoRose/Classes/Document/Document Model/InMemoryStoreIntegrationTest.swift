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

@Suite(
    "InMemory Store Integration Test",
    .tags(.integration)
)
struct InMemoryStoreIntegrationTest {
    private func sampleFilePath() throws -> String {
        guard let bundle = Bundle(identifier: "PaleoTerra.Unit-Tests"),
              let path = bundle.path(forResource: "rtest1", ofType: "XRose")
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
        let store = try #require(try InMemoryStore(interface: interface))
        let dbPointer = try #require(try store.store())
        let result: [TableSchema] = try #require(
            try interface.executeCodableQuery(
                sqlite: dbPointer,
                query: TableSchema.storedValues()
            )
        )
        let table = try #require(result.first { $0.name == execptedTable })
        let caputedSql = table.sql.replacingOccurrences(of: "IF NOT EXISTS ", with: "")
        #expect(table.sql == caputedSql)
    }

    private func assertDatabaseContentMatchesSampleFile(database: OpaquePointer) throws {
        let tables: [TableSchema] = try #require(
            try SQLiteInterface().executeCodableQuery(sqlite: database, query: TableSchema.storedValues())
        )
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

        let colors: [Color] = try #require(
            try SQLiteInterface().executeCodableQuery(sqlite: database, query: Color.storedValues())
        )
        #expect(colors.count == 4)
    }

    @Test("Given sample file, then loading the file will populate the in-memory store")
    func readFileShouldPopulateStore() throws {
        let store = try #require(try InMemoryStore())

        try backupFromSampleFileToInMemoryStore(store)

        let storePointer = try #require(store.store())

        try assertDatabaseContentMatchesSampleFile(database: storePointer)
    }

    @Test("Given a populated in-memory store, when backing up to new file, then backup successfully")
    func backupToNewFile() throws {
        let store = try #require(try InMemoryStore(interface: SQLiteInterface()))
        try backupFromSampleFileToInMemoryStore(store)

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try #require(try store.save(to: fileURL.path()))

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
        let store = try #require(try InMemoryStore(interface: SQLiteInterface()))

        let tables = try store.dataTables()
        #expect(tables.isEmpty)
    }

    @Test("Given document with data, when requesting data tables, then return array")
    func returnPopulatedTableListWhenNoData() throws {
        let store = try #require(try InMemoryStore(interface: SQLiteInterface()))
        try backupFromSampleFileToInMemoryStore(store)

        let tables = try store.dataTables()
        print(tables)
        #expect(tables.count == 1, "Expected 1 table, got \(tables.count)")
        #expect(tables.first?.name == "rtest")
    }

    @Test("Given document with data, when requesting datasets then resturn expected array with 2 records")
    func returnPopulatedDatasets() throws {
        let store = try #require(try InMemoryStore(interface: SQLiteInterface()))
        try backupFromSampleFileToInMemoryStore(store)

        let datasets = try store.dataSets()
        let expectedDataSet = DataSet(
            _id: 1,
            NAME: "Test",
            TABLENAME: "rtest",
            COLUMNNAME: "_id",
            PREDICATE: nil,
            COMMENTS: nil
        )
        try #require(datasets.count == 2, "Expected 2 datasets, got \(datasets.count)")
        #expect(datasets.first == expectedDataSet)
    }

    @Test("Given document with data, when requesting data for dataset, then return correct Float array")
    func returnPopulatedDataForDataset() throws {
        let store = try #require(try InMemoryStore(interface: SQLiteInterface()))
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
}
