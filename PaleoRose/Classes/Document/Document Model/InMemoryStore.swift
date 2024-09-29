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

class InMemoryStore: NSObject {
    private var sqliteStore: OpaquePointer?
    private let interface = SQLiteInterface()

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
    @objc func store() -> OpaquePointer? {
        guard let sqliteStore else {
            do {
                try createStore()
                try configureStore()
                return sqliteStore
            } catch {
                return nil
            }
        }
        return sqliteStore
    }

    private func createStore() throws {
        do {
            sqliteStore = try interface.createInMemoryStore()
        } catch {
            print("Error creating in-memory store: \(error)")
            throw error
        }
    }

    private func configureStore() throws {
        guard let sqliteStore else {
            return
        }
        try createTableQueries.forEach { query in
            try interface.executeQuery(sqlite: sqliteStore, query: query)
        }
    }

    deinit {
        if let sqliteStore {
            do {
                try interface.close(store: sqliteStore)
            } catch {
                print("Error closing in-memory store: \(error)")
            }
        }
    }
}
