//
// BindableTest.swift
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
import SQLite3
import Testing

// swiftlint:disable legacy_objc_type
struct BindableTest {
    let interface = SQLiteInterface()

    private func buildDatabase() throws -> OpaquePointer {
        let database = try interface.createInMemoryStore(identifier: UUID().uuidString)
        _ = try interface.executeQuery(sqlite: database, query: TestableTable.createTableQuery())
        return database
    }

    @Test(
        "Given Value, then bind correctly",
        arguments: [
            NSNull(),
            Int(17),
            Int8(8),
            Int16(34),
            Int32(342),
            Int64(342_342),
            UInt(123),
            UInt8(124),
            UInt16(125),
            UInt32(126),
            UInt64(127),
            Float(123.45),
            Double(123.556),
            CGFloat(123.656),
            String("Hello"),
            Data("Hello".utf8),
            NSNumber(value: Int16(43)),
            NSNumber(value: Int32(432)),
            NSNumber(value: Int64(432_432)),
            NSNumber(value: Int(343)),
            NSNumber(value: Float(343.4)),
            NSNumber(value: CGFloat(349.4)),
            NSNumber(value: Double(365.456)),
            NSString("Hello3"),
            true,
            false
        ]
    )
    func simpleBindingTest(value: Any) throws {
        let database = try buildDatabase()

        let statement = try interface.buildStatement(sqlite: database, query: TestableTable.insertQuery())
        let tvalue = try #require(value as? Bindable)
        try interface.bind(tvalue, to: statement, at: 1)
    }

    @Test("Given a nil value, then bind an NSNUll")
    func bindNillTtest() throws {
        let database = try buildDatabase()
        let value: Int32? = nil
        let statement = try interface.buildStatement(sqlite: database, query: TestableTable.insertQuery())
        try interface.bind(value, to: statement, at: 1)
    }
}

// swiftlint:enable legacy_objc_type
