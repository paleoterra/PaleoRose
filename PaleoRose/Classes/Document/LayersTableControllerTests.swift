//
// LayersTableControllerTests.swift
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

final class MockLayerTableDataSource: LayerTableControllerDataSource {
    private let subject = CurrentValueSubject<[XRLayer], Never>([])

    var createDataLayerCallCount = 0
    var createCoreLayerCallCount = 0
    var createGridLayerCallCount = 0
    var deleteLayerCallCount = 0
    var deleteLayersCallCount = 0
    var moveLayersCallCount = 0
    var updateLayerNameCallCount = 0
    var updateLayerVisibilityCallCount = 0

    var lastDataSetName: String?
    var lastColor: NSColor?
    var lastLayerName: String?
    var lastDeletedIndices: [Int] = []
    var lastMovedIndices: [Int] = []
    var lastMoveDestination: Int?

    var layersPublisher: AnyPublisher<[XRLayer], Never> {
        subject.eraseToAnyPublisher()
    }

    func updateLayers(_ layers: [XRLayer]) {
        subject.send(layers)
    }

    func createDataLayer(dataSetName: String, color: NSColor, name: String?) {
        createDataLayerCallCount += 1
        lastDataSetName = dataSetName
        lastColor = color
        lastLayerName = name
    }

    func createCoreLayer(name: String?) {
        createCoreLayerCallCount += 1
        lastLayerName = name
    }

    func createGridLayer(name: String?) {
        createGridLayerCallCount += 1
        lastLayerName = name
    }

    func createTextLayer(name: String?, parentView: NSView) {}

    func createLineArrowLayer(dataSetName: String, name: String?) {}

    func deleteLayer(_: XRLayer) {
        deleteLayerCallCount += 1
    }

    func deleteLayers(at indices: [Int]) {
        deleteLayersCallCount += 1
        lastDeletedIndices = indices
    }

    func deleteLayersForDataset(named tableName: String) {}

    func moveLayers(from indices: [Int], to destination: Int) {
        moveLayersCallCount += 1
        lastMovedIndices = indices
        lastMoveDestination = destination
    }

    func updateLayerName(_ layer: XRLayer, newName: String) {
        updateLayerNameCallCount += 1
        lastLayerName = newName
    }

    func updateLayerVisibility(_ layer: XRLayer, isVisible: Bool) {
        updateLayerVisibilityCallCount += 1
    }
}

// MARK: - Mock Table View

@MainActor
final class MockLayersTableView: NSTableView {
    var reloadDataCallCount = 0

    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }
}

// MARK: - Test Helpers

@MainActor
private func createMockGeometryController() -> XRGeometryController {
    XRGeometryController()
}

@MainActor
private func createMockLayer(name: String) -> XRLayer? {
    let controller = createMockGeometryController()
    let layer = XRLayerGrid(geometryController: controller)
    layer?.setLayerName(name)
    return layer
}

// MARK: - Test Fixture

@MainActor
struct LayersTableControllerTestFixture {
    let controller: LayersTableController
    let mockDataSource: MockLayerTableDataSource
    let mockTableView: MockLayersTableView
    let geometryController: XRGeometryController

    init() {
        geometryController = createMockGeometryController()
        let documentModel = DocumentModel(inMemoryStore: InMemoryStore(), document: nil)
        controller = LayersTableController(dataSource: documentModel, geometryController: geometryController)
        mockDataSource = MockLayerTableDataSource()
        mockTableView = MockLayersTableView()

        // Wire up components
        controller.tableView = mockTableView
        controller.dataSource = mockDataSource
    }

    func setLayers(_ layers: [XRLayer]) async throws {
        mockDataSource.updateLayers(layers)
        try await Task.sleep(for: .milliseconds(100))
    }
}

// MARK: - Test Suite

@Suite("LayersTableController Tests")
@MainActor
struct LayersTableControllerTests {

    // MARK: - Subscription Tests

    @Test("Setting data source triggers subscription")
    func testDataSourceSubscription() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Layer 2"))

        try await fixture.setLayers([layer1, layer2])

