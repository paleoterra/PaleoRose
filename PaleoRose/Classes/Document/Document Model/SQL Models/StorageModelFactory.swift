//
// StorageModelFactory.swift
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
import CodableSQLiteNonThread

// swiftlint:disable type_body_length
class StorageModelFactory {

    enum StorageModelFactoryError: Error {
        case invalidLayerIdentifiable
    }

    var colors: [Color] = []
    let defaultStrokeColor: NSColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    let defaultFillColor: NSColor = .init(red: 1, green: 1, blue: 1, alpha: 1)

    func set(colors: [Color]) {
        clearColors()
        self.colors = colors
    }

    func clearColors() {
        colors.removeAll()
    }

    func strokeColor(id: Int) -> NSColor {
        guard let color = color(id: id) else {
            return defaultStrokeColor
        }
        return color
    }

    func fillColor(id: Int) -> NSColor {
        guard let color = color(id: id) else {
            return defaultFillColor
        }
        return color
    }

    func color(id: Int) -> NSColor? {
        guard let color = colors.first(where: { $0.COLORID == id }) else {
            return nil
        }
        return NSColor(
            red: CGFloat(color.RED),
            green: CGFloat(color.GREEN),
            blue: CGFloat(color.BLUE),
            alpha: CGFloat(color.ALPHA)
        )
    }

    // MARK: - Create Storage Layers

    func storageLayers(from inputLayer: XRLayer, at index: Int) -> [TableRepresentable] {
        var layers = [TableRepresentable]()
        layers.append(storageLayerRoot(from: inputLayer, at: index))
        switch inputLayer {
        case let layer as XRLayerCore:
            layers.append(storageLayerCore(from: layer, at: index))

        case let layer as XRLayerText:
            layers.append(storageLayerText(from: layer, at: index))

        case let layer as XRLayerLineArrow:
            layers.append(storageLayerLineArrow(from: layer, at: index))

        case let layer as XRLayerGrid:
            layers.append(storageLayerGrid(from: layer, at: index))

        case let layer as XRLayerData:
            layers.append(storageLayerData(from: layer, at: index))

        default:
            break
        }
        return layers
    }

    func storageLayerRoot(from inputLayer: XRLayer, at index: Int) -> Layer {
        Layer(
            LAYERID: index,
            TYPE: inputLayer.type(),
            VISIBLE: inputLayer.isVisible(),
            ACTIVE: inputLayer.isActive(),
            BIDIR: inputLayer.isBiDirectional(),
            LAYER_NAME: inputLayer.layerName(),
            LINEWEIGHT: inputLayer.lineWeight(),
            MAXCOUNT: Int(inputLayer.maxCount()),
            MAXPERCENT: Float(inputLayer.maxPercent()),
            STROKECOLORID: 0,
            FILLCOLORID: 0
        )
    }

    func storageLayerCore(from inputLayer: XRLayerCore, at index: Int) -> LayerCore {
        LayerCore(
            LAYERID: index,
            RADIUS: inputLayer.radius(),
            TYPE: inputLayer.coreType()
        )
    }

    func storageLayerText(from inputLayer: XRLayerText, at index: Int) -> LayerText {
        LayerText(
            LAYERID: index,
            CONTENTS: Encoding.encodeTextStorage(from: inputLayer.contents()),
            RECT_POINT_X: Float(inputLayer.textRect().origin.x),
            RECT_POINT_Y: Float(inputLayer.textRect().origin.y),
            RECT_SIZE_WIDTH: Float(inputLayer.textRect().size.width),
            RECT_SIZE_HEIGHT: Float(inputLayer.textRect().size.height)
        )
    }

