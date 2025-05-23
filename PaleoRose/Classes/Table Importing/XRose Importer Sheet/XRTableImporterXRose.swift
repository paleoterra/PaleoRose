//
//  XRTableImporterXRose.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRTableImporterXRose: NSObject {

    // MARK: - Properties

    private var tables: [TableInfo] = []

    // MARK: - Types

    struct TableInfo {
        var isSelected: Bool
        var name: String
    }

    // MARK: - Initialization

    override init() {
        super.init()
        loadNib()
    }

    // MARK: - Nib Loading

    private func loadNib() {
        var topLevelObjects: NSArray? = []
        Bundle.main.loadNibNamed("XRTableImporterXRoseSheet",
                                 owner: self,
                                 topLevelObjects: &topLevelObjects)
    }

    // MARK: - Public Methods

    func setTableNames(_ names: [String]) {
        tables = names.map { TableInfo(isSelected: true, name: $0) }
    }

    func selectedTableNames() -> [String] {
        tables.filter(\.isSelected).map(\.name)
    }

    // MARK: - Table Data Source (for NSTableView if needed)

    var numberOfTables: Int {
        tables.count
    }

    func tableName(at index: Int) -> String? {
        guard index >= 0, index < tables.count else { return nil }
        return tables[index].name
    }

    func isTableSelected(at index: Int) -> Bool {
        guard index >= 0, index < tables.count else { return false }
        return tables[index].isSelected
    }

    func setSelected(_ selected: Bool, forTableAt index: Int) {
        guard index >= 0, index < tables.count else { return }
        tables[index].isSelected = selected
    }

    // MARK: - Sheet Presentation

    func beginSheetModal(for window: NSWindow, completionHandler: @escaping (NSApplication.ModalResponse) -> Void) {
        guard let sheet = self.window else {
            completionHandler(.cancel)
            return
        }

        window.beginSheet(sheet) { response in
            completionHandler(response)
        }
    }

    // MARK: - IBOutlets & IBActions (if using xib)

    @IBOutlet private var window: NSWindow?

    @IBAction private func cancel(_: Any) {
        guard let window else { return }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }

    @IBAction private func importSelected(_: Any) {
        guard let window else { return }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }

    // MARK: - Deinitialization

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
