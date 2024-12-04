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
    private var inMemoryStore: InMemoryStore
    var dataTables: [TableSchema] = []
    @objc var dataSets: [XRDataSet] = []
    @objc weak var document: NSDocument?
    private let storageLayerFactory = StorageLayerFactory()

    @available(*, deprecated, message: "This code will become unavailable")
    @objc init(inMemoryStore: InMemoryStore, document: NSDocument?) {
        self.inMemoryStore = inMemoryStore
        self.document = document
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

    @objc func fileURL() -> URL? {
        if let document {
            return document.fileURL
        }
        return nil
    }

    @objc func windowSize() -> CGSize {
        do {
            return try inMemoryStore.windowSize()
        } catch {
            return .zero
        }
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
        let geometry = Geometry(
            isEqualArea: geometryController.isEqualArea(),
            isPercent: geometryController.isPercent(),
            MAXCOUNT: Int(geometryController.geometryMaxCount()),
            MAXPERCENT: geometryController.geometryMaxPercent(),
            HOLLOWCORE: geometryController.hollowCoreSize(),
            SECTORSIZE: geometryController.sectorSize(),
            STARTINGANGLE: geometryController.startingAngle(),
            SECTORCOUNT: Int(geometryController.sectorCount()),
            RELATIVESIZE: geometryController.relativeSizeOfCircleRect()
        )
        try inMemoryStore.store(geometry: geometry)
    }

    @objc func configure(geometryController: XRGeometryController) throws {
        do {
            let geometry = try inMemoryStore.geometry()
            geometryController.configureIsEqualArea(
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
        } catch {
            return
        }
    }

    // MARK: - Layers

    @objc func storeLayers(_ layers: [XRLayer]) throws {
        var finalLayers = [Layer]()
        var textLayers = [LayerText]()
        var lineArrrowLayers = [LayerLineArrow]()
        var coreLayers = [LayerCore]()
        var dataLayers = [LayerData]()
        var gridLayers = [LayerGrid]()
        for (id, oldLayer) in layers.enumerated() {
            finalLayers.append(storageLayerFactory.storageLayer(from: oldLayer, at: id))
            switch oldLayer {
            case let textLayer as XRLayerText:
                throw DocumentModelError.unknownLayerType

            case let lineArrowLayer as  XRLayerLineArrow:
                throw DocumentModelError.unknownLayerType

            case let coreLayer as  XRLayerCore:
                throw DocumentModelError.unknownLayerType

            case let dataLayer as  XRLayerData:
                throw DocumentModelError.unknownLayerType

            case let gridLayer as  XRLayerGrid:
                gridLayers.append(
                    storageLayerFactory.storageLayerGrid(from: gridLayer, at: id)
                )

            default:
                throw DocumentModelError.unknownLayerType
            }
        }
        try inMemoryStore.store(layers: finalLayers)
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
