//
// LayerText+Testing.swift
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

// swiftlint:disable line_length identifier_name indentation_width opening_brace
extension LayerText {

    static func stub(
        LAYERID: Int = 1,
        contents: String = "Text",
        RECT_POINT_X: Float = 0.0,
        RECT_POINT_Y: Float = 0.0,
        RECT_SIZE_WIDTH: Float = 40.0,
        RECT_SIZE_HEIGHT: Float = 40.0
    ) -> LayerText {
        let storage = NSTextStorage(string: contents)
        return LayerText(
            LAYERID: LAYERID,
            CONTENTS: Encoding.encodeTextStorage(from: storage),
            RECT_POINT_X: RECT_POINT_X,
            RECT_POINT_Y: RECT_POINT_Y,
            RECT_SIZE_WIDTH: RECT_SIZE_WIDTH,
            RECT_SIZE_HEIGHT: RECT_SIZE_HEIGHT
        )
    }

    func compare(with layer: XRLayerText, id: Int) throws -> Bool {

        let attributedString = Encoding.decodeTextStorage(from: CONTENTS)
        if attributedString?.string != layer.contents()?.string {
            return false
        }
        let layerFont: NSFont? = attributedString?.attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.font] as? NSFont
        let xrLayerFont: NSFont? = layer.contents().attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.font] as? NSFont
        if layerFont != xrLayerFont {
            return false
        }
        if LAYERID == id,
           RECT_POINT_X == Float(layer.textRect().origin.x),
           RECT_POINT_Y == Float(layer.textRect().origin.y),
           RECT_SIZE_WIDTH == Float(layer.textRect().size.width),
           RECT_SIZE_HEIGHT == Float(layer.textRect().size.height)
        {
            return true
        }
        return false
    }
}
