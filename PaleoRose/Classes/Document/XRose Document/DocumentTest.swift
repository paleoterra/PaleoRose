//
// DocumentTest.swift
// Unit Tests
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

@testable import PaleoRose
import Testing

@MainActor
struct DocumentTest {
    enum DocumentTestError: Error, Equatable {
        case readingDocumentFailed
        case windowControllerNotFound
        case writingDocumentFailed
    }

    @Test("Initialization")
    func initialization() {
        let mockDocumentModel = MockDocumentModel()
        let sut = Document(documentModel: mockDocumentModel)
        #expect(sut.isDocumentEdited == false)
    }

    // MARK: Reading the document

    @Test("Document Reading Fails")
    func readingDocumentFails() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRose"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        mockDocumentModel.errorToThrow = DocumentTestError.readingDocumentFailed
        let sut = Document(documentModel: mockDocumentModel)

        #expect(throws: DocumentTestError.readingDocumentFailed) {
            _ = try sut.read(from: url, ofType: typeName)
        }
        #expect(mockDocumentModel.openFileCalled)
        #expect(mockDocumentModel.url == nil)
        print("printing url")
        print("\(String(describing: mockDocumentModel.url?.path))")
    }

    @Test("Document Invalid File Type Fails")
    func readingDocumentFailsBadType() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRoseXX"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        let sut = Document(documentModel: mockDocumentModel)

        #expect(throws: CocoaError(.fileReadUnknown)) {
            _ = try sut.read(from: url, ofType: typeName)
        }
        #expect(!mockDocumentModel.openFileCalled)
        #expect(mockDocumentModel.url == nil)
    }

    @Test("Document Reading Happy Path")
    func readDocumentSuccess() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRose"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        let sut = Document(documentModel: mockDocumentModel)
        try sut.read(from: url, ofType: typeName)
    }

    @Test("Make Window Controllers")
    func creatingTheMainController() throws {
        let mockDocumentModel = MockDocumentModel()
        let sut = Document(documentModel: mockDocumentModel)

        #expect(sut.windowControllers.isEmpty)
        sut.makeWindowControllers()
        #expect(sut.windowControllers.count == 1)

        guard let windowController = sut.windowControllers.first as? XRoseWindowController else {
            throw DocumentTestError.windowControllerNotFound
        }
        #expect(windowController.documentModel === mockDocumentModel)
    }

    @Test("Document Invalid File Type Fails")
    func writeInvalidFileType() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRoseXX"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        let sut = Document(documentModel: mockDocumentModel)

        #expect(throws: CocoaError(.fileWriteUnknown)) {
            _ = try sut.write(to: url, ofType: typeName)
        }
        #expect(!mockDocumentModel.writeToFileCalled)
        #expect(mockDocumentModel.url == nil)
    }

    @Test("Document fails to write")
    func writingFileFails() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRose"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        let sut = Document(documentModel: mockDocumentModel)
        mockDocumentModel.errorToThrow = DocumentTestError.writingDocumentFailed
        #expect(throws: DocumentTestError.writingDocumentFailed) {
            _ = try sut.write(to: url, ofType: typeName)
        }
        #expect(mockDocumentModel.writeToFileCalled)
        #expect(mockDocumentModel.url == nil)
    }

    @Test("Document write to file succeeds")
    func writingFileSucceeds() throws {
        let mockDocumentModel = MockDocumentModel()
        let typeName = "XRose"
        let url = try #require(URL(string: "file:///Volumes/test/MyFile.XRose"))
        let sut = Document(documentModel: mockDocumentModel)

        try sut.write(to: url, ofType: typeName)

        #expect(mockDocumentModel.writeToFileCalled)
    }
}
