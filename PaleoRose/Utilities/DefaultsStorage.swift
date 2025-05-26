//
// DefaultsStorage.swift
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

/// A property wrapper that provides type-safe access to UserDefaults with support for SwiftUI bindings.
///
/// Usage:
/// ```
/// @DefaultsStorage(.someKey, defaultValue: 0) private var someValue: Int
/// ```
///
/// - Note: This property wrapper automatically persists values to UserDefaults and updates the view
///   when the value changes.
@propertyWrapper
public struct DefaultsStorage<Value>: DynamicProperty {
    // MARK: - Properties

    /// The current value stored in UserDefaults, or the default value if none exists.
    @State private var value: Value

    /// The key used to store the value in UserDefaults.
    private let key: UserDefaultsKey

    /// The default value to use when no value is found in UserDefaults.
    private let defaultValue: Value

    // MARK: - Property Wrapper Requirements

    /// The underlying value referenced by the property wrapper.
    ///
    /// The wrapped value provides direct access to the stored value and automatically
    /// persists changes to UserDefaults.
    public var wrappedValue: Value {
        get {
            value
        }
        nonmutating set {
            value = newValue
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }

    // MARK: - Projected Value

    /// A binding to the value that can be used with SwiftUI controls.
    ///
    /// Use the projected value to create a two-way binding to the stored value.
    /// For example:
    /// ```
    /// Toggle("Enabled", isOn: $isEnabled)
    /// ```
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    // MARK: - Initialization

    /// Creates a property that can read and write to UserDefaults.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value to use if no value is found in UserDefaults.
    ///   - key: The key to use to store the value in UserDefaults.
    public init(wrappedValue: Value, _ key: UserDefaultsKey) {
        self.key = key
        self.defaultValue = wrappedValue

        // Initialize _value with the current value from UserDefaults
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Value {
            _value = State(initialValue: value)
        } else {
            _value = State(initialValue: wrappedValue)
        }
    }

    /// Creates a property that can read and write to UserDefaults.
    ///
    /// This initializer provides an alternative syntax for creating a `DefaultsStorage`
    /// property by taking the key as the first parameter and the default value as a
    /// separate parameter.
    ///
    /// - Parameters:
    ///   - key: The key to use to store the value in UserDefaults.
    ///   - defaultValue: The default value to use if no value is found in UserDefaults.
    ///
    /// ## Example:
    /// ```swift
    /// @DefaultsStorage(.vectorCalculationMethod, defaultValue: 0)
    /// private var vectorCalcMethod: Int
    /// ```
    public init(_ key: UserDefaultsKey, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue

        // Initialize _value with the current value from UserDefaults if it exists,
        // otherwise use the provided default value
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Value {
            _value = State(initialValue: value)
        } else {
            _value = State(initialValue: defaultValue)
        }
    }

    // MARK: - DynamicProperty Conformance

    /// Updates the stored value from UserDefaults.
    ///
    /// This method is called automatically by SwiftUI as part of the view update process.
    /// It ensures that the stored value is in sync with the current value in UserDefaults.
    ///
    /// - Important: This method is part of the `DynamicProperty` protocol conformance and
    ///   is automatically called by SwiftUI. You should not call this method directly.
    ///
    /// - Note: If the value in UserDefaults has been changed by another part of the app
    ///   (e.g., through direct UserDefaults access), this method will update the local
    ///   `@State` value to reflect that change, triggering a view update if needed.
    public func update() {
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Value {
            self.value = value
        } else {
            self.value = defaultValue
        }
    }
}

// MARK: - Example Usage

/*
// In your view:
struct SettingsView: View {
    @DefaultsStorage(\.vectorCalculationMethod) private var vectorCalcMethod = 0

    var body: some View {
        Picker("Vector Calculation Method", selection: $vectorCalcMethod) {
            Text("Vector-Doubling").tag(0)
            Text("Standard").tag(1)
        }
    }
}

// In your AppKit code:
let method = UserDefaults.standard.integer(forKey: .vectorCalculationMethod)
UserDefaults.standard.set(1, forKey: .vectorCalculationMethod)
*/
