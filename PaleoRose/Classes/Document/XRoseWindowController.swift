// XRoseWindowController.swift
// MIT License
// Copyright (c) 2005 to present Thomas L. Moore.
import Cocoa
import SQLite3

@objc class XRoseWindowController: NSWindowController, NSToolbarDelegate {
    weak var documentModel: DocumentModel?
    weak var rosePlotController: AnyObject?
    weak var roseTableController: AnyObject?
    weak var roseTableView: AnyObject?
    weak var roseView: AnyObject?
    weak var tableSplitView: AnyObject?
    weak var windowSplitView: AnyObject?
    var splitterOnePosition: Float = 0.0
    var splitterTwoPosition: Float = 0.0
    var tableDataList: [Any]? = nil
    weak var tableNameTableView: AnyObject?

    @objc func getTableController() -> AnyObject? { nil }
    @objc func getGeometryController() -> AnyObject? { nil }
    @objc func copyPDFToPasteboard() {}
    @objc func copyTIFFToPasteboard() {}
    @objc func getMainView() -> NSView? { nil }
    @objc func getWindowControllerXMLSettings() -> LITMXMLTree? { nil }
    @objc func setWindowSettings(withXMLTree xmlTree: LITMXMLTree) {}
    @objc func setTableDataList(_ tableDataArray: [Any]) { tableDataList = tableDataArray }
    @objc func windowControllerXMLSettings() -> LITMXMLTree? { nil }
    @objc func setWindowSettings(withXMLTree tree: LITMXMLTree) {}
    @objc func setTableList(_ tableArray: [Any]) { tableList = tableArray }
    @IBAction func addLayerAction(_: Any?) {}
    @IBAction func deleteLayerAction(_: Any?) {}
    @IBAction func importTableAction(_: Any?) {}
    @IBAction func deleteTableAction(_: Any?) {}
    @objc func updateTable() {}
    @objc func performAzimuthFromVector() {}
    @objc func importerCompleted(_: Notification) {}
}
