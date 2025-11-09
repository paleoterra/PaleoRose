//
// TableListControllerTests.swift
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
@testable import PaleoRose
import Testing

// MARK: - Mock Data Source

@MainActor
final class MockTableListDataSource: TableListControllerDataSource {
    private let subject = CurrentValueSubject<[String], Never>([])
    var renameCallCount = 0
    var lastRenameOldName: String?
    var lastRenameNewName: String?

    var dataSetRecordsPublisher: AnyPublisher<[String], Never> {
        subject.eraseToAnyPublisher()
    }

    func updateTableNames(_ names: [String]) {
        subject.send(names)
    }

    func renameTable(oldName: String, to newName: String) {
        renameCallCount += 1
        lastRenameOldName = oldName
        lastRenameNewName = newName
    }
}

// MARK: - Mock Table View

@MainActor
final class MockTableView: NSTableView {
    var reloadDataCallCount = 0

    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }
}

// MARK: - Test Helpers

@MainActor
private func createMockDocumentModel() -> DocumentModel {
    let store = InMemoryStore()
    return DocumentModel(inMemoryStore: store, document: nil)
}

/// Test fixture encapsulating common test setup
@MainActor
struct TableListControllerTestFixture {
    let controller: TableListController
    let mockDataSource: MockTableListDataSource
    let mockTableView: MockTableView

    init() {
        let mockDocument = createMockDocumentModel()
        controller = TableListController(dataSource: mockDocument)
        mockDataSource = MockTableListDataSource()
        mockTableView = MockTableView()

        // Wire up components
        controller.tableView = mockTableView
        controller.dataSource = mockDataSource
    }

    /// Set table names and wait for async propagation
    func setTableNames(_ names: [String]) async throws {
        mockDataSource.updateTableNames(names)
        try await Task.sleep(for: .milliseconds(100))
    }
}

// MARK: - Test Suite

@Suite("TableListController Tests")
@MainActor
struct TableListControllerTests {

    // MARK: - Data Source Tests

    @Test("Setting data source triggers subscription")
    func testDataSourceSubscription() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1", "Table2"])

        #expect(fixture.mockTableView.reloadDataCallCount > 0)
    }

    @Test("Data source publishes table names updates")
    func testDataSourcePublishesUpdates() async throws {
        let fixture = TableListControllerTestFixture()
        let initialReloadCount = fixture.mockTableView.reloadDataCallCount

        try await fixture.setTableNames(["Table1", "Table2", "Table3"])

        #expect(fixture.mockTableView.reloadDataCallCount > initialReloadCount)
    }

    @Test("Multiple data source updates trigger multiple reloads")
    func testMultipleDataSourceUpdates() async throws {
        let fixture = TableListControllerTestFixture()

        fixture.mockDataSource.updateTableNames(["Table1"])
        try await Task.sleep(for: .milliseconds(50))

        fixture.mockDataSource.updateTableNames(["Table1", "Table2"])
        try await Task.sleep(for: .milliseconds(50))

        fixture.mockDataSource.updateTableNames(["Table1", "Table2", "Table3"])
        try await Task.sleep(for: .milliseconds(50))

        #expect(fixture.mockTableView.reloadDataCallCount >= 3)
    }

    // MARK: - NSTableViewDataSource Tests

    @Test("Number of rows returns correct count")
    func testNumberOfRows() async throws {
        let fixture = TableListControllerTestFixture()

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 0)

        try await fixture.setTableNames(["Table1", "Table2", "Table3"])

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 3)
    }

    @Test("Object value for valid row returns table name")
    func testObjectValueForValidRow() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1", "Table2", "Table3"])

        let value0 = fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: 0) as? String
        let value1 = fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: 1) as? String
        let value2 = fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: 2) as? String

        #expect(value0 == "Table1")
        #expect(value1 == "Table2")
        #expect(value2 == "Table3")
    }

    @Test("Object value for invalid row returns nil")
    func testObjectValueForInvalidRow() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1", "Table2"])

        let valueNegative = fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: -1)
        let valueOutOfBounds = fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: 5)

        #expect(valueNegative == nil)
        #expect(valueOutOfBounds == nil)
    }

    // MARK: - Table Name Editing Tests

    @Test("Setting valid object value renames table")
    func testSettingValidObjectValue() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["OldName", "Table2"])

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "NewName" as Any, for: nil, row: 0)

        #expect(fixture.mockDataSource.renameCallCount == 1)
        #expect(fixture.mockDataSource.lastRenameOldName == "OldName")
        #expect(fixture.mockDataSource.lastRenameNewName == "NewName")
    }

    @Test("Setting empty string does not rename table")
    func testSettingEmptyString() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1"])

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "" as Any, for: nil, row: 0)

        #expect(fixture.mockDataSource.renameCallCount == 0)
    }

    @Test("Setting non-string object does not rename table")
    func testSettingNonStringObject() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1"])

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: 123 as Any, for: nil, row: 0)

        #expect(fixture.mockDataSource.renameCallCount == 0)
    }

    @Test("Setting object value for invalid row does not rename")
    func testSettingObjectValueForInvalidRow() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1"])

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "NewName" as Any, for: nil, row: 5)

        #expect(fixture.mockDataSource.renameCallCount == 0)
    }

    @Test("Setting object value without data source does nothing")
    func testSettingObjectValueWithoutDataSource() async throws {
        let fixture = TableListControllerTestFixture()

        try await fixture.setTableNames(["Table1"])

        fixture.controller.dataSource = nil

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "NewName" as Any, for: nil, row: 0)

        #expect(fixture.mockDataSource.renameCallCount == 0)
    }

    // MARK: - TableView Property Tests

    @Test("Setting tableView triggers reload")
    func testSettingTableViewTriggersReload() {
        let mockDocument = createMockDocumentModel()
        let controller = TableListController(dataSource: mockDocument)
        let mockTableView = MockTableView()

        controller.tableView = mockTableView

        #expect(mockTableView.reloadDataCallCount == 1)
    }

    @Test("Replacing tableView triggers reload on new view")
    func testReplacingTableView() {
        let mockDocument = createMockDocumentModel()
        let controller = TableListController(dataSource: mockDocument)
        let mockTableView1 = MockTableView()
        let mockTableView2 = MockTableView()

        controller.tableView = mockTableView1
        #expect(mockTableView1.reloadDataCallCount == 1)

        controller.tableView = mockTableView2
        #expect(mockTableView2.reloadDataCallCount == 1)
    }

    // MARK: - Integration Tests

    @Test("Complete workflow: initialize, set data source, update names, rename")
    func testCompleteWorkflow() async throws {
        let fixture = TableListControllerTestFixture()

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 0)

        try await fixture.setTableNames(["Table1", "Table2", "Table3"])

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 3)
        #expect(fixture.controller.tableView(fixture.mockTableView, objectValueFor: nil, row: 1) as? String == "Table2")

        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "RenamedTable" as Any, for: nil, row: 1)

        #expect(fixture.mockDataSource.renameCallCount == 1)
        #expect(fixture.mockDataSource.lastRenameOldName == "Table2")
        #expect(fixture.mockDataSource.lastRenameNewName == "RenamedTable")
    }
}
