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

/// Protocol defining geometry-related functionality for graphics objects
protocol XRGeometryProviding {
    /// The path used for drawing the graphic
    var drawingPath: NSBezierPath? { get set }
    
    /// The bounds of the graphic
    var bounds: NSRect { get }
    
    /// Whether the graphic needs to be redrawn
    var needsRedraw: Bool { get set }
    
    /// Calculate the geometry of the graphic
    func calculateGeometry()
    
    /// Test if a point is within the graphic's bounds
    func hitTest(_ point: NSPoint) -> Bool
    
    /// Draw the graphic in the given rectangle
    func draw(in rect: NSRect)
}

/// Default implementation of hit testing for geometry providers
extension XRGeometryProviding {
    func hitTest(_ point: NSPoint) -> Bool {
        guard let path = drawingPath else { return false }
        return path.contains(point)
    }
}
