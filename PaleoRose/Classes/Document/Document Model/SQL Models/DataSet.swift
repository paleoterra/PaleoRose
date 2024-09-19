//
// DataSet.swift
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

struct DataSet: TableRepresentable {
    static var tableName: String = "_datasets"
    static var primaryKey: String? = "_id"

    // swiftlint:disable:next identifier_name
    var _id: Int
    var NAME: String
    var TABLENAME: String
    var COLUMNNAME: String
    var PREDICATE: String
    var COMMENTS: String

    // MARK: - TableRepresentable

    static func createTableQuery() -> any QueryProtocol {
        Query(sql: "CREATE TABLE IF NOT EXISTS _datasets ( _id INTEGER PRIMARY KEY, NAME TEXT, TABLENAME TEXT, COLUMNNAME text, PREDICATE text,COMMENTS BLOB)")
    }

    static func insertQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func updateQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }
}
