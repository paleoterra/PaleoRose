// XRFileParser.swift
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

import Foundation

@objc class XRFileParser: NSObject {
    // MARK: - Static Methods

    @objc static func currentVersionXML(fromDictionary dictionary: [String: Any]) -> Data {
        let parser = XRFileParser1()
        var baseString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        let xmlTree = parser.documentBaseTree()
        if let geometrySettings = dictionary["geometrySettings"] as? [String: Any] {
            xmlTree.addChild(parser.treeForGeometryController(dictionary: geometrySettings))
        }
        if let layersSettings = dictionary["layersSettings"] as? [String: Any] {
            xmlTree.addChild(parser.treeForTableController(dictionary: layersSettings))
        }
        baseString += xmlTree.xml()
        return baseString.data(using: .utf8) ?? Data()
    }

    @objc static func xml(fromDictionary dict: [String: Any], forVersion version: String) -> Data? {
        nil
    }

    @objc static func file(fromXMLData data: Data) -> [String: Any]? {
        guard let parser = LITMXMLParser.xmlParser(for: data).treeArray().first,
              let version = parser.attributesDictionary()["VERSION"] as? String,
              version == "1.0"
        else {
            return nil
        }

        let fileParser = XRFileParser1()
        return fileParser.dictionary(forDocumentTree: parser)
    }

    // MARK: - Instance Methods

    @objc func documentBaseTree() -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forDocumentTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForDataSet(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forDataSetXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGeometryController(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGeometryControllerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForTableController(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forTableControllerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForLayer(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forLayerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForDataLayer(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forDataLayerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGridLayer(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGridLayerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForCoreLayer(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forCoreLayerXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphic(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicCircle(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicCircleXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicCircleLabel(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicCircleLabelXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicLine(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicLineXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicKite(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicKiteXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicPetal(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicPetalXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicDot(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicDotXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicHistogram(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicHistogramXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }

    @objc func treeForGraphicDotDeviation(dictionary dict: [String: Any]) -> LITMXMLTree? {
        nil
    }

    @objc func dictionary(forGraphicDotDeviationXMLTree tree: LITMXMLTree) -> [String: Any]? {
        nil
    }
}
