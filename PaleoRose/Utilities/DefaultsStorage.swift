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

/// Property wrapper for using UserDefaultsKey with @AppStorage
@propertyWrapper
struct DefaultsStorage<Value>: DynamicProperty {
    @State private var value: Value
    private let key: UserDefaultsKey
    private let defaultValue: Value

    var wrappedValue: Value {
        get {
            value
        }
        nonmutating set {
            value = newValue
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey) {
        self.key = key
        self.defaultValue = wrappedValue

        // Initialize _value with the current value from UserDefaults
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Value {
            _value = State(initialValue: value)
        } else {
            _value = State(initialValue: wrappedValue)
        }
    }

    init(_ key: UserDefaultsKey, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue

        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Value {
            _value = State(initialValue: value)
        } else {
            _value = State(initialValue: defaultValue)
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
