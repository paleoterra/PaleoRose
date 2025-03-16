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

// swiftlint:disable indentation_width

@Suite("IntegrationTest", .tags(.integration))
struct IntegrationTest {
    let sut = SQLiteInterface()
    let expectedTestableTable: [TestableTable] = [
        .init(
            boolValue: true,
            intValue: 1,
            int32Value: 2,
            uintValue: 3,
            uint32Value: 4,
            int16Value: 5,
            uint16Value: 6,
            floatValue: 17.1,
            doubleValue: 342.234234,
            cgFloatValue: 23.23,
            stringValue: "dream",
            optionalString: nil,
            dataStore: nil
        ),
        .init(
            boolValue: false,
            intValue: 2,
            int32Value: 3,
            uintValue: 2,
            uint32Value: 54,
            int16Value: 34,
            uint16Value: 2,
            floatValue: 13.1,
            doubleValue: 540.3,
            cgFloatValue: 23.23,
            stringValue: "bacon",
            optionalString: "sunshine",
            dataStore: nil
        ),
        .init(
            boolValue: true,
            intValue: 3,
            int32Value: 33,
            uintValue: 23,
            uint32Value: 543,
            int16Value: 345,
            uint16Value: 15,
            floatValue: 145.2323,
            doubleValue: 520,
            cgFloatValue: 23,
            stringValue: "day",
            optionalString: "week",
            dataStore: nil
        )
    ]

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

    private func openTestFile() throws -> OpaquePointer {
        guard let bundle = Bundle(identifier: "paleoterra.CodableSQLiteNonThreadTests"),
              let path = bundle.path(forResource: "testfile", ofType: "sqlite")
        else {
            Issue.record("Could not find test file")
            throw SQLiteError.failedToOpen
        }
        return try sut.openDatabase(path: path)
    }

    private func openTemporaryFile(directory: URL, name: String) throws -> OpaquePointer {
        try sut.openDatabase(path: directory.appendingPathComponent(name).path)
    }

    private func temporaryDirectory() throws -> URL {
        FileManager.default.temporaryDirectory
    }

    @Test("Given initializing a database, it is created")
    func createDatabase() throws {
        _ = try createInMemoryStore()
    }

    @Test("Given creating a test table, it does not throw")
    func createTable() throws {
        let store = try #require(try createInMemoryStore())
        defer {
            do {
                try #require(try sut.close(store: store))
            } catch {
                Issue.record("Failed to close database file: \(error)")
            }
        }
        try #require(try createTestableTable(store: store))
    }

    @Test("Given Created Table, when inserting new record, it does not throw")
    func insertRecord() throws {
        let store = try #require(try createInMemoryStore())
        try #require(try createTestableTable(store: store))
        defer {
            do {
                try #require(try sut.close(store: store))
            } catch {
                Issue.record("Failed to close database file: \(error)")
            }
        }
        let records = [
            TestableTable.stub(intValue: 1, stringValue: "Test1"),
            TestableTable.stub(intValue: 2, stringValue: "Test2"),
            TestableTable.stub(intValue: 3, stringValue: "Test3")
        ]

        try #require(try insert(records: records, intoStore: store))
    }

//    @Test("Given Create Table, and records inserted, then return correct item count")
//    func countRecords() throws {
//        let store = try #require(try createInMemoryStore())
//        defer {
//            do {
//                try #require(try sut.close(store: store))
//            } catch {
//                Issue.record("Failed to close database file: \(error)")
//            }
//        }
//        try #require(try createTestableTable(store: store))
//
//        let records = [
//            TestableTable.stub(intValue: 4, stringValue: "Test4"),
//            TestableTable.stub(intValue: 5, stringValue: "Test5"),
//            TestableTable.stub(intValue: 6, stringValue: "Test6"),
//            TestableTable.stub(intValue: 7, stringValue: "Test7")
//        ]
//
//        try #require(try insert(records: records, intoStore: store))
//
//        let query = TestableTable.countQuery()
//        let countResult: RecordCount = try #require(
//            try SQLiteInterface().executeCodableQuery(sqlite: store, query: query).first
//        )
//        #expect(countResult.count == 4)
//    }

//    @Test("Given inserted records, then pull expected records from database")
//    func getRectords() throws {
//        let store = try #require(try createInMemoryStore())
//        defer {
//            do {
//                try #require(try sut.close(store: store))
//            } catch {
//                Issue.record("Failed to close database file: \(error)")
//            }
//        }
//        try #require(try createTestableTable(store: store))
//        let value = TestableTable.stub(intValue: 5, stringValue: "Test5")
//        let data = try JSONEncoder().encode(value)
//
//        let records: [TestableTable] = [
//            TestableTable.stub(intValue: 1, stringValue: "Test1"),
//            TestableTable.stub(intValue: 2, stringValue: "Test2"),
//            TestableTable.stub(intValue: 3, stringValue: "Test3"),
//            TestableTable.stub(
//                intValue: 4,
//                stringValue: "Test4",
//                optionalString: "My Optional string",
//                dataStore: data
//            )
//        ]
//
//        try #require(try insert(records: records, intoStore: store))
//        let fromDatabase: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: store, query: TestableTable.storedValues())
//        )
//
//        #expect(fromDatabase == records)
//    }

