//
//  XRGridInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRGridInspector: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viewPopup: NSPopUpButton!
    @IBOutlet private weak var spokeFont: NSComboBox!
    @IBOutlet private weak var ringFont: NSComboBox!
    @IBOutlet private weak var ringPercentBox: NSTextField!
    @IBOutlet private weak var spokeFontSize: NSTextField!
    @IBOutlet private weak var spokeFontSizeStepper: NSStepper!
    
    // MARK: - Properties
    private var currentGrid: XRLayerGrid?
    
    // MARK: - Initialization
    init() {
        super.init(nibName: "XRGridInspector", bundle: nil)
        setupFonts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFonts()
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - Setup
    private func setupFonts() {
        loadViewIfNeeded()
        
        // Configure font popups
        let availableFonts = NSFontManager.shared.availableFonts.sorted()
        
        spokeFont.removeAllItems()
        spokeFont.addItems(withObjectValues: availableFonts)
        
        ringFont.removeAllItems()
        ringFont.addItems(withObjectValues: availableFonts)
        
        // Select first item
        viewPopup.selectItem(at: 0)
    }
    
    private func configureView() {
        // Additional view configuration
        ringPercentBox.formatter = LITMPercentFormatter()
    }
    
    // MARK: - Public Methods
    func displayInfo(for object: AnyObject?) {
        currentGrid = object as? XRLayerGrid
        updateUI()
    }
    
    // MARK: - IBActions
    @IBAction private func handleFontChange(_ sender: Any) {
        guard let grid = currentGrid else { return }
        
        if sender as AnyObject? === spokeFontSize || 
           sender as AnyObject? === spokeFontSizeStepper || 
           sender as AnyObject? === spokeFont {
            
            let fontSize = CGFloat(spokeFontSize.doubleValue)
            let fontName = spokeFont.stringValue
            
            if let font = NSFont(name: fontName, size: fontSize) {
                // Update grid's spoke font
                // grid.spokeFont = font
            }
        }
        
        // Handle other UI elements similarly
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        guard let grid = currentGrid else {
            // Reset UI to default state
            return
        }
        
        // Update UI elements based on grid properties
        // spokeFont.selectItem(withObjectValue: grid.spokeFont?.fontName ?? "")
        // spokeFontSize.doubleValue = grid.spokeFont?.pointSize ?? 12.0
        // spokeFontSizeStepper.doubleValue = Double(grid.spokeFont?.pointSize ?? 12.0)
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - XRInspectorProtocol
extension XRGridInspector: XRInspectorProtocol {
    func displayInfo(for object: AnyObject?) {
        displayInfo(for: object)
    }
    
    var view: NSView {
        return self.view
    }
}
