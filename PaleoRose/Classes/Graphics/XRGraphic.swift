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

// MARK: - Constants

enum XRGraphicKey: String {
    case fillColor = "XRGraphicKeyFillColor"
    case strokeColor = "XRGraphicKeyStrokeColor"
    case lineWidth = "XRGraphicKeyLineWidth"
    case drawsFill = "XRGraphicKeyDrawsFill"
}

class XRGraphic: NSObject, XRGeometryProviding, XRAppearanceProviding {
    // MARK: - Properties
    
    var drawingPath: NSBezierPath? {
        didSet {
            drawingPath?.lineWidth = lineWidth
            setNeedsDisplay(true)
        }
    }
    
    private(set) var needsRedraw: Bool = true
    
    private var fillColor: NSColor = .black {
        didSet { setNeedsDisplay(true) }
    }
    
    private var strokeColor: NSColor = .black {
        didSet { setNeedsDisplay(true) }
    }
    
    private var lineWidth: CGFloat = 1.0 {
        didSet {
            drawingPath?.lineWidth = lineWidth
            setNeedsDisplay(true)
        }
    }
    
    private var drawsFill: Bool = false {
        didSet { setNeedsDisplay(true) }
    }
    
    private var isSelected: Bool = false {
        didSet { setNeedsDisplay(true) }
    }
    
    weak var geometryController: XRGeometryController?
    
    // MARK: - XRAppearanceProviding
    
    var fills: Bool {
        get { drawsFill }
        set { drawsFill = newValue }
    }
    
    var stroke: NSColor {
        get { strokeColor }
        set { strokeColor = newValue }
    }
    
    var fill: NSColor {
        get { fillColor }
        set { fillColor = newValue }
    }
    
    var width: CGFloat {
        get { lineWidth }
        set { lineWidth = newValue }
    }
    
    // MARK: - Initialization
    
    init(controller: XRGeometryController) {
        self.geometryController = controller
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(geometryDidChange),
                                             name: .XRGeometryDidChange,
                                             object: controller)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Geometry Methods
    @objc func geometryDidChange(_ notification: Notification) {
        calculateGeometry()
    }
    
    func calculateGeometry() {
        // Subclasses must override to set up the geometry of the graphic object
    }
    
    // MARK: - Display Methods
    
    func setNeedsDisplay(_ display: Bool) {
        needsRedraw = display
    }
    
    var bounds: NSRect {
        drawingPath?.bounds ?? .zero
    }
    
    func draw(in rect: NSRect) {
        guard let path = drawingPath,
              NSIntersectsRect(rect, path.bounds) else { return }
        
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        
        strokeColor.set()
        path.stroke()
        
        if drawsFill {
            fillColor.set()
            path.fill()
        }
        
        needsRedraw = false
    }
    
    // MARK: - Hit Testing
    func hitTest(_ point: NSPoint) -> Bool {
        return false
    }
    
    // MARK: - Selection Methods
    
    var isSelectable: Bool { false } // Override in subclasses
    
    var selected: Bool {
        get { isSelected }
        set { isSelected = newValue }
    }
    
    func select() {
        guard isSelectable else { return }
        selected = true
    }
    
    func deselect() {
        guard isSelectable else { return }
        selected = false
    }
    
    // MARK: - Inspector Info
    
    var inspectorInfo: [String: Any] {
        [
            XRGraphicKey.fillColor.rawValue: fillColor,
            XRGraphicKey.strokeColor.rawValue: strokeColor,
            XRGraphicKey.lineWidth.rawValue: lineWidth,
            XRGraphicKey.drawsFill.rawValue: drawsFill
        ]
    }
    
    // MARK: - Appearance
    
    var fills: Bool {
        get { drawsFill }
        set { drawsFill = newValue }
    }
    
    var stroke: NSColor {
        get { strokeColor }
        set { strokeColor = newValue }
    }
    
    var fill: NSColor {
        get { fillColor }
        set { fillColor = newValue }
    }
    
    var width: CGFloat {
        get { lineWidth }
        set { lineWidth = newValue }
    }
    
    func resetColors() {
        strokeColor = .black
        fillColor = .black
    }
    
    func setAlpha(_ alpha: CGFloat) {
        let clampedAlpha = min(alpha, 1.0)
        strokeColor = strokeColor.withAlphaComponent(clampedAlpha) ?? strokeColor
        fillColor = fillColor.withAlphaComponent(clampedAlpha) ?? fillColor
    }
    
    func setColors(stroke: NSColor, fill: NSColor) {
        self.strokeColor = stroke
        self.fillColor = fill
    }
    
    // MARK: - Color Utilities
    
    static func compare(_ color1: NSColor, with color2: NSColor) -> Bool {
        guard let color1RGB = color1.usingColorSpace(.deviceRGB),
              let color2RGB = color2.usingColorSpace(.deviceRGB) else {
            return false
        }
        
        let components1 = color1RGB.cgColor.components ?? []
        let components2 = color2RGB.cgColor.components ?? []
        return components1.elementsEqual(components2)
    }
    
    static func data(from color: NSColor) -> Data {
        guard let rgbColor = color.usingColorSpace(.deviceRGB) else { return Data() }
        
        let components = [
            rgbColor.redComponent,
            rgbColor.greenComponent,
            rgbColor.blueComponent,
            rgbColor.alphaComponent
        ]
        
        return components.withUnsafeBytes { Data($0) }
    }
    
    static func color(from data: Data) -> NSColor? {
        guard data.count >= MemoryLayout<CGFloat>.size * 4 else { return nil }
        
        return data.withUnsafeBytes { ptr -> NSColor? in
            guard let components = ptr.bindMemory(to: CGFloat.self).baseAddress else { return nil }
            
            return NSColor(deviceRed: components[0],
                          green: components[1],
                          blue: components[2],
                          alpha: components[3])
        }
    }
    
    // MARK: - Graphic Settings
    
    enum GraphicType: String {
        case graphic = "Graphic"
        case labelCircle = "LabelCircle"
        case circle = "Circle"
        case line = "Line"
        case kite = "Kite"
        case petal = "Petal"
        case dot = "Dot"
        case histogram = "Histogram"
        case dotDeviation = "DotDeviation"
        
        static func from(_ graphic: XRGraphic) -> GraphicType {
            switch graphic {
            case is XRGraphicCircleLabel: return .labelCircle
            case is XRGraphicCircle: return .circle
            case is XRGraphicLine: return .line
            case is XRGraphicKite: return .kite
            case is XRGraphicPetal: return .petal
            case is XRGraphicDot: return .dot
            case is XRGraphicHistogram: return .histogram
            case is XRGraphicDotDeviation: return .dotDeviation
            default: return .graphic
            }
        }
    }
    
    var graphicSettings: [String: Any] {
        [
            "GraphicType": GraphicType.from(self).rawValue,
            "_fillColor": fillColor,
            "_strokeColor": strokeColor,
            "_lineWidth": String(format: "%.6f", lineWidth)
        ]
    }
}
