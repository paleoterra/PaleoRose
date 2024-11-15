//
// SQLiteInterface.swift
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

import Foundation
import OSLog
import SQLite3

// swiftlint:disable:next identifier_name
let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
// swiftlint:disable:next identifier_name
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// The Codeable (Non-threaded) interface for Sqlite
public struct SQLiteInterface {
    private let columnProcessor = SQLiteColumnProcessor()
    /// Simple init
    public init() {}

    // document the createInMemoryStore function
    /// Create an in memory store
    /// When using an in-memory store, the user must hold on to the pointer to the store.
    /// Allowing the pointer to go nil may delete he store and could lead to a memory leak
    /// - Parameters:
    /// - Identifier: Specify an identifier for the store. One will be set automatically if not specified
    /// - Returns:OpaquePointer, the pointer to the SQLite in-memory store
    /// - throws:on failure, throws  with a SQLiteError
    public func createInMemoryStore(identifier: String) throws -> OpaquePointer {
        var sqliteStore: OpaquePointer?
        try SQLiteError.checkSqliteStatus(sqlite3_open_v2(
            identifier,
            &sqliteStore,
            SQLITE_OPEN_MEMORY | SQLITE_OPEN_READWRITE,
            nil
        ))
        guard let store = sqliteStore else {
            throw SQLiteError.unknownSqliteError("Failed to open in-memory store")
        }
        return store
    }

    /// Open a sqlite database on disk
    /// - Parameters:
    /// - Path: String representing the file location on disk
    ///
    /// - Returns: Pointer representing the sqlite file
    /// - Throws: SQLite error if opening the file fails
    public func openDatabase(path: String) throws -> OpaquePointer {
        var sqliteStore: OpaquePointer?
        try SQLiteError.checkSqliteStatus(sqlite3_open_v2(
            path,
            &sqliteStore,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            nil
        ))
        guard let store = sqliteStore else {
            throw SQLiteError.unknownSqliteError("Failed to open database at \(path)")
        }
        return store
    }

    /// Copies SQLite contents from inmemory to disk or vice versa
    ///
    /// - Parameters:
    /// - source: The database pointer to be copied
    /// - destination: The database pointer that is the target of the copy
    ///
    /// - Throws: If the copy process fails, expect a SQLiteError
    public func backup(source: OpaquePointer, destination: OpaquePointer) throws {
        let backup = sqlite3_backup_init(
            destination,
            "main",
            source,
            "main"
        )
        guard let backup else {
            throw SQLiteError.backupFailed
        }
        defer {
            sqlite3_backup_finish(backup)
        }
        try SQLiteError.checkSqliteStatus(sqlite3_backup_step(backup, -1))
    }

    /// Closes a SQLite store.
    /// clase will close either an in-memory SQLite store or a file-based store.
    /// - Parameters:
    /// - store: The SQLite OpagePointer to a file or in-memory store
    /// - throws:on failure, throws  with a SQLiteError
    public func close(store: OpaquePointer) throws {
        try SQLiteError.checkSqliteStatus(sqlite3_close(store))
    }

