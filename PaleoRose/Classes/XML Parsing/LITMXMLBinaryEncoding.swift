// LITMXMLBinaryEncoding.swift
//
// MIT License
//
// Copyright (c) 2003 to present Thomas L. Moore.
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

@objc class LITMXMLBinaryEncoding: NSObject {
    private static let base16Chars = Array("0123456789abcdef")
    private static let base64Chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

    @objc static func encodeBase16(_ data: Data) -> String {
        var result = ""
        let bytes = [UInt8](data)

        for byte in bytes {
            let high = Int(byte >> 4)
            let low = Int(byte & 0x0F)
            result.append(base16Chars[high])
            result.append(base16Chars[low])
        }

        // Format into 80-character lines
        let chars = Array(result)
        var finalResult = ""
        let lineLength = 80
        var index = 0

        while index < chars.count {
            let endIndex = min(index + lineLength, chars.count)
            let line = String(chars[index ..< endIndex])
            finalResult += line
            if endIndex < chars.count {
                finalResult += "\n"
            }
            index = endIndex
        }

        return finalResult
    }

    @objc static func decodeBase16(_ string: String) -> Data? {
        let cleanString = string.components(separatedBy: .whitespacesAndNewlines).joined()
        guard cleanString.count % 2 == 0 else { return nil }

        var bytes = [UInt8]()
        var index = cleanString.startIndex

        while index < cleanString.endIndex {
            let nextIndex = cleanString.index(index, offsetBy: 2)
            let byteString = cleanString[index ..< nextIndex]

            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            bytes.append(byte)

            index = nextIndex
        }

        return Data(bytes)
    }

    @objc static func encodeBase64(_ data: Data) -> String? {
        guard !data.isEmpty else { return nil }

        var bytes = [UInt8](data)
        let padding = bytes.count % 3
        let paddingCount = padding > 0 ? 3 - padding : 0

        // Add padding bytes if needed
        if paddingCount > 0 {
            bytes.append(contentsOf: Array(repeating: 0, count: paddingCount))
        }

        var encoded = ""
        var index = 0

        while index + 2 < bytes.count {
            let byte1 = bytes[index]
            let byte2 = bytes[index + 1]
            let byte3 = bytes[index + 2]

            let char1 = base64Chars[Int(byte1 >> 2)]
            let char2 = base64Chars[Int(((byte1 & 0x03) << 4) | (byte2 >> 4))]
            let char3 = base64Chars[Int(((byte2 & 0x0F) << 2) | (byte3 >> 6))]
            let char4 = base64Chars[Int(byte3 & 0x3F)]

            encoded.append(char1)
            encoded.append(char2)
            encoded.append(char3)
            encoded.append(char4)

            index += 3
        }

        if paddingCount > 0 {
            encoded.removeLast(paddingCount)
            encoded.append(String(repeating: "=", count: paddingCount))
        }

        // Format into 76-character lines as per RFC 2045
        let chars = Array(encoded)
        var finalResult = ""
        let lineLength = 76
        index = 0

        while index < chars.count {
            let endIndex = min(index + lineLength, chars.count)
            let line = String(chars[index ..< endIndex])
            finalResult += line
            if endIndex < chars.count {
                finalResult += "\n"
            }
            index = endIndex
        }

        return finalResult
    }

    @objc static func decodeBase64(_ string: String) -> Data? {
        decodeBase64(string, encoding: String.Encoding.ascii.rawValue)
    }

    @objc static func decodeBase64(withEncoding string: String, encoding: UInt) -> Data? {
        let cleanString = string.components(separatedBy: .whitespacesAndNewlines).joined()
        guard !cleanString.isEmpty else { return nil }

        let paddingLength = cleanString.filter { $0 == "=" }.count
        guard paddingLength <= 2 else { return nil }

        let base64 = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")
        var bytes = [UInt8]()
        var index = cleanString.startIndex

        while index < cleanString.endIndex {
            var chunk = ""
            for _ in 0 ..< 4 where index < cleanString.endIndex {
                chunk.append(cleanString[index])
                index = cleanString.index(after: index)
            }

            guard chunk.count == 4 else { return nil }

            var values = [UInt8](repeating: 0, count: 4)
            for (index, char) in chunk.enumerated() {
                if char == "=" {
                    values[index] = 0
                } else if let value = base64.firstIndex(of: char) {
                    values[index] = UInt8(value)
                } else {
                    return nil
                }
            }

            let byte1 = (values[0] << 2) | (values[1] >> 4)
            let byte2 = ((values[1] & 0x0F) << 4) | (values[2] >> 2)
            let byte3 = ((values[2] & 0x03) << 6) | values[3]

            bytes.append(byte1)
            if chunk[chunk.index(chunk.startIndex, offsetBy: 2)] != "=" {
                bytes.append(byte2)
            }
            if chunk[chunk.index(chunk.startIndex, offsetBy: 3)] != "=" {
                bytes.append(byte3)
            }
        }

        return Data(bytes)
    }
}