        #expect(fixture.mockTableView.reloadDataCallCount > 0)
    }

    @Test("Data source publishes layer updates")
    func testDataSourcePublishesUpdates() async throws {
        let fixture = LayersTableControllerTestFixture()
        let initialReloadCount = fixture.mockTableView.reloadDataCallCount

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Layer 2"))
        let layer3 = try #require(createMockLayer(name: "Layer 3"))

        try await fixture.setLayers([layer1, layer2, layer3])

        #expect(fixture.mockTableView.reloadDataCallCount > initialReloadCount)
    }

    // MARK: - NSTableViewDataSource Tests

    @Test("Number of rows returns correct count")
    func testNumberOfRows() async throws {
        let fixture = LayersTableControllerTestFixture()

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 0)

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Layer 2"))

        try await fixture.setLayers([layer1, layer2])

        #expect(fixture.controller.numberOfRows(in: fixture.mockTableView) == 2)
    }

    @Test("Object value for valid row returns layer name")
    func testObjectValueForValidRow() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Test Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Test Layer 2"))

        try await fixture.setLayers([layer1, layer2])

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("layerName"))
        let value0 = fixture.controller.tableView(fixture.mockTableView, objectValueFor: column, row: 0) as? String
        let value1 = fixture.controller.tableView(fixture.mockTableView, objectValueFor: column, row: 1) as? String

        #expect(value0 == "Test Layer 1")
        #expect(value1 == "Test Layer 2")
    }

    @Test("Object value for invalid row returns nil")
    func testObjectValueForInvalidRow() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        try await fixture.setLayers([layer1])

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("layerName"))
        let valueNegative = fixture.controller.tableView(fixture.mockTableView, objectValueFor: column, row: -1)
        let valueOutOfBounds = fixture.controller.tableView(fixture.mockTableView, objectValueFor: column, row: 5)

        #expect(valueNegative == nil)
        #expect(valueOutOfBounds == nil)
    }

    @Test("Setting layer name calls updateLayerName")
    func testSettingLayerName() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Old Name"))
        try await fixture.setLayers([layer1])

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("layerName"))
        fixture.controller.tableView(fixture.mockTableView, setObjectValue: "New Name" as Any, for: column, row: 0)

        #expect(fixture.mockDataSource.updateLayerNameCallCount == 1)
        #expect(fixture.mockDataSource.lastLayerName == "New Name")
    }

    @Test("Setting visibility calls updateLayerVisibility")
    func testSettingVisibility() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        try await fixture.setLayers([layer1])

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("isVisible"))
        fixture.controller.tableView(
            fixture.mockTableView,
            setObjectValue: NSControl.StateValue.on,
            for: column,
            row: 0
        )

        #expect(fixture.mockDataSource.updateLayerVisibilityCallCount == 1)
    }

    // MARK: - Layer Utilities Tests

    @Test("layerExists returns true for existing layer")
    func testLayerExistsTrue() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Existing Layer"))
        try await fixture.setLayers([layer1])

        #expect(fixture.controller.layerExists(withName: "Existing Layer") == true)
    }

    @Test("layerExists returns false for non-existing layer")
    func testLayerExistsFalse() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        try await fixture.setLayers([layer1])

        #expect(fixture.controller.layerExists(withName: "Non-existing Layer") == false)
    }

    @Test("newLayerName generates unique name")
    func testNewLayerName() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Grid"))
        let layer2 = try #require(createMockLayer(name: "Grid-1"))
        try await fixture.setLayers([layer1, layer2])

        let newName = fixture.controller.newLayerName(forBaseName: "Grid")
        #expect(newName == "Grid-2")
    }

    @Test("lastLayer returns last layer")
    func testLastLayer() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Layer 2"))
        try await fixture.setLayers([layer1, layer2])

        let last = fixture.controller.lastLayer()
        #expect(last?.layerName() == "Layer 2")
    }

    // MARK: - Layer Deletion Tests

    @Test("deleteLayers calls dataSource with indices")
    func testDeleteLayers() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        let layer2 = try #require(createMockLayer(name: "Layer 2"))
        try await fixture.setLayers([layer1, layer2])

        fixture.mockTableView.selectRowIndexes(IndexSet([0, 1]), byExtendingSelection: false)
        fixture.controller.deleteLayers(nil as Any?)

        #expect(fixture.mockDataSource.deleteLayersCallCount == 1)
        #expect(fixture.mockDataSource.lastDeletedIndices.count == 2)
    }

    @Test("deleteLayer calls dataSource")
    func testDeleteLayer() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Layer 1"))
        try await fixture.setLayers([layer1])

        fixture.controller.deleteLayer(layer1)

        #expect(fixture.mockDataSource.deleteLayerCallCount == 1)
    }

    // MARK: - Statistics Tests

    @Test("generateStatisticsString returns empty for non-data layers")
    func testGenerateStatisticsStringEmpty() async throws {
        let fixture = LayersTableControllerTestFixture()

        let layer1 = try #require(createMockLayer(name: "Grid"))
        try await fixture.setLayers([layer1])

        let stats = fixture.controller.generateStatisticsString()
        #expect(stats.isEmpty)
    }
}
