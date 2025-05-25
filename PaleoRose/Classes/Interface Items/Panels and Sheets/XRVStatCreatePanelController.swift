//
//  XRVStatCreatePanelController.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRVStatCreatePanelController: NSWindowController {
    // MARK: - Properties

    private let names: [String]

    // MARK: - Initialization

    init(names: [String]) {
        self.names = names
        super.init(window: nil)
        loadWindow()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Window Lifecycle

    override var windowNibName: String? {
        "XRVStatPanel"
    }

    // MARK: - Actions

    @IBAction func cancel(_: Any) {
        guard let window else { return }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }

    @IBAction func createLayer(_: Any) {
        guard let window else { return }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }

    // MARK: - Public Methods

    var selectedName: String? {
        guard let popup = window?.contentView?.viewWithTag(1) as? NSPopUpButton else {
            return nil
        }
        return popup.titleOfSelectedItem
    }
}
