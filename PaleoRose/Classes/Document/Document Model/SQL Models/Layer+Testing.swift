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

// swiftlint:disable identifier_name
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
        MAXPERCENT: Float = 0.34
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
            MAXPERCENT: MAXPERCENT
        )
    }

    func compare(with layer: some XRLayer, id: Int) -> Bool {
        LAYERID == id &&
            TYPE == layer.type() &&
            VISIBLE == layer.isVisible() &&
            ACTIVE == layer.isActive() &&
            BIDIR == layer.isBiDirectional() &&
            LAYER_NAME == layer.layerName() &&
            LINEWEIGHT == layer.lineWeight() &&
            MAXCOUNT == layer.maxCount() &&
            MAXPERCENT == layer.maxPercent()
    }
}
