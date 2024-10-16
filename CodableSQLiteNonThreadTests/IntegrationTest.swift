//
// IntegrationTest.swift
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

@Suite("IntegrationTest", .tags(.integration))
struct IntegrationTest {
    let sut = SQLiteInterface()

    private func createInMemoryStore() throws -> OpaquePointer? {
        try sut.createInMemoryStore(identifier: UUID().uuidString)
    }

    private func createTestableTable(store: OpaquePointer) throws {
        let query = TestableTable.createTableQuery()
        try sut.executeQuery(sqlite: store, query: query)
    }

    private func insert(records: [TestableTable], intoStore store: OpaquePointer) throws {
        var insertQuery = TestableTable.insertQuery()
        let bindings = try records.compactMap { try $0.valueBindables(keys: insertQuery.keys) }
        insertQuery.bindings = bindings

        try sut.executeQuery(sqlite: store, query: insertQuery)
    }

    @Test("Given initializing a database, it is created")
    func createDatabase() throws {
        _ = try createInMemoryStore()
    }

    @Test("Given creating a test table, it does not throw")
    func createTable() throws {
        let store = try #require(try createInMemoryStore())
        try #require(try createTestableTable(store: store))
    }

    @Test("Given Created Table, when inserting new record, it does not throw")
    func insertRecord() throws {
        let store = try #require(try createInMemoryStore())
        try #require(try createTestableTable(store: store))

        let records = [
            TestableTable.stub(intValue: 1, stringValue: "Test1"),
            TestableTable.stub(intValue: 2, stringValue: "Test2"),
            TestableTable.stub(intValue: 3, stringValue: "Test3")
        ]

        try #require(try insert(records: records, intoStore: store))
    }

    @Test("Given Create Table, and records inserted, then return correct item count")
    func countRecords() throws {
        let store = try #require(try createInMemoryStore())
        try #require(try createTestableTable(store: store))

        let records = [
            TestableTable.stub(intValue: 4, stringValue: "Test4"),
            TestableTable.stub(intValue: 5, stringValue: "Test5"),
            TestableTable.stub(intValue: 6, stringValue: "Test6"),
            TestableTable.stub(intValue: 7, stringValue: "Test7")
        ]

        try #require(try insert(records: records, intoStore: store))

        let query = TestableTable.countQuery()
        let countResult: RecordCount = try #require(
            try SQLiteInterface().executeCodableQuery(sqlite: store, query: query).first
        )
        #expect(countResult.count == 4)
    }

    @Test("Given inserted records, then pull expected records from database")
    func getRectords() throws {
        let store = try #require(try createInMemoryStore())
        try #require(try createTestableTable(store: store))
        let value = TestableTable.stub(intValue: 5, stringValue: "Test5")
        let data = try JSONEncoder().encode(value)

        let records: [TestableTable] = [
            TestableTable.stub(intValue: 1, stringValue: "Test1"),
            TestableTable.stub(intValue: 2, stringValue: "Test2"),
            TestableTable.stub(intValue: 3, stringValue: "Test3"),
            TestableTable.stub(
                intValue: 4,
                stringValue: "Test4",
                optionalString: "My Optional string",
                dataStore: data
            )
        ]

        try #require(try insert(records: records, intoStore: store))
        let fromDatabase: [TestableTable] = try #require(
            try sut.executeCodableQuery(sqlite: store, query: TestableTable.storedValues())
        )

        #expect(fromDatabase == records)
    }
}
