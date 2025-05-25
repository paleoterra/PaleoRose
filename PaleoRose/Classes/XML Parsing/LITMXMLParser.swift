// LITMXMLParser.swift
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

@objc class LITMXMLParser: NSObject, XMLParserDelegate {
    private var rootArray: [LITMXMLTree] = []

    @objc static func xmlParser(for data: Data) -> LITMXMLParser {
        let parser = LITMXMLParser()
        let baseParser = XMLParser(data: data)
        baseParser.delegate = parser
        baseParser.parse()
        return parser
    }

    @objc override init() {
        super.init()
    }

    @objc func treeArray() -> [LITMXMLTree] {
        rootArray
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let tree = LITMXMLTree()
        tree.elementName = elementName
        tree.elementType = "element"
        tree.attributesDictionary = attributeDict
        tree.attributeOrder = NSMutableArray(array: attributeDict.keys.map { $0 })
        rootArray.append(tree)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let indexOfTree = rootArray.lastIndex { $0.elementName == elementName } ?? -1
        guard indexOfTree >= 0 else { return }

        let tree = rootArray[indexOfTree]
        tree.isClosed = true

        // Add all subsequent elements as children
        for index in (indexOfTree + 1) ..< rootArray.count {
            tree.addChild(rootArray[index])
        }

        // Remove all subsequent elements from root array
        rootArray.removeSubrange((indexOfTree + 1) ..< rootArray.count)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let lastTree = rootArray.last,
              !lastTree.isClosed,
              lastTree.childCount == 0 else { return }

        lastTree.appendContentsString(string)
    }

    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        // Processing instruction handling can be implemented here if needed
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Error handling can be implemented here if needed
    }
}
