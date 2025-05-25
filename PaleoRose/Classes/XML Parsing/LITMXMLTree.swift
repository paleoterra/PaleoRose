// LITMXMLTree.swift
//
// MIT License
//
// Copyright (c) 2003 to present Thomas L. Moore.
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

@objc class LITMXMLTree: NSObject, LITMXMLNodeProtocol {
    // MARK: - Properties

    @objc weak var nodeParent: LITMXMLTree?
    @objc var nodeChildren: NSMutableArray = []
    @objc var elementContents: String = ""
    @objc var elementName: String = ""
    @objc var elementAttributes: NSMutableDictionary = [:]
    @objc var attributeOrder: NSMutableArray = []
    @objc var elementType: String = ""
    @objc var isClosed: Bool = false
    private var level: Int = 0

    // MARK: - Initialization

    @objc static func xmlTree(withElementTag name: String, attributes: [String: Any]?, attributeOrder order: [Any]?, contents: String?) -> LITMXMLTree {
        let tree = LITMXMLTree()
        tree.elementName = name
        if let attrs = attributes {
            tree.elementAttributes = NSMutableDictionary(dictionary: attrs)
        }
        if let order {
            tree.attributeOrder = NSMutableArray(array: order)
        }
        if let contents {
            tree.elementContents = contents
        }
        return tree
    }

    @objc static func xmlTree(withElementTag name: String) -> LITMXMLTree {
        xmlTree(withElementTag: name, attributes: nil, attributeOrder: nil, contents: nil)
    }

    // MARK: - Attributes

    @objc func setAttributesDictionary(_ attributes: [String: Any]?) {
        if let attrs = attributes {
            elementAttributes = NSMutableDictionary(dictionary: attrs)
        } else {
            elementAttributes.removeAllObjects()
        }
    }

    @objc func attributesDictionary() -> [String: Any] {
        elementAttributes as? [String: Any] ?? [:]
    }

    @objc func addAttribute(_ name: String, value: String) {
        elementAttributes[name] = value
        if !attributeOrder.contains(name) {
            attributeOrder.add(name)
        }
    }

    @objc func removeAttribute(withName name: String) {
        elementAttributes.removeObject(forKey: name)
        attributeOrder.remove(name)
    } // 'remove' on NSMutableArray is safe if the object exists, does nothing otherwise.

    // MARK: - Contents

    @objc func setContentsString(_ string: String?) {
        elementContents = string ?? ""
    }

    @objc func contentsString() -> String {
        elementContents
    }

    @objc func appendContentsString(_ string: String) {
        elementContents += string
    }

    @objc func setBase16Contents(_ data: Data) {
        elementContents = LITMXMLBinaryEncoding.encodeBase16(data)
    }

    @objc func decodedBase16Contents() -> Data? {
        LITMXMLBinaryEncoding.decodeBase16(elementContents)
    }

    @objc func setBase64Contents(_ data: Data) {
        elementContents = LITMXMLBinaryEncoding.encodeBase64(data) ?? ""
    }

    @objc func decodedBase64Contents() -> Data? {
        LITMXMLBinaryEncoding.decodeBase64(elementContents)
    }

    // MARK: - Level

    @objc func setLevel(_ newLevel: Int) {
        level = newLevel
    }

    @objc func getLevel() -> Int {
        level
    }

    // MARK: - Tree Navigation

    @objc func findXMLTreeElement(_ name: String) -> LITMXMLTree? {
        if elementName == name {
            return self
        }

        for case let child as LITMXMLTree in nodeChildren {
            if let found = child.findXMLTreeElement(name) {
                return found
            }
        }

        return nil
    }

    // MARK: - Parent Management

    @objc func setParent(_ parent: LITMXMLTree?) {
        nodeParent = parent
    }

    @objc func parent() -> LITMXMLTree? {
        nodeParent
    }

    @objc func removeParent() {
        nodeParent = nil
    }

    // MARK: - Child Management

    @objc func insertChild(_ child: LITMXMLTree, at index: Int) {
        nodeChildren.insert(child, at: index)
        child.setParent(self)
    }

    @objc func addChild(_ child: LITMXMLTree) {
        nodeChildren.add(child)
        child.setParent(self)
    }

    @objc func removeChild(_ child: LITMXMLTree) {
        nodeChildren.remove(child)
        child.removeParent()
    }

    @objc func removeChild(at index: Int) {
        if let child = nodeChildren[index] as? LITMXMLTree {
            child.removeParent()
        }
        nodeChildren.removeObject(at: index)
    }

    @objc var childCount: Int {
        nodeChildren.count
    }

    @objc func firstChild() -> LITMXMLTree? {
        nodeChildren.firstObject as? LITMXMLTree
    }

    @objc func lastChild() -> LITMXMLTree? {
        nodeChildren.lastObject as? LITMXMLTree
    }

    @objc func child(at index: Int) -> LITMXMLTree? {
        nodeChildren[index] as? LITMXMLTree
    }

    @objc func index(of child: LITMXMLTree) -> Int {
        nodeChildren.index(of: child)
    }

    @objc func children() -> [LITMXMLTree] {
        if let nodeChildren as? [LITMXMLTree] {
            return nodeChildren
        }
        return []
    }

    @objc var isExpandable: Bool {
        !nodeChildren.isEmpty
    }

    // MARK: - XML Generation

    @objc func xml() -> String {
        elementTag("")
    }

    @objc func elementTag(_ levelIndent: String) -> String {
        if nodeChildren.isEmpty, elementContents.isEmpty {
            return childlessContentlessElementTag(elementName, withIndent: levelIndent)
        }

        var tag = "\(levelIndent)<\(elementName)"

        // Add attributes
        for name in attributeOrder {
            if let vname = name as? String, let value = elementAttributes[vname] as? String {
                tag += xmlAttributeName(vname value: value)
            }
        }

        if nodeChildren.isEmpty, !elementContents.isEmpty {
            tag += ">\(elementContents)</\(elementName)>\n"
            return tag
        }

        tag += ">\n"

        // Add children
        let nextIndent = levelIndent + "    "
        for case let child as LITMXMLTree in nodeChildren {
            tag += child.elementTag(nextIndent)
        }

        tag += "\(levelIndent)</\(elementName)>\n"
        return tag
    }

    @objc func xmlAttributeName(_ name: String, value: String) -> String {
        " \(name)=\"\(value)\""
    }

    @objc func closedElementTag(_ levelIndent: String) -> String {
        var tag = "\(levelIndent)<\(elementName)"

        // Add attributes
        for name in attributeOrder {
            if let vname = name as? String, let value = elementAttributes[vname] as? String {
                tag += xmlAttributeName(vname, value: value)
            }
        }

        tag += "/>\n"
        return tag
    }

    @objc func childlessContentlessElementTag(_ name: String, withIndent levelIndent: String) -> String {
        var tag = "\(levelIndent)<\(name)"

        // Add attributes
        for attrName in attributeOrder {
            if let vname = attrName as? String, let value = elementAttributes[vname] as? String {
                tag += xmlAttributeName(vname, value: value)
            }
        }

        tag += "/>\n"
        return tag
    }
}
