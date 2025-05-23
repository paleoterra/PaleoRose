//
//  XRGeometryPropertyInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRGeometryPropertyInspector: NSObject {
    
    // MARK: - Properties
    private var inspectorController: XRGeometryInspector?
    private var currentObject: AnyObject?
    
    // MARK: - Singleton
    static let shared = XRGeometryPropertyInspector()
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupInspector()
    }
    
    // MARK: - Setup
    private func setupInspector() {
        inspectorController = XRGeometryInspector()
    }
    
    // MARK: - Public Methods
    func displayInfo(for object: AnyObject?) {
        currentObject = object
        
        if let geometryObject = object as? XRGeometryController {
            inspectorController?.displayInfo(for: geometryObject)
        } else {
            // Handle case where object is not a geometry object
            inspectorController?.displayInfo(for: nil)
        }
    }
    
    // MARK: - View Access
    var view: NSView? {
        return inspectorController?.view
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - XRInspectorProtocol
extension XRGeometryPropertyInspector: XRInspectorProtocol {
    func displayInfo(for object: AnyObject?) {
        displayInfo(for: object)
    }
    
    var view: NSView {
        guard let inspectorView = inspectorController?.view else {
            return NSView()
        }
        return inspectorView
    }
}
