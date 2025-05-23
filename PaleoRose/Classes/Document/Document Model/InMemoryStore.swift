//
// InMemoryStore.swift
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
import OSLog

protocol InMemoryStoreDelegate: AnyObject {
    var tableNames: [String] { get set }
    var windowSize: CGSize { get set }
    var dataSets: [XRDataSet] { get set }
    var layers: [XRLayer] { get set }

    func update(geometry: Geometry)
}

// swiftlint:disable type_body_length file_length
class InMemoryStore: NSObject {
    enum InMemoryStoreError: Error {
        case databaseDoesNotExist
        case unknownType
        case unexpectedEmptyResult
        case invalidLayersStore
    }

    enum BackupType {
        case fromFile
        case toFile
    }

    struct BackupInfo {
        let path: String
        let type: BackupType
    }

    private var sqliteStore: OpaquePointer?
    private let storageLayerFactory = StorageModelFactory()
    private let storedWindowSizes: [WindowControllerSize] = []
    private var storedColors: [Color] = []
    private var storedDataSets: [DataSet] = []
    let interface: StoreProtocol

    weak var delegate: InMemoryStoreDelegate?

    private let createTableQueries: [QueryProtocol] = [
        WindowControllerSize.createTableQuery(),
        Geometry.createTableQuery(),
        Layer.createTableQuery(),
        Color.createTableQuery(),
        DataSet.createTableQuery(),
        LayerText.createTableQuery(),
        LayerLineArrow.createTableQuery(),
        LayerCore.createTableQuery(),
        LayerGrid.createTableQuery(),
        LayerData.createTableQuery()
    ]

    @available(*, deprecated, message: "This code will become unavailable")
    @objc override init() {
        interface = SQLiteInterface()
        super.init()
        do {
            try setupDatabase()
        } catch {
            logError(error: "Error creating in-memory store: \(error)")
            return
        }
    }

    init(interface: StoreProtocol = SQLiteInterface()) throws {
        self.interface = interface
        super.init()
        try setupDatabase()
    }

    @available(*, deprecated, message: "This code will become unavailable")
    @objc func store() -> OpaquePointer? {
        sqliteStore
    }

    func sqlitePointer() throws -> OpaquePointer {
        try validateStore()
    }

    func load(from filePath: String) throws {
        try backup(info: BackupInfo(path: filePath, type: .fromFile))
    }

    func save(to filePath: String) throws {
        try backup(info: BackupInfo(path: filePath, type: .toFile))
    }

    // MARK: - Read All

