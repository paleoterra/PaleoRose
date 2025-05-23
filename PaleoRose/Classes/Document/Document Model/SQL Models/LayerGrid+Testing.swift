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

// swiftlint:disable cyclomatic_complexity identifier_name

extension LayerGrid {

    static func stub(
        LAYERID: Int = 1,
        RINGS_ISFIXEDCOUNT: Bool = false,
        RINGS_VISIBLE: Bool = false,
        RINGS_LABELS: Bool = false,
        RINGS_FIXEDCOUNT: Int = 1,
        RINGS_COUNTINCREMENT: Int = 1,
        RINGS_PERCENTINCREMENT: Float = 0.1,
        RINGS_LABELANGLE: Float = 0.1,
        RINGS_FONTNAME: String = "ArialMT",
        RINGS_FONTSIZE: Float = 1.0,
        RADIALS_COUNT: Int = 1,
        RADIALS_ANGLE: Float = 0.1,
        RADIALS_LABELALIGN: Int = 0,
        RADIALS_COMPASSPOINT: Int = 0,
        RADIALS_ORDER: Int = 0,
        RADIALS_FONT: String = "ArialMT",
        RADIALS_FONTSIZE: Float = 1.0,
        RADIALS_SECTORLOCK: Bool = false,
        RADIALS_VISIBLE: Bool = false,
        RADIALS_ISPERCENT: Bool = false,
        RADIALS_TICKS: Bool = true,
        RADIALS_MINORTICKS: Bool = true,
        RADIALS_LABELS: Bool = false
    ) -> LayerGrid {
        LayerGrid(
            LAYERID: LAYERID,
            RINGS_ISFIXEDCOUNT: RINGS_ISFIXEDCOUNT,
            RINGS_VISIBLE: RINGS_VISIBLE,
            RINGS_LABELS: RINGS_LABELS,
            RINGS_FIXEDCOUNT: RINGS_FIXEDCOUNT,
            RINGS_COUNTINCREMENT: RINGS_COUNTINCREMENT,
            RINGS_PERCENTINCREMENT: RINGS_PERCENTINCREMENT,
            RINGS_LABELANGLE: RINGS_LABELANGLE,
            RINGS_FONTNAME: RINGS_FONTNAME,
            RINGS_FONTSIZE: RINGS_FONTSIZE,
            RADIALS_COUNT: RADIALS_COUNT,
            RADIALS_ANGLE: RADIALS_ANGLE,
            RADIALS_LABELALIGN: RADIALS_LABELALIGN,
            RADIALS_COMPASSPOINT: RADIALS_COMPASSPOINT,
            RADIALS_ORDER: RADIALS_ORDER,
            RADIALS_FONT: RADIALS_FONT,
            RADIALS_FONTSIZE: RADIALS_FONTSIZE,
            RADIALS_SECTORLOCK: RADIALS_SECTORLOCK,
            RADIALS_VISIBLE: RADIALS_VISIBLE,
            RADIALS_ISPERCENT: RADIALS_ISPERCENT,
            RADIALS_TICKS: RADIALS_TICKS,
            RADIALS_MINORTICKS: RADIALS_MINORTICKS,
            RADIALS_LABELS: RADIALS_LABELS
        )
    }

