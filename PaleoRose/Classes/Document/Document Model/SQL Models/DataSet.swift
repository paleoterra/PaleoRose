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

struct DataSet: TableRepresentable, Equatable {
    static var tableName: String = "_datasets"
    static var primaryKey: String? = "_id"

    // swiftlint:disable:next identifier_name
    var _id: Int?
    var NAME: String?
    var TABLENAME: String?
    var COLUMNNAME: String?
    var PREDICATE: String?
    var COMMENTS: String? // Base 64 encoded

    // MARK: - TableRepresentable

    static func allKeys() -> [String] {
        let keys: [CodingKeys] = [.NAME, .TABLENAME, .COLUMNNAME, .PREDICATE, .COMMENTS]
        return keys.map(\.stringValue)
    }

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _datasets ( _id INTEGER PRIMARY KEY, NAME TEXT, TABLENAME TEXT, COLUMNNAME text, PREDICATE text, COMMENTS BLOB)")
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

    func decodedComments() -> NSAttributedString? {
        guard let COMMENTS else {
            return nil
        }
        guard let rtfData = Data(base64Encoded: COMMENTS) else {
            return nil
        }
        return NSAttributedString(rtf: rtfData, documentAttributes: nil)
    }

    mutating func set(comments: NSAttributedString?) {
        guard let comments else {
            COMMENTS = nil
            return
        }
        let range = NSRange(location: 0, length: comments.length)
        guard let rtfData = comments.rtf(from: range) else {
            COMMENTS = nil
            return
        }
        COMMENTS = rtfData.base64EncodedString()
    }

    func dataQuery() -> any QueryProtocol {
        guard let tableName = TABLENAME else {
            return Query(sql: "")
        }
        let predicate = PREDICATE ?? ""
        return Query(sql: "SELECT * from \(tableName) \(predicate.isEmpty ? "" : "WHERE \(predicate)")")
    }
}
