// DataFrameTableWriter.swift
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
import TabularData

struct DataFrameTableWriter: DataFrameTableWriting {

    // MARK: - DataFrameTableWriting

    func affinity(for column: AnyColumn) -> String {
        switch column.wrappedElementType {
        case is Int.Type, is Int32.Type, is Int64.Type, is Double.Type, is Float.Type, is Bool.Type:
            "NUMERIC"

        default:
            "TEXT"
        }
    }

    func createSQL(for dataFrame: DataFrame, named tableName: String) -> String {
        let escapedName = tableName.sqliteEscaped
        let columnDefs = dataFrame.columns.map { col in "\"\(col.name.sqliteEscaped)\" \(affinity(for: col))" }
            .joined(separator: ",\n\t")
        return """
        CREATE TABLE "\(escapedName)" (
        \t_id INTEGER PRIMARY KEY,
        \t\(columnDefs)
        )
        """
    }

    func insertSQL(for dataFrame: DataFrame, named tableName: String) -> String {
        let escapedName = tableName.sqliteEscaped
        let cols = dataFrame.columns
            .map { "\"\($0.name.sqliteEscaped)\"" }
            .joined(separator: ", ")
        let placeholders = Array(repeating: "?", count: dataFrame.columns.count)
            .joined(separator: ", ")
        return "INSERT INTO \"\(escapedName)\" (\(cols)) VALUES (\(placeholders))"
    }

    func bindingRows(for dataFrame: DataFrame) -> [[Bindable?]] {
        (0 ..< dataFrame.rows.count).map { rowIndex in
            dataFrame.columns.map { bindable(from: $0, at: rowIndex) }
        }
    }

    // MARK: - Private

    // swiftlint:disable switch_case_on_newline
    private func bindable(from column: AnyColumn, at index: Int) -> Bindable? {
        switch column.wrappedElementType {
        case is Int.Type: return column[index] as? Int
        case is Double.Type: return column[index] as? Double
        case is Float.Type: return column[index] as? Float
        case is Bool.Type: return column[index] as? Bool
        case is String.Type: return column[index] as? String
        default: return column[index].map { "\($0)" }
        }
    }
    // swiftlint:enable switch_case_on_newline
}

// MARK: -

// swiftlint:disable:next no_extension_access_modifier
private extension String {
    var sqliteEscaped: String {
        replacingOccurrences(of: "\"", with: "\"\"")
    }
}
