// XRTableImporterDelimiterController.swift
//
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

@objc class XRTableImporterDelimiterController: NSObject {
    // MARK: - Properties
    
    @objc private(set) var tableName: String = ""
    @objc private var columnTitles: Int = 0
    @objc private var delimiterFieldValue: String = ""
    @objc private var delimiterPopup: Int = 0
    @objc private var encodingValue: Int = 0
    
    @IBOutlet private weak var window: NSWindow!
    @IBOutlet private weak var tableNameField: NSTextField!
    @IBOutlet private weak var delimiterField: NSTextField!
    
    // MARK: - Initialization
    
    @objc init?(path: String) {
        super.init()
        
        guard Bundle.main.loadNibNamed("XRTableInitialTextController", owner: self, topLevelObjects: nil) else {
            return nil
        }
        
        if !path.isEmpty {
            tableName = (path as NSString).lastPathComponent.deletingPathExtension
        } else {
            tableName = "Untitled_Table"
        }
        
        delimiterFieldValue = ", "
        columnTitles = NSControl.StateValue.on.rawValue
    }
    
    // MARK: - Actions
    
    @IBAction func cancelImport(_ sender: Any) {
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }
    
    @IBAction func import(_ sender: Any) {
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
    
    // MARK: - Public API
    
    @objc var activateDelimiterField: Bool {
        delimiterPopup > 0
    }
    
    override class func keyPathsForValuesAffecting(_ key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffecting(key)
        
        if key == "activateDelimiterField" {
            keyPaths.insert("delimiterPopup")
        }
        
        return keyPaths
    }
    
    @objc var results: [String: Any] {
        var dict: [String: Any] = [
            "tableName": tableName,
            "columnTitles": columnTitles,
            "delimiterPopup": delimiterPopup,
            "delimiterFieldValue": delimiterFieldValue
        ]
        
        let encoding: String.Encoding
        switch encodingValue {
        case 0:
            encoding = .ascii
        case 1:
            encoding = .macOSRoman
        case 2:
            encoding = .windowsCP1254
        case 3:
            encoding = .utf8
        case 4:
            encoding = .isoLatin1
        case 5:
            encoding = .isoLatin2
        default:
            encoding = .ascii
        }
        
        dict["encodingValue"] = encoding.rawValue
        return dict
    }
}
