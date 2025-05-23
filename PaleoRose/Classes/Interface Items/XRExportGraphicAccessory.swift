//
//  XRExportGraphicAccessory.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRExportGraphicAccessory: NSView {
    
    // MARK: - Properties
    private let popupButton: NSPopUpButton
    
    // MARK: - Public Properties
    var selectedFormat: ExportFormat {
        get {
            guard let title = popupButton.titleOfSelectedItem,
                  let format = ExportFormat(rawValue: title.lowercased()) else {
                return .pdf
            }
            return format
        }
    }
    
    // MARK: - Enums
    enum ExportFormat: String {
        case pdf
        case jpeg
        case tiff
        
        var fileExtension: String {
            return self.rawValue
        }
    }
    
    // MARK: - Initialization
    override init(frame frameRect: NSRect) {
        // Create and configure the popup button
        popupButton = NSPopUpButton(frame: NSRect(x: 65, y: 16, width: 190, height: 26))
        super.init(frame: frameRect)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Factory Method
    static func createAccessoryView() -> XRExportGraphicAccessory {
        let frame = NSRect(x: 0, y: 0, width: 272, height: 60)
        return XRExportGraphicAccessory(frame: frame)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure popup button
        popupButton.removeAllItems()
        popupButton.addItems(withTitles: ["PDF", "JPEG", "TIFF"])
        popupButton.target = self
        popupButton.action = #selector(selectionDidChange(_:))
        
        // Add to view
        addSubview(popupButton)
        
        // Configure view
        autoresizingMask = [.width, .height]
    }
    
    // MARK: - Actions
    @objc private func selectionDidChange(_ sender: NSPopUpButton) {
        // Handle selection change if needed
    }
    
    // MARK: - Public Methods
    func setSelectedFormat(_ format: ExportFormat) {
        popupButton.selectItem(withTitle: format.rawValue.uppercased())
    }
}
