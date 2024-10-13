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
}
