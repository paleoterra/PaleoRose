//
// InMemoryStore.swift
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
import OSLog

class InMemoryStore: NSObject {
    enum InMemoryStoreError: Error {
        case databaseDoesNotExist
    }

    private var sqliteStore: OpaquePointer?
    let interface: StoreProtocol

    private let createTableQueries: [QueryProtocol] = [
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

    @available(*, deprecated, message: "This code will become unavailable")
    @objc override init() {
        interface = SQLiteInterface()
        super.init()
        do {
            try setupDatabase()
        } catch {
            logError(error: "Error creating in-memory store: \(error)")
            return
        }
    }

    init(interface: StoreProtocol = SQLiteInterface()) throws {
        self.interface = interface
        super.init()
        try setupDatabase()
    }

    @available(*, deprecated, message: "This code will become unavailable")
    @objc func store() -> OpaquePointer? {
        sqliteStore
    }

    private func setupDatabase() throws {
        do {
            let store = try createStore()
            sqliteStore = store
            try configureStore(store: store)
        } catch {
            logError(error: "Error creating in-memory store: \(error)")
            throw error
        }
    }

    private func createStore() throws -> OpaquePointer {
        try interface.createInMemoryStore()
    }

    private func configureStore(store: OpaquePointer) throws {
        try createTableQueries.forEach { query in
            try _ = interface.executeQuery(sqlite: store, query: query)
        }
    }

    private func logError(error: String) {
        Logger.memoryStoreLogger.error("\(error)")
    }

    deinit {
        if let sqliteStore {
            do {
                try interface.close(store: sqliteStore)
            } catch {
                logError(error: "Error closing in-memory store: \(error)")
            }
        }
    }
}
