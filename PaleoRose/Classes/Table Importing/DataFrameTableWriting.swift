// DataFrameTableWriting.swift
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

/// Transforms a `DataFrame` into the SQL strings and bindings needed to create and populate a user data table.
protocol DataFrameTableWriting {
    /// Returns a CREATE TABLE SQL string with `_id INTEGER PRIMARY KEY` plus
    /// one column per DataFrame column using SQLite affinity rules.
    func createSQL(for dataFrame: DataFrame, named tableName: String) -> String

    /// Returns a parameterised INSERT SQL string with `?` placeholders.
    /// Column count matches `createSQL` (excludes `_id`).
    func insertSQL(for dataFrame: DataFrame, named tableName: String) -> String

    /// Returns one flat `[Bindable?]` array per row, matching the column order
    /// in `createSQL`. Used as `Query.bindings`.
    func bindingRows(for dataFrame: DataFrame) -> [[Bindable?]]
}
