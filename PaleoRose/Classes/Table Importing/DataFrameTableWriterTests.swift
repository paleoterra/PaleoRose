// DataFrameTableWriterTests.swift
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
@testable import PaleoRose
import TabularData
import Testing

@Suite("DataFrameTableWriter")
struct DataFrameTableWriterTests {

    let writer = DataFrameTableWriter()

    // MARK: - createSQL

    @Test("creates NUMERIC affinity for Int column")
    func numericAffinityInt() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "Azimuth", contents: [0, 90, 180]))
        #expect(writer.createSQL(for: df, named: "strikes").contains("\"Azimuth\" NUMERIC"))
    }

    @Test("creates TEXT affinity for String column")
    func textAffinityString() {
        var df = DataFrame()
        df.append(column: Column<String>(name: "Label", contents: ["N", "S"]))
        #expect(writer.createSQL(for: df, named: "labels").contains("\"Label\" TEXT"))
    }

    @Test("escapes double-quotes in table name")
    func escapesTableName() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "v", contents: [1]))
        #expect(writer.createSQL(for: df, named: "ta\"ble").contains("\"ta\"\"ble\""))
    }

    @Test("escapes double-quotes in column name")
    func escapesColumnName() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "col\"name", contents: [1]))
        #expect(writer.createSQL(for: df, named: "t").contains("\"col\"\"name\""))
    }

    @Test("CREATE TABLE includes _id INTEGER PRIMARY KEY")
    func includesPrimaryKey() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "v", contents: [1]))
        #expect(writer.createSQL(for: df, named: "t").contains("_id INTEGER PRIMARY KEY"))
    }

    // MARK: - insertSQL

    @Test("INSERT SQL placeholder count matches column count", arguments: [1, 3, 5])
    func insertPlaceholderCount(columnCount: Int) {
        var df = DataFrame()
        for i in 0 ..< columnCount {
            df.append(column: Column<Int>(name: "c\(i)", contents: [0]))
        }
        let placeholders = writer.insertSQL(for: df, named: "t").components(separatedBy: "?").count - 1
        #expect(placeholders == columnCount)
    }

    @Test("INSERT SQL escapes double-quotes in table name")
    func insertEscapesTableName() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "v", contents: [1]))
        #expect(writer.insertSQL(for: df, named: "ta\"ble").contains("\"ta\"\"ble\""))
    }

    // MARK: - bindingRows

    @Test("bindingRows count matches row count")
    func bindingRowCount() {
        var df = DataFrame()
        df.append(column: Column<Double>(name: "v", contents: [1.0, 2.0, 3.0]))
        #expect(writer.bindingRows(for: df).count == 3)
    }

    @Test("each binding row has one entry per column")
    func bindingColumnCount() {
        var df = DataFrame()
        df.append(column: Column<Int>(name: "a", contents: [1, 2]))
        df.append(column: Column<String>(name: "b", contents: ["x", "y"]))
        let rows = writer.bindingRows(for: df)
        #expect(rows.allSatisfy { $0.count == 2 })
    }

    @Test("binding values are non-nil for supported types",
          arguments: [
              makeAnyColumn(Column<Int>(name: "v", contents: [42])),
              makeAnyColumn(Column<Double>(name: "v", contents: [3.14])),
              makeAnyColumn(Column<String>(name: "v", contents: ["hi"])),
              makeAnyColumn(Column<Bool>(name: "v", contents: [true]))
          ])
    func bindableTypes(col: AnyColumn) {
        var df = DataFrame()
        df.append(column: col)
        #expect(writer.bindingRows(for: df)[0][0] != nil)
    }
}

// MARK: - Helpers

private func makeAnyColumn(_ column: Column<some Any>) -> AnyColumn {
    var df = DataFrame()
    df.append(column: column)
    return df.columns[0]
}
