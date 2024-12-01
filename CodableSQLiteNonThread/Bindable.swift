//
// Bindable.swift
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

import Foundation
import SQLite3

/// A protocol to define value types and classes that can be used in binding
public protocol Bindable {

    /// Bind a value to a sqlite statment
    ///
    /// - Parameters:
    /// - statement: Sqlite3 Statement pointer
    /// - Index: Int32 binding index. Starts at 1
    /// - throws an SQLite error
    func bind(statement: OpaquePointer, index: Int32) throws
}

extension Bindable {

    func bindNull(to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_null(statement, index)
        try checkError(value: nil, sqliteStatus: result)
    }

    func bindData(_ data: Data, to statement: OpaquePointer, at index: Int32) throws {
        let bytes = try data.withUnsafeBytes { value in
            guard let address = value.baseAddress else {
                throw SQLiteError.invalidBindings(type: "data", value: value, SQLiteError: -1)
            }
            return address
        }
        let result = sqlite3_bind_blob(statement, index, bytes, Int32(data.count), nil)
        try checkError(value: data, sqliteStatus: result)
    }

    func bindBoolean(_ value: Bool, to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_int64(statement, index, Int64(value ? 1 : 0))
        try checkError(value: value, sqliteStatus: result)
    }

    func bindInteger32(_ value: Int32, to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_int64(statement, index, Int64(value))
        try checkError(value: value, sqliteStatus: result)
    }

    func bindInteger64(_ value: Int64, to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_int64(statement, index, Int64(value))
        try checkError(value: value, sqliteStatus: result)
    }

    func bindBinaryFloatingPoint(
        _ value: some BinaryFloatingPoint,
        to statement: OpaquePointer,
        at index: Int32
    ) throws {
        let result = sqlite3_bind_double(statement, index, Double(value))
        try checkError(value: value, sqliteStatus: result)
    }

    func bindString(_ value: String, to statement: OpaquePointer, at index: Int32) throws {
        let result = sqlite3_bind_text(statement, index, value, -1, SQLITE_TRANSIENT)
        try checkError(value: value, sqliteStatus: result)
    }

    private func checkError(value: Any?, sqliteStatus: Int32) throws {
        if sqliteStatus != SQLITE_OK {
            if let value {
                throw SQLiteError.invalidBindings(
                    type: String(describing: type(of: value)),
                    value: value,
                    SQLiteError: sqliteStatus
                )
            }
            throw SQLiteError.invalidBindings(type: "nil", value: nil, SQLiteError: sqliteStatus)
        }
    }
}

extension Int: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger64(Int64(self), to: statement, at: index)
    }
}

extension Int8: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(Int32(self), to: statement, at: index)
    }
}

extension Int16: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(Int32(self), to: statement, at: index)
    }
}

extension Int32: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(self, to: statement, at: index)
    }
}

extension Int64: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger64(self, to: statement, at: index)
    }
}

extension UInt: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger64(Int64(self), to: statement, at: index)
    }
}

extension UInt8: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(Int32(self), to: statement, at: index)
    }
}

extension UInt16: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(Int32(self), to: statement, at: index)
    }
}

extension UInt32: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger32(Int32(self), to: statement, at: index)
    }
}

extension UInt64: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger64(Int64(self), to: statement, at: index)
    }
}

extension Float: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindBinaryFloatingPoint(self, to: statement, at: index)
    }
}

extension Double: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindBinaryFloatingPoint(self, to: statement, at: index)
    }
}

extension CGFloat: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindBinaryFloatingPoint(self, to: statement, at: index)
    }
}

// swiftlint:disable:next legacy_objc_type
extension NSNumber: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        let type = CFNumberGetType(self)
        switch type {
        case .sInt8Type, .sInt16Type, .sInt32Type, .shortType, .charType:
//            if isBoolNumber(num: self) {
//                try bindString(boolValue ? "TRUE" : "FALSE", to: statement, at: index)
//            } else {
            try bindInteger32(Int32(truncating: self), to: statement, at: index)
//            }

        case .longType, .longLongType, .intType, .cfIndexType, .sInt64Type, .nsIntegerType:
            try bindInteger64(Int64(truncating: self), to: statement, at: index)

        case .float32Type, .float64Type, .doubleType, .cgFloatType, .floatType:
            try bindBinaryFloatingPoint(Double(truncating: self), to: statement, at: index)

        default:
            throw SQLiteError.sqliteBindingError("Unknown NSNumber type: \(type).")
        }
    }

    private func isBoolNumber(num: NSNumber) -> Bool {
        let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
        let numID = CFGetTypeID(num) // the type ID of num
        return numID == boolID
    }
}

extension String: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindString(self, to: statement, at: index)
    }
}

// swiftlint:disable:next legacy_objc_type
extension NSString: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindString(self as String, to: statement, at: index)
    }
}

extension NSNull: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindNull(to: statement, at: index)
    }
}

extension Data: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindData(self, to: statement, at: index)
    }
}

extension Bool: Bindable {
    public func bind(statement: OpaquePointer, index: Int32) throws {
        try bindInteger64(Int64(self ? 1 : 0), to: statement, at: index)
    }
}
