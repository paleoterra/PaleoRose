//
// TestableTable.swift
// Unit Tests
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

struct TestableTable: TableRepresentable {

    static var tableName: String = "TestableTable"

    static var primaryKey: String?

    var intValue: Int
    var int32Value: Int32
    var uintValue: UInt
    var uint32Value: UInt32
    var int16Value: Int16
    var uint16Value: UInt16
    var floatValue: Float
    var doubleValue: Double
    var cgFloatValue: Double
    var stringValue: String
    var optionalString: String?

    static func stub(
        intValue: Int = 23212,
        int32Value: Int32 = 1600,
        uintValue: UInt = 4534,
        uint32Value: UInt32 = 34,
        int16Value: Int16 = 65,
        uint16Value: UInt16 = 344,
        floatValue: Float = 34.5,
        doubleValue: Double = 4534.3453,
        cgFloatValue: CGFloat = 4534.3453,
        stringValue: String = "Tests",
        optionalString: String? = nil
    ) -> Self {
        .init(
            intValue: intValue,
            int32Value: int32Value,
            uintValue: uintValue,
            uint32Value: uint32Value,
            int16Value: int16Value,
            uint16Value: uint16Value,
            floatValue: floatValue,
            doubleValue: doubleValue,
            cgFloatValue: cgFloatValue,
            stringValue: stringValue,
            optionalString: optionalString
        )
    }

    static func createTableQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func insertQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func updateQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    static func deleteQuery() -> any QueryProtocol {
        Query(sql: "")
    }

    // create encode function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(intValue, forKey: .intValue)
        try container.encode(int32Value, forKey: .int32Value)
        try container.encode(uintValue, forKey: .uintValue)
        try container.encode(uint32Value, forKey: .uint32Value)
        try container.encode(int16Value, forKey: .int16Value)
        try container.encode(uint16Value, forKey: .uint16Value)
        try container.encode(floatValue, forKey: .floatValue)
        try container.encode(doubleValue, forKey: .doubleValue)
        try container.encode(cgFloatValue, forKey: .cgFloatValue)
        try container.encode(stringValue, forKey: .stringValue)
        try container.encode(optionalString, forKey: .optionalString)
    }
}