    @Test("Given existing store url, then open, and then close again")
    func openAndCloseSqliteFileOnDisk() throws {
        let store = try #require(try openTestFile())
        try #require(try sut.close(store: store))
    }

//    @Test("Given database on disk, open file and read testable table, then verify records")
//    func readDataFromDisk() throws {
//        let file = try #require(try openTestFile())
//        defer {
//            do {
//                try #require(try sut.close(store: file))
//            } catch {
//                Issue.record("Failed to close database file: \(error)")
//            }
//        }
//        let items: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: file, query: TestableTable.storedValues())
//        )
//        try #require(items.count == 3)
//        #expect(items == expectedTestableTable)
//    }
//
//    @Test("Given sqlite file, when backing up to in-memory, then data copied")
//    func backupFromDiskToInMemory() throws {
//        let file = try #require(try openTestFile())
//        defer {
//            do {
//                try #require(try sut.close(store: file))
//            } catch {
//                Issue.record("Failed to close database file: \(error)")
//            }
//        }
//        let store = try #require(try createInMemoryStore())
//        defer {
//            do {
//                try #require(try sut.close(store: store))
//            } catch {
//                Issue.record("Failed to close database store: \(error)")
//            }
//        }
//
//        try sut.backup(source: file, destination: store)
//
//        let originalItems: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: file, query: TestableTable.storedValues())
//        )
//        let copiedItems: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: store, query: TestableTable.storedValues())
//        )
//        #expect(originalItems == copiedItems)
//        #expect(copiedItems == expectedTestableTable)
//    }
//
//    @Test("Given in-memory store, when backing up to file, then data copied")
//    func backupFromMemoryToInDisk() throws {
//        let temporaryDirectory = try temporaryDirectory()
//        let filename = UUID().uuidString
//        let path = temporaryDirectory.appendingPathComponent(filename).path
//        let file = try #require(try sut.openDatabase(path: path))
//        defer {
//            do {
//                try #require(try sut.close(store: file))
//                try #require(try FileManager.default.removeItem(atPath: path))
//            } catch {
//                Issue.record("Failed to close or delete database file: \(error)")
//            }
//        }
//
//        try #require(FileManager.default.fileExists(atPath: path))
//
//        let store = try #require(try createInMemoryStore())
//        defer {
//            do {
//                try #require(try sut.close(store: store))
//            } catch {
//                Issue.record("Failed to close database store: \(error)")
//            }
//        }
//
//        try sut.executeQuery(sqlite: store, query: TestableTable.createTableQuery())
//
//        var insertQuery = TestableTable.insertQuery()
//        let bindings = try expectedTestableTable.compactMap { try $0.valueBindables(keys: insertQuery.keys) }
//        insertQuery.bindings = bindings
//
//        try sut.executeQuery(sqlite: store, query: insertQuery)
//
//        try sut.backup(source: store, destination: file)
//
//        let originalItems: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: store, query: TestableTable.storedValues())
//        )
//        let copiedItems: [TestableTable] = try #require(
//            try sut.executeCodableQuery(sqlite: file, query: TestableTable.storedValues())
//        )
//        #expect(originalItems == copiedItems)
//        #expect(copiedItems == expectedTestableTable)
//    }

    @Test("Given request for columns, then return valid column array")
    func getColumnArray() throws {
        let store = try #require(try openTestFile())
        let expectedColumns: [ColumnInformation] = [
            .init(columnIndex: 0, name: "intValue", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 1, name: "int32Value", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 2, name: "uintValue", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 3, name: "uint32Value", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 4, name: "int16Value", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 5, name: "uint16Value", type: .integer, declairedType: "INTEGER"),
            .init(columnIndex: 6, name: "floatValue", type: .float, declairedType: "REAL"),
            .init(columnIndex: 7, name: "doubleValue", type: .float, declairedType: "DOUBLE"),
            .init(columnIndex: 8, name: "cgFloatValue", type: .float, declairedType: "DOUBLE"),
            .init(columnIndex: 9, name: "stringValue", type: .text, declairedType: "TEXT"),
            .init(columnIndex: 10, name: "optionalString", type: .null, declairedType: "TEXT"),
            .init(columnIndex: 11, name: "dataStore", type: .null, declairedType: "BLOB"),
            .init(columnIndex: 12, name: "boolValue", type: .integer, declairedType: "BOOL")
        ]

        defer {
            do {
                try #require(try sut.close(store: store))
            } catch {
                Issue.record("Failed to close database file: \(error)")
            }
        }
        let columns = try sut.columns(sqlite: store, table: "TestableTable")

        #expect(columns == expectedColumns)
    }
}