    // swiftlint:disable:next function_body_length
    func compare(with layer: XRLayerGrid, id: Int) -> Bool {
        guard LAYERID == id else {
            print("LAYERID \(LAYERID) != \(id)")
            return false
        }
        guard RINGS_ISFIXEDCOUNT == layer.fixedCount() else {
            print("RINGS_ISFIXEDCOUNT \(RINGS_ISFIXEDCOUNT) != \(layer.fixedCount())")
            return false
        }
        guard RINGS_VISIBLE == layer.isVisible() else {
            print("RINGS_VISIBLE \(RINGS_VISIBLE) != \(layer.isVisible())")
            return false
        }
        guard RINGS_LABELS == layer.showLabels() else {
            print("RINGS_LABELS \(RINGS_LABELS) != \(layer.showLabels())")
            return false
        }
        guard RINGS_FIXEDCOUNT == Int(layer.fixedRingCount()) else {
            print("RINGS_FIXEDCOUNT \(RINGS_FIXEDCOUNT) != \(layer.fixedRingCount())")
            return false
        }
        guard RINGS_COUNTINCREMENT == Int(layer.ringCountIncrement()) else {
            print("RINGS_COUNTINCREMENT \(RINGS_COUNTINCREMENT) != \(layer.ringCountIncrement())")
            return false
        }
        guard RINGS_PERCENTINCREMENT == layer.ringPercentIncrement() else {
            print("RINGS_PERCENTINCREMENT \(RINGS_PERCENTINCREMENT) != \(String(describing: layer.ringPercentIncrement))")
            return false
        }
        guard RINGS_LABELANGLE == layer.ringLabelAngle() else {
            print("RINGS_LABELANGLE \(RINGS_LABELANGLE) != \(layer.ringLabelAngle())")
            return false
        }
        guard RINGS_FONTNAME == layer.ringFontName() else {
            print("RINGS_FONTNAME \(RINGS_FONTNAME) != \(layer.ringFontName() ?? "")")
            return false
        }
        guard RINGS_FONTSIZE == layer.ringFontSize() else {
            print("RINGS_FONTSIZE \(RINGS_FONTSIZE) != \(String(describing: layer.ringFontSize))")
            return false
        }
        guard RADIALS_COUNT == Int(layer.radialsCount()) else {
            print("RADIALS_COUNT \(RADIALS_COUNT) != \(layer.radialsCount())")
            return false
        }
        guard RADIALS_ANGLE == layer.radialsAngle() else {
            print("RADIALS_ANGLE \(RADIALS_ANGLE) != \(layer.radialsAngle())")
            return false
        }
        guard RADIALS_LABELALIGN == Int(layer.radialsLabelAlign()) else {
            print("RADIALS_LABELALIGN \(RADIALS_LABELALIGN) != \(layer.radialsLabelAlign())")
            return false
        }
        guard RADIALS_COMPASSPOINT == Int(layer.radialsCompassPoint()) else {
            print("RADIALS_COMPASSPOINT \(RADIALS_COMPASSPOINT) != \(layer.radialsCompassPoint())")
            return false
        }
        guard RADIALS_ORDER == Int(layer.radiansOrder()) else {
            print("RADIALS_ORDER \(RADIALS_ORDER) != \(layer.radiansOrder())")
            return false
        }
        guard RADIALS_FONT == layer.radianFontName() else {
            print("RADIALS_FONT \(RADIALS_FONT) != \(layer.radianFontName() ?? "")")
            return false
        }
        guard RADIALS_FONTSIZE == layer.radianFontSize() else {
            print("RADIALS_FONTSIZE \(RADIALS_FONTSIZE) != \(String(describing: layer.radianFontSize))")
            return false
        }
        guard RADIALS_SECTORLOCK == layer.radianSectorLock() else {
            print("RADIALS_SECTORLOCK \(RADIALS_SECTORLOCK) != \(layer.radianSectorLock())")
            return false
        }
        guard RADIALS_VISIBLE == layer.radianVisible() else {
            print("RADIALS_VISIBLE \(RADIALS_VISIBLE) != \(layer.radianVisible())")
            return false
        }
        guard RADIALS_ISPERCENT == layer.radianIsPercent() else {
            print("RADIALS_ISPERCENT \(RADIALS_ISPERCENT) != \(layer.radianIsPercent())")
            return false
        }
        guard RADIALS_TICKS == layer.radianTicks() else {
            print("RADIALS_TICKS \(RADIALS_TICKS) != \(layer.radianTicks())")
            return false
        }
        guard RADIALS_MINORTICKS == layer.radianMinorTicks() else {
            print("RADIALS_MINORTICKS \(RADIALS_MINORTICKS) != \(layer.radianMinorTicks())")
            return false
        }
        guard RADIALS_LABELS == layer.radianLabels() else {
            print("RADIALS_LABELS \(RADIALS_LABELS) != \(layer.radianLabels())")
            return false
        }
        return true
    }
}
