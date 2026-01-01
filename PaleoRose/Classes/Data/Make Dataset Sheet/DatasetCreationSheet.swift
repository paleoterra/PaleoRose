//
// DatasetCreationSheet.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2006 to present Thomas L. Moore.
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

// MARK: - Column Provider Protocol

@objc protocol DatasetColumnProvider: AnyObject {
    func numericColumns(forTable tableName: String) -> [String]
}

// MARK: - Dataset Creation Sheet

@objc final class DatasetCreationSheet: NSWindowController, DatasetCreationSheetViewDelegate {

    // MARK: - Properties

    private let tables: [String]
    private weak var columnProvider: DatasetColumnProvider?

    @objc var selectedTable: String? {
        sheetView.selectedTableName()
    }

    @objc var selectedColumn: String? {
        sheetView.selectedColumnName()
    }

    @objc var selectedName: String {
        let name = sheetView.selectedLayerName()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? (selectedTable ?? "New Layer") : name
    }

    // UI
    private let sheetView = DatasetCreationSheetView(frame: .zero)

    // MARK: - Initialization

    @objc init(tableArray tables: [String], columnProvider: DatasetColumnProvider) {
        self.tables = tables
        self.columnProvider = columnProvider

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Create Data Layer"
        window.isReleasedWhenClosed = false

        super.init(window: window)

        setupWindow()
        populateTables()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupWindow() {
        guard let window else {
            return
        }

        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.delegate = self
        window.contentView = sheetView
    }

    // MARK: - Data Population

    private func populateTables() {
        sheetView.setAvailableTables(tables)

        if !tables.isEmpty {
            updateColumnsForSelectedTable()
            updatePlaceholder()
        }
    }

    private func updateColumnsForSelectedTable() {
        guard let table = selectedTable, let provider = columnProvider else {
            return
        }

        let columns = provider.numericColumns(forTable: table)
        sheetView.setAvailableColumns(columns)
    }

    private func updatePlaceholder() {
        sheetView.setLayerNamePlaceholder(selectedTable ?? "New Layer")
    }

    // MARK: - DatasetCreationSheetViewDelegate

    func datasetCreationSheetViewDidChangeTable(_: DatasetCreationSheetView) {
        updateColumnsForSelectedTable()
        updatePlaceholder()
    }

    func datasetCreationSheetViewDidCancel(_: DatasetCreationSheetView) {
        guard let window else {
            return
        }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }

    func datasetCreationSheetViewDidCreate(_: DatasetCreationSheetView) {
        guard let window else {
            return
        }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
}

// MARK: - Preview

import SwiftUI

private class MockColumnProvider: NSObject, DatasetColumnProvider {
    func numericColumns(forTable tableName: String) -> [String] {
        switch tableName {
        case "Orientations":
            ["angle", "strike", "dip", "azimuth"]

        case "Measurements":
            ["depth", "value", "error", "temperature"]

        case "Samples":
            ["id", "latitude", "longitude", "elevation"]

        default:
            []
        }
    }
}

struct DatasetCreationSheetWrapper: NSViewRepresentable {
    let tables: [String]

    func makeNSView(context: Context) -> NSView {
        let provider = MockColumnProvider()
        let sheet = DatasetCreationSheet(
            tableArray: tables,
            columnProvider: provider
        )
        return sheet.window?.contentView ?? NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Use modern #Preview macro if available (Xcode 15+), otherwise fall back to PreviewProvider
#if swift(>=5.9)
    #Preview("Dataset Creation Sheet") {
        DatasetCreationSheetWrapper(tables: ["Orientations", "Measurements", "Samples"])
            .frame(width: 460, height: 180)
    }

    #Preview("Dataset Creation Sheet - Single Table") {
        DatasetCreationSheetWrapper(tables: ["Orientations"])
            .frame(width: 460, height: 180)
    }

    #Preview("Dataset Creation Sheet - Empty") {
        DatasetCreationSheetWrapper(tables: [])
            .frame(width: 460, height: 180)
    }
#else
    @available(macOS 12.0, *)
    struct DatasetCreationSheet_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                DatasetCreationSheetWrapper(tables: ["Orientations", "Measurements", "Samples"])
                    .frame(width: 460, height: 180)
                    .previewDisplayName("Multiple Tables")

                DatasetCreationSheetWrapper(tables: ["Orientations"])
                    .frame(width: 460, height: 180)
                    .previewDisplayName("Single Table")

                DatasetCreationSheetWrapper(tables: [])
                    .frame(width: 460, height: 180)
                    .previewDisplayName("Empty")
            }
        }
    }
#endif
