//
// SQLiteColumnProcessor.swift
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

// swiftlint:disable opening_brace indentation_width

struct SQLiteColumnProcessor {
    let sqliteBool: Int32 = 1000
    let boolNameArray = ["bool", "boolean", "bit"]
    let columnProcessors: [Int32: SQLiteColumn] = [
        SQLITE_INTEGER: SQLiteIntegerColumn(),
        SQLITE_FLOAT: SQLiteFloatColumn(),
        SQLITE_TEXT: SQLiteTextColumn(),
        SQLITE_BLOB: SQLiteBlobColumn(),
        SQLITE_NULL: SQLiteNullColumn(),
        1000: SQLiteBoolColumn()
    ]

    func processColumn(statement: OpaquePointer, index: Int32) -> (String, Codable)? {
        guard let columnName = String(validatingUTF8: sqlite3_column_name(statement, index)) else {
            return nil
        }
        let columnType = getColumnType(statement: statement, index: index)

        if let columnProcessor = columnProcessors[columnType],
           let returnValue = columnProcessor.value(stmt: statement, index: index)
        {
            return (columnName, returnValue)
        }
        return nil
    }

    private func getColumnType(statement: OpaquePointer, index: Int32) -> Int32 {
        var columnType = sqlite3_column_type(statement, index)
        if let declaredTypePointer = sqlite3_column_decltype(statement, index) {
            let declaredType = String(cString: sqlite3_column_decltype(statement, index))
            if boolNameArray.contains(declaredType.lowercased()) {
                columnType = sqliteBool
            }
        }

        return columnType
    }
}
