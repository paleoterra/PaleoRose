// XRLayerText.swift
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

@objc class XRLayerText: XRLayer, NSTextViewDelegate {
    // MARK: - Properties

    private var contents: NSTextStorage
    private var textBounds: NSRect
    private var estimatedRadius: Float
    private var estimatedAngle: Float
    private var tempView: NSTextView?
    private var gutter: Float
    private weak var parentView: NSView?

    // MARK: - Class Methods

    override class func classTag() -> String {
        "Text"
    }

    // MARK: - Initialization

    @objc init(geometryController: XRGeometryController, parentView: NSView) {
        contents = NSTextStorage()
        textBounds = NSRect.zero
        estimatedRadius = 0.0
        estimatedAngle = 0.0
        gutter = 5.0
        self.parentView = parentView

        super.init(geometryController: geometryController)
    }

    @objc init(isVisible: Bool,
               active: Bool,
               biDir: Bool,
               name: String,
               lineWeight: Float,
               maxCount: Int,
               maxPercent: Float,
               strokeColor: NSColor,
               fillColor: NSColor,
               contents: NSAttributedString,
               rectOriginX: Float,
               rectOriginY: Float,
               rectHeight: Float,
               rectWidth: Float)
    {
        self.contents = NSTextStorage(attributedString: contents)
        textBounds = NSRect(x: CGFloat(rectOriginX),
                            y: CGFloat(rectOriginY),
                            width: CGFloat(rectWidth),
                            height: CGFloat(rectHeight))
        estimatedRadius = 0.0
        estimatedAngle = 0.0
        gutter = 5.0

        super.init()

        setIsVisible(isVisible)
        setIsActive(active)
        setBiDirectional(biDir)
        setLayerName(name)
        setLineWeight(lineWeight)
        self.maxCount = maxCount
        self.maxPercent = maxPercent
        setStrokeColor(strokeColor)
        setFillColor(fillColor)
    }

    required init(geometryController: XRGeometryController) {
        contents = NSTextStorage()
        textBounds = NSRect.zero
        estimatedRadius = 0.0
        estimatedAngle = 0.0
        gutter = 5.0

        super.init(geometryController: geometryController)
    }

    required init(geometryController: XRGeometryController, dictionary: [String: Any]) {
        contents = NSTextStorage()
        textBounds = NSRect.zero
        estimatedRadius = 0.0
        estimatedAngle = 0.0
        gutter = 5.0

        super.init(geometryController: geometryController, dictionary: dictionary)
        configureSelf(with: dictionary)
    }

    override required init() {
        contents = NSTextStorage()
        textBounds = NSRect.zero
        estimatedRadius = 0.0
        estimatedAngle = 0.0
        gutter = 5.0

        super.init()
    }

    // MARK: - Setup Methods

    private func configureSelf(with dictionary: [String: Any]) {
        if let encodedContents = dictionary["Contents"] as? String,
           let data = Data(base64Encoded: encodedContents),
           let attributedString = try? NSAttributedString(data: data,
                                                          options: [:],
                                                          documentAttributes: nil)
        {
            contents = NSTextStorage(attributedString: attributedString)
        }

        if let rect = dictionary["TextRect"] as? [String: Float] {
            textBounds = NSRect(x: CGFloat(rect["x"] ?? 0),
                                y: CGFloat(rect["y"] ?? 0),
                                width: CGFloat(rect["width"] ?? 100),
                                height: CGFloat(rect["height"] ?? 100))
        }
    }

    // MARK: - Public Methods

    @objc func setContents(_ newContents: Any) {
        if let string = newContents as? String {
            contents = NSTextStorage(string: string)
        } else if let attributedString = newContents as? NSAttributedString {
            contents = NSTextStorage(attributedString: attributedString)
        }
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func getContents() -> NSTextStorage {
        contents
    }

    @objc func imageBounds() -> NSRect {
        textBounds
    }

    @objc func dragImage() -> NSImage {
        let image = NSImage(size: textBounds.size)
        image.lockFocus()

        // Draw text content into image
        contents.draw(in: NSRect(origin: .zero, size: textBounds.size))

        image.unlockFocus()
        return image
    }

    @objc func moveToPoint(_ newPoint: NSPoint) {
        textBounds.origin = newPoint
        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func displayTextFieldForEditing(_: NSEvent) {
        guard let parentView else { return }

        tempView = NSTextView(frame: textBounds)
        tempView?.delegate = self
        tempView?.textStorage?.setAttributedString(contents)
        tempView?.backgroundColor = .clear

        parentView.addSubview(tempView!)
        tempView?.window?.makeFirstResponder(tempView)
    }

    @objc func removeTextFieldAfterEditing(_: NSEvent) {
        contents = NSTextStorage(attributedString: tempView?.textStorage ?? NSAttributedString())
        tempView?.removeFromSuperview()
        tempView = nil

        generateGraphics()
        NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
    }

    @objc func encodedContents() -> String {
        if let data = try? contents.data(from: NSRange(location: 0, length: contents.length),
                                         documentAttributes: [:])
        {
            return data.base64EncodedString()
        }
        return ""
    }

    @objc func textRect() -> NSRect {
        textBounds
    }

    // MARK: - XML Support

    override func xmlTree(forVersion version: String) -> LITMXMLTree {
        let tree = super.baseXMLTree(forVersion: version)

        tree.addAttribute("Contents", value: encodedContents())
        tree.addAttribute("TextRect_X", value: String(format: "%.1f", Float(textBounds.origin.x)))
        tree.addAttribute("TextRect_Y", value: String(format: "%.1f", Float(textBounds.origin.y)))
        tree.addAttribute("TextRect_Width", value: String(format: "%.1f", Float(textBounds.size.width)))
        tree.addAttribute("TextRect_Height", value: String(format: "%.1f", Float(textBounds.size.height)))

        return tree
    }

    override func configure(withXMLTree1_0 configureTree: LITMXMLTree) {
        super.configure(withXMLTree1_0: configureTree)

        if let attributes = configureTree.attributesDictionary() as? [String: String] {
            if let encodedContents = attributes["Contents"],
               let data = Data(base64Encoded: encodedContents),
               let attributedString = try? NSAttributedString(data: data,
                                                              options: [:],
                                                              documentAttributes: nil)
            {
                contents = NSTextStorage(attributedString: attributedString)
            }

            let xValue = Float(attributes["TextRect_X"] ?? "0.0") ?? 0.0
            let yValue = Float(attributes["TextRect_Y"] ?? "0.0") ?? 0.0
            let width = Float(attributes["TextRect_Width"] ?? "100.0") ?? 100.0
            let height = Float(attributes["TextRect_Height"] ?? "100.0") ?? 100.0

            textBounds = NSRect(x: CGFloat(xValue),
                                y: CGFloat(yValue),
                                width: CGFloat(width),
                                height: CGFloat(height))
        }
    }

    // MARK: - Drawing

    override func generateGraphics() {
        // Generate text graphics
    }

    override func draw(_: NSRect) {
        // Draw text content
        contents.draw(in: textBounds)
    }

    // MARK: - NSTextViewDelegate

    func textDidChange(_ notification: Notification) {
        if let textView = notification.object as? NSTextView {
            contents = NSTextStorage(attributedString: textView.textStorage ?? NSAttributedString())
            generateGraphics()
            NotificationCenter.default.post(name: NSNotification.Name(XRLayerRequiresRedraw), object: self)
        }
    }
}
