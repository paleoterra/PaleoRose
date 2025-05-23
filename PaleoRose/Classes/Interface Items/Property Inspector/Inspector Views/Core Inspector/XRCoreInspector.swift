//
//  XRCoreInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRCoreInspector: NSObject {
    // MARK: - Properties
    private var objectController: NSObjectController!
    private var viewPopup: NSPopUpButton!
    private weak var _object: XRLayerCore?
    
    var inspectedObject: XRLayerCore? {
        get { return _object }
        set {
            _object = newValue
            objectController.content = _object
            objectController.objectClass = XRLayerCore.self
            changeView(viewPopup)
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        Bundle.main.loadNibNamed("XRLayerCore", owner: self, topLevelObjects: nil)
    }
    
    // MARK: - View Management
    @objc private func changeView(_ sender: NSPopUpButton) {
        // Implementation for view change logic
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
