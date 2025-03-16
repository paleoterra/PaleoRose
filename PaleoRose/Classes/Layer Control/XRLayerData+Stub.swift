//
// XRLayerData+Stub.swift
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

extension XRLayerData {
    static func stub(
        isVisible: Bool = false,
        active: Bool = false,
        biDir: Bool = false,
        name: String = "XRLayerData",
        lineWeight: Float = 0.0,
        maxCount: Int32 = 0,
        maxPercent: Float = 0.0,
        stroke: NSColor = NSColor.black,
        fill: NSColor = NSColor.white,
        plotType: Int = 0,
        totalCount: Int = 10,
        dotRadius: Float = 2.0
    ) -> XRLayerData {
        XRLayerData(
            isVisible: isVisible,
            active: active,
            biDir: biDir,
            name: name,
            lineWeight: lineWeight,
            maxCount: maxCount,
            maxPercent: maxPercent,
            stroke: stroke,
            fill: fill,
            plotType: Int32(plotType),
            totalCount: Int32(totalCount),
            dotRadius: dotRadius
        )
    }
}
