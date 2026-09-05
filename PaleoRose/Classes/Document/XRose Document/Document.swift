//
// Document.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2026 to present Thomas L. Moore.
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
import CodableSQLiteNonThread
import OSLog

class Document: NSDocument {
    private let documentModel: any DocumentModelProtocol

    override init() {
        do {
            documentModel = try DocumentModel(
                inMemoryStore: InMemoryStore(interface: SQLiteInterface())
            )
            super.init()
        } catch {
            Logger.documentLogger.error("Failed to initialize document model: \(error)")
            fatalError("Failed to initialize document model: \(error)")
        }
    }

    init(documentModel: any DocumentModelProtocol) {
        self.documentModel = documentModel
        super.init()
    }

    override func read(from url: URL, ofType typeName: String) throws {
        switch typeName {
        case "XRose":
            try documentModel.openFile(url)

        default:
            throw CocoaError(.fileReadUnknown)
        }
    }

    override func write(to url: URL, ofType typeName: String) throws {
        switch typeName {
        case "XRose":
            try documentModel.writeToFile(url)

        default:
            throw CocoaError(.fileWriteUnknown)
        }
    }

    override func makeWindowControllers() {
        let windowController = XRoseWindowController(windowNibName: "XRoseDocument")
        addWindowController(windowController)
        windowController.documentModel = documentModel
    }

    override class var autosavesInPlace: Bool {
        true
    }

    override func printDocument(_: Any?) {
        guard let windowController = windowControllers.first as? XRoseWindowController else {
            Logger.documentLogger.error("No window controller for document: \(self)")
            return
        }
        windowController.printDiagram(printInfo)
    }
}
