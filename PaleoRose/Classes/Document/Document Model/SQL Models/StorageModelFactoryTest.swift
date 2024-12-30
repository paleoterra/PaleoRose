//
// StorageModelFactoryTest.swift
// Unit Tests
//
// MIT License
//
// Copyright (c) 2024 to present Thomas L. Moore.
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

struct StorageModelFactoryTest {
    let sut = StorageModelFactory()

    @Test("Given a layer text, then generate the correct storage layers")
    func createTextLayer() throws {
        let original = XRLayerText.stub()
        let location = 27
        let layer = sut.storageLayerRoot(from: original, at: location)
        #expect(layer.compare(with: original, id: location))

        let textLayer = sut.storageLayerText(from: original, at: location)

        #expect(try textLayer.compare(with: original, id: location))
    }

    @Test("Given a layer line arrow, then generate the correct storage layers")
    func createLineArrowLayer() throws {
        let original = XRLayerLineArrow.stub()
        let location = 27
        let layer = sut.storageLayerRoot(from: original, at: location)
        #expect(layer.compare(with: original, id: location))

        let textLayer = sut.storageLayerLineArrow(from: original, at: location)

        #expect(textLayer.compare(with: original, id: location))
    }

    @Test("Given a layer grid, then generate the correct storage layers")
    func createGridLayer() throws {
        let original = XRLayerGrid.stub()
        let location = 27
        let layer = sut.storageLayerRoot(from: original, at: location)
        #expect(layer.compare(with: original, id: location))

        let textLayer = sut.storageLayerGrid(from: original, at: location)

        #expect(textLayer.compare(with: original, id: location))
    }

    @Test("Given a layer core, then generate the correct storage layers")
    func createCoreLayer() throws {
        let original = XRLayerCore.stub()
        let location = 27
        let layer = sut.storageLayerRoot(from: original, at: location)
        #expect(layer.compare(with: original, id: location))

        let textLayer = sut.storageLayerCore(from: original, at: location)

        #expect(textLayer.compare(with: original, id: location))
    }

    @Test("Given a layer data, then generate the correct storage layers")
    func createDataLayer() throws {
        let original = XRLayerData.stub()
        let location = 27
        let layer = sut.storageLayerRoot(from: original, at: location)
        #expect(layer.compare(with: original, id: location))

        let textLayer = sut.storageLayerData(from: original, at: location)

        #expect(textLayer.compare(with: original, id: location))
    }

    // MARK: - XRLayer Type Creation

    @Test("Given a layer and layertext, then correctly create XRLayerText")
    func createTextLayerFromStorage() throws {
        let layerid = 4
        let layer = Layer.stub(LAYERID: layerid, TYPE: "XRLayerText")
        let textLayer = LayerText.stub(LAYERID: layerid)

        let xrLayer = sut.createXRLayerText(layer: layer, textLayer: textLayer)

        #expect(layer.compare(with: xrLayer, id: layerid))
        #expect(try textLayer.compare(with: xrLayer, id: layerid))
    }

    @Test("Given a layer and line arrow, then correctly create XRLayerLineArrow")
    func createLineArrowLayerFromStorage() throws {
        let layerid = 5
        let layer = Layer.stub(LAYERID: layerid, TYPE: "XRLayerLineArrow")
        let lineArrow = LayerLineArrow.stub(LAYERID: layerid)

        let xrLayer = sut.createXRLayerLineArrow(layer: layer, lineArrowLayer: lineArrow)

        #expect(layer.compare(with: xrLayer, id: layerid))
        #expect(lineArrow.compare(with: xrLayer, id: layerid))
    }

    @Test("Given a layer and grid, then correctly create XRLayerGrid")
    func createGridLayerFromStorage() {
        let layerid = 6
        let layer = Layer.stub(LAYERID: layerid, TYPE: "XRLayerGrid")
        let grid = LayerGrid.stub(LAYERID: layerid)

        let xrLayer = sut.createXRLayerGrid(layer: layer, gridLayer: grid)

        #expect(layer.compare(with: xrLayer, id: layerid))
        #expect(grid.compare(with: xrLayer, id: layerid))
    }

    @Test("Given a layer and core, then correctly create XRLayerCore")
    func createCoreLayerFromStorage() {
        let layerid = 7
        let layer = Layer.stub(LAYERID: layerid, TYPE: "XRLayerCore")
        let core = LayerCore.stub(LAYERID: layerid)

        let xrLayer = sut.createXRLayerCore(layer: layer, coreLayer: core)

        #expect(layer.compare(with: xrLayer, id: layerid))
        #expect(core.compare(with: xrLayer, id: layerid))
    }

    @Test("Given a layer and data, then correctly create XRLayerData")
    func createDataLayerFromStorage() {
        let layerid = 8
        let layer = Layer.stub(LAYERID: layerid, TYPE: "XRLayerData")
        let data = LayerData.stub(LAYERID: layerid)

        let xrLayer = sut.createXRLayerData(layer: layer, dataLayer: data)

        #expect(layer.compare(with: xrLayer, id: layerid))
        #expect(data.compare(with: xrLayer, id: layerid))
    }
}
