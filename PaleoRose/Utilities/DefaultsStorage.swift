//
//  DefaultsStorage.swift
//  PaleoRose
//
//  MIT License
//
//  Copyright (c) 2025 to present Thomas L. Moore.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  DefaultsStorage.swift
//  PaleoRose
//
//  Created by Thomas Moore on 5/26/25.
//  Copyright 2025 PaleoRose. All rights reserved.
//

import Foundation
import SwiftUI

/// Enum defining all UserDefaults keys used in the application
public enum DefaultsKey: String, CaseIterable {
    /// The method used for vector calculation
    case vectorCalculationMethod

    // Add more cases here as needed
}

/// A property wrapper that provides type-safe access to UserDefaults with support for SwiftUI bindings.
@propertyWrapper
public struct DefaultsStorage<Value>: DynamicProperty {
    // MARK: - Properties

    private let key: DefaultsKey
    private let defaultValue: Value
    private let defaults: UserDefaults

    // SwiftUI state to trigger UI updates
    @ObservedObject private var notifier = DefaultsChangeNotifier()

    // MARK: - Initialization

    /// Creates a new `DefaultsStorage` instance with the specified key and default value.
    /// - Parameters:
    ///   - key: The enum key identifying the UserDefaults value
    ///   - defaultValue: The default value to use if no value exists in UserDefaults
    ///   - defaults: The UserDefaults instance to use (defaults to .standard)
    public init(_ key: DefaultsKey, defaultValue: Value, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults

        // Save default value to UserDefaults if it doesn't exist
        if defaults.object(forKey: key.rawValue) == nil {
            defaults.set(defaultValue, forKey: key.rawValue)
            defaults.synchronize()
        }
    }

    /// Creates a new `DefaultsStorage` instance using the property wrapper syntax.
    /// - Parameters:
    ///   - wrappedValue: The default value
    ///   - key: The enum key
    ///   - defaults: The UserDefaults instance
    public init(wrappedValue: Value, _ key: DefaultsKey, defaults: UserDefaults = .standard) {
        self.init(key, defaultValue: wrappedValue, defaults: defaults)
    }

    // MARK: - Property Wrapper

    public var wrappedValue: Value {
        get {
            // Get the current value from UserDefaults
            defaults.object(forKey: key.rawValue) as? Value ?? defaultValue
        }
        nonmutating set {
            // Write the new value to UserDefaults
            defaults.set(newValue, forKey: key.rawValue)
            defaults.synchronize()

            // Notify SwiftUI that the value changed
            notifier.objectWillChange.send()
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                // Write directly to UserDefaults
                defaults.set(newValue, forKey: key.rawValue)
                defaults.synchronize()

                // Notify SwiftUI that the value changed
                notifier.objectWillChange.send()
            }
        )
    }

    // MARK: - DynamicProperty

    public mutating func update() {
        // We rely on the @ObservedObject to trigger updates
    }
}

// MARK: - SwiftUI Support

/// Helper class that notifies SwiftUI when values change
private class DefaultsChangeNotifier: ObservableObject {}

// MARK: - Testing Support

// Make these methods accessible only in test code
extension DefaultsStorage {
    /// Helper for testing - directly accesses UserDefaults
    func test_setValue(_ newValue: Value) {
        // Write directly to UserDefaults
        defaults.set(newValue, forKey: key.rawValue)
        defaults.synchronize()
        notifier.objectWillChange.send()
    }

    /// Helper for testing - directly reads from UserDefaults
    // swiftlint:disable:next identifier_name
    var _testValue: Value { wrappedValue }
}
