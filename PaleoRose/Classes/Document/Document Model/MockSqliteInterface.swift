//
// MockSqliteInterface.swift
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
import Foundation
@testable import PaleoRose

class MockSqliteInterface: StoreProtocol {
    var pointer: OpaquePointer?

    var createInMemoryStoreError: Error?
    var createInMemoryStoreCalled = false

    var createInMemoryStoreIdentifierCalled = false

    var queryError: Error?
    var executeQueryResult: [[String: any Codable]] = []
    var executeQueryCalled = false
    var queryAccumulator: [QueryProtocol] = []

    var closeError: Error?
    var closeCalled = false

    var openDatabaseCalled = false
    var openDatabaseCapturedPath: String?

    var backupCalled = false

    func createInMemoryStore() throws -> OpaquePointer {
        createInMemoryStoreCalled = true
        if let createInMemoryStoreError {
            throw createInMemoryStoreError
        }
        guard let pointer else {
            fatalError("Pointer is nil")
        }
        return pointer
    }

    func createInMemoryStore(identifier: String) throws -> OpaquePointer {
        createInMemoryStoreIdentifierCalled = true
        if let createInMemoryStoreError {
            throw createInMemoryStoreError
        }
        guard let pointer else {
            fatalError("Pointer is nil")
        }
        return pointer
    }

    func executeQuery(sqlite: OpaquePointer, query: any QueryProtocol) throws -> [[String: any Codable]] {
        executeQueryCalled = true
        queryAccumulator.append(query)
        if let queryError {
            throw queryError
        }
        return executeQueryResult
    }

    func close(store _: OpaquePointer) throws {
        closeCalled = true
        if let closeError {
            throw closeError
        }
    }

    func openDatabase(path: String) throws -> OpaquePointer {
        openDatabaseCalled = true
        openDatabaseCapturedPath = path
        if let createInMemoryStoreError {
            throw createInMemoryStoreError
        }
        guard let pointer else {
            fatalError("Pointer is nil")
        }
        return pointer
    }

    func backup(source: OpaquePointer, destination: OpaquePointer) throws {
        backupCalled = true
    }
}
