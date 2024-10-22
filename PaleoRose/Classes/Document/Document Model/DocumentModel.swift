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

    @objc func readFromFile(_ file: URL) throws {
        try inMemoryStore.load(from: file.path)
        dataTables = try inMemoryStore.dataTables()
    }

    @objc func dataTableNames() -> [String] {
        return dataTables.map{ $0.name }
    }
}
