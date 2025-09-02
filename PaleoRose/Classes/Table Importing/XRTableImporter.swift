// XRTableImporter.swift
// XRose
//
// Created by Tom Moore on 12/13/05.
//
// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

@objc class XRTableImporter: NSObject {
    // MARK: - Properties

    private var sourcePath: String = ""
    private var targetDocument: NSDocument?
    private var delimiterController: XRTableImporterDelimiterController?
    private var importerController: XRTableImporterXRose?

    // MARK: - Public Methods

    @objc func importTable(fromFile source: String, for document: NSDocument) {
        sourcePath = source
        targetDocument = document

        let pathExtension = (source as NSString).pathExtension.lowercased()

        switch pathExtension {
        case "txt":
            importTextFromFile()
        case "xrose":
            importFromXRoseDB()
        case "xml":
            importFromFMXML()
        default:
            break
        }
    }

    // MARK: - Private Methods

    private func clear() {
        sourcePath = ""
        targetDocument = nil
    }

    private func importTextFromFile() {
        delimiterController = XRTableImporterDelimiterController(path: sourcePath)

        guard
            let window = targetDocument?.windowControllers.first?.window,
            let sheet = delimiterController?.window else { return }

        window.beginSheet(sheet) { [weak self] response in
            guard let self else { return }

            if response == .OK {
                processTextImport()
            }
            delimiterController = nil
        }
    }

    private func processTextImport() {
        guard
            let results = delimiterController?.results,
            let tableName = results["tableName"] as? String,
            let sourceString = try? String(contentsOfFile: sourcePath, encoding: .utf8) else { return }

        var lines = sourceString.components(separatedBy: .newlines)
        if lines.count == 1 {
            lines = sourceString.components(separatedBy: "\r")
        }

        let contents = lines.map { $0.components(separatedBy: "\t") }
        guard
            let columnCount = contents.first?.count,
            contents.allSatisfy({ $0.count == columnCount })
        else {
            presentError("Text table has improper shape.")
            return
        }

        var columnTitles: [String]
        var dataContents = contents

        if (results["columnTitles"] as? Int) == NSControl.StateValue.on.rawValue {
            columnTitles = contents[0]
            dataContents.removeFirst()
        } else {
            columnTitles = (0 ..< columnCount).map { "Column_\($0 + 1)" }
        }

        let types = determineColumnTypes(for: dataContents, columnCount: columnCount)
        let createSQL = createTableSQL(tableName: tableName, columnTitles: columnTitles, types: types)

        createTable(withSQL: createSQL, contents: dataContents, tableName: tableName, columnNames: columnTitles)
    }

    private func determineColumnTypes(for contents: [[String]], columnCount: Int) -> [String] {
        var types: [String] = []
        let letterSet = CharacterSet.letters

        for column in 0 ..< columnCount {
            let isText = contents.contains { row in
                guard column < row.count else { return false }
                return row[column].rangeOfCharacter(from: letterSet) != nil
            }
            types.append(isText ? "TEXT" : "NUMERIC")
        }

        return types
    }

    private func createTableSQL(tableName: String, columnTitles: [String], types: [String]) -> String {
        var sql = "CREATE TABLE \"\(tableName)\" (\n"
        sql += "\t_id INTEGER PRIMARY KEY,\n"

        for (index, (title, type)) in zip(columnTitles, types).enumerated() {
            sql += "\t\"\(title)\" \(type)"
            sql += index == columnTitles.count - 1 ? "\n" : ",\n"
        }
        sql += ")"

        return sql
    }

