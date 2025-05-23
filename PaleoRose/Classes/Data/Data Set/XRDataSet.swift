// XRDataSet.swift
// XRose
//
// Created by Tom Moore on Tue Jan 06 2004.
//
// MIT License
//
// Copyright (c) 2004 to present Thomas L. Moore.
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

import Foundation
import SQLite3

extension Notification.Name {
    static let XRDataSetChangedStatistics = Notification.Name("XRDataSetChangedStatisticsNotification")
}

@objc class XRDataSet: NSObject {
    // MARK: - Properties
    
    private var values: NSMutableData
    @objc private(set) var name: String
    private var comments: NSMutableAttributedString?
    private var circularStatistics: [XRStatistic] = []
    @objc var predicate: String?
    @objc var tableName: String?
    @objc var columnName: String?
    @objc private(set) var setId: Int32 = 0
    
    // MARK: - Initialization
    
    @objc init(table: String, column: String, db: OpaquePointer?) {
        self.values = NSMutableData()
        self.name = ""
        self.tableName = table
        self.columnName = column
        super.init()
        
        guard readSQL(db: db) else { return }
    }
    
    @objc init(table: String, column: String, db: OpaquePointer?, predicate: String) {
        self.values = NSMutableData()
        self.name = ""
        self.tableName = table
        self.columnName = column
        self.predicate = predicate
        super.init()
        
        guard readSQL(db: db) else { return }
    }
    
    @objc init(data: Data, name: String) {
        self.values = NSMutableData()
        self.name = name
        super.init()
        self.values.append(data)
    }
    
    @objc init(id: Int32, name: String, tableName: String, column: String, predicate: String?, comments: NSAttributedString?, data: Data) {
        self.values = NSMutableData()
        self.name = name
        self.setId = id
        self.tableName = tableName
        self.columnName = column
        self.predicate = predicate
        super.init()
        
        if let comments = comments {
            self.comments = NSMutableAttributedString(attributedString: comments)
        }
        self.values.append(data)
    }
    
    // MARK: - Public API
    
    @objc var theData: Data {
        values as Data
    }
    
    @objc func setId(_ newId: Int32) {
        setId = newId
    }
    
    @objc func setName(_ newName: String) {
        name = newName
    }
    
    @objc func setComments(_ comments: NSMutableAttributedString) {
        self.comments = comments
    }
    
    @objc var commentsString: NSAttributedString? {
        comments
    }
    
    @objc var dataSetDictionary: [String: Any] {
        var dict: [String: Any] = [
            "values": values,
            "name": name
        ]
        if let comments = comments {
            dict["comments"] = comments
        }
        return dict
    }
    
    // MARK: - Statistics
    
    @objc var currentStatistics: [XRStatistic] {
        circularStatistics
    }
    
    @objc func currentStatistic(withName name: String) -> XRStatistic? {
        circularStatistics.first { $0.statisticName == name }
    }
    
    @objc func valueCount(fromAngle startAngle: Float, toAngle2 endAngle: Float) -> Int32 {
    valueCount(fromAngle: startAngle, toAngle2: endAngle, biDirectional: false)
}
    
    @objc func valueCount(fromAngle startAngle: Float, toAngle2 endAngle: Float, biDirectional: Bool) -> Int32 {
    var valueCountResult: Int32 = 0
    values.withUnsafeBytes { buffer in
        guard let pointer = buffer.baseAddress?.assumingMemoryBound(to: Float.self) else { return }
        let floatCount = values.length / MemoryLayout<Float>.size
        for index in 0..<floatCount {
            var angleValue = pointer[index]
            if biDirectional {
                angleValue = angleValue.truncatingRemainder(dividingBy: 180.0)
                if angleValue < 0 {
                    angleValue += 180.0
                }
            } else {
                angleValue = angleValue.truncatingRemainder(dividingBy: 360.0)
                if angleValue < 0 {
                    angleValue += 360.0
                }
            }
            if angleValue >= startAngle && angleValue <= endAngle {
                valueCountResult += 1
            }
        }
    }
    return valueCountResult
}
    
    @objc func meanCount(withIncrement angleIncrement: Float, startingAngle: Float, isBiDirectional: Bool) -> [String: Any] {
    var countArray: [Int32] = []
    var angleArray: [Float] = []
    var currentAngle = startingAngle
    let maxAngle = isBiDirectional ? 180.0 : 360.0
    while currentAngle < maxAngle {
        let count = valueCount(fromAngle: currentAngle, toAngle2: currentAngle + angleIncrement, biDirectional: isBiDirectional)
        countArray.append(count)
        angleArray.append(currentAngle)
        currentAngle += angleIncrement
    }
    return [
        "counts": countArray,
        "angles": angleArray
    ]
}
    
    @objc func standardDeviation(_ floatValues: [Float], mean: Float) -> Float {
    let sumSquares = floatValues.reduce(0.0) { sum, value in
        sum + pow(value - mean, 2)
    }
    return sqrt(sumSquares / Float(floatValues.count - 1))
}
    
    // MARK: - Private Methods
    
    private func readSQL(db: OpaquePointer?) -> Bool {
        guard let db = db else { return false }
        
        var sql = "SELECT \"\(columnName ?? "")\" FROM \"\(tableName ?? "")\""
        if let predicate = predicate {
            sql += " WHERE \(predicate)"
        }
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return false
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let value = sqlite3_column_double(statement, 0)
            let floatValue = Float(value)
            values.append(&floatValue, length: MemoryLayout<Float>.size)
        }
        
        sqlite3_finalize(statement)
        return true
    }
    
    private func computeVectors(isBiDir: Bool) -> (xVector: Float, yVector: Float) {
        var sumX: Float = 0
        var sumY: Float = 0
        
        values.withUnsafeBytes { buffer in
            guard let ptr = buffer.baseAddress?.assumingMemoryBound(to: Float.self) else { return }
            let count = values.length / MemoryLayout<Float>.size
            
            for index in 0..<count {
                var angle = ptr[index]
                if isBiDir {
                    angle = angle.truncatingRemainder(dividingBy: 180.0)
                    if angle < 0 {
                        angle += 180.0
                    }
                    angle *= 2
                }
                let radians = angle * .pi / 180.0
                sumX += cos(radians)
                sumY += sin(radians)
            }
        }
        
        return (sumX, sumY)
    }
}
