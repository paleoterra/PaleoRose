// XRoseDocument.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import AppKit
import SQLite3

@objc class XRoseDocument: NSDocument {
    // MARK: - Data Management

    @objc func addDataLayer(_: Any?) {}
    @objc func removeDataSet(_: XRDataSet) {}
    @objc func configureDocument() {}
    @objc func fTestStatistics(forSetNames setNames: [String], biDirectional: Bool) -> String? { nil }
    @objc func importTable(_: Any?) {}
    @objc func discoverTables() {}
    @objc func documentInMemoryStore() -> OpaquePointer? { nil }
    @objc func renameDataSetTable(from oldName: String, to newName: String) {}
    @objc func tableList() -> [Any]? { nil }
    @objc func retrieveNonTextColumnNames(fromTable tableName: String) -> [Any]? { nil }
}
