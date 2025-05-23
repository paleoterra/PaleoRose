//
// LayerGrid.swift
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

// swiftlint:disable identifier_name
struct LayerGrid: TableRepresentable, LayerIdentifiable {
    static var tableName: String = "_layerGrid"

    static var primaryKey: String?

    var LAYERID: Int
    var RINGS_ISFIXEDCOUNT: Bool
    var RINGS_VISIBLE: Bool
    var RINGS_LABELS: Bool
    var RINGS_FIXEDCOUNT: Int
    var RINGS_COUNTINCREMENT: Int
    var RINGS_PERCENTINCREMENT: Float
    var RINGS_LABELANGLE: Float
    var RINGS_FONTNAME: String
    var RINGS_FONTSIZE: Float
    var RADIALS_COUNT: Int
    var RADIALS_ANGLE: Float
    var RADIALS_LABELALIGN: Int
    var RADIALS_COMPASSPOINT: Int
    var RADIALS_ORDER: Int
    var RADIALS_FONT: String
    var RADIALS_FONTSIZE: Float
    var RADIALS_SECTORLOCK: Bool
    var RADIALS_VISIBLE: Bool
    var RADIALS_ISPERCENT: Bool
    var RADIALS_TICKS: Bool
    var RADIALS_MINORTICKS: Bool
    var RADIALS_LABELS: Bool

    // MARK: - TableRepresentable

    static func allKeys() -> [String] {
        let keys: [CodingKeys] = [
            .LAYERID,
            .RINGS_ISFIXEDCOUNT,
            .RINGS_VISIBLE,
            .RINGS_LABELS,
            .RINGS_FIXEDCOUNT,
            .RINGS_COUNTINCREMENT,
            .RINGS_PERCENTINCREMENT,
            .RINGS_LABELANGLE,
            .RINGS_FONTNAME,
            .RINGS_FONTSIZE,
            .RADIALS_COUNT,
            .RADIALS_ANGLE,
            .RADIALS_LABELALIGN,
            .RADIALS_COMPASSPOINT,
            .RADIALS_ORDER,
            .RADIALS_FONT,
            .RADIALS_FONTSIZE,
            .RADIALS_SECTORLOCK,
            .RADIALS_VISIBLE,
            .RADIALS_ISPERCENT,
            .RADIALS_TICKS,
            .RADIALS_MINORTICKS,
            .RADIALS_LABELS
        ]
        return keys.map(\.stringValue)
    }

    static func createTableQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "CREATE TABLE IF NOT EXISTS _layerGrid ( LAYERID INTEGER, RINGS_ISFIXEDCOUNT bool, RINGS_VISIBLE bool, RINGS_LABELS bool,RINGS_FIXEDCOUNT  INTEGER, RINGS_COUNTINCREMENT INTEGER,RINGS_PERCENTINCREMENT  FLOAT, RINGS_LABELANGLE FLOAT, RINGS_FONTNAME text, RINGS_FONTSIZE float,RADIALS_COUNT INTEGER,RADIALS_ANGLE float,RADIALS_LABELALIGN integer,RADIALS_COMPASSPOINT integer,RADIALS_ORDER integer,RADIALS_FONT text,RADIALS_FONTSIZE float,RADIALS_SECTORLOCK bool, RADIALS_VISIBLE bool, RADIALS_ISPERCENT bool,RADIALS_TICKS bool,RADIALS_MINORTICKS bool,RADIALS_LABELS bool);")
    }

    static func insertQuery() -> any QueryProtocol {
        // swiftlint:disable:next line_length
        Query(sql: "INSERT INTO _layerGrid (LAYERID, RINGS_ISFIXEDCOUNT, RINGS_VISIBLE, RINGS_LABELS, RINGS_FIXEDCOUNT, RINGS_COUNTINCREMENT, RINGS_PERCENTINCREMENT, RINGS_LABELANGLE, RINGS_FONTNAME, RINGS_FONTSIZE,  RADIALS_COUNT, RADIALS_ANGLE, RADIALS_LABELALIGN, RADIALS_COMPASSPOINT, RADIALS_ORDER, RADIALS_FONT, RADIALS_FONTSIZE, RADIALS_SECTORLOCK, RADIALS_VISIBLE, RADIALS_ISPERCENT, RADIALS_TICKS, RADIALS_MINORTICKS, RADIALS_LABELS) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);")
    }

    static func updateQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }
}

// swiftlint:enable identifier_name
