// TableImportCoordinatorTests.swift
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

import AppKit
@testable import PaleoRose
import TabularData
import Testing

// MARK: - Mock

final class MockUserTableImporting: NSObject, UserTableImporting {
    var importedFrames: [(DataFrame, String)] = []
    var copiedTables: [(URL, [(original: String, destination: String)])] = []
    var existingTableNames: [String] = []
    var shouldThrow: Error?

    func importTable(_ dataFrame: DataFrame, named tableName: String) throws {
        if let e = shouldThrow { throw e }
        importedFrames.append((dataFrame, tableName))
    }

    func copyTables(from url: URL, selecting tables: [(original: String, destination: String)]) throws {
        if let e = shouldThrow { throw e }
        copiedTables.append((url, tables))
    }

    func dataTableNames() -> [String] {
        existingTableNames
    }
}

// MARK: - Tests

@MainActor
@Suite("TableImportCoordinator")
struct TableImportCoordinatorTests {

    private func makeCoordinator() -> (TableImportCoordinator, MockUserTableImporting) {
        let mock = MockUserTableImporting()
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [],
            backing: .buffered,
            defer: true
        )
        let coordinator = TableImportCoordinator(documentModel: mock, window: window)
        return (coordinator, mock)
    }

    @Test("throws unsupportedFileFormat for unknown extension")
    func unsupportedExtension() async throws {
        let (coordinator, _) = makeCoordinator()
        let url = URL(fileURLWithPath: "/tmp/data.csv2")
        await #expect(throws: TableImportError.self) {
            try await coordinator.beginImport(from: url)
        }
    }

    @Test("throws unsupportedFileFormat with the actual extension")
    func unsupportedExtensionCarriesValue() async throws {
        let (coordinator, _) = makeCoordinator()
        let url = URL(fileURLWithPath: "/tmp/data.xlsx")
        await #expect(throws: TableImportError.unsupportedFileFormat("xlsx")) {
            try await coordinator.beginImport(from: url)
        }
    }
}