    func storageLayerLineArrow(from inputLayer: XRLayerLineArrow, at index: Int) -> LayerLineArrow {
        LayerLineArrow(
            LAYERID: index,
            DATASET: Int(inputLayer.datasetId()),
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

    func storageLayerData(from inputLayer: XRLayerData, at index: Int) -> LayerData {
        LayerData(
            LAYERID: index,
            DATASET: Int(inputLayer.datasetId()),
            PLOTTYPE: Int(inputLayer.plotType()),
            TOTALCOUNT: Int(inputLayer.totalCount()),
            DOTRADIUS: inputLayer.dotRadius()
        )
    }

    func storageGeometry(from geometryController: XRGeometryController) -> Geometry {
        Geometry(
            isEqualArea: geometryController.isEqualArea(),
            isPercent: geometryController.isPercent(),
            MAXCOUNT: Int(geometryController.geometryMaxCount()),
            MAXPERCENT: geometryController.geometryMaxPercent(),
            HOLLOWCORE: geometryController.hollowCoreSize(),
            SECTORSIZE: geometryController.sectorSize(),
            STARTINGANGLE: geometryController.startingAngle(),
            SECTORCOUNT: Int(geometryController.sectorCount()),
            RELATIVESIZE: geometryController.relativeSizeOfCircleRect()
        )
    }

    // MARK: - Create XRLayer Types

    func createXRLayer(baseLayer: Layer, targetLayer: LayerIdentifiable) throws -> XRLayer {
        switch targetLayer {
        case let layer as LayerText:
            return createXRLayerText(layer: baseLayer, textLayer: layer)

        case let layer as LayerLineArrow:
            return createXRLayerLineArrow(layer: baseLayer, lineArrowLayer: layer)

        case let layer as LayerCore:
            return createXRLayerCore(layer: baseLayer, coreLayer: layer)

        case let layer as LayerGrid:
            return createXRLayerGrid(layer: baseLayer, gridLayer: layer)

        case let layer as LayerData:
            return createXRLayerData(layer: baseLayer, dataLayer: layer)

        default:
            throw StorageModelFactoryError.invalidLayerIdentifiable
        }
    }

    func createXRLayerText(layer: Layer, textLayer: LayerText) -> XRLayerText {

        XRLayerText(
            isVisible: layer.VISIBLE,
            active: layer.ACTIVE,
            biDir: layer.BIDIR,
            name: layer.LAYER_NAME,
            lineWeight: layer.LINEWEIGHT,
            maxCount: Int32(layer.MAXCOUNT),
            maxPercent: layer.MAXPERCENT,
            stroke: strokeColor(id: layer.STROKECOLORID),
            fill: fillColor(id: layer.FILLCOLORID),
            contents: Encoding.decodeTextStorage(from: textLayer.CONTENTS),
            rectOriginX: textLayer.RECT_POINT_X,
            rectOriginY: textLayer.RECT_POINT_Y,
            rectHeight: textLayer.RECT_SIZE_HEIGHT,
            rectWidth: textLayer.RECT_SIZE_WIDTH
        )
    }

    func createXRLayerLineArrow(layer: Layer, lineArrowLayer: LayerLineArrow) -> XRLayerLineArrow {

        XRLayerLineArrow(
            isVisible: layer.VISIBLE,
            active: layer.ACTIVE,
            biDir: layer.BIDIR,
            name: layer.LAYER_NAME,
            lineWeight: layer.LINEWEIGHT,
            maxCount: Int32(layer.MAXCOUNT),
            maxPercent: layer.MAXPERCENT,
            stroke: strokeColor(id: layer.STROKECOLORID),
            fill: fillColor(id: layer.FILLCOLORID),
            arrowSize: lineArrowLayer.ARROWSIZE,
            vectorType: Int32(lineArrowLayer.VECTORTYPE),
            arrowType: Int32(lineArrowLayer.ARROWTYPE),
            showVector: lineArrowLayer.SHOWVECTOR,
            showError: lineArrowLayer.SHOWERROR
        )
    }

    func createXRLayerCore(layer: Layer, coreLayer: LayerCore) -> XRLayerCore {

        XRLayerCore(
            isVisible: layer.VISIBLE,
            active: layer.ACTIVE,
            biDir: layer.BIDIR,
            name: layer.LAYER_NAME,
            lineWeight: layer.LINEWEIGHT,
            maxCount: Int32(layer.MAXCOUNT),
            maxPercent: layer.MAXPERCENT,
            stroke: strokeColor(id: layer.STROKECOLORID),
            fill: fillColor(id: layer.FILLCOLORID),
            percentRadius: coreLayer.RADIUS,
            type: coreLayer.TYPE
        )
    }

    func createXRLayerData(layer: Layer, dataLayer: LayerData) -> XRLayerData {
        XRLayerData(
            isVisible: layer.VISIBLE,
            active: layer.ACTIVE,
            biDir: layer.BIDIR,
            name: layer.LAYER_NAME,
            lineWeight: layer.LINEWEIGHT,
            maxCount: Int32(layer.MAXCOUNT),
            maxPercent: layer.MAXPERCENT,
            stroke: strokeColor(id: layer.STROKECOLORID),
            fill: fillColor(id: layer.FILLCOLORID),
            plotType: Int32(dataLayer.PLOTTYPE),
            totalCount: Int32(dataLayer.TOTALCOUNT),
            dotRadius: dataLayer.DOTRADIUS
        )
    }

    func createXRLayerGrid(layer: Layer, gridLayer: LayerGrid) -> XRLayerGrid {
        let ringFont = NSFont(name: gridLayer.RINGS_FONTNAME, size: CGFloat(gridLayer.RINGS_FONTSIZE)) ??
            NSFont.systemFont(ofSize: CGFloat(gridLayer.RINGS_FONTSIZE))
        let radialFont = NSFont(name: gridLayer.RADIALS_FONT, size: CGFloat(gridLayer.RADIALS_FONTSIZE)) ??
            NSFont.systemFont(ofSize: CGFloat(gridLayer.RADIALS_FONTSIZE))
        return XRLayerGrid(
            isVisible: layer.VISIBLE,
            active: layer.ACTIVE,
            biDir: layer.BIDIR,
            name: layer.LAYER_NAME,
            lineWeight: layer.LINEWEIGHT,
            maxCount: Int32(layer.MAXCOUNT),
            maxPercent: layer.MAXPERCENT,
            stroke: strokeColor(id: layer.STROKECOLORID),
            fill: fillColor(id: layer.FILLCOLORID),
            isFixedCount: gridLayer.RINGS_ISFIXEDCOUNT,
            ringsVisible: gridLayer.RINGS_VISIBLE,
            fixedRingCount: Int32(gridLayer.RINGS_FIXEDCOUNT),
            ringCountIncrement: Int32(gridLayer.RINGS_COUNTINCREMENT),
            ringPercentIncrement: gridLayer.RINGS_PERCENTINCREMENT,
            showRingLabels: gridLayer.RINGS_LABELS,
            labelAngle: gridLayer.RINGS_LABELANGLE,
            ring: ringFont,
            radialsCount: Int32(gridLayer.RADIALS_COUNT),
            radialsAngle: gridLayer.RADIALS_ANGLE,
            radialsLabelAlignment: Int32(gridLayer.RADIALS_LABELALIGN),
            radialsCompassPoint: Int32(gridLayer.RADIALS_COMPASSPOINT),
            radialsOrder: Int32(gridLayer.RADIALS_ORDER),
            radialFont: radialFont,
            radialsSectorLock: gridLayer.RADIALS_SECTORLOCK,
            radialsVisible: gridLayer.RADIALS_VISIBLE,
            radialsIsPercent: gridLayer.RADIALS_ISPERCENT,
            radialsTicks: gridLayer.RADIALS_TICKS,
            radialsMinorTicks: gridLayer.RADIALS_MINORTICKS,
            radialLabels: gridLayer.RADIALS_LABELS
        )
    }
}
