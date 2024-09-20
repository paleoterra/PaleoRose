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
    public func createInMemoryStore(identifier: String = UUID().uuidString) throws -> OpaquePointer {
        var sqliteStore: OpaquePointer?
        let result = sqlite3_open_v2(
            identifier,
            &sqliteStore,
            SQLITE_OPEN_MEMORY | SQLITE_OPEN_READWRITE,
            nil
        )
        switch result {
        case SQLITE_OK, SQLITE_DONE, SQLITE_ROW:
            guard let sqliteStore else {
                throw SQLiteError.sqliteError(String(cString: sqlite3_errstr(result), encoding: .utf8) ?? "")
            }
            return sqliteStore

        default:
            throw SQLiteError.sqliteError(String(cString: sqlite3_errstr(result), encoding: .utf8) ?? "")
        }
    }

    /// Closes a SQLite store.
    /// clase will close either an in-memory SQLite store or a file-based store.
    /// - Parameters:
    /// - store: The SQLite OpagePointer to a file or in-memory store
    /// - throws:on failure, throws  with a SQLiteError
    public func close(store: OpaquePointer) throws {
        let result = sqlite3_close(store)
        switch result {
        case SQLITE_OK, SQLITE_DONE, SQLITE_ROW:
            return

        default:
            throw SQLiteError.sqliteError(String(cString: sqlite3_errstr(result), encoding: .utf8) ?? "")
        }
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
            let error = sqlite3_errcode(sqlite)
            if error != SQLITE_OK, error != SQLITE_DONE {
                try processSQLiteError(sqlite: sqlite)
            }
        }

        sqlite3_finalize(statement)
        return rowData
    }

    // MARK: Private API

    private func processSQLiteError(sqlite: OpaquePointer) throws {
        let message = String(cString: sqlite3_errmsg(sqlite))
        throw (SQLiteError.sqliteError(message))
    }

    private func buildStatement(sqlite: OpaquePointer, query: QueryProtocol) throws -> OpaquePointer {
        var theStmt: OpaquePointer?
        let prepareResult = sqlite3_prepare_v2(sqlite, query.sql, -1, &theStmt, nil)

        guard let stmt = theStmt else {
            let message = String(cString: sqlite3_errmsg(sqlite))
            throw (SQLiteError.sqliteStatementError(message))
        }

        if prepareResult != SQLITE_OK {
            try processSQLiteError(sqlite: sqlite)
        }

        return stmt
    }

    private func bind(bindings: [Any?], statement: OpaquePointer) throws {
        for (index, binding) in bindings.enumerated() {
            let currentIndex = Int32(index + 1)
            try bind(binding, to: statement, at: currentIndex)
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
    public func bind(_ value: (some Any)?, to statement: OpaquePointer?, at index: Int32) throws {
        guard let statement else {
            throw SQLiteError.invalidStatement
        }

        guard let value else {
            try bindNull(to: statement, at: index)
            return
        }

        switch value {
        case let dataValue as Data:
            try bindData(dataValue, to: statement, at: index)

        case let value as any BinaryInteger:
            try bindInteger(value, to: statement, at: index)

        case let value as any BinaryFloatingPoint:
            try bindBinaryFloatingPoint(value, to: statement, at: index)

        case let value as CGFloat:
            let doubleValue = Double(value)
            try bindBinaryFloatingPoint(doubleValue, to: statement, at: index)

        case let value as String:
            try bindString(value, to: statement, at: index)

        default:
            throw SQLiteError.invalidBindings
        }
    }

    private func bindNull(to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_null(statement, index)
        if result != SQLITE_OK {
            throw SQLiteError.invalidBindings
        }
    }

    private func bindData(_ data: Data, to statement: OpaquePointer, at index: Int32) throws {
        let bytes = try data.withUnsafeBytes { value in
            guard let address = value.baseAddress else {
                throw SQLiteError.invalidBindings
            }
            return address
        }
        let result = sqlite3_bind_blob(statement, index, bytes, Int32(data.count), nil)
        if result != SQLITE_OK {
            throw SQLiteError.invalidBindings
        }
    }

    private func bindInteger<T: BinaryInteger>(_ value: T, to statement: OpaquePointer, at index: Int32) throws {
        let memeorySize = MemoryLayout<T>.size
        var result: Int32 = 0
        let byteCount = 4
        if memeorySize <= byteCount {
            result = sqlite3_bind_int(statement, index, Int32(value))
        } else {
            result = sqlite3_bind_int64(statement, index, Int64(value))
        }
        if result != SQLITE_OK {
            throw SQLiteError.invalidBindings
        }
    }

    private func bindBinaryFloatingPoint(
        _ value: some BinaryFloatingPoint,
        to statement: OpaquePointer,
        at index: Int32
    ) throws {
        let result = sqlite3_bind_double(statement, index, Double(value))
        if result != SQLITE_OK {
            throw SQLiteError.invalidBindings
        }
    }

    private func bindString(_ value: String, to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_text(statement, index, value, -1, nil)
        if result != SQLITE_OK {
            throw SQLiteError.invalidBindings
        }
    }
}
