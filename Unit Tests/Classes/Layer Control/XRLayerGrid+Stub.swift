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
import Testing

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

    // swiftlint:disable:next function_parameter_count
    func verify(
        isVisible: Bool,
        active: Bool,
        biDir: Bool,
        name: String,
        lineWeight: Float,
        maxCount: Int32,
        maxPercent: Float,
//        stroke: NSColor,
//        fill: NSColor,
        isFixedCount: Bool,
        ringsVisible: Bool,
        fixedRingCount: Int,
        ringCountIncrement: Int,
        ringPercentIncrement: Float,
        showRingLabels: Bool,
        labelAngle: Float,
        ringFont: NSFont,
        radialsCount: Int,
        radialsAngle: Float,
        radialsLabelAlignment: Int,
        radialsCompassPoint: Int,
        radialsOrder: Int,
        radialFont: NSFont,
        radialsSectorLock: Bool,
        radialsVisible: Bool,
        radialsIsPercent: Bool,
        radialsTicks: Bool,
        radialsMinorTicks: Bool,
        radialLabels: Bool,
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
        // stroke id
        // fill id
        #expect(fixedCount() == isFixedCount, sourceLocation: sourceLocation)
        #expect(self.ringsVisible() == ringsVisible, sourceLocation: sourceLocation)
        #expect(self.fixedRingCount() == fixedRingCount, sourceLocation: sourceLocation)
        #expect(self.ringCountIncrement() == ringCountIncrement, sourceLocation: sourceLocation)
        #expect(self.ringPercentIncrement() == ringPercentIncrement, sourceLocation: sourceLocation)
        #expect(ringLabelAngle() == labelAngle, sourceLocation: sourceLocation)
        #expect(ringFontName() == ringFont.fontName, sourceLocation: sourceLocation)
        #expect(ringFontSize() == Float(ringFont.pointSize), sourceLocation: sourceLocation)
        #expect(self.radialsCount() == radialsCount, sourceLocation: sourceLocation)
        #expect(self.radialsAngle() == radialsAngle, sourceLocation: sourceLocation)
        #expect(radialsLabelAlign() == radialsLabelAlignment, sourceLocation: sourceLocation)
        #expect(self.radialsCompassPoint() == radialsCompassPoint, sourceLocation: sourceLocation)
        #expect(radiansOrder() == radialsOrder, sourceLocation: sourceLocation)
        #expect(radianFontName() == radialFont.fontName, sourceLocation: sourceLocation)
        #expect(radianFontSize() == Float(radialFont.pointSize), sourceLocation: sourceLocation)
        #expect(radianSectorLock() == radialsSectorLock, sourceLocation: sourceLocation)
        #expect(radianVisible() == radialsVisible, sourceLocation: sourceLocation)
        #expect(radianIsPercent() == radialsIsPercent, "radiansIsPercent \(radianIsPercent())", sourceLocation: sourceLocation)
        #expect(radianTicks() == radialsTicks, sourceLocation: sourceLocation)
        #expect(radianMinorTicks() == radialsMinorTicks, sourceLocation: sourceLocation)
        #expect(radianLabels() == radialLabels, sourceLocation: sourceLocation)
    }
}
