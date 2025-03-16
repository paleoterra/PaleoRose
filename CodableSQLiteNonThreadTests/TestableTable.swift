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

struct TestableTable: TableRepresentable, Equatable {
    enum CodingKeys: String, CodingKey {
        case boolValue
        case intValue
        case int32Value
        case uintValue
        case uint32Value
        case int16Value
        case uint16Value
        case floatValue
        case doubleValue
        case cgFloatValue
        case stringValue
        case optionalString
        case dataStore
    }

    static var tableName: String = "TestableTable"
    static var primaryKey: String?

    var boolValue: Bool
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
    var dataStore: Data?

    init(
        boolValue: Bool,
        intValue: Int,
        int32Value: Int32,
        uintValue: UInt,
        uint32Value: UInt32,
        int16Value: Int16,
        uint16Value: UInt16,
        floatValue: Float,
        doubleValue: Double,
        cgFloatValue: CGFloat,
        stringValue: String,
        optionalString: String?,
        dataStore: Data?
    ) {
        self.boolValue = boolValue
        self.intValue = intValue
        self.int32Value = int32Value
        self.uintValue = uintValue
        self.uint32Value = uint32Value
        self.int16Value = int16Value
        self.uint16Value = uint16Value
        self.floatValue = floatValue
        self.doubleValue = doubleValue
        self.cgFloatValue = cgFloatValue
        self.stringValue = stringValue
        self.optionalString = optionalString
        self.dataStore = dataStore
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        boolValue = try container.decodeSqliteBool(forKey: .boolValue)
        intValue = try container.decode(Int.self, forKey: .intValue)
        int32Value = try container.decode(Int32.self, forKey: .int32Value)
        uintValue = try container.decode(UInt.self, forKey: .uintValue)
        uint32Value = try container.decode(UInt32.self, forKey: .uint32Value)
        int16Value = try container.decode(Int16.self, forKey: .int16Value)
        uint16Value = try container.decode(UInt16.self, forKey: .uint16Value)
        floatValue = try container.decode(Float.self, forKey: .floatValue)
        doubleValue = try container.decode(Double.self, forKey: .doubleValue)
        cgFloatValue = try container.decode(Double.self, forKey: .cgFloatValue)
        stringValue = try container.decode(String.self, forKey: .stringValue)
        optionalString = try container.decodeIfPresent(String.self, forKey: .optionalString)
        dataStore = try container.decodeIfPresent(Data.self, forKey: .dataStore)
    }

    static func stub(
        boolValue: Bool = true,
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
        optionalString: String? = nil,
        dataStore: Data? = nil
    ) -> Self {
        .init(
            boolValue: boolValue,
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
            optionalString: optionalString,
            dataStore: dataStore
        )
    }

    static func createTableQuery() -> any QueryProtocol {
        Query(
            sql:
            """
            CREATE TABLE \(tableName)
            (intValue INTEGER PRIMARY KEY,
            boolValue BOOL not null,
            int32Value INTEGER not null,
            uintValue INTEGER not null,
            uint32Value INTEGER not null,
            int16Value INTEGER not null,
            uint16Value INTEGER not null,
            floatValue REAL not null,
            doubleValue DOUBLE not null,
            cgFloatValue DOUBLE not null,
            stringValue TEXT not null,
            optionalString TEXT,
            dataStore blob);
            """
        )
    }

    static func allKeys() -> [String] {
        let keys: [CodingKeys] = [
            .intValue,
            .boolValue,
            .int32Value,
            .uintValue,
            .uint32Value,
            .int16Value,
            .uint16Value,
            .floatValue,
            .doubleValue,
            .cgFloatValue,
            .stringValue,
            .optionalString,
            .dataStore
        ]
        return keys.map(\.stringValue)
    }

    static func insertQuery() -> any QueryProtocol {
        // sql insert command for TestableTable
        let keys = Self.allKeys()

        return Query(sql: "INSERT INTO \(tableName) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", keys: keys)
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

        try container.encode(boolValue, forKey: .boolValue)
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
        try container.encode(dataStore, forKey: .dataStore)
    }
}
