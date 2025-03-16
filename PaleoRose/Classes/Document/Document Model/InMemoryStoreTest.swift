//
// InMemoryStoreTest.swift
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
@testable import PaleoRose
import SQLite3
import Testing

struct InMemoryStoreTest {
    enum InMemoryStoreTestError: Error {
        case failedToCreateStore
        case queryError
    }

    private var sqlitePointer: OpaquePointer?
    private let sqliteInterface = MockSqliteInterface()

    private func createPointer() throws -> OpaquePointer {
        var pointer: OpaquePointer?
        let result = sqlite3_open(":memory:", &pointer)
        try #require(result == SQLITE_OK)
        return try #require(pointer)
    }

    private func closePointer(pointer: OpaquePointer) throws {
        let result = sqlite3_close(pointer)
        try #require(result == SQLITE_OK)
    }

    private func assignSqlitePointerToInterface() throws -> OpaquePointer {
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        return pointer
    }

    @Test("Creating and clearing with ObjC init the object does not crash")
    func createObject() throws {
        let pointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: pointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        var sut: InMemoryStore? = try InMemoryStore(interface: sqliteInterface)
        #expect(sut != nil)
        sut = nil
        #expect(sut == nil)
    }

    @Test("Store called, given interface, when createStore throws, then return nil")
    func catchCreateStoreError() throws {

        sqliteInterface.createInMemoryStoreError = InMemoryStoreTestError.failedToCreateStore
        #expect(throws: (any Error).self) {
            try InMemoryStore(interface: sqliteInterface)
        }
    }

    @Test("Store called, given interface, when configureStore throws, then return nil")
    func catchConfigureStoreError() throws {
        sqliteInterface.queryError = InMemoryStoreTestError.queryError
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        #expect(throws: (any Error).self) {
            try InMemoryStore(interface: sqliteInterface)
        }
        try closePointer(pointer: pointer)
    }

    @Test("Store called, given interface, when configures, call create and executequery without error")
    func configureStoreWithoutError() throws {
        let pointer = try createPointer()
        sqliteInterface.pointer = pointer
        _ = try #require(try InMemoryStore(interface: sqliteInterface))

        #expect(sqliteInterface.createInMemoryStoreCalled)
        #expect(sqliteInterface.executeQueryCalled)

        try closePointer(pointer: pointer)
    }

    @Test(
        "Store called, given interface, when configures, execute a query per table",
        arguments: [
            WindowControllerSize.tableName,
            Geometry.tableName,
            Layer.tableName,
            Color.tableName,
            DataSet.tableName,
            LayerText.tableName,
            LayerLineArrow.tableName,
            LayerCore.tableName,
            LayerGrid.tableName,
            LayerData.tableName
        ]
    )
    func configureStoreContainsQuery(tableName: String) throws {
        let pointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: pointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        _ = try #require(try InMemoryStore(interface: sqliteInterface))

        let allQueries = sqliteInterface.queryAccumulator.map(\.sql).joined(separator: "\n")
        #expect(allQueries.contains(tableName))
    }

    @Test("Given sqlite pointer, then return pointer when sqlitePointer is called")
    func getSqlitePointer() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        let pointer = try #require(try store.sqlitePointer())
        let expectedPointerInt = Int(bitPattern: expectedPointer)
        let pointerInt = Int(bitPattern: pointer)
        #expect(pointerInt == expectedPointerInt)
    }

    // MARK: - Layer Storage

    @Test("Given an XRLayer, then attempt to remove all layers")
    func onStoreLayersDeleteAllLayers() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerText.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 6)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        #expect(sqlStrings.contains("DELETE FROM _layers;"))
        #expect(sqlStrings.contains("DELETE FROM _layerLineArrow;"))
        #expect(sqlStrings.contains("DELETE FROM _layerCore;"))
        #expect(sqlStrings.contains("DELETE FROM _layerGrid;"))
        #expect(sqlStrings.contains("DELETE FROM _layerData;"))
    }

    @Test("Given an XRLayerText, then attempt to store the layer")
    func storeXRLayerText() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerText.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 8)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layers (LAYERID, TYPE, VISIBLE, ACTIVE, BIDIR, LAYER_NAME, LINEWEIGHT, MAXCOUNT, MAXPERCENT, STROKECOLORID, FILLCOLORID) VALUES (?,?,?,?,?,?,?,?,?,?,?)"))
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layerText (LAYERID,CONTENTS,RECT_POINT_X,RECT_POINT_Y,RECT_SIZE_HEIGHT,RECT_SIZE_WIDTH) values (?,?,?,?,?,?)"))
    }

    @Test("Given an XRLayerLineArrow, then attempt to store the layer")
    func storeXRLayerLineArrow() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerLineArrow.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 8)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layers (LAYERID, TYPE, VISIBLE, ACTIVE, BIDIR, LAYER_NAME, LINEWEIGHT, MAXCOUNT, MAXPERCENT, STROKECOLORID, FILLCOLORID) VALUES (?,?,?,?,?,?,?,?,?,?,?)"))
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layerLineArrow (LAYERID, DATASET, ARROWSIZE, VECTORTYPE, ARROWTYPE, SHOWVECTOR, SHOWERROR) VALUES (?,?,?,?,?,?,?);"))
    }

    @Test("Given an XRLayerCore, then attempt to store the layer")
    func storeXRLayerCore() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerCore.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 8)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layers (LAYERID, TYPE, VISIBLE, ACTIVE, BIDIR, LAYER_NAME, LINEWEIGHT, MAXCOUNT, MAXPERCENT, STROKECOLORID, FILLCOLORID) VALUES (?,?,?,?,?,?,?,?,?,?,?)"))
        #expect(sqlStrings.contains("INSERT INTO _layerCore (LAYERID, RADIUS, TYPE) VALUES (?,?,?);"))
    }

    @Test("Given an XRLayerGrid, then attempt to store the layer")
    func storeXRLayerGrid() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerGrid.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 8)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layers (LAYERID, TYPE, VISIBLE, ACTIVE, BIDIR, LAYER_NAME, LINEWEIGHT, MAXCOUNT, MAXPERCENT, STROKECOLORID, FILLCOLORID) VALUES (?,?,?,?,?,?,?,?,?,?,?)"))
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layerGrid (LAYERID, RINGS_ISFIXEDCOUNT, RINGS_VISIBLE, RINGS_LABELS, RINGS_FIXEDCOUNT, RINGS_COUNTINCREMENT, RINGS_PERCENTINCREMENT, RINGS_LABELANGLE, RINGS_FONTNAME, RINGS_FONTSIZE,  RADIALS_COUNT, RADIALS_ANGLE, RADIALS_LABELALIGN, RADIALS_COMPASSPOINT, RADIALS_ORDER, RADIALS_FONT, RADIALS_FONTSIZE, RADIALS_SECTORLOCK, RADIALS_VISIBLE, RADIALS_ISPERCENT, RADIALS_TICKS, RADIALS_MINORTICKS, RADIALS_LABELS) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"))
    }

    @Test("Given an XRLayerData, then attempt to store the layer")
    func storeXRLayerData() throws {
        let expectedPointer = try assignSqlitePointerToInterface()
        defer {
            do {
                try closePointer(pointer: expectedPointer)
            } catch {
                Issue.record("Failed to close pointer: \(error)")
            }
        }
        let layer = XRLayerData.stub()
        let store = try #require(try InMemoryStore(interface: sqliteInterface))
        sqliteInterface.resetMock()
        try store.store(layers: [layer])
        #expect(sqliteInterface.queryAccumulator.count >= 8)
        let sqlStrings = sqliteInterface.queryAccumulator.map(\.sql)
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layers (LAYERID, TYPE, VISIBLE, ACTIVE, BIDIR, LAYER_NAME, LINEWEIGHT, MAXCOUNT, MAXPERCENT, STROKECOLORID, FILLCOLORID) VALUES (?,?,?,?,?,?,?,?,?,?,?)"))
        // swiftlint:disable:next line_length
        #expect(sqlStrings.contains("INSERT INTO _layerData (LAYERID,DATASET,PLOTTYPE,TOTALCOUNT,DOTRADIUS) VALUES (?,?,?,?,?);"))
    }
}
