//
// Geometry.swift
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

struct Geometry: TableRepresentable {
    static var tableName: String = "_geometryController"
    static var primaryKey: String?

    // swiftlint:disable:next identifier_name
    var _id: String
    var isEqualArea: Bool
    var isPercent: Bool
    var MAXCOUT: Int
    var MAXPERCENT: Float
    var HOLLOWCORE: Float
    var SECTORSIZE: Float
    var STARTINGANGLE: Float
    var SECTORCOUNT: Int
    var RELATIVESIZE: Float

    // MARK: - TableRepresentable

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _geometryController (isEqualArea bool, isPercent bool, MAXCOUNT int, MAXPERCENT float, HOLLOWCORE float, SECTORSIZE float, STARTINGANGLE float, SECTORCOUNT int, RELATIVESIZE float);")
    }

    static func insertQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "INSERT INTO _geometryController (isEqualArea, isPercent, MAXCOUNT, MAXPERCENT, HOLLOWCORE, SECTORSIZE, STARTINGANGLE, SECTORCOUNT, RELATIVESIZE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);", keys: ["isEqualArea", "isPercent", "MAXCOUNT", "MAXPERCENT", "MAXPERCENT", "HOLLOWCORE", "SECTORSIZE", "STARTINGANGLE", "SECTORCOUNT", "RELATIVESIZE"])
    }

    static func updateQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "update _geometryController  set isEqualArea=?, isPercent=?, MAXCOUNT=?, MAXPERCENT=?, HOLLOWCORE=?, SECTORSIZE=?, STARTINGANGLE=?, SECTORCOUNT=?, RELATIVESIZE=?;", keys: ["isEqualArea", "isPercent", "MAXCOUNT", "MAXPERCENT", "MAXPERCENT", "HOLLOWCORE", "SECTORSIZE", "STARTINGANGLE", "SECTORCOUNT", "RELATIVESIZE"])
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }
}
