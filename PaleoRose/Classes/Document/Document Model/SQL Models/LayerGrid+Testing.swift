//
// LayerGrid+Testing.swift
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
@testable import PaleoRose

// swiftlint:disable conditional_returns_on_newline cyclomatic_complexity

extension LayerGrid {
    func compare(with layer: XRLayerGrid, id: Int) -> Bool {
        guard LAYERID == id else { return false }
        guard RINGS_ISFIXEDCOUNT == layer.fixedCount() else { return false }
        guard RINGS_VISIBLE == layer.isVisible() else { return false }
        guard RINGS_LABELS == layer.showLabels() else { return false }
        guard RINGS_FIXEDCOUNT == Int(layer.fixedRingCount()) else { return false }
        guard RINGS_COUNTINCREMENT == Int(layer.ringCountIncrement()) else { return false }
        guard RINGS_PERCENTINCREMENT == layer.ringPercentIncrement() else { return false }
        guard RINGS_LABELANGLE == layer.ringLabelAngle() else { return false }
        guard RINGS_FONTNAME == layer.ringFontName() else { return false }
        guard RINGS_FONTSIZE == layer.ringFontSize() else { return false }
        guard RADIALS_COUNT == Int(layer.radialsCount()) else { return false }
        guard RADIALS_ANGLE == layer.radialsAngle() else { return false }
        guard RADIALS_LABELALIGN == Int(layer.radialsLabelAlign()) else { return false }
        guard RADIALS_COMPASSPOINT == Int(layer.radialsCompassPoint()) else { return false }
        guard RADIALS_ORDER == Int(layer.radiansOrder()) else { return false }
        guard RADIALS_FONT == layer.radianFontName() else { return false }
        guard RADIALS_FONTSIZE == layer.radianFontSize() else { return false }
        guard RADIALS_SECTORLOCK == layer.radianSectorLock() else { return false }
        guard RADIALS_VISIBLE == layer.radianVisible() else { return false }
        guard RADIALS_ISPERCENT == layer.radianIsPercent() else { return false }
        guard RADIALS_TICKS == layer.radianTicks() else { return false }
        guard RADIALS_MINORTICKS == layer.radianMintoTicks() else { return false }
        guard RADIALS_LABELS == layer.radianLabels() else { return false }
        return true
    }
}
