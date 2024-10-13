//
// TableRepresentable.swift
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

/// A type must conform to this protocol in order to work with Codable decoding from Sqlite
public protocol TableRepresentable: Codable {
    static var tableName: String { get }
    static var primaryKey: String? { get }

    static func createTableQuery() -> QueryProtocol
    static func insertQuery() -> QueryProtocol
    static func updateQuery() -> QueryProtocol
    static func deleteQuery() -> QueryProtocol
    static func countQuery() -> QueryProtocol
    static func storedValues() -> QueryProtocol

    func valueBindables(keys: [String]) throws -> [Bindable?]
}

// swiftlint:disable:next no_extension_access_modifier
public extension TableRepresentable {
    /// Returns a query design to count items in a table
    static func countQuery() -> QueryProtocol {
        Query(sql: "SELECT COUNT(*) FROM \(tableName);")
    }

    /// Returns a rows in a table
    static func storedValues() -> QueryProtocol {
        Query(sql: "SELECT * FROM \(tableName);")
    }

    /// Assign keys to create bindings
    func valueBindables(keys: [String] = []) throws -> [Bindable?] {
        try bindingArray(keys: keys)
    }

    private func dictionaryRepresentation() throws -> [String: Any?] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return json ?? [:]
    }

    private func bindingArray(keys: [String]) throws -> [Bindable?] {
        let keyValues = try dictionaryRepresentation()
        var bindables: [Bindable?] = []
        for key in keys {
            if let value = keyValues[key] as? Bindable {
                if isData(key: key) {
                    bindables.append(bindingValueForDataColumn(key: key, value: value))
                } else {
                    bindables.append(value)
                }
            } else {
                bindables.append(nil)
            }
        }
        return bindables
    }

    private func bindingValueForDataColumn(key: String, value: Bindable?) -> Bindable? {
        if let value = value as? Data {
            return value
        }
        if let value = value as? String,
           let data = value.data(using: .utf8),
           let decoded = Data(base64Encoded: data)
        {
            return decoded
        }
        return nil
    }

    private func isData(key: String) -> Bool {
        for property in Mirror(reflecting: self).children {
            if property.value is Data, property.label == key {
                return true
            }
        }
        return false
    }
}
