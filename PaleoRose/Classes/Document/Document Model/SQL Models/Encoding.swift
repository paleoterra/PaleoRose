//
// Encoding.swift
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

import Foundation

enum Encoding {
    static func encodeTextStorage(from input: NSTextStorage) -> Data {
        let range = NSRange(location: 0, length: input.length)
        let rtfData = input.rtf(from: range)
        if let base64EncodedString = rtfData?.base64EncodedString(), let data = base64EncodedString.data(using: .utf8) {
            return data
        }
        return Data()
    }

//    static func decodeAttributedString(from input: Data) -> NSAttributedString? {
//        guard let base64EncodedString = String(
//            data: input,
//            encoding: .utf8
//        ), let rtfData = base64EncodedString.data(using: .utf8) else {
//            return nil
//        }
//        return NSAttributedString(rtf: rtfData, documentAttributes: nil)
//    }

    static func decodeTextStorage(from input: Data) -> NSTextStorage? {
        guard let base64EncodedString = String(
            data: input,
            encoding: .utf8
        ), let rtfData = base64EncodedString.data(using: .utf8) else {
            return nil
        }
        return NSTextStorage(rtf: rtfData, documentAttributes: nil)
    }
}
