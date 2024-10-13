//
// TableSchemaTest.swift
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
import Testing

struct TableSchemaTest {
    let interface = SQLiteInterface()

    @Test("Given Table, then read the schema")
    func readSchema() throws {
        let database = try interface.createInMemoryStore(identifier: UUID().uuidString)
        _ = try interface.executeQuery(sqlite: database, query: TestableTable.createTableQuery())

        let schema: [TableSchema] = try interface.executeCodableQuery(
            sqlite: database,
            query: TableSchema.storedValues()
        )
        let scheme = try #require(schema.first)
        #expect(schema.count == 1)
        #expect(scheme.name == "TestableTable")
        #expect(scheme.sql + ";" == TestableTable.createTableQuery().sql)
    }

    @Test("Generate empty queries")
    func generateEmptyQueries() throws {
        #expect(TableSchema.storedValues().sql == "SELECT * FROM sqlite_schema;")
        #expect(TableSchema.createTableQuery().sql.isEmpty)
        #expect(TableSchema.insertQuery().sql.isEmpty)
        #expect(TableSchema.updateQuery().sql.isEmpty)
        #expect(TableSchema.deleteQuery().sql.isEmpty)
    }
}
