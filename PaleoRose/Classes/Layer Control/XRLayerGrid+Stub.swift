//
// XRLayerGrid+Stub.swift
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

extension XRLayerGrid {
    static func stub(
        isVisible: Bool = false,
        active: Bool = false,
        biDir: Bool = false,
        name: String = "XRLayerGrid",
        lineWeight: Float = 0.0,
        maxCount: Int32 = 0,
        maxPercent: Float = 0.0,
        stroke: NSColor = .black,
        fill: NSColor = .white,
        isFixedCount: Bool = false,
        ringsVisible: Bool = false,
        fixedRingCount: Int = 1,
        ringCountIncrement: Int = 1,
        ringPercentIncrement: Float = 1.0,
        showRingLabels: Bool = false,
        labelAngle: Float = 3.0,
        ringFont: NSFont = NSFont.systemFont(ofSize: 12.0),
        radialsCount: Int = 1,
        radialsAngle: Float = 3.0,
        radialsLabelAlignment: Int = 1,
        radialsCompassPoint: Int = 1,
        radialsOrder: Int = 1,
        radialFont: NSFont = NSFont.systemFont(ofSize: 12.0),
        radialsSectorLock: Bool = false,
        radialsVisible: Bool = false,
        radialsIsPercent: Bool = false,
        radialsTicks: Bool = false,
        radialsMinorTicks: Bool = false,
        radialLabels: Bool = false
    ) -> XRLayerGrid {
        XRLayerGrid(
            isVisible: isVisible,
            active: active,
            biDir: biDir,
            name: name,
            lineWeight: lineWeight,
            maxCount: maxCount,
            maxPercent: maxPercent,
            stroke: stroke,
            fill: fill,
            isFixedCount: isFixedCount,
            ringsVisible: ringsVisible,
            fixedRingCount: Int32(fixedRingCount),
            ringCountIncrement: Int32(ringCountIncrement),
            ringPercentIncrement: ringPercentIncrement,
            showRingLabels: showRingLabels,
            labelAngle: labelAngle,
            ring: ringFont,
            radialsCount: Int32(fixedRingCount),
            radialsAngle: radialsAngle,
            radialsLabelAlignment: Int32(fixedRingCount),
            radialsCompassPoint: Int32(fixedRingCount),
            radialsOrder: Int32(fixedRingCount),
            radialFont: radialFont,
            radialsSectorLock: radialsSectorLock,
            radialsVisible: radialsVisible,
            radialsIsPercent: radialsIsPercent,
            radialsTicks: radialsTicks,
            radialsMinorTicks: radialsMinorTicks,
            radialLabels: radialLabels
        )
    }
}
