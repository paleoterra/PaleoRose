//
//  XREmptyInspectorController.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XREmptyInspectorController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet private(set) var contentView: NSView!

    // MARK: - Initialization

    init() {
        super.init(nibName: "XREmptyInspector", bundle: nil)
        loadViewIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewIfNeeded()
    }

    // MARK: - View Lifecycle

    override func loadView() {
        super.loadView()

        // Ensure the nib is loaded
        Bundle.main.loadNibNamed("XREmptyInspector", owner: self, topLevelObjects: nil)

        // Set up the view hierarchy
        if contentView.superview == nil {
            view = contentView
        }
    }

    // MARK: - Public Methods

    func displayInfo(for object: AnyObject?) {
        // No action needed for empty inspector
    }
}

// MARK: - XRInspectorProtocol

extension XREmptyInspectorController: XRInspectorProtocol {
    var view: NSView {
        contentView
    }
}
