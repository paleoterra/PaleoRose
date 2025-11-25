//
// LayerTableControllerDataSource.swift
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

import AppKit
import Combine

/// Protocol for providing layer data to LayersTableController
/// Implemented by DocumentModel to manage layer creation, deletion, and modification
protocol LayerTableControllerDataSource: AnyObject {
    /// Publisher that emits layer array whenever it changes
    var layersPublisher: AnyPublisher<[XRLayer], Never> { get }

    // MARK: - Layer Creation

    /// Creates a data layer for the specified dataset
    /// - Parameters:
    ///   - dataSetName: Name of the dataset to associate with the layer
    ///   - color: Color for the layer (stroke and fill)
    ///   - name: Optional custom name for the layer (auto-generated if nil)
    func createDataLayer(dataSetName: String, color: NSColor, name: String?)

    /// Creates a core layer
    /// - Parameters:
    ///   - name: Optional custom name for the layer
    func createCoreLayer(name: String?)

    /// Creates a grid layer
    /// - Parameters:
    ///   - name: Optional custom name for the layer
    func createGridLayer(name: String?)

    /// Creates a text layer
    /// - Parameters:
    ///   - name: Optional custom name for the layer
    ///   - parentView: Parent view for the text layer
    func createTextLayer(name: String?, parentView: NSView)

    /// Creates a line arrow layer (vector statistics)
    /// - Parameters:
    ///   - dataSetName: Name of the dataset to associate with the layer
    ///   - name: Optional custom name for the layer
    func createLineArrowLayer(dataSetName: String, name: String?)

    // MARK: - Layer Deletion

    /// Deletes a specific layer
    /// - Parameter layer: The layer to delete
    func deleteLayer(_ layer: XRLayer)

    /// Deletes layers at the specified indices
    /// - Parameter indices: Array of indices to delete
    func deleteLayers(at indices: [Int])

    /// Deletes all layers associated with a specific dataset
    /// - Parameter tableName: Name of the dataset whose layers should be deleted
    func deleteLayersForDataset(named tableName: String)

    // MARK: - Layer Modification

    /// Moves layers from one position to another
    /// - Parameters:
    ///   - indices: Array of layer indices to move
    ///   - destination: Destination index for the moved layers
    func moveLayers(from indices: [Int], to destination: Int)

    /// Updates the name of a layer
    /// - Parameters:
    ///   - layer: The layer to update
    ///   - newName: New name for the layer
    func updateLayerName(_ layer: XRLayer, newName: String)

    /// Updates the visibility of a layer
    /// - Parameters:
    ///   - layer: The layer to update
    ///   - isVisible: New visibility state
    func updateLayerVisibility(_ layer: XRLayer, isVisible: Bool)
}
