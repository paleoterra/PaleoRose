//
// SQLiteErrorTest.swift
// PaleoRose
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
import SQLite3
import Testing

struct SQLiteErrorTest {
    struct ErrorContainer {
        let leftError: SQLiteError
        let rightError: SQLiteError
    }

    struct SingleError {
        let error: SQLiteError
    }

    @Test(
        "Given two equal errors, then they are equal",
        arguments: [
            ErrorContainer(leftError: .dataNotFound, rightError: .dataNotFound),
            .init(leftError: .decodeFailure, rightError: .decodeFailure),
            .init(leftError: .failedToOpen, rightError: .failedToOpen),
            .init(leftError: .fileNotFound, rightError: .fileNotFound),
            .init(leftError: .invalidFile, rightError: .invalidFile),
            .init(leftError: .invalidStatement, rightError: .invalidStatement),
            .init(leftError: .sqliteBindingError("test"), rightError: .sqliteBindingError("test")),
            .init(
                leftError: .sqliteError(
                    result: 3,
                    message: "test"
                ),
                rightError: .sqliteError(
                    result: 3,
                    message: "test"
                )
            ),
            .init(leftError: .sqliteStatementError("test"), rightError: .sqliteStatementError("test")),
            .init(leftError: .unknownSqliteError("test"), rightError: .unknownSqliteError("test")),
            .init(
                leftError: .invalidBindings(
                    type: "cheese",
                    value: 32,
                    SQLiteError: 321
                ),
                rightError: .invalidBindings(
                    type: "cheese",
                    value: 32,
                    SQLiteError: 321
                )
            )
        ]
    )
    func testEquality(values: ErrorContainer) {
        #expect(values.leftError == values.rightError)
    }

    @Test(
        "Given two unqual errors, then they are not equal",
        arguments:
        [
            SingleError(error: .dataNotFound),
            SingleError(error: .decodeFailure),
            SingleError(error: .failedToOpen),
            SingleError(error: .invalidBindings(
                type: "MyType1",
                value: 32,
                SQLiteError: 2
            )),
            SingleError(error: .sqliteBindingError("test")),
            SingleError(error: .sqliteError(result: 3, message: "test")),
            SingleError(error: .sqliteStatementError("test")),
            SingleError(error: .unknownSqliteError("test"))
        ],

        [
            SingleError(error: .fileNotFound),
            SingleError(error: .invalidFile),
            SingleError(error: .invalidStatement),
            SingleError(error: .invalidBindings(
                type: "MyType2",
                value: 32,
                SQLiteError: 2
            )),
            SingleError(error: .sqliteBindingError("test1")),
            SingleError(error: .sqliteError(result: 3, message: "test1")),
            SingleError(error: .sqliteStatementError("test1")),
            SingleError(error: .unknownSqliteError("test1"))
        ]
    )
    func testInequality(lhs: SingleError, rhs: SingleError) {
        #expect(lhs.error != rhs.error)
    }

    @Test(
        "Given sqlite valid status, then do not throw",
        arguments: [SQLITE_OK, SQLITE_DONE, SQLITE_ROW]
    )
    func testValidSqliteStatus(result: Int32) throws {
        #expect(throws: Never.self) {
            try SQLiteError.checkSqliteStatus(result)
        }
    }

    @Test(
        "Given sqlite valid status, then do not throw",
        arguments: [SQLITE_MISUSE, SQLITE_ERROR, SQLITE_IOERR]
    )
    func testSqliteStatus(result: Int32) throws {
        #expect(throws: SQLiteError.self) {
            try SQLiteError.checkSqliteStatus(result)
        }
    }
}
