// MIT License
//
// Copyright (c) 2004 to present Thomas L. Moore.
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

import Cocoa

/// Protocol defining appearance-related functionality for graphics objects
protocol XRAppearanceProviding {
    /// Whether the graphic should be filled
    var fills: Bool { get set }

    /// The stroke color of the graphic
    var stroke: NSColor { get set }

    /// The fill color of the graphic
    var fill: NSColor { get set }

    /// The line width of the graphic
    var width: CGFloat { get set }

    /// Reset colors to their default values
    func resetColors()

    /// Set the alpha component of both stroke and fill colors
    func setAlpha(_ alpha: CGFloat)

    /// Set both stroke and fill colors
    func setColors(stroke: NSColor, fill: NSColor)
}

/// Default implementation of color utilities for appearance providers
extension XRAppearanceProviding {
    func resetColors() {
        stroke = .black
        fill = .black
    }

    func setAlpha(_ alpha: CGFloat) {
        let clampedAlpha = min(alpha, 1.0)
        stroke = stroke.withAlphaComponent(clampedAlpha) ?? stroke
        fill = fill.withAlphaComponent(clampedAlpha) ?? fill
    }

    func setColors(stroke: NSColor, fill: NSColor) {
        self.stroke = stroke
        self.fill = fill
    }
}
