//
//  DefaultsStorageTests.swift
//  PaleoRose Tests
//
//  Created by Thomas Moore on 5/26/25.
//  Copyright © 2025 PaleoRose. All rights reserved.
//

@testable import PaleoRose
import Testing

@Suite("DefaultsStorage Tests")
struct DefaultsStorageTests {

    @Test("Should initialize with default value")
    func testInitialization() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = DefaultsKey.vectorCalculationMethod
        let defaultValue = 42

        // When
        let storage = DefaultsStorage(wrappedValue: defaultValue, key, defaults: defaults)

        // Then
        #expect(storage.wrappedValue == defaultValue, "Expected \(defaultValue), but got \(storage.wrappedValue)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should update stored value")
    func testValueUpdate() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = DefaultsKey.vectorCalculationMethod
        let initialValue = 42
        let newValue = 100
        let storage = DefaultsStorage(wrappedValue: initialValue, key, defaults: defaults)

        // When
        storage.wrappedValue = newValue

        // Force UserDefaults to save changes
        defaults.synchronize()

        // Then
        let storedValue = defaults.integer(forKey: key.rawValue)
        #expect(storedValue == newValue, "UserDefaults value should be updated to \(newValue), but got \(storedValue)")
        #expect(storage.wrappedValue == newValue, "Expected \(newValue), but got \(storage.wrappedValue)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should use existing value from UserDefaults")
    func testExistingValue() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = DefaultsKey.vectorCalculationMethod
        let existingValue = 100
        let defaultValue = 42

        // Store value in UserDefaults
        defaults.set(existingValue, forKey: key.rawValue)
        defaults.synchronize() // Ensure value is written before DefaultsStorage initialization

        // When
        let storage = DefaultsStorage(wrappedValue: defaultValue, key, defaults: defaults)

        // Then
        #expect(storage.wrappedValue == existingValue, "Should use existing value \(existingValue) instead of default \(defaultValue)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should support binding through projected value")
    func testBinding() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = DefaultsKey.vectorCalculationMethod
        let initialValue = 42
        let newValue = 100
        let storage = DefaultsStorage(wrappedValue: initialValue, key, defaults: defaults)

        // When
        storage.projectedValue.wrappedValue = newValue

        // Force UserDefaults to save changes
        defaults.synchronize()

        // Then
        let storedValue = defaults.integer(forKey: key.rawValue)
        #expect(storedValue == newValue, "UserDefaults should be updated through binding to \(newValue), but got \(storedValue)")
        #expect(storage.wrappedValue == newValue, "Value should be updated through binding to \(newValue)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should handle different value types")
    func testValueTypes() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = DefaultsKey.vectorCalculationMethod

        // Test String
        let stringStorage = DefaultsStorage<String>(wrappedValue: "default", key, defaults: defaults)
        stringStorage.wrappedValue = "test"
        defaults.synchronize()
        #expect(defaults.string(forKey: key.rawValue) == "test", "String not stored in UserDefaults")
        #expect(stringStorage.wrappedValue == "test", "String storage failed")

        // Test Bool
        let boolStorage = DefaultsStorage<Bool>(wrappedValue: false, key, defaults: defaults)
        boolStorage.wrappedValue = true
        defaults.synchronize()
        #expect(defaults.bool(forKey: key.rawValue) == true, "Bool not stored in UserDefaults")
        #expect(boolStorage.wrappedValue == true, "Bool storage failed")

        // Test Double
        let doubleStorage = DefaultsStorage<Double>(wrappedValue: 0.0, key, defaults: defaults)
        doubleStorage.wrappedValue = 3.14
        defaults.synchronize()
        #expect(abs(defaults.double(forKey: key.rawValue) - 3.14) < 0.001, "Double not stored in UserDefaults")
        #expect(doubleStorage.wrappedValue == 3.14, "Double storage failed")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }
}