    // swiftlint:disable:next function_body_length
    func readFromStore(completion: @escaping (Result<Bool, Error>) -> Void) {
        // swiftlint:disable:next closure_body_length
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else {
                completion(.failure(InMemoryStoreError.databaseDoesNotExist))
                return
            }
            do {
                let group = DispatchGroup()
                let sqliteStore = try validateStore()
                // directly settable values
                let tableNames = try tableNames(sqliteStore: sqliteStore)
                group.enter()
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.tableNames = tableNames
                    group.leave()
                }
                do {
                    let windowSize = try windowSize(sqliteStore: sqliteStore)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.windowSize = windowSize
                        group.leave()
                    }
                } catch InMemoryStoreError.unexpectedEmptyResult {
                    print("Window size not found")
                } catch {
                    throw error
                }
                do {
                    let geometry = try geometry(sqliteStore: sqliteStore)
                    group.enter()
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.update(geometry: geometry)
                        group.leave()
                    }
                } catch InMemoryStoreError.unexpectedEmptyResult {
                    print("Window size not found")
                } catch {
                    throw error
                }
                // requires additional processing
                let dataSets = try dataSets(sqliteStore: sqliteStore)

                group.enter()
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.dataSets = dataSets
                    group.leave()
                }
                let layers = try readLayers(sqliteStore: sqliteStore)
                group.enter()
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.layers = layers
                    group.leave()
                }
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Tables

    func tableNames(sqliteStore: OpaquePointer) throws -> [String] {
        let sqliteStore = try validateStore()
        let tables = try tableMetadata(sqliteStore: sqliteStore)
        return tables.map(\.name)
    }

    private func tableMetadata(sqliteStore: OpaquePointer) throws -> [TableSchema] {
        let tables: [TableSchema] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: TableSchema.storedValues()
        )
        let nonDataTableNames = [
            WindowControllerSize.tableName,
            Geometry.tableName,
            Layer.tableName,
            Color.tableName,
            DataSet.tableName,
            LayerText.tableName,
            LayerLineArrow.tableName,
            LayerCore.tableName,
            LayerGrid.tableName,
            LayerData.tableName,
            "sqlite_master",
            "sqlite_sequence"
        ]
        return tables.filter { !nonDataTableNames.contains($0.name) }
    }

    // MARK: - BEGIN READING TABLES

    // MARK: - Read Table Names

    private func dataSets(sqliteStore: OpaquePointer) throws -> [XRDataSet] {
        let sets: [DataSet] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: DataSet.storedValues()
        )
        return try sets.map { set in
            let values = try dataSetValues(for: set)
            let data = Data(bytes: values, count: MemoryLayout<Float>.size * values.count)
            return XRDataSet(
                id: Int32(set._id ?? -1),
                name: set.NAME ?? "Unnamed",
                tableName: set.TABLENAME ?? "Unnamed",
                column: set.COLUMNNAME ?? "Unnamed",
                predicate: set.PREDICATE ?? "",
                comments: set.decodedComments() ?? NSMutableAttributedString(),
                data: data
            )
        }
    }

    // MARK: - Read Window Size

    func windowSize(sqliteStore: OpaquePointer) throws -> CGSize {
        let sqliteStore = try validateStore()
        let sizes: [WindowControllerSize] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: WindowControllerSize.storedValues()
        )
        if sizes.isEmpty {
            throw InMemoryStoreError.unexpectedEmptyResult
        }
        return CGSize(width: sizes[0].width, height: sizes[0].height)
    }

    private func readWindowSize(sqliteStore: OpaquePointer) throws -> [WindowControllerSize] {
        let sizes: [WindowControllerSize] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: WindowControllerSize.storedValues()
        )
        if sizes.isEmpty {
            throw InMemoryStoreError.unexpectedEmptyResult
        }
        return sizes
    }

    // MARK: - Read Geometry

    func geometry(sqliteStore: OpaquePointer) throws -> Geometry {
        let geometries: [Geometry] = try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: Geometry.storedValues()
        )
        if geometries.isEmpty {
            throw InMemoryStoreError.unexpectedEmptyResult
        }
        return geometries[0]
    }

    // MARK: - Read Colors

    private func readColors(sqliteStore: OpaquePointer) throws -> [Color] {
        try interface.executeCodableQuery(
            sqlite: sqliteStore,
            query: Color.storedValues()
        )
    }

    // MARK: - Read Layers

    private func readLayerTable(sqliteStore: OpaquePointer) throws -> [Layer] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: Layer.storedValues())
    }

    private func readLayerTextTable(sqliteStore: OpaquePointer) throws -> [LayerText] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: LayerText.storedValues())
    }

    private func readLayerLineArrowTable(sqliteStore: OpaquePointer) throws -> [LayerLineArrow] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: LayerLineArrow.storedValues())
    }

    private func readLayerCoreTable(sqliteStore: OpaquePointer) throws -> [LayerCore] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: LayerCore.storedValues())
    }

    private func readLayerGridTable(sqliteStore: OpaquePointer) throws -> [LayerGrid] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: LayerGrid.storedValues())
    }

    private func readLayerDataTable(sqliteStore: OpaquePointer) throws -> [LayerData] {
        try interface.executeCodableQuery(sqlite: sqliteStore, query: LayerData.storedValues())
    }

    // MARK: - END READING TABLES

    // MARK: - BEGIN PROCESSING READ TABLES

    // MARK: - END PROCESSING READ TABLES

    // MARK: - Write Window Size

    func store(windowSize: CGSize) throws {
        let sqliteStore = try validateStore()
        let size = WindowControllerSize(width: windowSize.width, height: windowSize.height)
        _ = try interface.executeQuery(
            sqlite: sqliteStore, query: WindowControllerSize.deleteAllRecords()
        ) // No primary key exists
        var query = WindowControllerSize.insertQuery()
        query.bindings = try [size.valueBindables(keys: WindowControllerSize.allKeys())]
        _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
    }

    // MARK: - Data Sets

    func dataSetValues(for dataSet: DataSet) throws -> [Float] {
        let sqliteStore = try validateStore()
        guard let columnName = dataSet.COLUMNNAME else {
            throw InMemoryStoreError.databaseDoesNotExist
        }
        let values = try interface.executeQuery(
            sqlite: sqliteStore,
            query: dataSet.dataQuery()
        )
        return try values.compactMap { value in
            guard let value = value[columnName] else {
                return nil
            }
            if let stringValue = value as? String {
                return Float(stringValue)
            }
            // swiftlint:disable:next legacy_objc_type
            if let number = value as? NSNumber {
                return Float(truncating: number)
            }
            throw InMemoryStoreError.unknownType
        }
    }

    func valueColumnNames(for table: String) throws -> [String] {
        let valueColumnsTypes: [ColumnAffinity] = [.integer, .float]
        let sqliteStore = try validateStore()
        let columns = try interface.columns(sqlite: sqliteStore, table: table)
        return columns.compactMap { column in
            if let affinity = column.type, valueColumnsTypes.contains(affinity) {
                return column.name
            }
            return nil
        }
    }

    // MARK: - Geometry

    func store(geometryController: XRGeometryController) throws {
        let sqliteStore = try validateStore()
        let geometry = storageLayerFactory.storageGeometry(from: geometryController)
        _ = try interface.executeQuery(sqlite: sqliteStore, query: Geometry.deleteAllRecords())
        var query = Geometry.insertQuery()
        query.bindings = try [geometry.valueBindables(keys: Geometry.allKeys())]
        _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
    }

    func configure(geometryController: XRGeometryController) throws {
        let sqliteStore = try validateStore()
        let geometry = try geometry(sqliteStore: sqliteStore)
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
    }

    // MARK: - Colors

    private func storeColors(sqliteStore: OpaquePointer) throws {
        _ = try interface.executeQuery(
            sqlite: sqliteStore,
            query: Color.deleteAllRecords()
        )
        var query = Color.insertQuery()
        query.bindings = try storedColors.map { color in
            try color.valueBindables(keys: Color.allKeys())
        }
        _ = try interface.executeQuery(
            sqlite: sqliteStore,
            query: query
        )
    }

    // MARK: - Storing Layers

    func store(layers: [XRLayer]) throws {
        let sqliteStore = try validateStore()
        try deleteAllLayers(sqliteStore: sqliteStore)
        for (index, layer) in layers.enumerated() {
            print("Storing layer \(index)")
            try store(layer: layer, at: index, in: sqliteStore)
        }
    }

    private func store(layer: XRLayer, at index: Int, in sqliteStore: OpaquePointer) throws {
        try storageLayerFactory.storageLayers(from: layer, at: index)
            .forEach { storageLayer in
                let layerType = type(of: storageLayer)
                var query = layerType.insertQuery()
                query.bindings = try [storageLayer.valueBindables(keys: layerType.allKeys())]
                _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
            }
    }

    private func deleteAllLayers(sqliteStore: OpaquePointer) throws {
        let deleteQueries = [
            Layer.deleteAllRecords(),
            LayerText.deleteAllRecords(),
            LayerLineArrow.deleteAllRecords(),
            LayerCore.deleteAllRecords(),
            LayerGrid.deleteAllRecords(),
            LayerData.deleteAllRecords()
        ]
        try deleteQueries.forEach { query in
            _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
        }
    }

    // MARK: - Reading Layers

    func readLayers(sqliteStore: OpaquePointer) throws -> [XRLayer] {
        let sqliteStore = try validateStore()
        let layers = try readLayerTable(sqliteStore: sqliteStore)
        var typeLayers: [String: [LayerIdentifiable]] = [:]
        let layerTexts = try readLayerTextTable(sqliteStore: sqliteStore)
        typeLayers["XRLayerText"] = layerTexts
        let layerLineArrows = try readLayerLineArrowTable(sqliteStore: sqliteStore)
        typeLayers["XRLayerLineArrow"] = layerLineArrows
        let layerCores = try readLayerCoreTable(sqliteStore: sqliteStore)
        typeLayers["XRLayerCore"] = layerCores
        let layerGrids = try readLayerGridTable(sqliteStore: sqliteStore)
        print("radials is percent \(layerGrids[0].RADIALS_ISPERCENT)")
        typeLayers["XRLayerGrid"] = layerGrids
        let layerDatas = try readLayerDataTable(sqliteStore: sqliteStore)
        typeLayers["XRLayerData"] = layerDatas
        let colors = try readColors(sqliteStore: sqliteStore)
        storageLayerFactory.set(colors: colors)
        var xrLayers: [XRLayer] = []
        for layer in layers {
            guard let typeLayerArray = typeLayers[layer.TYPE],
                let typeLayer = typeLayerArray.first(where: { $0.LAYERID == layer.LAYERID }) else {
                throw InMemoryStoreError.invalidLayersStore
            }
            let newLayer = try storageLayerFactory.createXRLayer(baseLayer: layer, targetLayer: typeLayer)
            xrLayers.append(newLayer)
        }
        return xrLayers
    }

    // MARK: - Table Manipulation

    @objc func renameTable(from: String, toName: String) throws {
        let sqliteStore = try validateStore()
        let query = Query(sql: "ALTER TABLE \(from) RENAME TO \(toName)")
        _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
    }

    @objc func addColumn(to table: String, columnDefinition: String) throws {
        let sqliteStore = try validateStore()
        let query = Query(sql: "ALTER TABLE \(table) ADD COLUMN \(columnDefinition)")
        _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
    }

    @objc func drop(table: String) throws {
        let sqliteStore = try validateStore()
        let query = Query(sql: "DROP TABLE \(table)")
        _ = try interface.executeQuery(sqlite: sqliteStore, query: query)
    }

    @discardableResult
    private func validateStore() throws -> OpaquePointer {
        guard let sqliteStore else {
            throw InMemoryStoreError.databaseDoesNotExist
        }
        return sqliteStore
    }

    private func backup(info: BackupInfo) throws {
        let store = try validateStore()
        let file = try interface.openDatabase(path: info.path)
        defer {
            closeFile(file: file)
        }
        switch info.type {
        case .fromFile:
            try interface.backup(source: file, destination: store)

        case .toFile:
            try interface.backup(source: store, destination: file)
        }
    }

    private func closeFile(file: OpaquePointer) {
        do {
            try interface.close(store: file)
        } catch {
            logError(error: "Error closing file store: \(error)")
        }
    }

    private func setupDatabase() throws {
        do {
            let store = try createStore()
            sqliteStore = store
            try configureStore(store: store)
        } catch {
            logError(error: "Error creating in-memory store at setupDatabase: \(error)")
            throw error
        }
    }

    private func createStore() throws -> OpaquePointer {
        try interface.createInMemoryStore()
    }

    private func configureStore(store: OpaquePointer) throws {
        try createTableQueries.forEach { query in
            try _ = interface.executeQuery(sqlite: store, query: query)
        }
    }

    private func logError(error: String) {
        Logger.memoryStoreLogger.error("\(error)")
    }

    deinit {
        if let sqliteStore {
            do {
                try interface.close(store: sqliteStore)
            } catch {
                logError(error: "Error closing in-memory store: \(error)")
            }
        }
    }
}
