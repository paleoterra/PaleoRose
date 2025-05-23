// PTFMXMLParser.swift
// XRose
//
// Created by Tom Moore on 12/28/05.
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

@objc class PTFMXMLParser: NSObject, XMLParserDelegate {
    // MARK: - Properties
    
    private var tableDefinition: [[String: String]] = []
    private var dataRows: [[Any]] = []
    private var isValid: Bool = false
    private var correctType: Bool = false
    private var parser: XMLParser
    private var currentRow: [Any]?
    private var currentContents: NSMutableString?
    private var hasData: Bool = false
    private var tableName: String = ""
    private var tableStep: Int = 0
    
    // MARK: - Initialization
    
    @objc init?(xmlAtPath path: String) {
        guard let url = URL(fileURLWithPath: path) else { return nil }
        guard let xmlParser = XMLParser(contentsOf: url) else { return nil }
        
        self.parser = xmlParser
        super.init()
        
        parser.delegate = self
        isValid = parser.parse()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "FMPXMLRESULT":
            correctType = true
            
        case "DATABASE":
            tableName = attributeDict["NAME"] ?? ""
            
        case "FIELD":
            tableDefinition.append(attributeDict)
            
        case "ROW":
            currentRow = []
            
        case "COL":
            hasData = false
            
        case "DATA":
            hasData = true
            currentContents = NSMutableString()
            
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "ROW":
            if let row = currentRow {
                dataRows.append(row)
                currentRow = nil
            }
            
        case "COL":
            if !hasData {
                currentRow?.append(NSNull())
            }
            
        case "DATA":
            if let contents = currentContents as? String {
                currentRow?.append(contents)
            } else {
                currentContents = nil
            }

        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentContents?.append(string)
    }
    
    // MARK: - Public API
    
    @objc var isCorrectType: Bool {
        correctType
    }
    
    @objc var isValidParse: Bool {
        isValid
    }
    
    @objc var rowCount: Int {
        dataRows.count
    }
    
    @objc func stepTableName() {
        if tableStep == 0 {
            tableName += "_1"
            tableStep += 1
        } else {
            if let range = tableName.range(of: "_\(tableStep)", options: .backwards) {
                tableName = String(tableName[..<range.lowerBound]) + "_\(tableStep + 1)"
            }
            tableStep += 1
        }
    }
    
    @objc func sqliteTableSchema() -> String {
        var schema = "CREATE TABLE \"\(tableName)\" (\n_id INTEGER PRIMARY KEY,\n"
        
        for (index, field) in tableDefinition.enumerated() {
            let name = field["NAME"] ?? ""
            let type = field["TYPE"] ?? ""
            
            if index == tableDefinition.count - 1 {
                schema += "\(name) \(type)\n)"
            } else {
                schema += "\(name) \(type),\n"
            }
        }
        
        return schema
    }
    
    @objc func sqliteCommand(forRow row: Int) -> String {
        guard row < dataRows.count else { return "" }
        
        let rowArray = dataRows[row]
        var command = assembleSQLITEInsertBase()
        command += "VALUES ("
        
        for (index, value) in rowArray.enumerated() {
            if value is NSNull {
                command += "NULL"
            } else {
                command += "\"\(value)\""
            }
            
            if index < rowArray.count - 1 {
                command += ","
            } else {
                command += ")"
            }
        }
        
        return command
    }
    
    @objc func writeToSQLITE(_ db: OpaquePointer?, withError error: NSErrorPointer) -> Bool {
        guard let db = db else { return false }
        
        let schemaSQL = sqliteTableSchema()
        var errorMsg: UnsafeMutablePointer<Int8>?
        
        if sqlite3_exec(db, schemaSQL, nil, nil, &errorMsg) != SQLITE_OK {
            if let error = error {
                error.pointee = NSError(domain: "PTFMXMLParser",
                                      code: 1,
                                      userInfo: [NSLocalizedDescriptionKey: String(cString: errorMsg!)])
            }
            sqlite3_free(errorMsg)
            return false
        }
        
        for row in 0..<dataRows.count {
            let command = sqliteCommand(forRow: row)
            if sqlite3_exec(db, command, nil, nil, &errorMsg) != SQLITE_OK {
                if let error = error {
                    error.pointee = NSError(domain: "PTFMXMLParser",
                                          code: 2,
                                          userInfo: [NSLocalizedDescriptionKey: String(cString: errorMsg!)])
                }
                sqlite3_free(errorMsg)
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func assembleSQLITEInsertBase() -> String {
        var base = "INSERT INTO \"\(tableName)\" ("
        
        for (index, field) in tableDefinition.enumerated() {
            if let name = field["NAME"] {
                if index == tableDefinition.count - 1 {
                    base += "\(name)) "
                } else {
                    base += "\(name),"
                }
            }
        }
        
        return base
    }
}
