//
//  UserDefaultsKeyTests.swift
//  PaleoRose Tests
//
//  Created by Thomas Moore on 5/26/25.
//  Copyright © 2025 PaleoRose. All rights reserved.
//

@testable import PaleoRose
import Testing

@Suite("UserDefaultsKey Tests")
struct UserDefaultsKeyTests {

    @Test("All keys should have unique raw values")
    func testUniqueRawValues() throws {
        let allKeys = UserDefaultsKey.allCases
        let rawValues = allKeys.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)

        #expect(rawValues.count == uniqueRawValues.count, "Expected \(rawValues.count) unique raw values, but found \(uniqueRawValues.count)")
    }

    @Test("Raw values should not contain spaces or special characters")
    func testRawValueFormat() throws {
        for key in UserDefaultsKey.allCases {
            let rawValue = key.rawValue
            let validCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
            let containsInvalidCharacters = rawValue.unicodeScalars.contains { !validCharacterSet.contains($0) }

            #expect(!containsInvalidCharacters, "Key '\(key)' contains invalid characters in raw value '\(rawValue)'")
        }
    }

    @Test("All keys should have non-empty raw values")
    func testNonEmptyRawValues() throws {
        for key in UserDefaultsKey.allCases {
            #expect(!key.rawValue.isEmpty, "Key '\(key)' has an empty raw value")
        }
    }
}
