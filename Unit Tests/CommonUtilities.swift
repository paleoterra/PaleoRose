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

    static func assertEqualColors(lhs: NSColor, rhs: NSColor) throws -> Bool {
        guard let lhsComponents = lhs.cgColor.components, let rhsComponents = rhs.cgColor.components else {
            throw CommonUtilityError.invalidColor
        }
        let lhsStrings = CommonUtilities.convertComponentsToString(lhsComponents)
        let rhsStrings = CommonUtilities.convertComponentsToString(rhsComponents)
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
}