    /// Executes a query on a database with the expectation of returning items of type T
    /// - Parameters:
    /// - sqlite: The SQLite OpagePointer to a file or in-memory store
    /// - query: The QueryProtocol for the query to execute
    /// - returns: An array of type T
    /// - throws:on failure, throws  with a SQLiteError
    public func executeCodableQuery<T: Codable>(sqlite: OpaquePointer, query: QueryProtocol) throws -> [T] {
        do {
            let result = try executeDataQuery(sqlite: sqlite, query: query)
            return try JSONDecoder().decode([T].self, from: result)
        } catch {
            if #available(macOS 11.0, *) {
                Logger.codableLog.debug("\(error.localizedDescription, privacy: .private)")
            }
            throw error
        }
    }

    /// Executes a query on a database with the expectation of returning data
    /// - Parameters:
    /// - sqlite: The SQLite OpagePointer to a file or in-memory store
    /// - query: The QueryProtocol for the query to execute
    /// - returns: JSON Data object
    /// - throws:on failure, throws  with a SQLiteError
    public func executeDataQuery(sqlite: OpaquePointer, query: QueryProtocol) throws -> Data {
        let result = try executeQuery(sqlite: sqlite, query: query)
        return try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
    }

    /// Executes a query on a database with the expectation of returning decoded data
    /// - Parameters:
    /// - sqlite: The SQLite OpagePointer to a file or in-memory store
    /// - query: The QueryProtocol for the query to execute
    /// - returns: an array of [String: Codable] dictionaries representing the result
    /// - throws:on failure, throws  with a SQLiteError
    @discardableResult
    public func executeQuery(sqlite: OpaquePointer, query: QueryProtocol) throws -> [[String: Codable]] {
        let statement = try buildStatement(sqlite: sqlite, query: query)

        var rowData = [[String: Codable]]()

        let subqueries = query.subqueries()

        for subquery in subqueries {
            sqlite3_reset(statement)
            try bind(bindings: subquery.bindables, statement: statement)
            while sqlite3_step(statement) == SQLITE_ROW {
                rowData.append(processRow(theStmt: statement))
            }
            try SQLiteError.checkSqliteStatus(sqlite3_errcode(sqlite))
        }

        sqlite3_finalize(statement)
        return rowData
    }

    /// Create a statement for a database using a query
    ///
    /// - Parameters:
    ///   - sqlite: Pointer to the database
    ///   - query: Query for building the statement
    ///   - returns: Pointer to the statement
    ///   - throws: SQLite error
    public func buildStatement(sqlite: OpaquePointer, query: QueryProtocol) throws -> OpaquePointer {
        var theStmt: OpaquePointer?
        try SQLiteError.checkSqliteStatus(sqlite3_prepare_v2(sqlite, query.sql, -1, &theStmt, nil))
        guard let statement = theStmt else {
            throw SQLiteError.unknownSqliteError("Failed to prepare statement")
        }
        return statement
    }

    /// Returns column information for a given table name
    ///
    /// - Parameters:
    /// - sqlite: Pointer to the database
    /// - table: Name of the table as a string
    ///
    /// - Returns: A ColumnInformation array containing information about all of the columns
    public func columns(sqlite: OpaquePointer, table: String) throws -> [ColumnInformation] {
        let sql = Query(sql: "SELECT * FROM \(table)")
        let statement = try buildStatement(sqlite: sqlite, query: sql)
        defer {
            sqlite3_finalize(statement)
        }
        sqlite3_step(statement)
        var columns: [ColumnInformation] = []
        let columnCount = sqlite3_column_count(statement)
        for column in 0 ..< columnCount {
            let name = String(cString: sqlite3_column_name(statement, column))
            let type = ColumnAffinity(rawValue: sqlite3_column_type(statement, column))
            let decType = String(cString: sqlite3_column_decltype(statement, column))
            columns.append(
                ColumnInformation(
                    columnIndex: Int(column),
                    name: name,
                    type: type,
                    declairedType: decType
                )
            )
        }
        return columns
    }

    // MARK: Private API

    private func bind(bindings: [Bindable?], statement: OpaquePointer) throws {
        for (index, binding) in bindings.enumerated() {
            if let binding {
                let currentIndex = Int32(index + 1)
                try bind(binding, to: statement, at: currentIndex)
            }
        }
    }

    @discardableResult
    private func processRow(theStmt: OpaquePointer) -> [String: Codable] {
        var aRecord = [String: Codable]()
        let count = sqlite3_column_count(theStmt)
        for column in 0 ..< count {
            if let value = columnProcessor.processColumn(statement: theStmt, index: column) {
                aRecord[value.0] = value.1
            }
        }
        return aRecord
    }

    // MARK: - Binding

    /// Allows binding values to a sqlite call
    /// Normally, this process should be done useing the query. This is available if required.
    /// - Parameters:
    /// - value: An array of values to bind
    /// - statement: SQLite statement pointer
    /// - throws:on failure, throws  with a SQLiteError
    public func bind(_ value: (some Bindable)?, to statement: OpaquePointer, at index: Int32) throws {
        guard let value else {
            try bindNull(to: statement, at: index)
            return
        }
        try value.bind(statement: statement, index: index)
    }

    private func bindNull(to statement: OpaquePointer, at index: Int32) throws {
        do {
            try SQLiteError.checkSqliteStatus(sqlite3_bind_null(statement, index))
        } catch let SQLiteError.sqliteError(result, _) {
            throw SQLiteError.invalidBindings(
                type: String(describing: type(of: NSNull.self)),
                value: nil,
                SQLiteError: result
            )
        } catch {
            throw error
        }
    }
}
