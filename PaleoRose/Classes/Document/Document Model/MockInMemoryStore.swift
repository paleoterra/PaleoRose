//
// MockInMemoryStore.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2026 to present Thomas L. Moore.
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
@testable import PaleoRose

class MockInMemoryStore: NSObject, InMemoryStoreProtocol {

    // MARK: - Delegate

    weak var delegate: InMemoryStoreDelegate?

    // MARK: - Error injection

    /// Set to force all throwing methods to throw this error.
    var errorToThrow: Error?

    // MARK: - Stubs (configurable return values)

    var stubbedSqlitePointer: OpaquePointer?
    var stubbedTableNames: [String] = []
    var stubbedWindowSize: CGSize = .zero
    var stubbedGeometry: Geometry?
    var stubbedDataSetValues: [Float] = []
    var stubbedValueColumnNames: [String] = []
    var stubbedDataSet: XRDataSet?
    var stubbedLayers: [XRLayer] = []
    var stubbedReadFromStoreResult: Result<Bool, Error> = .success(true)

    // MARK: - Call tracking

    var sqlitePointerCalled = false

    var loadFromFileCalled = false
    var loadFromFileArguments: [String] = []

    var saveToFileCalled = false
    var saveToFileArguments: [String] = []

    var readFromStoreCalled = false

    var tableNamesCalled = false
    var tableNamesArguments: [OpaquePointer] = []

    var windowSizeCalled = false
    var windowSizeArguments: [OpaquePointer] = []

    var geometryCalled = false
    var geometryArguments: [OpaquePointer] = []

    var storeWindowSizeCalled = false
    var storeWindowSizeArguments: [CGSize] = []

    var dataSetValuesCalled = false
    var dataSetValuesArguments: [DataSet] = []

    var valueColumnNamesCalled = false
    var valueColumnNamesArguments: [String] = []

    var storeDataSetCalled = false
    // swiftlint:disable:next large_tuple
    var storeDataSetArguments: [(name: String, tableName: String, columnName: String)] = []

    var storeGeometryControllerCalled = false
    var storeGeometryControllerArguments: [XRGeometryController] = []

    var configureGeometryControllerCalled = false
    var configureGeometryControllerArguments: [XRGeometryController] = []

    var storeLayersCalled = false
    var storeLayersArguments: [[XRLayer]] = []

    var readLayersCalled = false
    var readLayersArguments: [OpaquePointer] = []

    var renameTableCalled = false
    var renameTableArguments: [(from: String, toName: String)] = []

    var addColumnCalled = false
    var addColumnArguments: [(table: String, columnDefinition: String)] = []

    var dropTableCalled = false
    var dropTableArguments: [String] = []

    var createUserTableCalled = false
    // swiftlint:disable:next large_tuple
    var createUserTableArguments: [(createSQL: String, insertSQL: String, rows: [[Bindable?]])] = []

    var copyTablesCalled = false
    var copyTablesArguments: [(sourceURL: URL, tables: [(original: String, destination: String)])] = []

    var saveToError: Error?
    var storeGeometryError: Error?
    var storeLayersError: Error?

    // MARK: - InMemoryStoreProtocol

    func sqlitePointer() throws -> OpaquePointer {
        sqlitePointerCalled = true
        if let error = errorToThrow { throw error }
        guard let pointer = stubbedSqlitePointer else {
            throw InMemoryStore.InMemoryStoreError.databaseDoesNotExist
        }
        return pointer
    }

    func load(from filePath: String) throws {
        loadFromFileCalled = true
        loadFromFileArguments.append(filePath)
        if let error = errorToThrow { throw error }
    }

    func save(to filePath: String) throws {
        saveToFileCalled = true
        saveToFileArguments.append(filePath)
        if let error = saveToError { throw error }
    }

    func readFromStore(completion: @escaping (Result<Bool, Error>) -> Void) {
        readFromStoreCalled = true
        completion(stubbedReadFromStoreResult)
    }

