//
// LayerData+Testing.swift
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

// swiftlint:disable conditional_returns_on_newline

extension LayerData {

    static func stub(
        LAYERID: Int = 1,
        DATASET: Int = 0,
        PLOTTYPE: Int = 0,
        TOTALCOUNT: Int = 1,
        DOTRADIUS: Float = 1.0
    ) -> LayerData {
        LayerData(
            LAYERID: LAYERID,
            DATASET: DATASET,
            PLOTTYPE: PLOTTYPE,
            TOTALCOUNT: TOTALCOUNT,
            DOTRADIUS: DOTRADIUS
        )
    }

    func compare(with layer: XRLayerData, id: Int) -> Bool {
        guard LAYERID == id else { return false }
        guard DATASET == layer.datasetId() else { return false }
        guard PLOTTYPE == layer.plotType() else { return false }
        guard TOTALCOUNT == layer.totalCount() else { return false }
        guard DOTRADIUS == layer.dotRadius() else { return false }
        return true
    }
}
