//
// Layer+Testing.swift
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

// swiftlint:disable identifier_name conditional_returns_on_newline
extension Layer {

    static func stub(
        LAYERID: Int = 0,
        TYPE: String = "XRLayerText",
        VISIBLE: Bool = false,
        ACTIVE: Bool = false,
        BIDIR: Bool = false,
        LAYER_NAME: String = "Test Layer",
        LINEWEIGHT: Float = 1,
        MAXCOUNT: Int = 30,
        MAXPERCENT: Float = 0.34,
        STROKECOLORID: Int = 0,
        FILLCOLORID: Int = 1
    ) -> Layer {
        Layer(
            LAYERID: LAYERID,
            TYPE: TYPE,
            VISIBLE: VISIBLE,
            ACTIVE: ACTIVE,
            BIDIR: BIDIR,
            LAYER_NAME: LAYER_NAME,
            LINEWEIGHT: LINEWEIGHT,
            MAXCOUNT: MAXCOUNT,
            MAXPERCENT: MAXPERCENT,
            STROKECOLORID: STROKECOLORID,
            FILLCOLORID: FILLCOLORID
        )
    }

    func compare(with layer: some XRLayer, id: Int) -> Bool {
        guard LAYERID == id else { return false }
        guard TYPE == layer.type() else { return false }
        guard VISIBLE == layer.isVisible() else { return false }
        guard ACTIVE == layer.isActive() else { return false }
        guard BIDIR == layer.isBiDirectional() else { return false }
        guard LAYER_NAME == layer.layerName() else { return false }
        guard LINEWEIGHT == layer.lineWeight() else { return false }
        guard MAXCOUNT == layer.maxCount() else { return false }
        guard MAXPERCENT == layer.maxPercent() else { return false }
        return true
    }
}
