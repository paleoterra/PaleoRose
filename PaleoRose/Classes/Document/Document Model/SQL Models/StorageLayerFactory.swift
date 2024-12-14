//
// LayerFactory.swift
// PaleoRose
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

import Cocoa

struct StorageLayerFactory {

    // MARK: - Utility Methods

    func encodeTextStorage(from input: NSTextStorage) -> Data {
        let range = NSRange(location: 0, length: input.length)
        let rtfData = input.rtf(from: range)
        if let base64EncodedString = rtfData?.base64EncodedString(), let data = base64EncodedString.data(using: .utf8) {
            return data
        }
        return Data()
    }

    func decodeTextStorage(from input: Data) -> NSTextStorage? {
        guard let base64EncodedString = String(
            data: input,
            encoding: .utf8
        ), let rtfData = base64EncodedString.data(using: .utf8) else {
            return nil
        }
        return NSTextStorage(rtf: rtfData, documentAttributes: nil)
    }

    // MARK: - Create Storage Layers
    func storageLayer(from inputLayer: XRLayer, at index: Int) -> Layer {
        Layer(
            LAYERID: index,
            TYPE: inputLayer.type(),
            VISIBLE: inputLayer.isVisible(),
            ACTIVE: inputLayer.isActive(),
            BIDIR: inputLayer.isBiDirectional(),
            LAYER_NAME: inputLayer.layerName(),
            LINEWEIGHT: inputLayer.lineWeight(),
            MAXCOUNT: Int(inputLayer.maxCount()),
            MAXPERCENT: Float(inputLayer.maxPercent())
        )
    }

    func storageLayer(from inputLayer: XRLayerCore, at index: Int) -> LayerCore {
        LayerCore(
            LAYERID: index,
            RADIUS: inputLayer.radius(),
            TYPE: inputLayer.coreType()
        )
    }

    func storageLayerText(from inputLayer: XRLayerText, at index: Int) -> LayerText {
        LayerText(
            LAYERID: index,
            CONTENTS: encodeTextStorage(from: inputLayer.contents()),
            RECT_POINT_X: Float(inputLayer.textRect().origin.x),
            RECT_POINT_Y: Float(inputLayer.textRect().origin.y),
            RECT_SIZE_WIDTH: Float(inputLayer.textRect().size.width),
            RECT_SIZE_HEIGHT: Float(inputLayer.textRect().size.height)
        )
    }

    // **** PROBLEM
    func storageLayerLineArrow(from inputLayer: XRLayerLineArrow, at index: Int, dataSetId: Int) -> LayerLineArrow {
        LayerLineArrow(
            LAYERID: index,
            DATASET: dataSetId,
            ARROWSIZE: inputLayer.arrowSize(),
            VECTORTYPE: Int(inputLayer.vectorType()),
            ARROWTYPE: Int(inputLayer.arrowType()),
            SHOWVECTOR: inputLayer.showVector(),
            SHOWERROR: inputLayer.showError()
        )
    }

    func storageLayerGrid(from inputLayer: XRLayerGrid, at index: Int) -> LayerGrid {
        LayerGrid(
            LAYERID: index,
            RINGS_ISFIXEDCOUNT: inputLayer.fixedCount(),
            RINGS_VISIBLE: inputLayer.isVisible(),
            RINGS_LABELS: inputLayer.showLabels(),
            RINGS_FIXEDCOUNT: Int(inputLayer.fixedRingCount()),
            RINGS_COUNTINCREMENT: Int(inputLayer.ringCountIncrement()),
            RINGS_PERCENTINCREMENT: inputLayer.ringPercentIncrement(),
            RINGS_LABELANGLE: inputLayer.ringLabelAngle(),
            RINGS_FONTNAME: inputLayer.ringFontName(),
            RINGS_FONTSIZE: inputLayer.ringFontSize(),
            RADIALS_COUNT: Int(inputLayer.radialsCount()),
            RADIALS_ANGLE: inputLayer.radialsAngle(),
            RADIALS_LABELALIGN: Int(inputLayer.radialsLabelAlign()),
            RADIALS_COMPASSPOINT: Int(inputLayer.radialsCompassPoint()),
            RADIALS_ORDER: Int(inputLayer.radiansOrder()),
            RADIALS_FONT: inputLayer.radianFontName(),
            RADIALS_FONTSIZE: inputLayer.radianFontSize(),
            RADIALS_SECTORLOCK: inputLayer.radianSectorLock(),
            RADIALS_VISIBLE: inputLayer.radianVisible(),
            RADIALS_ISPERCENT: inputLayer.radianIsPercent(),
            RADIALS_TICKS: inputLayer.radianTicks(),
            RADIALS_MINORTICKS: inputLayer.radianMintoTicks(),
            RADIALS_LABELS: inputLayer.radianLabels()
        )
    }

    // ***** PROBLEM
    func storageLayerData(from inputLayer: XRLayerData, at index: Int, dataSetId: Int) -> LayerData {
        LayerData(
            LAYERID: index,
            DATASET: dataSetId,
            PLOTTYPE: Int(inputLayer.plotType()),
            TOTALCOUNT: Int(inputLayer.totalCount()),
            DOTRADIUS: inputLayer.dotRadius()
            )
    }
}
