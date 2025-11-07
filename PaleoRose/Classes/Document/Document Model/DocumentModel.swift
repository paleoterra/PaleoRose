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

    enum DocumentModelError: Error {
        case unknownLayerType
    }

    // MARK: - Properties

    private var inMemoryStore: InMemoryStore
    @objc var tableNames: [String] = []
    @objc var windowSize: CGSize = .zero
    @objc var dataSets: [XRDataSet] = []
    @objc var layers: [XRLayer] = []
    @objc weak var document: NSDocument?
    @objc var geometryController: XRGeometryController?

    // MARK: - Deprecated Methods

    @available(*, deprecated, message: "This code will become unavailable")
    @objc init(inMemoryStore: InMemoryStore, document: NSDocument?) {
        self.inMemoryStore = inMemoryStore
        self.document = document
        super.init()
        inMemoryStore.delegate = self
    }

    @available(*, deprecated, message: "This code will become unavailable")
    @objc func memoryStore() -> OpaquePointer? {
        inMemoryStore.store()
    }

    // MARK: - File Management

    @objc func writeToFile(_ file: URL) throws {
        try inMemoryStore.save(to: file.path)
    }

    @objc func openFile(_ file: URL) throws {
        try inMemoryStore.load(from: file.path)
        readFromStore {}
    }

    @objc func fileURL() -> URL? {
        if let document {
            return document.fileURL
        }
        return nil
    }

    // MARK: - General

    @objc func dataTableNames() -> [String] {
        tableNames
    }

    @objc func possibleColumnNames(table: String) throws -> [String] {
        try inMemoryStore.valueColumnNames(for: table)
    }

    @objc func setWindowSize(_ size: CGSize) throws {
        try inMemoryStore.store(windowSize: size)
    }

    @objc func rename(table: String, toName: String) throws {
        try inMemoryStore.renameTable(from: table, toName: toName)
    }

    @objc func delete(table: String) throws {
        try inMemoryStore.drop(table: table)
    }

    @objc func add(table: String, column: String) throws {
        try inMemoryStore.addColumn(to: table, columnDefinition: column)
    }

    @objc func store(geometryController: XRGeometryController) throws {
        try inMemoryStore.store(geometryController: geometryController)
    }

    @objc func configure(geometryController: XRGeometryController) throws {
        do {
            try inMemoryStore.configure(geometryController: geometryController)
        } catch {
            return
        }
    }

    // MARK: - Layers

    @objc func store(layers: [XRLayer]) throws {
        try inMemoryStore.store(layers: layers)
    }

    // MARK: - Read From Store

    @objc func readFromStore(completion: @escaping () -> Void) {
        inMemoryStore.readFromStore { _ in
            completion()
        }
    }
}

extension DocumentModel: InMemoryStoreDelegate {

    func update(tableNames: [String]) {
        self.tableNames = tableNames
    }

    func update(windowSize: CGSize) {
        self.windowSize = windowSize
    }

    func update(dataSets: [XRDataSet]) {
        self.dataSets = dataSets
    }

    func update(layers: [XRLayer]) {
        self.layers = layers
    }

    func update(geometry: Geometry) {
        guard let controller = geometryController else {
            return
        }
        controller.configureIsEqualArea(
            geometry.isEqualArea,
            isPercent: geometry.isPercent,
            maxCount: Int32(geometry.MAXCOUNT),
            maxPercent: geometry.MAXPERCENT,
            hollowCore: geometry.HOLLOWCORE,
            sectorSize: geometry.SECTORSIZE,
            startingAngle: geometry.STARTINGANGLE,
            sectorCount: Int32(geometry.SECTORCOUNT),
            relativeSize: geometry.RELATIVESIZE
        )
    }
}
