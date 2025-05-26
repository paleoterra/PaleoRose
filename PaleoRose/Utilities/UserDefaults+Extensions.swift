//
// UserDefaultsKey.swift
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
import SwiftUICore

extension UserDefaults {
    // Convenience methods for common types

    func integer(forKey key: UserDefaultsKey) -> Int {
        integer(forKey: key.rawValue)
    }

    func float(forKey key: UserDefaultsKey) -> Float {
        float(forKey: key.rawValue)
    }

    func double(forKey key: UserDefaultsKey) -> Double {
        double(forKey: key.rawValue)
    }

    func bool(forKey key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func string(forKey key: UserDefaultsKey) -> String? {
        string(forKey: key.rawValue)
    }

    func url(forKey key: UserDefaultsKey) -> URL? {
        url(forKey: key.rawValue)
    }

    func set(_ value: Any?, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    /// Type-safe getter/setter for UserDefaults
    subscript<T>(key: UserDefaultsKey) -> T? {
        get { value(forKey: key.rawValue) as? T }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Type-safe getter/setter with default value
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
