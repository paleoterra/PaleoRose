//
// Color.swift
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

struct Color: TableRepresentable {
    static var tableName = "_colors"
    static var primaryKey: String? = "COLORID"

    var COLORID: Int
    var RED: Float
    var BLUE: Float
    var GREEN: Float
    var ALPHA: Float

    // MARK: - TableRepresentable

    static func allKeys() -> [String] {
        let keys: [CodingKeys] = [.COLORID, .RED, .BLUE, .GREEN, .ALPHA]
        return keys.map(\.stringValue)
    }

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _colors (COLORID INTEGER PRIMARY KEY AUTOINCREMENT, RED REAL, BLUE REAL, GREEN REAL, ALPHA REAL)")
    }

    static func insertQuery() -> any QueryProtocol {
        Query(sql: "INSERT INTO _colors (COLORID, RED, BLUE, GREEN, ALPHA) VALUES (?,?,?,?);")
    }

    static func updateQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    // MARK: - Conversion

    func nsColor() -> NSColor {
        NSColor(red: CGFloat(RED), green: CGFloat(GREEN), blue: CGFloat(BLUE), alpha: CGFloat(ALPHA))
    }
}
