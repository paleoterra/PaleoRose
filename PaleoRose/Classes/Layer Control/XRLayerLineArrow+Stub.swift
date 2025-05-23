//
// XRLayerLineArrow+Stub.swift
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

import PaleoRose
import Testing

extension XRLayerLineArrow {
    static func stub(
        isVisible: Bool = false,
        active: Bool = false,
        biDir: Bool = false,
        name: String = "XRLayerLineArrow",
        lineWeight: Float = 0.0,
        maxCount: Int = 0,
        maxPercent: Float = 0.0,
        stroke: NSColor = .black,
        fill: NSColor = .white,
        arrowSize: Float = 2.0,
        vectorType: Int = 0,
        arrowType: Int = 0,
        showVector: Bool = false,
        showError: Bool = false
    ) -> XRLayerLineArrow {
        XRLayerLineArrow(
            isVisible: isVisible,
            active: active,
            biDir: biDir,
            name: name,
            lineWeight: lineWeight,
            maxCount: Int32(maxCount),
            maxPercent: maxPercent,
            stroke: stroke,
            fill: fill,
            arrowSize: arrowSize,
            vectorType: Int32(vectorType),
            arrowType: Int32(arrowType),
            showVector: showVector,
            showError: showError
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
        arrowSize: Float,
        vectorType: Int,
        arrowType: Int,
        showVector: Bool,
        showError: Bool,
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
        #expect(self.arrowSize() == arrowSize, sourceLocation: sourceLocation)
        #expect(self.vectorType() == vectorType, sourceLocation: sourceLocation)
        #expect(self.arrowType() == arrowType, sourceLocation: sourceLocation)
        #expect(self.showVector() == showVector, sourceLocation: sourceLocation)
        #expect(self.showError() == showError, sourceLocation: sourceLocation)
    }
}
