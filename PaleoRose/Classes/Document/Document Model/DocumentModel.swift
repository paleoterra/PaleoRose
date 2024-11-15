//
// DocumentModel.swift
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

class DocumentModel: NSObject {
    private var inMemoryStore: InMemoryStore
    var dataTables: [TableSchema] = []
    @objc var dataSets: [XRDataSet] = []

    @available(*, deprecated, message: "This code will become unavailable")
    @objc init(inMemoryStore: InMemoryStore) {
        self.inMemoryStore = inMemoryStore
    }

    @available(*, deprecated, message: "This code will become unavailable")
    @objc func store() -> OpaquePointer? {
        inMemoryStore.store()
    }

    @objc func writeToFile(_ file: URL) throws {
        try inMemoryStore.save(to: file.path)
    }

    @objc func openFile(_ file: URL) throws {
        try inMemoryStore.load(from: file.path)
        dataTables = try inMemoryStore.dataTables()
        dataSets = try loadDataSets()
    }

    @objc func dataTableNames() -> [String] {
        dataTables.map(\.name)
    }

    @objc func possibleColumnNames(table: String) throws -> [String] {
        try inMemoryStore.valueColumnNames(for: table)
    }

    // MARK: - Read From Store

    private func loadFromFile(_ file: URL) throws {
        try inMemoryStore.load(from: file.path)
    }

    private func loadDataSets() throws -> [XRDataSet] {
        let dataSetValues = try inMemoryStore.dataSets().map { dataSet in
            let values = try inMemoryStore.dataSetValues(for: dataSet)
            return (dataSet, values)
        }
        return dataSetValues.map { dataSet, values in
            var localValues = values
            let data = Data(bytes: &localValues, count: MemoryLayout<Float>.size * values.count)
            return XRDataSet(
                name: dataSet.NAME ?? "Unnamed",
                tableName: dataSet.TABLENAME ?? "Unnamed",
                column: dataSet.COLUMNNAME ?? "Unnamed",
                predicate: dataSet.PREDICATE ?? "",
                comments: dataSet.decodedComments() ?? NSMutableAttributedString(),
                data: data
            )
        }
    }
}
