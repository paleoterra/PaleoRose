//
// CommonUtilities.swift
// Unit Tests
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

import Cocoa
@testable import PaleoRose
import Testing

enum CommonUtilities {
    enum CommonUtilityError: Error {
        case invalidColor
    }

    static func assertEqualColors(
        lhs: NSColor,
        rhs: NSColor,
    ) throws -> Bool {
        guard let lhsComponents = lhs.cgColor.components, let rhsComponents = rhs.cgColor.components else {
            throw CommonUtilityError.invalidColor
        }
        let lhsStrings = Self.convertComponentsToString(lhsComponents)
        let rhsStrings = Self.convertComponentsToString(rhsComponents)
        print(lhsStrings)
        print(rhsStrings)
        print(lhsStrings == rhsStrings)
        return lhsStrings == rhsStrings
    }

    private static func convertComponentsToString(_ components: [CGFloat], precision: Int = 6) -> [String] {
        var strings = [String]()
        for component in components {
            let stringComponent = String(format: "%.\(precision)f", component)
            strings.append(stringComponent)
        }
        if strings.count == 2 {
            let value = strings[0]
            strings.insert(value, at: 1)
            strings.insert(value, at: 1)
        }
        return strings
    }

    // swiftlint:disable:next function_default_parameter_at_end function_parameter_count
    static func assertXRLayerHasCorrectValues(
        layer: XRLayer,
        isVisible: Bool = true,
        isActive: Bool = true,
        isBiDirectional: Bool = true,
        name: String,
        lineWeight: Float,
        maxCount: Int,
        maxPercent: Float,
        strokeColor: NSColor,
        fillColor: NSColor
    ) throws {
        #expect(layer.isVisible() == isVisible)
        #expect(layer.isActive() == isActive)
        #expect(layer.isBiDirectional() == isBiDirectional)
        #expect(layer.layerName() == name)
        #expect(layer.lineWeight() == lineWeight)
        #expect(layer.maxCount() == Int32(maxCount))
        #expect(layer.maxPercent() == maxPercent)
        #expect(try assertEqualColors(lhs: layer.strokeColor(), rhs: strokeColor))
        #expect(try assertEqualColors(lhs: layer.fillColor(), rhs: fillColor))
    }

    static func verifyEqualColorsWithAlpha(
        lhs: NSColor,
        rhs: NSColor,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    )
        throws
    {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        try verifyEqualColors(lhs: lhs, rhs: rhs, componentCount: 4, sourceLocation: sourceLocation)
    }

    static func verifyEqualColorsWithOutAlpha(
        lhs: NSColor,
        rhs: NSColor,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    )
        throws
    {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        try verifyEqualColors(lhs: lhs, rhs: rhs, componentCount: 3, sourceLocation: sourceLocation)
    }

    private static func verifyEqualColors(lhs: NSColor, rhs: NSColor, componentCount: Int, sourceLocation: SourceLocation) throws {
        let colorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let lhsCG = try #require(lhs.cgColor.converted(
            to: colorSpace,
            intent: .defaultIntent,
            options: nil
        ))
        let rhsCG = try #require(rhs.cgColor.converted(
            to: colorSpace,
            intent: .defaultIntent,
            options: nil
        ))
        let components1 = try #require(lhsCG.components)
        let components2 = try #require(rhsCG.components)
        let colorMatches = zip(
            components1.prefix(componentCount),
            components2.prefix(componentCount)
        ).allSatisfy { lhs, rhs in
            lhs.isApproximatelyEqual(to: rhs, absoluteTolerance: 0.01)
        }
        #expect(colorMatches, "Color doesn't match expected color: \(lhs.description), \(rhs.description)", sourceLocation: sourceLocation)
    }

    static func compareGraphicSettings(
        values: [AnyHashable: Any],
        expected: [AnyHashable: Any],
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) throws {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        let sortedValueKeys = values.keys.compactMap { $0 as? String }.sorted()
        let sortedExpectationKeys = expected.keys.compactMap { $0 as? String }.sorted()
        #expect(
            sortedValueKeys == sortedExpectationKeys,
            "Settings should have the same keys",
            sourceLocation: sourceLocation
        )

        let valuesStrings = values.filter { $0.value is String } as? [String: String] ?? [:]
        let valuesColors = values.filter { $0.value is NSColor } as? [String: NSColor] ?? [:]

        let expectedStrings = expected.filter { $0.value is String } as? [String: String] ?? [:]
        let expectedColors = expected.filter { $0.value is NSColor } as? [String: NSColor] ?? [:]

        for key in valuesStrings.keys {
            #expect(
                valuesStrings[key] == expectedStrings[key],
                "String values for key \(key) do not match \(String(describing: valuesStrings[key])) \(String(describing: expectedStrings[key]))",
                sourceLocation: sourceLocation
            )
        }

        for key in valuesColors.keys {
            let valueColor = try #require(valuesColors[key])
            let expectedColor = try #require(expectedColors[key])
            try Self.verifyEqualColorsWithAlpha(
                lhs: valueColor,
                rhs: expectedColor,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
        }
    }
}
