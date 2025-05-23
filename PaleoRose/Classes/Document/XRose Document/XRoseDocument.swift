// XRoseDocument.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import AppKit
import SQLite3

@objc class XRoseDocument: NSDocument {
    // MARK: - Data Management
    @objc func addDataLayer(_ sender: Any?) {}
    @objc func removeDataSet(_ dataSet: XRDataSet) {}
    @objc func configureDocument() {}
    @objc func fTestStatistics(forSetNames setNames: [String], biDirectional: Bool) -> String? { return nil }
    @objc func importTable(_ sender: Any?) {}
    @objc func discoverTables() {}
    @objc func documentInMemoryStore() -> OpaquePointer? { return nil }
    @objc func renameDataSetTable(from oldName: String, to newName: String) {}
    @objc func tableList() -> [Any]? { return nil }
    @objc func retrieveNonTextColumnNames(fromTable tableName: String) -> [Any]? { return nil }
}
