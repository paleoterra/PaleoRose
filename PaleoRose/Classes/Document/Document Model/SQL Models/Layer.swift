//
// Layer.swift
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

struct Layer: TableRepresentable {
    static var tableName: String = "_layers"
    static var primaryKey: String?

    var LAYERID: Int
    var TYPE: String
    var VISIBLE: Bool
    var ACTIVE: Bool
    var BIDIR: Bool
    // swiftlint:disable:next identifier_name
    var LAYER_NAME: String
    var LINEWEIGHT: Float
    var MAXCOUNT: Int
    var MAXPERCENT: Float

    // MARK: - TableRepresentable

    private static func allKeys() -> [String] {
        let keys: [CodingKeys] = [
            .LAYERID,
            .TYPE,
            .VISIBLE,
            .ACTIVE,
            .BIDIR,
            .LAYER_NAME,
            .LINEWEIGHT,
            .MAXCOUNT,
            .MAXPERCENT
        ]

        return keys.map(\.stringValue)
    }

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _layers (LAYERID INTEGER PRIMARY KEY AUTOINCREMENT, TYPE TEXT, VISIBLE BOOL, ACTIVE BOOL, BIDIR BOOL, LAYER_NAME TEXT, LINEWEIGHT REAL, MAXCOUNT INTEGER, MAXPERCENT REAL);")
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
