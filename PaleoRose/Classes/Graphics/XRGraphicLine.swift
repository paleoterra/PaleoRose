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
enum XRGraphicLineTickType: Int {
    case none = 0
    case minor = 1
    case major = 2
}

enum XRGraphicLineNumberingOrder: Int {
    case order360 = 0
    case orderQuad = 1
}

enum XRGraphicLineNumberAlign: Int {
    case horizontal = 0
    case angle = 1
}

enum XRGraphicLineNumberCompassPoint: Int {
    case numbersOnly = 0
    case points = 1
}

class XRGraphicLine: XRGraphic {
    // MARK: - Properties
    private var relativePercent: CGFloat = 1.0
    private var angleSetting: CGFloat = 0.0
    private var tickType: XRGraphicLineTickType = .none
    private var showTick: Bool = false
    private var currentFont: NSFont
    private var spokeNumberAlign: XRGraphicLineNumberAlign = .horizontal
    private var spokeNumberCompassPoint: XRGraphicLineNumberCompassPoint = .points
    private var spokeNumberOrder: XRGraphicLineNumberingOrder = .orderQuad
    private var showLabel: Bool = true
    private var spokePointOnly: Bool = false
    private var lineLabel: NSMutableAttributedString?
    private var labelTransform: NSAffineTransform?
    
    // MARK: - Initialization
    override init(controller: XRGeometryController) {
        self.currentFont = NSFont(name: "Arial-Black", size: 12) ?? NSFont.systemFont(ofSize: 12)
        super.init(controller: controller)
        setLineLabel()
    }
    
    // MARK: - Spoke Methods
    func setSpokeAngle(_ angle: CGFloat) {
        angleSetting = angle
        setLineLabel()
        calculateGeometry()
    }
    
    func spokeAngle() -> CGFloat {
        return angleSetting
    }
    
    func setPointsOnly(_ value: Bool) {
        spokePointOnly = value
        setLineLabel()
    }
    
    // MARK: - Tick Methods
    func setTickType(_ type: XRGraphicLineTickType) {
        tickType = type
        calculateGeometry()
    }
    
    func getTickType() -> XRGraphicLineTickType {
        return tickType
    }
    
    func setShowTick(_ show: Bool) {
        showTick = show
        calculateGeometry()
    }
    
    // MARK: - Label Methods
    func setShowLabel(_ show: Bool) {
        showLabel = show
    }
    
    func setNumberAlignment(_ alignment: XRGraphicLineNumberAlign) {
        spokeNumberAlign = alignment
    }
    
    func setNumberOrder(_ order: XRGraphicLineNumberingOrder) {
        spokeNumberOrder = order
        setLineLabel()
    }
    
    func setNumberPoints(_ pointRule: XRGraphicLineNumberCompassPoint) {
        spokeNumberCompassPoint = pointRule
        setLineLabel()
    }
    
    func setFont(_ font: NSFont) {
        currentFont = font
        calculateGeometry()
    }
    
    func getFont() -> NSFont {
        return currentFont
    }
    
    // MARK: - Geometry Methods
    override func calculateGeometry() {
        guard let controller = geometryController else { return }
        
        var radius = controller.radius(ofRelativePercent: 0.0)
        var point = NSPoint(x: 0.0, y: radius)
        point = controller.rotation(ofPoint: point, byAngle: angleSetting)
        
        let path = NSBezierPath()
        path.move(to: point)
        
        if tickType == .none || !showTick {
            radius = controller.radius(ofRelativePercent: relativePercent)
        } else if tickType == .minor {
            radius = controller.unrestrictedRadius(ofRelativePercent: relativePercent + 0.05)
        } else {
            radius = controller.unrestrictedRadius(ofRelativePercent: relativePercent + 0.1)
        }
        
        point = NSPoint(x: 0.0, y: radius)
        point = controller.rotation(ofPoint: point, byAngle: angleSetting)
        path.line(to: point)
        
        drawingPath = path
        setLabelTransform()
    }
    
    // MARK: - Label Transform Methods
    private func setLineLabel() {
        let angle = Double(angleSetting)
        var labelText = ""
        
        if angle == 0.0 || angle == 90.0 || angle == 180.0 || angle == 270.0 || angle == 360.0 {
            if spokeNumberCompassPoint == .points {
                labelText = {
                    switch angle {
                    case 0.0, 360.0: return "N"
                    case 90.0: return "E"
                    case 180.0: return "S"
                    case 270.0: return "W"
                    default: return ""
                    }
                }()
            } else {
                labelText = formatAngle(angle)
            }
        } else if !spokePointOnly {
            if spokeNumberOrder == .order360 {
                labelText = formatAngle(angle)
            } else {
                let workAngle = calculateQuadrantAngle(angle)
                labelText = formatAngle(workAngle)
            }
        }
        
        lineLabel = NSMutableAttributedString(string: labelText)
        setLabelTransform()
    }
    