    func tableNames(sqliteStore: OpaquePointer) throws -> [String] {
        tableNamesCalled = true
        tableNamesArguments.append(sqliteStore)
        if let error = errorToThrow { throw error }
        return stubbedTableNames
    }

    func windowSize(sqliteStore: OpaquePointer) throws -> CGSize {
        windowSizeCalled = true
        windowSizeArguments.append(sqliteStore)
        if let error = errorToThrow { throw error }
        return stubbedWindowSize
    }

    func geometry(sqliteStore: OpaquePointer) throws -> Geometry {
        geometryCalled = true
        geometryArguments.append(sqliteStore)
        if let error = errorToThrow { throw error }
        guard let geometry = stubbedGeometry else {
            throw InMemoryStore.InMemoryStoreError.unexpectedEmptyResult
        }
        return geometry
    }

    func store(windowSize: CGSize) throws {
        storeWindowSizeCalled = true
        storeWindowSizeArguments.append(windowSize)
        if let error = errorToThrow { throw error }
    }

    func dataSetValues(for dataSet: DataSet) throws -> [Float] {
        dataSetValuesCalled = true
        dataSetValuesArguments.append(dataSet)
        if let error = errorToThrow { throw error }
        return stubbedDataSetValues
    }

    func valueColumnNames(for table: String) throws -> [String] {
        valueColumnNamesCalled = true
        valueColumnNamesArguments.append(table)
        if let error = errorToThrow { throw error }
        return stubbedValueColumnNames
    }

    func store(dataSetWithName name: String, tableName: String, columnName: String) throws -> XRDataSet {
        storeDataSetCalled = true
        storeDataSetArguments.append((name: name, tableName: tableName, columnName: columnName))
        if let error = errorToThrow { throw error }
        guard let dataSet = stubbedDataSet else {
            throw InMemoryStore.InMemoryStoreError.unexpectedEmptyResult
        }
        return dataSet
    }

    func store(geometryController: XRGeometryController) throws {
        storeGeometryControllerCalled = true
        storeGeometryControllerArguments.append(geometryController)
        if let error = storeGeometryError { throw error }
    }

    func configure(geometryController: XRGeometryController) throws {
        configureGeometryControllerCalled = true
        configureGeometryControllerArguments.append(geometryController)
        if let error = errorToThrow { throw error }
    }

    func store(layers: [XRLayer]) throws {
        storeLayersCalled = true
        storeLayersArguments.append(layers)
        if let error = storeLayersError { throw error }
    }

    func readLayers(sqliteStore: OpaquePointer) throws -> [XRLayer] {
        readLayersCalled = true
        readLayersArguments.append(sqliteStore)
        if let error = errorToThrow { throw error }
        return stubbedLayers
    }

    func renameTable(from: String, toName: String) throws {
        renameTableCalled = true
        renameTableArguments.append((from: from, toName: toName))
        if let error = errorToThrow { throw error }
    }

    func addColumn(to table: String, columnDefinition: String) throws {
        addColumnCalled = true
        addColumnArguments.append((table: table, columnDefinition: columnDefinition))
        if let error = errorToThrow { throw error }
    }

    func drop(table: String) throws {
        dropTableCalled = true
        dropTableArguments.append(table)
        if let error = errorToThrow { throw error }
    }

    func createUserTable(
        createSQL: String,
        insertSQL: String,
        rows: [[Bindable?]]
    ) throws {
        createUserTableCalled = true
        createUserTableArguments.append((createSQL: createSQL, insertSQL: insertSQL, rows: rows))
        if let error = errorToThrow { throw error }
    }

    func copyTables(
        from sourceURL: URL,
        selecting tables: [(original: String, destination: String)]
    ) throws {
        copyTablesCalled = true
        copyTablesArguments.append((sourceURL: sourceURL, tables: tables))
        if let error = errorToThrow { throw error }
    }
}
