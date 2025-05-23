//
//  XRPropertyInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

/// Keys for inspector types
enum XRInspectorType: String {
    case empty = "Empty"
    case geometry = "Geometry"
    case data = "Data"
    case core = "Core"
    case grid = "Grid"
    case vector = "Vector"
}

class XRPropertyInspector: NSWindowController {
    
    // MARK: - Properties
    private var inspectorControllers: [String: AnyObject] = [:]  // TODO: Replace AnyObject with a protocol
    private var currentInspector: AnyObject?
    private var currentInspectorView: NSView?
    
    // MARK: - Singleton
    static let shared = XRPropertyInspector()
    
    // MARK: - Initialization
    override init(window: NSWindow?) {
        super.init(window: nil)
        setupInspectors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupInspectors() {
        // Initialize all inspector controllers
        // TODO: Replace with actual inspector initializations
        inspectorControllers[XRInspectorType.empty.rawValue] = XREmptyInspectorController()
        inspectorControllers[XRInspectorType.geometry.rawValue] = XRGeometryInspector()
        inspectorControllers[XRInspectorType.data.rawValue] = XRDataInspector()
        inspectorControllers[XRInspectorType.core.rawValue] = XRCoreInspector()
        inspectorControllers[XRInspectorType.grid.rawValue] = XRGridInspector()
        // inspectorControllers[XRInspectorType.vector.rawValue] = XRVectorInspector()
    }
    
    // MARK: - Public Methods
    func displayInspector(for object: AnyObject?) {
        guard let object = object else {
            showEmptyInspector()
            return
        }
        
        // Determine the appropriate inspector based on the object type
        let inspectorKey: XRInspectorType
        
        switch object {
        case is XRLayerCore:
            inspectorKey = .core
        case is XRLayerData:
            inspectorKey = .data
        case is XRLayerGrid:
            inspectorKey = .grid
        // Add other cases as needed
        default:
            inspectorKey = .empty
        }
        
        showInspector(type: inspectorKey, for: object)
    }
    
    // MARK: - Private Methods
    private func showEmptyInspector() {
        showInspector(type: .empty, for: nil)
    }
    
    private func showInspector(type: XRInspectorType, for object: AnyObject?) {
        // Remove current inspector view
        currentInspectorView?.removeFromSuperview()
        
        // Get the new inspector
        guard let inspector = inspectorControllers[type.rawValue] else { return }
        
        // Configure the inspector with the object
        if let configurableInspector = inspector as? XRInspectorProtocol {
            configurableInspector.displayInfo(for: object)
        }
        
        // Add the inspector's view to the window
        if let inspectorView = (inspector as? NSViewController)?.view {
            currentInspectorView = inspectorView
            // TODO: Add layout constraints for the inspector view
        }
        
        currentInspector = inspector
    }
}

// MARK: - Inspector Protocol
protocol XRInspectorProtocol: AnyObject {
    func displayInfo(for object: AnyObject?)
    var view: NSView { get }
}