    private func formatAngle(_ angle: Double) -> String {
        return angle == floor(angle) ? String(format: "%d", Int(angle)) : String(format: "%.1f", angle)
    }
    
    private func calculateQuadrantAngle(_ angle: Double) -> Double {
        if angle <= 90.0 {
            return angle
        } else if angle <= 180.0 {
            return 180.0 - angle
        } else if angle <= 270.0 {
            return angle - 180.0
        } else {
            return 360.0 - angle
        }
    }
    
    private func setLabelTransform() {
        guard let label = lineLabel else { return }
        
        let range = NSRange(location: 0, length: label.length)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: currentFont,
            .foregroundColor: getStrokeColor()
        ]
        label.setAttributes(attributes, range: range)
        
        labelTransform = NSAffineTransform()
        if spokeNumberAlign == .horizontal {
            appendHorizontalTransform()
        } else {
            appendParallelTransform()
        }
    }
    
    private func appendHorizontalTransform() {
        guard let transform = labelTransform, let label = lineLabel else { return }
        guard let controller = geometryController else { return }
        
        let size = label.size()
        let displacement = controller.unrestrictedRadius(ofRelativePercent: relativePercent + 0.2)
        let rotationAngle = angleSetting - 90.0
        
        transform.translate(x: -0.5 * size.width, y: -0.5 * size.height)
        transform.rotate(byDegrees: -rotationAngle)
        transform.translate(x: displacement, y: 0.0)
        transform.rotate(byDegrees: rotationAngle)
    }
    
    private func appendParallelTransform() {
        guard let transform = labelTransform, let label = lineLabel else { return }
        guard let controller = geometryController else { return }
        
        let size = label.size()
        let displacement = controller.unrestrictedRadius(ofRelativePercent: relativePercent + 0.1)
        let rotationAngle = 90.0 - angleSetting
        
        if angleSetting == 0.0 {
            transform.translate(x: -0.5 * size.width, y: displacement)
        } else if angleSetting == 180.0 {
            transform.translate(x: -0.5 * size.width, y: -(displacement + size.height))
        } else {
            if angleSetting > 180.0 {
                transform.rotate(byDegrees: rotationAngle - 180.0)
                transform.translate(x: -(displacement + size.width), y: 0.0)
                transform.translate(x: 0.0, y: -0.5 * size.height)
            } else {
                transform.rotate(byDegrees: rotationAngle)
                transform.translate(x: displacement, y: 0.0)
                transform.translate(x: 0.0, y: -0.5 * size.height)
            }
        }
    }
    
    // MARK: - Drawing
    override func draw(_ dirtyRect: NSRect) {
        guard let path = drawingPath, NSIntersectsRect(dirtyRect, path.bounds) else { return }
        
        NSGraphicsContext.saveGraphicsState()
        
        getStrokeColor().set()
        path.stroke()
        
        if getDrawsFill() {
            getFillColor().set()
            path.fill()
        }
        
        if showLabel, let transform = labelTransform, let label = lineLabel {
            transform.concat()
            label.draw(at: .zero)
        }
        
        NSGraphicsContext.restoreGraphicsState()
        setNeedsDisplay(false)
    }
    
    // MARK: - Settings Dictionary
    override var graphicSettings: [String: Any] {
        var settings = super.graphicSettings
        
        settings["_relativePercent"] = String(format: "%f", relativePercent)
        settings["_angleSetting"] = String(format: "%f", angleSetting)
        settings["_tickType"] = String(format: "%d", tickType.rawValue)
        settings["_showTick"] = showTick ? "YES" : "NO"
        settings["_spokeNumberAlign"] = String(format: "%d", spokeNumberAlign.rawValue)
        settings["_spokeNumberCompassPoint"] = String(format: "%d", spokeNumberCompassPoint.rawValue)
        settings["_spokeNumberOrder"] = String(format: "%d", spokeNumberOrder.rawValue)
        settings["_showLabel"] = showLabel ? "YES" : "NO"
        settings["_lineLabel"] = lineLabel as Any
        settings["_currentFont"] = currentFont
        
        return settings
    }
}
