//
// SQLiteError.swift
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
import SQLite3

public enum SQLiteError: Error {

    case dataNotFound
    case decodeFailure
    case failedToOpen
    case fileNotFound
    case invalidBindings(type: String, value: Any?, SQLiteError: Int32?)
    case invalidFile
    case invalidStatement
    case sqliteBindingError(String)
    case sqliteError(result: Int32, message: String)
    case sqliteStatementError(String)
    case unknownSqliteError(String)
    case backupFailed

    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            "Data not found"

        case .decodeFailure:
            "Failed to decode data"

        case .failedToOpen:
            "Failed to open database"

        case .fileNotFound:
            "File not found"

        case let .invalidBindings(type, value, error):
            "Invalid bindings: \(type): \(String(describing: value)), \(String(describing: error))"

        case .invalidFile:
            "Invalid file"

        case .invalidStatement:
            "Invalid statement"

        case let .sqliteBindingError(message):
            "SQLite binding error: \(message)"

        case let .sqliteError(result: result, message: message):
            "SQLite error: \(String(describing: result)): \(message)"

        case let .sqliteStatementError(message):
            "SQLite statement error: \(message)"

        case let .unknownSqliteError(message):
            "Unknown SQLite error: \(message)"

        case .backupFailed:
            "SQLite backup failed"
        }
    }

    public static func checkSqliteStatus(_ status: Int32) throws {
        guard [SQLITE_OK, SQLITE_ROW, SQLITE_DONE].contains(status) else {
            throw sqliteError(result: status, message: String(cString: sqlite3_errstr(status)))
        }
    }
}

extension SQLiteError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhsDescription = lhs.localizedDescription
        let rhsDescription = rhs.localizedDescription

        return lhsDescription == rhsDescription
    }
}
