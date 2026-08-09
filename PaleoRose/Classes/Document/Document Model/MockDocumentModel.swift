//
// MockDocumentModel.swift
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

import Foundation
@testable import PaleoRose

class MockDocumentModel: NSObject, DocumentModelProtocol {

    // MARK: - Properties

    var windowSize: CGSize = .zero
    let geometryController = XRGeometryController()
    var undoManager: UndoManager?
    var url: URL?

    // MARK: - Error injection

    /// Set to force all throwing methods to throw this error.
    var errorToThrow: Error?

    // MARK: - Stubs (configurable return values)

    var stubbedFileURL: URL?
    var stubbedDataTableNames: [String] = []
    var stubbedPossibleColumnNames: [String] = []
    var stubbedDataSet: XRDataSet?
    var stubbedCreatedDataSet: XRDataSet?

    // MARK: - Call tracking

    var writeToFileCalled = false
    var writeToFileArguments: [URL] = []

    var openFileCalled = false
    var openFileArguments: [URL] = []

    var fileURLCalled = false

    var dataTableNamesCalled = false

    var possibleColumnNamesCalled = false
    var possibleColumnNamesArguments: [String] = []

    var setWindowSizeCalled = false
    var setWindowSizeArguments: [CGSize] = []

    var deleteTableCalled = false
    var deleteTableArguments: [String] = []

    var dataSetCalled = false
    var dataSetArguments: [String] = []

    var createDataSetCalled = false
    var createDataSetArguments: [(tableName: String, columnName: String, name: String)] = []

    var saveGeometryCalled = false

    var saveLayersCalled = false

    var readFromStoreCalled = false

    var refreshTableNamesCalled = false

    // MARK: - DocumentModelProtocol

    // MARK: File Management

    func writeToFile(_ file: URL) throws {
        writeToFileCalled = true
        writeToFileArguments.append(file)
        if let error = errorToThrow { throw error }
    }

    func openFile(_ file: URL) throws {
        openFileCalled = true
        openFileArguments.append(file)
        if let error = errorToThrow { throw error }
    }

    func fileURL() -> URL? {
        fileURLCalled = true
        return stubbedFileURL
    }

    // MARK: General

    func dataTableNames() -> [String] {
        dataTableNamesCalled = true
        return stubbedDataTableNames
    }

    func possibleColumnNames(table: String) throws -> [String] {
        possibleColumnNamesCalled = true
        possibleColumnNamesArguments.append(table)
        if let error = errorToThrow { throw error }
        return stubbedPossibleColumnNames
    }

    func setWindowSize(_ size: CGSize) throws {
        setWindowSizeCalled = true
        setWindowSizeArguments.append(size)
        if let error = errorToThrow { throw error }
    }

    func delete(table: String) throws {
        deleteTableCalled = true
        deleteTableArguments.append(table)
        if let error = errorToThrow { throw error }
    }

    func dataSet(name: String) -> XRDataSet? {
        dataSetCalled = true
        dataSetArguments.append(name)
        return stubbedDataSet
    }

    // MARK: Persistence

    func createDataSet(tableName: String, columnName: String, name: String) throws -> XRDataSet {
        createDataSetCalled = true
        createDataSetArguments.append((tableName: tableName, columnName: columnName, name: name))
        if let error = errorToThrow { throw error }
        guard let dataSet = stubbedCreatedDataSet else {
            throw DocumentModel.DocumentModelError.unknownLayerType
        }
        return dataSet
    }

    func saveGeometry() throws {
        saveGeometryCalled = true
        if let error = errorToThrow { throw error }
    }

    func saveLayers() throws {
        saveLayersCalled = true
        if let error = errorToThrow { throw error }
    }

    // MARK: Read From Store

    func readFromStore(completion: @escaping () -> Void) {
        readFromStoreCalled = true
        completion()
    }

    func refreshTableNames() {
        refreshTableNamesCalled = true
    }
}
