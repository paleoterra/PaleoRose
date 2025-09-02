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

extension CGAffineTransform {
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
    static func unitTestTranform(_ transform: TestTransform) -> CGAffineTransform {
        switch transform {
        case .horizontal10Degree:
            CGAffineTransform(
                a: 0.9999999999999999,
                b: 1.2380714832134292e-17,
                c: 1.2380714832134292e-17,
                d: 1.0,
                tx: -6.267424473330696,
                ty: 1.3480775301220795
            )

        case .horizontal75Degree:
            CGAffineTransform(
                a: 1.0,
                b: 1.2253002782949126e-17,
                c: 1.2253002782949126e-17,
                d: 1.0,
                tx: 1.655352012890683,
                ty: -5.911809548974793
            )

        case .horizontal289Degree:
            CGAffineTransform(
                a: 0.9999999999999999,
                b: 4.062288780148174e-18,
                c: 4.062288780148174e-18,
                d: 0.9999999999999999,
                tx: -17.459092005993167,
                ty: -5.244318455428433
            )

        case .horizontal0Degree:
            CGAffineTransform(
                a: 1.0,
                b: 0.0,
                c: 0.0,
                d: 1.0,
                tx: -4.998046874999999,
                ty: 1.5
            )

        case .horizontal180Degree:
            CGAffineTransform(
                a: 1.0,
                b: 0.0,
                c: 0.0,
                d: 1.0,
                tx: -4.333007812499999,
                ty: -18.5
            )

        case .parallel10Degree:
            CGAffineTransform(
                a: 0.17364817766693041,
                b: 0.984807753012208,
                c: -0.984807753012208,
                d: 0.17364817766693041,
                tx: 10.107347677273072,
                ty: 8.37206801995317
            )

        case .parallel75Degree:
            CGAffineTransform(
                a: 0.9659258262890683,
                b: 0.25881904510252074,
                c: -0.25881904510252074,
                d: 0.9659258262890683,
                tx: 11.859220146262109,
                ty: -5.622179072431873
            )

        case .parallel289Degree:
            CGAffineTransform(
                a: 0.945518575599317,
                b: -0.32556815445715626,
                c: 0.32556815445715626,
                d: 0.945518575599317,
                tx: -27.358199142339938,
                ty: 0.4304076244985655
            )

        case .parallel0Degree:
            CGAffineTransform(
                a: 1.0,
                b: 0.0,
                c: 0.0,
                d: 1.0,
                tx: -4.998046875,
                ty: 10.0
            )

        case .parallel180Degree:
            CGAffineTransform(
                a: 1.0,
                b: 0.0,
                c: 0.0,
                d: 1.0,
                tx: -4.3330078125,
                ty: -27.0
            )
        }
    }

    func assertEqual(
        to other: CGAffineTransform,
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
            a.isApproximatelyEqual(to: other.a, absoluteTolerance: defaultTolerance),
            "a mismatch: expected: \(a), actual \(other.a)",
            sourceLocation: sourceLocation
        )
        #expect(
            b.isApproximatelyEqual(to: other.b, absoluteTolerance: defaultTolerance),
            "b mismatch: expected: \(b), actual \(other.b)",
            sourceLocation: sourceLocation
        )
        #expect(
            c.isApproximatelyEqual(to: other.c, absoluteTolerance: defaultTolerance),
            "c mismatch: expected: \(c), actual \(other.c)",
            sourceLocation: sourceLocation
        )
        #expect(
            d.isApproximatelyEqual(to: other.d, absoluteTolerance: defaultTolerance),
            "d mismatch: expected: \(d), actual \(other.d)",
            sourceLocation: sourceLocation
        )
        #expect(
            tx.isApproximatelyEqual(to: other.tx, absoluteTolerance: defaultTolerance),
            "tx mismatch: expected: \(tx), actual \(other.tx)",
            sourceLocation: sourceLocation
        )
        #expect(
            ty.isApproximatelyEqual(to: other.ty, absoluteTolerance: defaultTolerance),
            "ty mismatch: expected: \(ty), actual \(other.ty)",
            sourceLocation: sourceLocation
        )
    }

    func assertEqual(
        to other: CGAffineTransform?,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        guard let other else {
            #expect(Bool(false), "CGAffineTransform is nil", sourceLocation: SourceLocation(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            ))
            return
        }

        assertEqual(to: other, fileID: fileID, filePath: filePath, line: line, column: column)
    }
}
