//
// DatasetCreationSheetView.swift
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

// MARK: - Dataset Creation Sheet View Delegate

protocol DatasetCreationSheetViewDelegate: AnyObject {
    func datasetCreationSheetViewDidChangeTable(_ view: DatasetCreationSheetView)
    func datasetCreationSheetViewDidCancel(_ view: DatasetCreationSheetView)
    func datasetCreationSheetViewDidCreate(_ view: DatasetCreationSheetView)
}

// MARK: - Dataset Creation Sheet View

final class DatasetCreationSheetView: NSView {

    // MARK: - Properties

    weak var delegate: DatasetCreationSheetViewDelegate?

    // MARK: - UI Components

    private let tableLabel = NSTextField(labelWithString: "Table:")
    private let tablePopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let columnLabel = NSTextField(labelWithString: "Data Column:")
    private let columnPopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let nameLabel = NSTextField(labelWithString: "Layer Name:")
    private let nameField = NSTextField()
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
    private let createButton = NSButton(title: "Create", target: nil, action: nil)

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func setLayerNamePlaceholder(_ name: String) {
        nameField.placeholderString = name
    }

    func setAvailableTables(_ tables: [String]) {
        tablePopup.removeAllItems()
        tablePopup.addItems(withTitles: tables)
        if tables.isEmpty {
            return
        }
        tablePopup.selectItem(at: 0)
    }

    func setAvailableColumns(_ columns: [String]) {
        columnPopup.removeAllItems()
        columnPopup.addItems(withTitles: columns)
        if columns.isEmpty {
            return
        }
        columnPopup.selectItem(at: 0)
    }

    func selectedLayerName() -> String? {
        if nameField.stringValue.isEmpty {
            return nameField.placeholderString
        }
        return nameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func selectedTableName() -> String? {
        tablePopup.selectedItem?.title
    }

    func selectedColumnName() -> String? {
        columnPopup.selectedItem?.title
    }

    // MARK: - Setup

    private func setupView() {
        // Configure labels with modern styling
        configureLabel(nameLabel)
        configureLabel(tableLabel)
        configureLabel(columnLabel)

        // Layer name field with modern styling (at top)
        nameField.placeholderString = ""
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.font = .systemFont(ofSize: 13)
        addSubview(nameLabel)
        addSubview(nameField)

        // Table row
        tablePopup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableLabel)
        addSubview(tablePopup)

        // Column row
        columnPopup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(columnLabel)
        addSubview(columnPopup)

        // Buttons with modern styling
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.keyEquivalent = "\u{1b}"
        cancelButton.bezelStyle = .rounded
        addSubview(cancelButton)

        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.keyEquivalent = "\r"
        createButton.bezelStyle = .rounded
        createButton.hasDestructiveAction = false
        if #available(macOS 11.0, *) {
            createButton.bezelColor = .controlAccentColor
        }
        addSubview(createButton)

        setupConstraints()
        setupActions()
    }

    private func setupActions() {
        tablePopup.target = self
        tablePopup.action = #selector(tableChanged)

        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped)

        createButton.target = self
        createButton.action = #selector(createTapped)
    }

    private func configureLabel(_ label: NSTextField) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.alignment = .right
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Name row (at top)
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.widthAnchor.constraint(equalToConstant: 100),

            nameField.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nameField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 12),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Table row
            tableLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            tableLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableLabel.widthAnchor.constraint(equalToConstant: 100),

            tablePopup.centerYAnchor.constraint(equalTo: tableLabel.centerYAnchor),
            tablePopup.leadingAnchor.constraint(equalTo: tableLabel.trailingAnchor, constant: 12),
            tablePopup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Column row
            columnLabel.topAnchor.constraint(equalTo: tableLabel.bottomAnchor, constant: 20),
            columnLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            columnLabel.widthAnchor.constraint(equalToConstant: 100),

            columnPopup.centerYAnchor.constraint(equalTo: columnLabel.centerYAnchor),
            columnPopup.leadingAnchor.constraint(equalTo: columnLabel.trailingAnchor, constant: 12),
            columnPopup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Buttons
            cancelButton.topAnchor.constraint(equalTo: columnLabel.bottomAnchor, constant: 28),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -12),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 90),

            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 90)
        ])
    }

    // MARK: - Actions

    @objc private func tableChanged() {
        delegate?.datasetCreationSheetViewDidChangeTable(self)
    }

    @objc private func cancelTapped() {
        delegate?.datasetCreationSheetViewDidCancel(self)
    }

    @objc private func createTapped() {
        delegate?.datasetCreationSheetViewDidCreate(self)
    }
}

// MARK: - Preview

import SwiftUI

struct DatasetCreationSheetViewWrapper: NSViewRepresentable {
    let populated: Bool

    func makeNSView(context: Context) -> DatasetCreationSheetView {
        let view = DatasetCreationSheetView(frame: NSRect(x: 0, y: 0, width: 460, height: 180))

        if populated {
            view.setAvailableTables(["Orientations", "Measurements", "Samples"])
            view.setAvailableColumns(["angle", "strike", "dip", "azimuth"])
        }

        return view
    }

    func updateNSView(_ nsView: DatasetCreationSheetView, context: Context) {}
}

// Use modern #Preview macro if available (Xcode 15+), otherwise fall back to PreviewProvider
#if swift(>=5.9)
    #Preview("Dataset Creation Sheet View") {
        DatasetCreationSheetViewWrapper(populated: true)
            .frame(width: 460, height: 180)
    }

    #Preview("Dataset Creation Sheet View - Empty") {
        DatasetCreationSheetViewWrapper(populated: false)
            .frame(width: 460, height: 180)
    }
#else
    @available(macOS 12.0, *)
    struct DatasetCreationSheetView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                DatasetCreationSheetViewWrapper(populated: true)
                    .frame(width: 460, height: 180)
                    .previewDisplayName("Populated")

                DatasetCreationSheetViewWrapper(populated: false)
                    .frame(width: 460, height: 180)
                    .previewDisplayName("Empty")
            }
        }
    }
#endif
