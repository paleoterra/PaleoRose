//
// SQLiteBoolColumn.swift
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

struct SQLiteBoolColumn: SQLiteColumn {
    func value(stmt: OpaquePointer, index: Int32) -> (any Codable)? {
        let columnType = sqlite3_column_type(stmt, index)
        switch columnType {
        case SQLITE_INTEGER:
            return boolAsInt(stmt: stmt, index: index)

        case SQLITE_FLOAT:
            return boolAsFloat(stmt: stmt, index: index)

        case SQLITE_TEXT:
            return boolAsString(stmt: stmt, index: index)

        case SQLITE_BLOB:
            return false

        case SQLITE_NULL:
            return false

        default:
            return false
        }
    }

    func boolAsString(stmt: OpaquePointer, index: Int32) -> Bool {
        let possibles = ["true", "yes", "1", "t", "y"]
        guard let pointer = UnsafeRawPointer(sqlite3_column_text(stmt, index)) else {
            return false
        }
        let value = String(cString: pointer.assumingMemoryBound(to: CChar.self))
        return possibles.contains(value.lowercased())
    }

    func boolAsInt(stmt: OpaquePointer, index: Int32) -> Bool {
        sqlite3_column_int(stmt, index) > 0
    }

    func boolAsFloat(stmt: OpaquePointer, index: Int32) -> Bool {
        sqlite3_column_double(stmt, index) > 0
    }
}
