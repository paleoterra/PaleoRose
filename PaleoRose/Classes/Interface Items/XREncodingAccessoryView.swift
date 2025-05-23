//
//  XREncodingAccessoryView.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XREncodingAccessoryView: NSView {

    // MARK: - Properties

    private let encodingPopup: NSPopUpButton

    // MARK: - Public Properties

    var selectedEncoding: String.Encoding {
        get {
            guard let identifier = encodingPopup.selectedItem?.representedObject as? UInt,
                  let encoding = String.Encoding(rawValue: identifier)
            else {
                return .utf8
            }
            return encoding
        }
        set {
            if let index = encodingPopup.indexOfItem(withRepresentedObject: NSNumber(value: newValue.rawValue)) {
                encodingPopup.selectItem(at: index)
            }
        }
    }

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        // Create and configure UI elements
        encodingPopup = NSPopUpButton(frame: NSRect(x: 140, y: 16, width: 150, height: 26))
        super.init(frame: NSRect(x: 0, y: 0, width: 314, height: 55))

        setupUI()
    }

    convenience init() {
        self.init(frame: NSRect(x: 0, y: 0, width: 314, height: 55))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // Configure view
        autoresizingMask = [.width, .height]

        // Add encoding label
        let labelFrame = NSRect(x: 17, y: 20, width: 114, height: 19)
        let label = NSTextField(labelWithString: "Encoding:")
        label.frame = labelFrame
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        addSubview(label)

        // Configure encoding popup
        encodingPopup.target = self
        encodingPopup.action = #selector(encodingDidChange(_:))

        // Add common encodings
        let encodings: [String.Encoding] = [
            .utf8,
            .utf16,
            .windowsCP1252,
            .macOSRoman,
            .ascii
        ]

        for encoding in encodings {
            let title = String.localizedName(of: encoding)
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.representedObject = NSNumber(value: encoding.rawValue)
            encodingPopup.menu?.addItem(item)
        }

        // Add to view
        addSubview(encodingPopup)
    }

    // MARK: - Actions

    @objc private func encodingDidChange(_: NSPopUpButton) {
        // Handle encoding change if needed
    }
}
