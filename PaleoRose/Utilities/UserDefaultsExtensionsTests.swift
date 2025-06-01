//
//  UserDefaultsExtensionsTests.swift
//  PaleoRose Tests
//
//  Created by Thomas Moore on 5/26/25.
//  Copyright © 2025 PaleoRose. All rights reserved.
//

@testable import PaleoRose
import Testing

@Suite("UserDefaults Extensions Tests")
struct UserDefaultsExtensionsTests {

    @Test("Should store and retrieve integer values")
    func testIntegerStorage() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let value = 42

        // When
        defaults.set(value, forKey: key.rawValue)
        let retrieved = defaults.integer(forKey: key)

        // Then
        #expect(retrieved == value, "Expected \(value), but got \(retrieved)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should store and retrieve boolean values")
    func testBoolStorage() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let value = true

        // When
        defaults.set(value, forKey: key.rawValue)
        let retrieved = defaults.bool(forKey: key)

        // Then
        #expect(retrieved == value, "Expected \(value), but got \(retrieved)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should store and retrieve string values")
    func testStringStorage() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let value = "test string"

        // When
        defaults.set(value, forKey: key.rawValue)
        let retrieved = defaults.string(forKey: key)

        // Then
        #expect(retrieved == value, "Expected \(value), but got \(String(describing: retrieved))")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should store and retrieve URL values")
    func testURLStorage() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let value = try #require(URL(string: "https://example.com"))

        // When
        defaults.set(value, forKey: key.rawValue)
        let retrieved = defaults.url(forKey: key)

        // Then
        #expect(retrieved == value, "Expected \(value), but got \(String(describing: retrieved))")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should handle subscript access with optional values")
    func testSubscriptOptionalAccess() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let value = 42

        // When
        defaults[key] = value
        let retrieved: Int? = defaults[key]

        // Then
        #expect(retrieved == value, "Expected \(value), but got \(String(describing: retrieved))")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }

    @Test("Should handle subscript access with default values")
    func testSubscriptDefaultValue() throws {
        // Given
        let defaults = try #require(UserDefaults(suiteName: #function))
        let key = UserDefaultsKey.vectorCalculationMethod
        let defaultValue = 100

        // When
        let retrieved = defaults[key, default: defaultValue]

        // Then
        #expect(retrieved == defaultValue, "Expected default value \(defaultValue), but got \(retrieved)")

        // Cleanup
        defaults.removePersistentDomain(forName: #function)
    }
}
