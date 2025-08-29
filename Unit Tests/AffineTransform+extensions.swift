//
// AffineTransform+extensions.swift
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

import AppKit
import Numerics
import Testing

extension AffineTransform {
    enum TestTransform {
        case horizontal10Degree
        case horizontal75Degree
        case horizontal289Degree
        case horizontal0Degree
        case horizontal180Degree

        case parallel10Degree
        case parallel75Degree
        case parallel289Degree
        case parallel0Degree
        case parallel180Degree
    }

    // swiftlint:disable:next function_body_length
    static func unitTestTranform(_ transform: TestTransform) -> AffineTransform {
        switch transform {
        case .horizontal10Degree:
            .init(
                m11: 0.9999999999999999,
                m12: 1.2380714832134292e-17,
                m21: 1.2380714832134292e-17,
                m22: 1.0,
                tX: -6.267424473330696,
                tY: 1.3480775301220795
            )

        case .horizontal75Degree:
            .init(
                m11: 1.0,
                m12: 1.2253002782949126e-17,
                m21: 1.2253002782949126e-17,
                m22: 1.0,
                tX: 1.655352012890683,
                tY: -5.911809548974793
            )

        case .horizontal289Degree:
            .init(
                m11: 0.9999999999999999,
                m12: 4.062288780148174e-18,
                m21: 4.062288780148174e-18,
                m22: 0.9999999999999999,
                tX: -17.459092005993167,
                tY: -5.244318455428433
            )

        case .horizontal0Degree:
            .init(
                m11: 1.0,
                m12: 0.0,
                m21: 0.0,
                m22: 1.0,
                tX: -4.998046874999999,
                tY: 1.5
            )

        case .horizontal180Degree:
            .init(
                m11: 1.0,
                m12: 0.0,
                m21: 0.0,
                m22: 1.0,
                tX: -4.333007812499999,
                tY: -18.5
            )

        case .parallel10Degree:
            .init(
                m11: 0.17364817766693041,
                m12: 0.984807753012208,
                m21: -0.984807753012208,
                m22: 0.17364817766693041,
                tX: 10.107347677273072,
                tY: 8.37206801995317
            )

        case .parallel75Degree:
            .init(
                m11: 0.9659258262890683,
                m12: 0.25881904510252074,
                m21: -0.25881904510252074,
                m22: 0.9659258262890683,
                tX: 11.859220146262109,
                tY: -5.622179072431873
            )

        case .parallel289Degree:
            .init(
                m11: 0.945518575599317,
                m12: -0.32556815445715626,
                m21: 0.32556815445715626,
                m22: 0.945518575599317,
                tX: -27.358199142339938,
                tY: 0.4304076244985655
            )

        case .parallel0Degree:
            .init(
                m11: 1.0,
                m12: 0.0,
                m21: 0.0,
                m22: 1.0,
                tX: -4.998046875,
                tY: 10.0
            )

        case .parallel180Degree:
            .init(
                m11: 1.0,
                m12: 0.0,
                m21: 0.0,
                m22: 1.0,
                tX: -4.3330078125,
                tY: -27.0
            )
        }
    }

    func assertEqual(
        to other: AffineTransform,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let defaultTolerance: CGFloat = 0.1
        let sourceLocation = SourceLocation(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        #expect(
            m11.isApproximatelyEqual(to: other.m11, absoluteTolerance: defaultTolerance),
            "m11 mismatch: expected: \(m11), actual \(other.m11)",
            sourceLocation: sourceLocation
        )
        #expect(
            m12.isApproximatelyEqual(to: other.m12, absoluteTolerance: defaultTolerance),
            "m12 mismatch: expected: \(m12), actual \(other.m12)",
            sourceLocation: sourceLocation
        )
        #expect(
            m21.isApproximatelyEqual(to: other.m21, absoluteTolerance: defaultTolerance),
            "m21 mismatch: expected: \(m21), actual \(other.m21)",
            sourceLocation: sourceLocation
        )
        #expect(
            m22.isApproximatelyEqual(to: other.m22, absoluteTolerance: defaultTolerance),
            "m22 mismatch: expected: \(m22), actual \(other.m22)",
            sourceLocation: sourceLocation
        )
        #expect(
            tX.isApproximatelyEqual(to: other.tX, absoluteTolerance: defaultTolerance),
            "tX mismatch: expected: \(tX), actual \(other.tX)",
            sourceLocation: sourceLocation
        )
        #expect(
            tY.isApproximatelyEqual(to: other.tY, absoluteTolerance: defaultTolerance),
            "tY mismatch: expected: \(tY), actual \(other.tY)",
            sourceLocation: sourceLocation
        )
    }

    func assertEqual(
        to other: NSAffineTransform?,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        guard let other else {
            #expect(Bool(false), "NSAffineTransform is nil", sourceLocation: SourceLocation(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            ))
            return
        }

        // Convert NSAffineTransform to AffineTransform
        let transform = other.transformStruct
        let otherAffine = AffineTransform(
            m11: transform.m11,
            m12: transform.m12,
            m21: transform.m21,
            m22: transform.m22,
            tX: transform.tX,
            tY: transform.tY
        )

        assertEqual(to: otherAffine, fileID: fileID, filePath: filePath, line: line, column: column)
    }
}
