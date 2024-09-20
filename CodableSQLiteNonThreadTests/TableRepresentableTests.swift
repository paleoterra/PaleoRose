//
// TableRepresentableTests.swift
// Unit Tests
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

import CodableSQLiteNonThread
import Testing

// swiftlint:disable legacy_objc_type no_magic_numbers
@Suite struct TableRepresentableTests {
    struct BindingsExpectation {
        let keys: [String]
        let values: [Any?]
        let testableTable: TestableTable

        init(keys: [String], values: [Any?], testableTable: TestableTable = TestableTable.stub()) {
            self.keys = keys
            self.values = values
            self.testableTable = testableTable
        }
    }

    private func compareBinding(binding: Any?, value: Any?) throws {
        switch (binding, value) {
        case let (binding as NSNumber, value as NSNumber):
            #expect(binding == value)
            return

        case let (binding as String, value as String):
            #expect(binding == value)
            return

        default:
            break
        }

        if binding is NSNull, value == nil {
            #expect(value == nil)
            return
        }

        Issue.record("Binding (\(String(describing: binding)))and value (\(String(describing: value)))are not equal")
    }

    @Test(
        "Given keys for binding, then return array of correct values",
        arguments: [
            BindingsExpectation(
                keys: [],
                values: [],
                testableTable: TestableTable.stub()
            ),
            BindingsExpectation(
                keys: ["intValue"],
                values: [NSNumber(value: 132)],
                testableTable: TestableTable.stub(intValue: 132)
            ),
            BindingsExpectation(
                keys: ["int32Value"],
                values: [NSNumber(value: 132)],
                testableTable: TestableTable.stub(int32Value: 132)
            ),
            BindingsExpectation(
                keys: ["uintValue"],
                values: [NSNumber(value: 132)],
                testableTable: TestableTable.stub(uintValue: 132)
            ),
            BindingsExpectation(
                keys: ["uint32Value"],
                values: [NSNumber(value: 132)],
                testableTable: TestableTable.stub(uint32Value: 132)
            ),
            BindingsExpectation(
                keys: ["int16Value"],
                values: [NSNumber(value: -132)],
                testableTable: TestableTable.stub(int16Value: -132)
            ),
            BindingsExpectation(
                keys: ["uint16Value"],
                values: [NSNumber(value: 132)],
                testableTable: TestableTable.stub(uint16Value: 132)
            ),
            BindingsExpectation(
                keys: ["floatValue"],
                values: [NSNumber(value: 27.2)],
                testableTable: TestableTable.stub(floatValue: 27.2)
            ),
            BindingsExpectation(
                keys: ["doubleValue"],
                values: [NSNumber(value: 27.9)],
                testableTable: TestableTable.stub(doubleValue: 27.9)
            ),
            BindingsExpectation(
                keys: ["cgFloatValue"],
                values: [NSNumber(value: 37.9)],
                testableTable: TestableTable.stub(cgFloatValue: 37.9)
            ),
            BindingsExpectation(
                keys: ["stringValue"],
                values: ["Testing string"],
                testableTable: TestableTable.stub(stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["intValue", "stringValue"],
                values: [17, "Testing string"],
                testableTable: TestableTable.stub(intValue: 17, stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["int32Value", "stringValue"],
                values: [45, "Testing string"],
                testableTable: TestableTable.stub(int32Value: 45, stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["uintValue", "stringValue"],
                values: [44, "Testing string"],
                testableTable: TestableTable.stub(uintValue: 44, stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["uint32Value", "stringValue"],
                values: [65, "Testing string"],
                testableTable: TestableTable.stub(uint32Value: 65, stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["int16Value", "stringValue"],
                values: [8, "Testing string"],
                testableTable: TestableTable.stub(int16Value: 8, stringValue: "Testing string")
            ),
            BindingsExpectation(
                keys: ["optionalString"],
                values: [nil],
                testableTable: TestableTable.stub(optionalString: nil)
            ),
            BindingsExpectation(
                keys: ["optionalString"],
                values: ["Testing string"],
                testableTable: TestableTable.stub(optionalString: "Testing string")
            ),
            BindingsExpectation(
                // swiftlint:disable:next line_length
                keys: ["intValue", "int32Value", "uintValue", "uint32Value", "int16Value", "uint16Value", "floatValue", "doubleValue", "cgFloatValue", "stringValue", "optionalString"],
                values: [17, 45, 44, 65, 8, 16, 32.0, 64.0, 128.0, "Testing string", "Testing string"],
                // swiftlint:disable:next line_length
                testableTable: TestableTable.stub(intValue: 17, int32Value: 45, uintValue: 44, uint32Value: 65, int16Value: 8, uint16Value: 16, floatValue: 32.0, doubleValue: 64.0, cgFloatValue: 128.0, stringValue: "Testing string", optionalString: "Testing string")
            ),
            BindingsExpectation(
                // swiftlint:disable:next line_length
                keys: ["intValue", "int32Value", "uintValue", "uint32Value", "int16Value", "uint16Value", "floatValue", "doubleValue", "cgFloatValue", "stringValue", "optionalString"],
                values: [17, 45, 44, 65, 8, 16, 32.0, 64.0, 128.0, "Testing string", nil],
                // swiftlint:disable:next line_length
                testableTable: TestableTable.stub(intValue: 17, int32Value: 45, uintValue: 44, uint32Value: 65, int16Value: 8, uint16Value: 16, floatValue: 32.0, doubleValue: 64.0, cgFloatValue: 128.0, stringValue: "Testing string", optionalString: nil)
            )
        ]
    )
    func testBindingArrays(bindingExpectations: BindingsExpectation) throws {
        let sut = bindingExpectations.testableTable
        let bindables = try sut.valueBindables(keys: bindingExpectations.keys).compactMap { $0 }
        let expectedValues = bindingExpectations.values
        try #require(bindables.count == expectedValues.count)
        try bindables.compactMap { $0 }.enumerated().forEach { index, bindable in
            try compareBinding(binding: bindable, value: expectedValues[index])
        }
    }

    @Test("Given table name, then create the correct SQL count query")
    func countQuery() throws {
        let query = TestableTable.countQuery()
        #expect(query.sql == "SELECT COUNT(*) FROM TestableTable;")
    }
}

// swiftlint:enable legacy_objc_type no_magic_numbers
