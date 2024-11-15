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
        case unknownType
    }

    enum BackupType {
        case fromFile
        case toFile
    }

    struct BackupInfo {
        let path: String
        let type: BackupType
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

    func sqlitePointer() throws -> OpaquePointer {
        try validateStore()
    }

    func load(from filePath: String) throws {
        try backup(info: BackupInfo(path: filePath, type: .fromFile))
    }

    func save(to filePath: String) throws {
        try backup(info: BackupInfo(path: filePath, type: .toFile))
    }

    func dataTables() throws -> [TableSchema] {
        let sqliteStore = try validateStore()
        let tables: [TableSchema] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: TableSchema.storedValues()
        )
        let nonDataTableNames = [
            WindowControllerSize.tableName,
            Geometry.tableName,
            Layer.tableName,
            Color.tableName,
            DataSet.tableName,
            LayerText.tableName,
            LayerLineArrow.tableName,
            LayerCore.tableName,
            LayerGrid.tableName,
            LayerData.tableName,
            "sqlite_master",
            "sqlite_sequence"
        ]
        return tables.filter { !nonDataTableNames.contains($0.name) }
    }

    func dataSets() throws -> [DataSet] {
        let sqliteStore = try validateStore()

        return try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: DataSet.storedValues()
        )
    }

    func dataSetValues(for dataSet: DataSet) throws -> [Float] {
        let sqliteStore = try validateStore()
        guard let columnName = dataSet.COLUMNNAME else {
            throw InMemoryStoreError.databaseDoesNotExist
        }
        let values = try interface.executeQuery(
            sqlite: sqliteStore,
            query: dataSet.dataQuery()
        )
        return try values.compactMap { value in
            guard let value = value[columnName] else {
                return nil
            }
            if let stringValue = value as? String {
                return Float(stringValue)
            }
            // swiftlint:disable:next legacy_objc_type
            if let number = value as? NSNumber {
                return Float(truncating: number)
            }
            throw InMemoryStoreError.unknownType
        }
    }

    func valueColumnNames(for table: String) throws -> [String] {
        let valueColumnsTypes: [ColumnAffinity] = [.integer, .float]
        let sqliteStore = try validateStore()
        let columns = try interface.columns(sqlite: sqliteStore, table: table)
        return columns.compactMap { column in
            if let affinity = column.type, valueColumnsTypes.contains(affinity) {
                return column.name
            }
            return nil
        }
    }

    @discardableResult
    private func validateStore() throws -> OpaquePointer {
        guard let sqliteStore else {
            throw InMemoryStoreError.databaseDoesNotExist
        }
        return sqliteStore
    }

    private func backup(info: BackupInfo) throws {
        let store = try validateStore()
        let file = try interface.openDatabase(path: info.path)
        defer {
            closeFile(file: file)
        }
        switch info.type {
        case .fromFile:
            try interface.backup(source: file, destination: store)

        case .toFile:
            try interface.backup(source: store, destination: file)
        }
    }

    private func closeFile(file: OpaquePointer) {
        do {
            try interface.close(store: file)
        } catch {
            logError(error: "Error closing file store: \(error)")
        }
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
