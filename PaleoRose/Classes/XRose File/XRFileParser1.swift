// XRFileParser1.swift
//
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

@objc class XRFileParser1: XRFileParser {
    // MARK: - Common Layer Methods
    
    @objc func commonLayerAttributeOrder() -> [String] {
        return [
            "name",
            "isVisible",
            "isLocked",
            "isActive",
            "opacity",
            "blendMode"
        ]
    }
    
    @objc func commonLayerAttributes(fromDictionary dict: [String: Any]) -> [String: Any] {
        var attributes: [String: Any] = [:]
        
        if let name = dict["name"] as? String {
            attributes["name"] = name
        }
        if let isVisible = dict["isVisible"] as? Bool {
            attributes["isVisible"] = isVisible ? "YES" : "NO"
        }
        if let isLocked = dict["isLocked"] as? Bool {
            attributes["isLocked"] = isLocked ? "YES" : "NO"
        }
        if let isActive = dict["isActive"] as? Bool {
            attributes["isActive"] = isActive ? "YES" : "NO"
        }
        if let opacity = dict["opacity"] as? CGFloat {
            attributes["opacity"] = String(format: "%.2f", opacity)
        }
        if let blendMode = dict["blendMode"] as? Int {
            attributes["blendMode"] = "\(blendMode)"
        }
        
        return attributes
    }
    
    // MARK: - Color Methods
    
    @objc func tree(from color: NSColor, withName name: String) -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "color"
        
        let calibratedColor = color.usingColorSpace(.genericRGB) ?? color
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        calibratedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        tree.addAttribute("name", value: name)
        tree.addAttribute("red", value: String(format: "%.3f", red))
        tree.addAttribute("green", value: String(format: "%.3f", green))
        tree.addAttribute("blue", value: String(format: "%.3f", blue))
        tree.addAttribute("alpha", value: String(format: "%.3f", alpha))
        
        return tree
    }
    
    @objc func color(fromTree tree: LITMXMLTree) -> NSColor? {
        guard let attributes = tree.attributesDictionary() as? [String: String],
              let redStr = attributes["red"],
              let greenStr = attributes["green"],
              let blueStr = attributes["blue"],
              let alphaStr = attributes["alpha"],
              let red = Double(redStr),
              let green = Double(greenStr),
              let blue = Double(blueStr),
              let alpha = Double(alphaStr) else {
            return nil
        }
        
        return NSColor(red: CGFloat(red),
                      green: CGFloat(green),
                      blue: CGFloat(blue),
                      alpha: CGFloat(alpha))
    }
    
    // MARK: - Font Methods
    
    @objc func tree(from font: NSFont) -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "font"
        
        tree.addAttribute("name", value: font.fontName)
        tree.addAttribute("size", value: String(format: "%.1f", font.pointSize))
        
        return tree
    }
    
    @objc func font(fromTree tree: LITMXMLTree) -> NSFont? {
        guard let attributes = tree.attributesDictionary() as? [String: String],
              let name = attributes["name"],
              let sizeStr = attributes["size"],
              let size = Double(sizeStr) else {
            return nil
        }
        
        return NSFont(name: name, size: CGFloat(size))
    }
    
    // MARK: - Data Methods
    
    @objc func tree(fromDataDictionary dict: [String: Any]) -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "data"
        
        // Add data attributes and children based on dictionary content
        // Implementation depends on data structure
        
        return tree
    }
    
    @objc func convertLayerTree(toDictionary tree: LITMXMLTree) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let attributes = tree.attributesDictionary() as? [String: String] {
            // Convert common layer attributes
            dict["name"] = attributes["name"]
            dict["isVisible"] = attributes["isVisible"] == "YES"
            dict["isLocked"] = attributes["isLocked"] == "YES"
            dict["isActive"] = attributes["isActive"] == "YES"
            if let opacityStr = attributes["opacity"], let opacity = Double(opacityStr) {
                dict["opacity"] = opacity
            }
            if let blendModeStr = attributes["blendMode"], let blendMode = Int(blendModeStr) {
                dict["blendMode"] = blendMode
            }
        }
        
        return dict
    }
    
    // MARK: - Attributed String Methods
    
    @objc func attributedString(fromXMLTree tree: LITMXMLTree) -> NSAttributedString? {
        guard let content = tree.contentsString() as String? else {
            return nil
        }
        
        let attributes: [NSAttributedString.Key: Any] = [:]
        // Add attributes based on XML tree
        
        return NSAttributedString(string: content, attributes: attributes)
    }
    
    // MARK: - Override Methods
    
    override func documentBaseTree() -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = "XRoseDocument"
        tree.addAttribute("VERSION", value: "1.0")
        return tree
    }
    
    override func dictionary(forDocumentTree tree: LITMXMLTree) -> [String: Any]? {
        var dict: [String: Any] = [:]
        
        for child in tree.children() {
            switch child.elementName {
            case "geometrySettings":
                dict["geometrySettings"] = dictionary(forGeometryControllerXMLTree: child)
            case "layersSettings":
                dict["layersSettings"] = dictionary(forTableControllerXMLTree: child)
            default:
                break
            }
        }
        
        return dict
    }
}
