// MIT License
//
// Copyright (c) 2006 to present Thomas L. Moore.
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

import Cocoa
import SQLite3

@objc class XRMakeDatasetController: NSWindowController {
    // MARK: - Outlets
    
    @IBOutlet private weak var columnsPop: NSPopUpButton!
    @IBOutlet private weak var tablesPop: NSPopUpButton!
    @IBOutlet private weak var layerNameField: NSTextField!
    @IBOutlet private weak var predicateSource: NSTextView!
    @IBOutlet private weak var predicateTableColumnsPop: NSPopUpButton!
    @IBOutlet private weak var errorTextField: NSTextField!
    @IBOutlet private weak var placeholderView: NSView!
    @IBOutlet private weak var advancedSelectView: NSView!
    @IBOutlet private weak var advancedViewSwitch: NSButton!
    @IBOutlet private weak var createButton: NSButton!
    @IBOutlet private weak var validateButton: NSButton!
    @IBOutlet private weak var operatorPopup: NSPopUpButton!
    
    // MARK: - Properties
    
    private var tables: [String] = []
    private var columns: [String] = []
    private var selectColumns: [String] = []
    private var placeholderOriginalRect: NSRect = .zero
    private var windowOriginalRect: NSRect = .zero
    private var inMemoryStore: OpaquePointer?
    
    // MARK: - Initialization
    
    @objc init(tableArray tables: [String], inMemoryDocument db: OpaquePointer?) {
        self.tables = tables
        self.inMemoryStore = db
        self.columns = []
        self.selectColumns = []
        super.init(windowNibName: "XRCreateDatasetSheet")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tablesPop.removeAllItems()
        tablesPop.addItems(withTitles: tables)
        selectColumns(self)
        
        placeholderOriginalRect = placeholderView.frame
        windowOriginalRect = placeholderView.frame
        
        advancedSelectView.isHidden = true
        isValid = true
        errorTextField.stringValue = ""
        
        predicateSource.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        NSApp.endSheet(window!, returnCode: .cancel)
    }
    
    @IBAction func create(_ sender: Any) {
        NSApp.endSheet(window!, returnCode: .OK)
    }
    
    @IBAction func selectColumns(_ sender: Any) {
        guard let inMemoryStore = inMemoryStore,
              let selectedTable = tablesPop.titleOfSelectedItem else { return }
        
        let sqlQuery = "SELECT * FROM \"\(selectedTable)\" LIMIT 1"
        var sqlStatement: OpaquePointer?
        
        columns.removeAll()
        selectColumns.removeAll()
        
        if sqlite3_prepare_v2(inMemoryStore, sqlQuery, -1, &sqlStatement, nil) == SQLITE_OK {
            while sqlite3_step(sqlStatement) == SQLITE_ROW {
                let columnCount = sqlite3_column_count(sqlStatement)
                for columnIndex in 0..<columnCount {
                    let columnType = sqlite3_column_type(sqlStatement, columnIndex)
                    let columnName = String(cString: sqlite3_column_name(sqlStatement, columnIndex))
                    let name = String(cString: sqlite3_column_name(statement, i))
                    
                    if type == SQLITE_INTEGER || type == SQLITE_FLOAT {
                        columns.append(name)
                    }
                    selectColumns.append(name)
                }
            }
        }
        
        sqlite3_finalize(statement)
        
        columnsPop.removeAllItems()
        predicateTableColumnsPop.removeAllItems()
        columnsPop.addItems(withTitles: columns)
        predicateTableColumnsPop.addItems(withTitles: selectColumns)
    }
    
    @IBAction func showAdvancedSelect(_ sender: NSButton) {
        let difference = NSSize(
            width: advancedSelectView.frame.size.width - placeholderView.frame.size.width,
            height: advancedSelectView.frame.size.height - placeholderView.frame.size.height
        )
        
        if sender.state == .on {
            var frame = window!.frame
            frame.size.height += difference.height
            frame.origin.y -= difference.height
            window?.setFrame(frame, display: true, animate: true)
            
            var advancedFrame = advancedSelectView.frame
            advancedFrame.origin = placeholderView.frame.origin
            advancedFrame.origin.y -= difference.height
            advancedSelectView.frame = advancedFrame
            advancedSelectView.isHidden = false
        } else {
            advancedSelectView.isHidden = true
            var frame = window!.frame
            frame.origin.y += difference.height
            frame.size.height -= difference.height
            window?.setFrame(frame, display: true, animate: true)
        }
    }
    
    @IBAction func addPopupText(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        let text = sender == predicateTableColumnsPop ? " \"\(title)\" " : title
        predicateSource.insertText(text)
    }
    
    @IBAction func validatePredicate(_ sender: Any) {
        guard let inMemoryStore = inMemoryStore,
              let selectedTable = tablesPop.titleOfSelectedItem,
              let selectedColumn = columnsPop.titleOfSelectedItem,
              let predicateString = predicateSource.string else { return }
        
        let sql = """
            SELECT count(*) FROM "\(selectedTable)" 
            WHERE "\(selectedColumn)">=0 
            AND "\(selectedColumn)"<=360 
            AND \(predicateString)
        """
        
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(inMemoryStore, sql, nil, nil, &errorMessage) != SQLITE_OK {
            if let error = errorMessage {
                errorTextField.stringValue = String(cString: error)
                sqlite3_free(error)
            }
        } else {
            errorTextField.stringValue = ""
            isValid = true
        }
    }
    
    // MARK: - Properties
    
    @objc var selectedTable: String? {
        tablesPop.titleOfSelectedItem
    }
    
    @objc var selectedColumn: String? {
        columnsPop.titleOfSelectedItem
    }
    
    @objc var selectedName: String {
        layerNameField.stringValue
    }
    
    @objc var predicate: String {
        predicateSource.string.isEmpty ? "1" : predicateSource.string
    }
    
    var isValid: Bool = false {
        didSet {
            validateButton.isEnabled = !isValid
            createButton.isEnabled = isValid
        }
    }
}

// MARK: - NSTextViewDelegate

extension XRMakeDatasetController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        isValid = false
    }
}
