// InMemoryStoreUserTableTests.swift
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

@Suite("InMemoryStore — createUserTable")
struct InMemoryStoreUserTableTests {

    @Test("created table appears in tableNames")
    func tableAppearsAfterCreate() throws {
        let store = try InMemoryStore()
        try store.createUserTable(
            createSQL: "CREATE TABLE \"strikes\" (_id INTEGER PRIMARY KEY, \"Azimuth\" NUMERIC)",
            insertSQL: "INSERT INTO \"strikes\" (\"Azimuth\") VALUES (?)",
            rows: [[90 as Bindable?], [180 as Bindable?]]
        )
        let names = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(names.contains("strikes"))
    }

    @Test("row count matches inserted rows")
    func rowCountMatches() throws {
        let store = try InMemoryStore()
        try store.createUserTable(
            createSQL: "CREATE TABLE \"t\" (_id INTEGER PRIMARY KEY, \"v\" NUMERIC)",
            insertSQL: "INSERT INTO \"t\" (\"v\") VALUES (?)",
            rows: [[1 as Bindable?], [2 as Bindable?], [3 as Bindable?]]
        )
        let database = try store.sqlitePointer()
        let result = try store.interface.executeQuery(
            sqlite: database, query: Query(sql: "SELECT count(*) AS n FROM \"t\"")
        )
        #expect(result.first?["n"] as? Int32 == 3)
    }

    @Test("rolls back entirely on INSERT failure — table does not exist")
    func rollsBackOnError() throws {
        let store = try InMemoryStore()
        #expect(throws: (any Error).self) {
            try store.createUserTable(
                createSQL: "CREATE TABLE \"t\" (_id INTEGER PRIMARY KEY, \"v\" NUMERIC)",
                insertSQL: "INSERT INTO \"t\" (\"bad_col\") VALUES (?)",
                rows: [[1 as Bindable?]]
            )
        }
        let names = try store.tableNames(sqliteStore: store.sqlitePointer())
        #expect(!names.contains("t"))
    }

    @Test("multiple columns: all values stored correctly")
    func multipleColumnsStored() throws {
        let store = try InMemoryStore()
        try store.createUserTable(
            createSQL: """
            CREATE TABLE "samples" (
            \t_id INTEGER PRIMARY KEY,
            \t"Azimuth" NUMERIC,
            \t"Label" TEXT
            )
            """,
            insertSQL: "INSERT INTO \"samples\" (\"Azimuth\", \"Label\") VALUES (?, ?)",
            rows: [
                [45 as Bindable?, "North" as Bindable?],
                [90 as Bindable?, "East" as Bindable?]
            ]
        )
        let database = try store.sqlitePointer()
        let result = try store.interface.executeQuery(
            sqlite: database, query: Query(sql: "SELECT count(*) AS n FROM \"samples\"")
        )
        #expect(result.first?["n"] as? Int32 == 2)
        #expect(try store.tableNames(sqliteStore: database).contains("samples"))
    }
}
