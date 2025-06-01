//
// UserDefaults+Extensions.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2025 to present Thomas L. Moore.
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
import SwiftUI
import SwiftUICore

/// Extends UserDefaults with type-safe convenience methods for working with `UserDefaultsKey`.
///
/// This extension provides a more Swifty interface to UserDefaults by adding methods that work
/// with the `UserDefaultsKey` enum instead of raw strings, reducing the chance of typos and
/// making the code more maintainable.
extension UserDefaults {
    // MARK: - Type-Safe Accessors

    /// Returns the integer value associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The integer value associated with the specified key.
    ///            If the specified key doesn't exist, this method returns 0.
    func integer(forKey key: UserDefaultsKey) -> Int {
        integer(forKey: key.rawValue)
    }

    /// Returns the float value associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The float value associated with the specified key.
    ///            If the specified key doesn't exist, this method returns 0.0.
    func float(forKey key: UserDefaultsKey) -> Float {
        float(forKey: key.rawValue)
    }

    /// Returns the double value associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The double value associated with the specified key.
    ///            If the specified key doesn't exist, this method returns 0.0.
    func double(forKey key: UserDefaultsKey) -> Double {
        double(forKey: key.rawValue)
    }

    /// Returns the Boolean value associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The Boolean value associated with the specified key.
    ///            If the specified key doesn't exist, this method returns false.
    func bool(forKey key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    /// Returns the string associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The string associated with the specified key, or `nil` if the key does not exist
    ///            or if the value is not a string.
    func string(forKey key: UserDefaultsKey) -> String? {
        string(forKey: key.rawValue)
    }

    /// Returns the URL associated with the specified key.
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The URL associated with the specified key, or `nil` if the URL does not exist
    ///            or if the value is not a valid URL.
    func url(forKey key: UserDefaultsKey) -> URL? {
        url(forKey: key.rawValue)
    }

    /// Sets the value of the specified default key.
    /// - Parameters:
    ///   - value: The value to store in the defaults database.
    ///   - key: The key with which to associate the value.
    func set(_ value: Any?, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    // MARK: - Type-Safe Subscripts

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// Use this subscript to get and set values from the user's defaults database.
    /// The return type is inferred from the context in which the subscript is used.
    ///
    /// - Parameter key: The key for which to return the corresponding value.
    /// - Returns: The value associated with the specified key, or `nil` if the key does not exist
    ///            or if the value cannot be converted to the expected type.
    subscript<T>(key: UserDefaultsKey) -> T? {
        get { value(forKey: key.rawValue) as? T }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Accesses the value associated with the given key for reading and writing,
    /// with a default value to return if the key doesn't exist.
    ///
    /// - Parameters:
    ///   - key: The key for which to return the corresponding value.
    ///   - default: A closure that returns a default value to use if the key doesn't exist.
    /// - Returns: The value associated with the specified key, or the default value if the key
    ///            doesn't exist or if the value cannot be converted to the expected type.
    subscript<T>(key: UserDefaultsKey, default default: @autoclosure () -> T) -> T {
        get { value(forKey: key.rawValue) as? T ?? `default`() }
        set { set(newValue, forKey: key.rawValue) }
    }
}

// MARK: - KeyPath Convenience

extension EnvironmentValues {
    private struct VectorCalculationMethodKey: EnvironmentKey {
        static let defaultValue = UserDefaults.standard.integer(forKey: .vectorCalculationMethod)
    }

    var vectorCalculationMethod: Int {
        get { self[VectorCalculationMethodKey.self] }
        set { self[VectorCalculationMethodKey.self] = newValue }
    }
}
