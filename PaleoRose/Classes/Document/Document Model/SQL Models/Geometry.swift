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

struct Geometry: TableRepresentable, Equatable {
    static var tableName: String = "_geometryController"
    static var primaryKey: String?

    var isEqualArea: Bool
    var isPercent: Bool
    var MAXCOUNT: Int
    var MAXPERCENT: Float
    var HOLLOWCORE: Float
    var SECTORSIZE: Float
    var STARTINGANGLE: Float
    var SECTORCOUNT: Int
    var RELATIVESIZE: Float

    init(
        isEqualArea: Bool,
        isPercent: Bool,
        MAXCOUNT: Int,
        MAXPERCENT: Float,
        HOLLOWCORE: Float,
        SECTORSIZE: Float,
        STARTINGANGLE: Float,
        SECTORCOUNT: Int,
        RELATIVESIZE: Float
    ) {
        self.isEqualArea = isEqualArea
        self.isPercent = isPercent
        self.MAXCOUNT = MAXCOUNT
        self.MAXPERCENT = MAXPERCENT
        self.HOLLOWCORE = HOLLOWCORE
        self.SECTORSIZE = SECTORSIZE
        self.STARTINGANGLE = STARTINGANGLE
        self.SECTORCOUNT = SECTORCOUNT
        self.RELATIVESIZE = RELATIVESIZE
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEqualArea = try container.decodeSqliteBool(forKey: .isEqualArea)
        isPercent = try container.decodeSqliteBool(forKey: .isPercent)
        MAXCOUNT = try container.decode(Int.self, forKey: .MAXCOUNT)
        MAXPERCENT = try container.decode(Float.self, forKey: .MAXPERCENT)
        HOLLOWCORE = try container.decode(Float.self, forKey: .HOLLOWCORE)
        SECTORSIZE = try container.decode(Float.self, forKey: .SECTORSIZE)
        STARTINGANGLE = try container.decode(Float.self, forKey: .STARTINGANGLE)
        SECTORCOUNT = try container.decode(Int.self, forKey: .SECTORCOUNT)
        RELATIVESIZE = try container.decode(Float.self, forKey: .RELATIVESIZE)
    }

    // MARK: - TableRepresentable

    static func allKeys() -> [String] {
        let keys: [CodingKeys] = [
            .isEqualArea,
            .isPercent,
            .MAXCOUNT,
            .MAXPERCENT,
            .HOLLOWCORE,
            .SECTORSIZE,
            .STARTINGANGLE,
            .SECTORCOUNT,
            .RELATIVESIZE
        ]
        return keys.map(\.stringValue)
    }

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _geometryController (isEqualArea bool, isPercent bool, MAXCOUNT int, MAXPERCENT float, HOLLOWCORE float, SECTORSIZE float, STARTINGANGLE float, SECTORCOUNT int, RELATIVESIZE float);")
    }

    static func insertQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "INSERT INTO _geometryController (isEqualArea, isPercent, MAXCOUNT, MAXPERCENT, HOLLOWCORE, SECTORSIZE, STARTINGANGLE, SECTORCOUNT, RELATIVESIZE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);", keys: allKeys())
    }

    static func updateQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "update _geometryController  set isEqualArea=?, isPercent=?, MAXCOUNT=?, MAXPERCENT=?, HOLLOWCORE=?, SECTORSIZE=?, STARTINGANGLE=?, SECTORCOUNT=?, RELATIVESIZE=?;", keys: allKeys())
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }
}
