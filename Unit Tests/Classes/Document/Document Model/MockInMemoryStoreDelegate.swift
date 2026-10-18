//
// MockInMemoryStoreDelegate.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2025 to present Thomas L. Moore.
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

class MockInMemoryStoreDelegate: InMemoryStoreDelegate {
    private(set) var tableNames: [String] = []
    private(set) var windowSize: CGSize = .zero
    private(set) var dataSets: [XRDataSet] = []
    private(set) var layers: [XRLayer] = []
    private(set) var capturedGeometry: Geometry?

    func update(tableNames: [String]) {
        self.tableNames = tableNames
    }

    func update(windowSize: CGSize) {
        self.windowSize = windowSize
    }

    func update(dataSets: [XRDataSet]) {
        self.dataSets = dataSets
    }

    func update(layers: [XRLayer]) {
        self.layers = layers
    }

    func update(geometry: Geometry) {
        capturedGeometry = geometry
    }
}
