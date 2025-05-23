// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

// NOTIFICATIONS
let XRRoseViewDrawingRectDidChange = "XRRoseViewDrawingRectDidChange"

class XRoseView: NSView {
    @IBOutlet private var rosePlotController: XRGeometryController!
    @IBOutlet private var roseTableController: XRoseTableController!
    private var lastFrame: NSRect = .zero
    private var drawingRect: NSRect = .zero
    private var draggedObject: AnyObject?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        postsFrameChangedNotifications = true
        registerForDraggedTypes([.tiff])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var frame: NSRect {
        didSet {
            resetDrawingFrames()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        computeDrawingFrames()
    }

    override func draw(_ dirtyRect: NSRect) {
        roseTableController.draw(dirtyRect)
    }

    func resetDrawingFrames() {
        guard !frame.equalTo(lastFrame) else { return }
        computeDrawingFrames()
    }

    func computeDrawingFrames() {
        // Set last frame
        lastFrame = frame

        // Do work here
        // Estimate internal rect
        drawingRect = lastFrame
        if lastFrame.size.width > lastFrame.size.height {
            // Sets the width to be smaller
            drawingRect.size.width = lastFrame.size.height
        } else {
            // Sets the height to be smaller
            drawingRect.size.height = lastFrame.size.width
        }

        // Reset bounds to center the drawingRect in the view
        var newBounds = NSRect(origin: .zero, size: lastFrame.size)
        newBounds.origin.x = -1 * (lastFrame.size.width / 2.0)
        newBounds.origin.y = -1 * (lastFrame.size.height / 2.0)
        bounds = newBounds

        // Bounds are now reset. Reset the origin of the drawingRect
        drawingRect.origin.x = -1 * (drawingRect.size.width / 2.0)
        drawingRect.origin.y = -1 * (drawingRect.size.height / 2.0)

        // Post notification that the drawing rect has changed
        rosePlotController.resetGeometry(withBoundsRect: drawingRect)
        NotificationCenter.default.post(name: Notification.Name(XRRoseViewDrawingRectDidChange), object: self)
    }

    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown, event.clickCount > 1 {
            roseTableController.handleMouseEvent(event)
        } else if let layer = roseTableController.activeLayer(withPoint: convert(event.locationInWindow, from: nil)),
                  event.type == .leftMouseDown
        {
            guard let textLayer = layer as? XRLayerText,
                  let dragImage = textLayer.dragImage else { return }

            NSPasteboard(name: .drag).setData(dragImage.tiffRepresentation, forType: .tiff)
            draggedObject = layer

            beginDraggingSession(with: [NSDraggingItem(pasteboardWriter: dragImage)],
                                 event: event,
                                 source: self)
        } else {
            roseTableController.handleMouseEvent(event)
        }
    }

    func copyPDFToPasteboard() {
        guard let data = dataWithPDF(inside: bounds) else { return }
        NSPasteboard.general.declareTypes([.pdf], owner: self)
        NSPasteboard.general.setData(data, forType: .pdf)
    }

    func copyTIFFToPasteboard() {
        guard let pdfData = dataWithPDF(inside: bounds) else { return }
        let image = NSImage(size: bounds.size)
        image.addRepresentation(NSPDFImageRep(data: pdfData)!)

        NSPasteboard.general.declareTypes([.tiff], owner: self)
        NSPasteboard.general.setData(image.tiffRepresentation(using: .none, factor: 1.0), forType: .tiff)
    }

    // MARK: - Printing

    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        let printHeight = calculatePrintHeight()
        range.pointee.location = 1
        range.pointee.length = Int(bounds.height / printHeight + 1)
        return true
    }

    override func rect(forPage page: Int) -> NSRect {
        bounds
    }

    func calculatePrintHeight() -> CGFloat {
        guard let printOperation = NSPrintOperation.current,
              let printInfo = printOperation.printInfo else { return 0 }

        let paperSize = printInfo.paperSize
        let pageHeight = paperSize.height - printInfo.topMargin - printInfo.bottomMargin

        if let scale = printInfo.dictionary[NSPrintInfo.AttributeKey.scalingFactor] as? NSNumber {
            return pageHeight / CGFloat(scale.floatValue)
        }
        return pageHeight
    }

    // MARK: - Dragging

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        if let draggedObject = draggedObject as? XRLayerText,
           let dragImage = draggedObject.dragImage
        {
            NSPasteboard(name: .drag).declareTypes([.tiff], owner: self)
            NSPasteboard(name: .drag).setData(dragImage.tiffRepresentation, forType: .tiff)
            return .move
        }
        return []
    }

    private func dragOperationForDraggingInfo(_ sender: NSDraggingInfo) -> NSDragOperation {
        sender.draggingSource === self ? .move : []
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        dragOperationForDraggingInfo(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        dragOperationForDraggingInfo(sender)
    }

    override func draggingExited(_: NSDraggingInfo?) {}

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        sender.draggingSource === self
    }

    override func performDragOperation(_: NSDraggingInfo) -> Bool {
        true
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo) {
        let draggedImageLocation = convert(sender.draggedImageLocation, from: nil)
        if let textLayer = draggedObject as? XRLayerText {
            textLayer.move(to: draggedImageLocation)
        }
        draggedObject = nil
    }

    func xmlTreeForPreview() -> LITMXMLTree {
        let preview = LITMXMLTree(elementTag: "PREVIEW")
        preview.base64Contents = dataWithPDF(inside: bounds)
        return preview
    }

    func imageData(forType type: String) -> Data? {
        if type.lowercased() == "pdf" {
            return dataWithPDF(inside: bounds)
        } else if type.lowercased() == "tif" {
            guard let pdfData = dataWithPDF(inside: bounds) else { return nil }
            let image = NSImage(size: bounds.size)
            image.addRepresentation(NSPDFImageRep(data: pdfData)!)
            return image.tiffRepresentation(using: .none, factor: 1.0)
        } else if type.lowercased() == "jpg" {
            let image = NSImage(size: bounds.size)
            let transform = AffineTransform(translationByX: bounds.size.width / 2.0,
                                            byY: bounds.size.height / 2.0)

            image.lockFocus()
            NSColor.white.set()
            NSBezierPath(rect: NSRect(origin: .zero, size: bounds.size)).fill()
            transform.concat()
            draw(bounds)
            image.unlockFocus()

            guard let tiffData = image.tiffRepresentation(using: .none, factor: 1.0),
                  let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }

            return bitmap.representation(using: .jpeg,
                                         properties: [.compressionFactor: NSNumber(value: 1.0)])
        }
        return nil
    }
}
