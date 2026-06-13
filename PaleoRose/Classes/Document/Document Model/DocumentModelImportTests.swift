// DocumentModelImportTests.swift
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
@testable import PaleoRose
import TabularData
import Testing

// MARK: - Mock

final class MockDataFrameTableWriter: DataFrameTableWriting {
    var createSQLResult = "CREATE TABLE \"t\" (_id INTEGER PRIMARY KEY, \"v\" NUMERIC)"
    var insertSQLResult = "INSERT INTO \"t\" (\"v\") VALUES (?)"
    var bindingRowsResult: [[Bindable?]] = []
    private(set) var createCallCount = 0

    func createSQL(for dataFrame: DataFrame, named tableName: String) -> String {
        createCallCount += 1
        return createSQLResult
    }

    func insertSQL(for dataFrame: DataFrame, named tableName: String) -> String {
        insertSQLResult
    }

    func bindingRows(for dataFrame: DataFrame) -> [[Bindable?]] {
        bindingRowsResult
    }
}

// MARK: - Tests

@Suite("DocumentModel — importTable")
struct DocumentModelImportTests {

    @Test("tableNamesSubject emits new name after import")
    func tableNamesPublisherFires() throws {
        let store = try InMemoryStore()
        let model = DocumentModel(inMemoryStore: store, document: nil)
        let mock = MockDataFrameTableWriter()
        mock.createSQLResult = "CREATE TABLE \"strikes\" (_id INTEGER PRIMARY KEY, \"v\" NUMERIC)"
        mock.insertSQLResult = "INSERT INTO \"strikes\" (\"v\") VALUES (?)"
        mock.bindingRowsResult = [[1.0 as Bindable?]]

        var dataframe = DataFrame()
        dataframe.append(column: Column<Double>(name: "v", contents: [1.0]))

        var received: [String] = []
        let cancellable = model.dataSetRecordsPublisher.sink { received = $0 }
        try model.importTable(dataframe, named: "strikes", writer: mock)

        #expect(received.contains("strikes"))
        cancellable.cancel()
    }

    @Test("throws emptyDataFrame for a zero-row DataFrame")
    func throwsOnEmptyFrame() throws {
        let store = try InMemoryStore()
        let model = DocumentModel(inMemoryStore: store, document: nil)
        #expect(throws: TableImportError.emptyDataFrame) {
            try model.importTable(DataFrame(), named: "t")
        }
    }

    @Test("writer is called exactly once per import")
    func writerCalledOnce() throws {
        let store = try InMemoryStore()
        let model = DocumentModel(inMemoryStore: store, document: nil)
        let mock = MockDataFrameTableWriter()
        mock.createSQLResult = "CREATE TABLE \"x\" (_id INTEGER PRIMARY KEY, \"v\" NUMERIC)"
        mock.insertSQLResult = "INSERT INTO \"x\" (\"v\") VALUES (?)"
        mock.bindingRowsResult = [[1 as Bindable?]]
        var dataframe = DataFrame()
        dataframe.append(column: Column<Int>(name: "v", contents: [1]))
        try model.importTable(dataframe, named: "x", writer: mock)
        #expect(mock.createCallCount == 1)
    }

    @Test("two-arg importTable uses real DataFrameTableWriter")
    func twoArgImportUsesRealWriter() throws {
        let store = try InMemoryStore()
        let model = DocumentModel(inMemoryStore: store, document: nil)
        var dataframe = DataFrame()
        dataframe.append(column: Column<Double>(name: "Azimuth", contents: [45.0, 90.0]))
        try model.importTable(dataframe, named: "azimuths")
        let names = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(names.contains("azimuths"))
    }
}
