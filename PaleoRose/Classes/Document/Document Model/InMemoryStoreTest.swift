//
// InMemoryStoreTest.swift
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
import SQLite3
import Testing

struct InMemoryStoreTest {
    enum InMemoryStoreTestError: Error {
        case failedToCreateStore
        case queryError
    }

    private var sqlitePointer: OpaquePointer?
    private let sqliteInterface = MockSqliteInterface()

    private func createPointer() throws -> OpaquePointer {
        var pointer: OpaquePointer?
        let result = sqlite3_open(":memory:", &pointer)
        try #require(result == SQLITE_OK)
        return try #require(pointer)
    }

    private func closePointer(pointer: OpaquePointer) throws {
        let result = sqlite3_close(pointer)
        try #require(result == SQLITE_OK)
    }

    private func assignSqlitePointerToInterface() throws -> OpaquePointer {
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        return pointer
    }

    @Test("Creating and clearing with ObjC init the object does not crash")
    func createObject() {
        var sut: InMemoryStore? = InMemoryStore()
        #expect(sut != nil)
        sut = nil
        #expect(sut == nil)
    }

    @Test("Store called, given interface, when createStore throws, then return nil")
    func catchCreateStoreError() throws {

        sqliteInterface.createInMemoryStoreError = InMemoryStoreTestError.failedToCreateStore
        #expect(throws: (any Error).self) {
            try InMemoryStore(interface: sqliteInterface)
        }
    }

    @Test("Store called, given interface, when configureStore throws, then return nil")
    func catchConfigureStoreError() throws {
        sqliteInterface.queryError = InMemoryStoreTestError.queryError
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        #expect(throws: (any Error).self) {
            try InMemoryStore(interface: sqliteInterface)
        }
        try closePointer(pointer: pointer)
    }

    @Test("Store called, given interface, when configures, call create and executequery without error")
    func configureStoreWithoutError() throws {
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        _ = try #require(try InMemoryStore(interface: sqliteInterface))

        #expect(sqliteInterface.createInMemoryStoreCalled)
        #expect(sqliteInterface.executeQueryCalled)

        try closePointer(pointer: pointer)
    }

    @Test(
        "Store called, given interface, when configures, execute a query per table",
        arguments: [
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
        ]
    )
    func configureStoreContainsQuery(tableName: String) throws {
        let pointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: pointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        _ = try #require(try InMemoryStore(interface: sqliteInterface))

        let allQueries = sqliteInterface.queryAccumulator.map(\.sql).joined(separator: "\n")
        #expect(allQueries.contains(tableName))
    }

    @Test("Given sqlite pointer, then return pointer when sqlitePointer is called")
    func getSqlitePointer() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        let pointer = try #require(try store.sqlitePointer())
        let expectedPointerInt = Int(bitPattern: expectedPointer)
        let pointerInt = Int(bitPattern: pointer)
        #expect(pointerInt == expectedPointerInt)
    }
}
