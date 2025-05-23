//
//  XRGeometryInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRGeometryInspector: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var systemPopup: NSPopUpButton!
    @IBOutlet private weak var subView: NSView!
    @IBOutlet private var gridView: NSView!
    
    // MARK: - Properties
    private var currentObject: XRGeometryController?
    
    // MARK: - Initialization
    init() {
        super.init(nibName: "XRGeometryInspector", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        systemPopup.selectItem(at: 0)
        
        // Add grid view to subview if not already added
        if !subView.subviews.contains(gridView) {
            subView.addSubview(gridView)
            gridView.frame = subView.bounds
            gridView.autoresizingMask = [.width, .height]
        }
    }
    
    // MARK: - Public Methods
    func displayInfo(for object: AnyObject?) {
        currentObject = object as? XRGeometryController
        updateUI()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        // Update UI based on currentObject
        // This is a placeholder - implement actual UI updates based on your needs
    }
    
    // MARK: - IBActions
    @IBAction private func systemPopupChanged(_ sender: NSPopUpButton) {
        // Handle system popup selection change
    }
    
    @IBAction private func maxValueChanged(_ sender: Any) {
        // Handle max value changes
        guard let popup = sender as? NSPopUpButton else { return }
        
        if popup.indexOfSelectedItem == 0 { // count
            if sender as AnyObject? === maxSizeTextBox {
                // Handle count max size text box
            }
            // Handle other count-specific controls
        } else {
            // Handle other unit types
        }
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - XRInspectorProtocol
extension XRGeometryInspector: XRInspectorProtocol {
    func displayInfo(for object: AnyObject?) {
        displayInfo(for: object)
    }
    
    var view: NSView {
        return self.view
    }
}
