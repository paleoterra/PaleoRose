//
// TableListController.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2025 to present Thomas L. Moore.
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
import Combine

// MARK: - Data Source Protocol

protocol TableListControllerDataSource: AnyObject {
    /// Publisher that emits dataset records whenever they change
    var dataSetRecordsPublisher: AnyPublisher<[String], Never> { get }

    /// Called when a dataset name is changed
    func renameTable(oldName: String, to newName: String)
}

// MARK: - Data Table Controller

@objc class TableListController: NSObject {

    // MARK: - Properties

    private var tableNames: [String] = []
    private var cancellables = Set<AnyCancellable>()

    @objc weak var tableView: NSTableView? {
        didSet {
            tableView?.reloadData()
        }
    }

    weak var dataSource: TableListControllerDataSource? {
        didSet {
            setupDataSourceSubscription()
        }
    }

    // MARK: - Initialization

    @objc init(dataSource: DocumentModel) {
        super.init()
        self.dataSource = dataSource
        setupDataSourceSubscription()
    }

    // MARK: - Private Methods

    private func setupDataSourceSubscription() {
        cancellables.removeAll()

        guard let dataSource else {
            return
        }

        // Subscribe to data source publisher
        dataSource.dataSetRecordsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self else {
                    return
                }
                tableNames = records
                tableView?.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - NSTableViewDelegate

extension TableListController: NSTableViewDelegate {}

// MARK: - NSTableViewDataSource

extension TableListController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        tableNames.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard tableNames.indices.contains(row) else {
            return nil
        }
        return tableNames[row]
    }

    func tableView(
        _ tableView: NSTableView,
        setObjectValue object: Any?,
        for tableColumn: NSTableColumn?,
        row: Int
    ) {
        guard
            let newName = object as? String,
            !newName.isEmpty,
            let dataSource,
            tableNames.indices.contains(row) else {
            return
        }

        dataSource.renameTable(
            oldName: tableNames[row],
            to: newName
        )
    }
}