    private func createTable(withSQL sqlCreate: String, contents: [[String]], tableName: String, columnNames: [String]) {
        guard let db = (targetDocument as? XRoseDocument)?.documentInMemoryStore else { return }

        var errorMsg: UnsafeMutablePointer<Int8>?

        // Begin transaction
        guard sqlite3_exec(db, "BEGIN", nil, nil, &errorMsg) == SQLITE_OK else {
            presentSQLiteError(String(cString: errorMsg!))
            sqlite3_exec(db, "ROLLBACK", nil, nil, &errorMsg)
            return
        }

        // Create table
        guard sqlite3_exec(db, sqlCreate, nil, nil, &errorMsg) == SQLITE_OK else {
            presentSQLiteError(String(cString: errorMsg!))
            sqlite3_exec(db, "ROLLBACK", nil, nil, &errorMsg)
            return
        }

        // Insert data
        let baseSQL = "INSERT INTO \"\(tableName)\" (\(columnNames.map { "\"\($0)\"" }.joined(separator: ","))) VALUES "

        for row in contents {
            let values = row.map { "\"\($0)\"" }.joined(separator: ",")
            let insertSQL = baseSQL + "(\(values))"

            guard sqlite3_exec(db, insertSQL, nil, nil, &errorMsg) == SQLITE_OK else {
                presentSQLiteError(String(cString: errorMsg!))
                sqlite3_exec(db, "ROLLBACK", nil, nil, &errorMsg)
                return
            }
        }

        // Commit transaction
        guard sqlite3_exec(db, "COMMIT", nil, nil, &errorMsg) == SQLITE_OK else {
            presentSQLiteError(String(cString: errorMsg!))
            sqlite3_exec(db, "ROLLBACK", nil, nil, &errorMsg)
            return
        }

        NotificationCenter.default.post(name: NSNotification.Name("XRTableListChanged"), object: nil)
    }

    private func importFromXRoseDB() {
        guard let db = openXRoseDatabase() else { return }
        defer { sqlite3_close(db) }

        let tableNames = fetchTableNames(from: db)
        importerController = XRTableImporterXRose()
        importerController?.setTableNames(tableNames)

        guard
            let window = targetDocument?.windowControllers.first?.window,
            let sheet = importerController?.window else { return }

        window.beginSheet(sheet) { [weak self] response in
            guard
                let self,
                response == .OK,
                let selectedTables = importerController?.selectedTableNames,
                !selectedTables.isEmpty else { return }

            importSelectedTables(selectedTables, from: db)
            importerController = nil
            NotificationCenter.default.post(name: NSNotification.Name("XRTableListChanged"), object: nil)
        }
    }

    private func importFromFMXML() {
        guard let parser = PTFMXMLParser(xmlAtPath: sourcePath) else {
            presentError("Could not create XML parser")
            return
        }

        guard parser.isCorrectType else {
            presentError("Incorrect XML format")
            return
        }

        guard parser.isValidParse else {
            presentError("Invalid XML file")
            return
        }

        var error: NSError?
        guard
            let db = (targetDocument as? XRoseDocument)?.documentInMemoryStore,
            parser.writeToSQLITE(db, withError: &error)
        else {
            if let error {
                presentError(error.localizedDescription)
            }
            return
        }

        NotificationCenter.default.post(name: NSNotification.Name("XRTableListChanged"), object: nil)
    }

    private func presentError(_ message: String) {
        let error = NSError(domain: "com.paleoterra.xrose",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message])
        targetDocument?.presentError(error)
    }

    private func presentSQLiteError(_ message: String) {
        let error = NSError(domain: "SQLITE",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message])
        targetDocument?.presentError(error)
    }

    private func openXRoseDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        guard sqlite3_open(sourcePath, &db) == SQLITE_OK else {
            if let db {
                sqlite3_close(db)
            }
            presentError("Could not open XRose database")
            return nil
        }
        return db
    }

    private func fetchTableNames(from db: OpaquePointer) -> [String] {
        var names: [String] = []
        var statement: OpaquePointer?
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let name = sqlite3_column_text(statement, 0) {
                    names.append(String(cString: name))
                }
            }
        }

        sqlite3_finalize(statement)
        return names
    }

    private func importSelectedTables(_ tables: [String], from sourceDB: OpaquePointer) {
        guard let targetDB = (targetDocument as? XRoseDocument)?.documentInMemoryStore else { return }

        for table in tables {
            importTable(table, from: sourceDB, to: targetDB)
        }
    }

    private func importTable(_ table: String, from sourceDB: OpaquePointer, to targetDB: OpaquePointer) {
        var statement: OpaquePointer?
        let schemaQuery = "SELECT sql FROM sqlite_master WHERE type='table' AND name=?"

        guard sqlite3_prepare_v2(sourceDB, schemaQuery, -1, &statement, nil) == SQLITE_OK else { return }
        sqlite3_bind_text(statement, 1, table, -1, nil)

        guard
            sqlite3_step(statement) == SQLITE_ROW,
            let schemaBytes = sqlite3_column_text(statement, 0)
        else {
            sqlite3_finalize(statement)
            return
        }

        let schema = String(cString: schemaBytes)
        sqlite3_finalize(statement)

        var errorMsg: UnsafeMutablePointer<Int8>?
        guard sqlite3_exec(targetDB, schema, nil, nil, &errorMsg) == SQLITE_OK else {
            if let error = errorMsg {
                presentSQLiteError(String(cString: error))
                sqlite3_free(error)
            }
            return
        }

        let insertQuery = "INSERT INTO \"\(table)\" SELECT * FROM source.\"\(table)\""
        guard sqlite3_exec(targetDB, insertQuery, nil, nil, &errorMsg) == SQLITE_OK else {
            if let error = errorMsg {
                presentSQLiteError(String(cString: error))
                sqlite3_free(error)
            }
            return
        }
    }
}
