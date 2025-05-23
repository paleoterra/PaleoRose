//
// XRLayerText+Stub.swift
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

import PaleoRose
import Testing

extension XRLayerText {

    static func stub(
        isVisible: Bool = false,
        active: Bool = false,
        biDir: Bool = false,
        name: String = "XRLayerText",
        lineWeight: Float = 0.0,
        maxCount: Int = 0,
        maxPercent: Float = 0.0,
        stroke: NSColor = .black,
        fill: NSColor = .white,
        contentString: String = "Text Content",
        rect: CGRect = CGRect(x: 1, y: 2, width: 3, height: 4)
    ) -> XRLayerText {
        XRLayerText(
            isVisible: isVisible,
            active: active,
            biDir: biDir,
            name: name,
            lineWeight: lineWeight,
            maxCount: Int32(maxCount),
            maxPercent: maxPercent,
            stroke: stroke,
            fill: fill,
            contents: NSTextStorage(string: contentString),
            rectOriginX: Float(rect.origin.x),
            rectOriginY: Float(rect.origin.y),
            rectHeight: Float(rect.size.width),
            rectWidth: Float(rect.size.height)
        )
    }

    // swiftlint:disable:next function_parameter_count
    func verify(
        isVisible: Bool,
        active: Bool,
        biDir: Bool,
        name: String,
        lineWeight: Float,
        maxCount: Int,
        maxPercent: Float,
        stroke: NSColor,
        fill: NSColor,
        contentString: String,
        rect: CGRect,
        fileId: String = #file,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let sourceLocation = SourceLocation(fileID: fileId, filePath: filePath, line: line, column: column)

        #expect(self.isVisible() == isVisible, sourceLocation: sourceLocation)
        #expect(isActive() == active, sourceLocation: sourceLocation)
        #expect(isBiDirectional() == biDir, sourceLocation: sourceLocation)
        #expect(layerName() == name, sourceLocation: sourceLocation)
        #expect(self.lineWeight() == lineWeight, sourceLocation: sourceLocation)
        #expect(self.maxCount() == maxCount, sourceLocation: sourceLocation)
        #expect(self.maxPercent() == maxPercent, sourceLocation: sourceLocation)
        #expect(strokeColor() == stroke, sourceLocation: sourceLocation)
        #expect(fillColor() == fill, sourceLocation: sourceLocation)
        #expect(contents().string == contentString, sourceLocation: sourceLocation)
        #expect(textRect() == rect, sourceLocation: sourceLocation)
    }
}
