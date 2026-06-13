// TableImportCoordinator.swift
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
import SQLite3
import TabularData

@objc final class TableImportCoordinator: NSObject {

    private weak var documentModel: (UserTableImporting & NSObject)?
    private weak var presentingWindow: NSWindow?

    init(documentModel: UserTableImporting & NSObject, window: NSWindow) {
        self.documentModel = documentModel
        presentingWindow = window
        super.init()
    }

    /// ObjC-compatible initialiser for use from `XRoseDocument.m`.
    @objc convenience init(documentModel: DocumentModel, window: NSWindow) {
        self.init(documentModel: documentModel as UserTableImporting & NSObject, window: window)
    }

    // MARK: - Entry point

    /// Routes the import by file extension, orchestrating sheet presentation and DataFrame construction.
    func beginImport(from url: URL) async throws {
        switch url.pathExtension.lowercased() {
        case "txt":
            try await importText(from: url)

        case "xrose":
            try await importXRose(from: url)

        default:
            throw TableImportError.unsupportedFileFormat(url.pathExtension)
        }
    }

    // MARK: - Text path

    private func importText(from url: URL) async throws {
        let options = try await showDelimiterSheet(for: url)
        let csvOptions = CSVReadingOptions(hasHeaderRow: options.hasColumnHeaders, delimiter: options.delimiter)
        let dataFrame = try DataFrame(contentsOfCSVFile: url, options: csvOptions)
        try documentModel?.importTable(dataFrame, named: options.tableName)
    }

    // MARK: - XRose path

    private func importXRose(from url: URL) async throws {
        let available = try listDataTables(in: url)
        let selected = try await showTableSelectionSheet(tables: available)
        let validated = resolveConflicts(selected)
        try documentModel?.copyTables(from: url, selecting: validated)
    }

    // MARK: - Sheet helpers (AppKit UI — manual test only)

    @MainActor
    private func showDelimiterSheet(for url: URL) async throws -> TextImportOptions {
        guard let window = presentingWindow else {
            throw TableImportError.storageFailure(underlying: "Presenting window unavailable")
        }
        guard
            let controller = XRTableImporterDelimiterController(path: url.path),
            let sheetWindow = controller.window() else {
            throw TableImportError.storageFailure(underlying: "Cannot load delimiter sheet")
        }
        return try await withCheckedThrowingContinuation { continuation in
            window.beginSheet(sheetWindow) { response in
                guard response != .cancel else {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                guard let dict = controller.results() else {
                    continuation.resume(
                        throwing: TableImportError.storageFailure(underlying: "No import results")
                    )
                    return
                }
                continuation.resume(returning: self.makeTextImportOptions(from: dict, url: url))
            }
        }
    }

    @MainActor
    private func showTableSelectionSheet(tables: [String]) async throws -> [String] {
        guard let window = presentingWindow else {
            throw TableImportError.storageFailure(underlying: "Presenting window unavailable")
        }
        let controller = XRTableImporterXRose()
        controller.setTableNames(tables)
        guard let sheetWindow = controller.window() else {
            throw TableImportError.storageFailure(underlying: "Cannot load table selection sheet")
        }
        return try await withCheckedThrowingContinuation { continuation in
            window.beginSheet(sheetWindow) { response in
                guard response != .cancel else {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                let selected = controller.selectedTableNames() as? [String] ?? []
                continuation.resume(returning: selected)
            }
        }
    }

    // MARK: - Private helpers

    /// Opens the source .XRose file read-only and returns names of tables not prefixed with `_`.
    private func listDataTables(in url: URL) throws -> [String] {
        var database: OpaquePointer?
        guard sqlite3_open_v2(url.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            throw TableImportError.storageFailure(underlying: "Cannot open source file")
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = "SELECT name FROM sqlite_master WHERE type='table' AND substr(name,1,1)!='_'"
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw TableImportError.storageFailure(underlying: "Cannot read source table list")
        }
        defer { sqlite3_finalize(statement) }

        var names: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let bytes = sqlite3_column_text(statement, 0) {
                names.append(String(cString: bytes))
            }
        }
        return names
    }

    /// Returns (original, destination) pairs, appending _1, _2… when a name conflicts with an existing table.
    private func resolveConflicts(_ names: [String]) -> [(original: String, destination: String)] {
        var used = Set(documentModel?.dataTableNames() ?? [])
        return names.map { name in
            var destination = name
            if used.contains(destination) {
                var counter = 1
                repeat {
                    destination = "\(name)_\(counter)"
                    counter += 1
                } while used.contains(destination)
            }
            used.insert(destination)
            return (original: name, destination: destination)
        }
    }

    private func makeTextImportOptions(from dict: [AnyHashable: Any], url: URL) -> TextImportOptions {
        let tableName = dict["tableName"] as? String ?? url.deletingPathExtension().lastPathComponent
        let hasHeaders = (dict["columnTitles"] as? Int) == NSControl.StateValue.on.rawValue
        let delimiterPopup = dict["delimiterPopup"] as? Int ?? 0
        let delimiterFieldValue = dict["delimiterFieldValue"] as? String ?? ", "
        let encodingInt = dict["encodingValue"] as? Int ?? Int(String.Encoding.utf8.rawValue)

        let delimiter: Character = if delimiterPopup == 0 {
            "\t"
        } else {
            delimiterFieldValue.first ?? ","
        }

        return TextImportOptions(
            tableName: tableName,
            hasColumnHeaders: hasHeaders,
            delimiter: delimiter,
            encoding: String.Encoding(rawValue: UInt(encodingInt))
        )
    }

    // MARK: - ObjC bridge

    /// Completion-handler wrapper for `beginImport(from:)`, callable from Objective-C.
    /// The coordinator is retained by the Task for the duration of the import.
    @objc(beginImportFromURL:completionHandler:)
    func beginImport(from url: URL, completion: @escaping (Error?) -> Void) {
        let retained = self
        Task { @MainActor in
            do {
                try await retained.beginImport(from: url)
                completion(nil)
            } catch is CancellationError {
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
