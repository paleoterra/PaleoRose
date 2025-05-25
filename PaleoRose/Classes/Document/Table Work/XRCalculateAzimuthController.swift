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

@objc class XRCalculateAzimuthController: NSObject {
    // MARK: - Outlets

    @IBOutlet private var tableNamePop: NSPopUpButton!
    @IBOutlet private var targetPop: NSPopUpButton!
    @IBOutlet private var window: NSWindow!
    @IBOutlet private var xVectorPop: NSPopUpButton!
    @IBOutlet private var yVectorPop: NSPopUpButton!

    // MARK: - Properties

    private var tables: [String] = []
    private var columnList: [String] = []
    private let initialSelectedIndex: Int
    private weak var document: XRoseDocument?

    // MARK: - Initialization

    @objc init(document: XRoseDocument, itemSelectedAtIndex index: Int) {
        self.document = document
        initialSelectedIndex = index
        super.init()
        Bundle.main.loadNibNamed("XRCalculateAzimuthSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        guard let document else { return }

        tables = document.tableList()

        tableNamePop.removeAllItems()
        tableNamePop.addItems(withTitles: tables)
        tableNamePop.selectItem(at: initialSelectedIndex)

        populateSelectedColumns(self)
    }

    // MARK: - Actions

    @IBAction func execute(_: Any) {
        NSApp.endSheet(window, returnCode: .OK)
    }

    @IBAction func cancel(_: Any) {
        NSApp.endSheet(window, returnCode: .cancel)
    }

    @IBAction func populateSelectedColumns(_: Any) {
        guard let document,
              let selectedTable = tableNamePop.titleOfSelectedItem else { return }

        let populateItems = document.retrieveNonTextColumnNames(fromTable: selectedTable)

        for popup in [xVectorPop, yVectorPop, targetPop] {
            popup?.removeAllItems()
            popup?.addItems(withTitles: populateItems)
        }
    }

    // MARK: - Public API

    @objc var resultDictionary: [String: String] {
        [
            "table": tableNamePop.titleOfSelectedItem ?? "",
            "xVector": xVectorPop.titleOfSelectedItem ?? "",
            "yVector": yVectorPop.titleOfSelectedItem ?? "",
            "target": targetPop.titleOfSelectedItem ?? ""
        ]
    }
}
