// XRStatistic.swift
// XRose
//
// Created by Tom Moore on Fri Jan 30 2004.
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

// MARK: - Constants

// swiftlint:disable identifier_name
enum XRStatisticName {
    static let n = "N"
    static let uni = "Unidirectional Statistics"
    static let xVector = "X Vector"
    static let xVectorStandard = "X Vector Standarized"
    static let yVector = "Y Vector"
    static let yVectorStandard = "Y Vector Standarized"
    static let resultLength = "Resultant Length (R)"
    static let resultLengthMean = "Mean Resultant Length (R-Bar)"
    static let meanDirection = "Mean Direction"
    static let circularVariance = "Circular Varience"
}

@objc class XRStatistic: NSObject {
    // MARK: - Properties
    
    @objc var statisticName: String
    @objc var ASCIIName: String?
    @objc var valueString: String = ""
    
    private var isEmpty: Bool = false
    private var isFloat: Bool = false
    private var formatter: Formatter?
    private var value: NSNumber?
    
    // MARK: - Initialization
    
    override init() {
        self.statisticName = ""
        super.init()
        self.isEmpty = false
    }
    
    @objc static func emptyStatistic(withName name: String) -> XRStatistic {
        let stat = XRStatistic()
        stat.statisticName = name
        stat.isEmpty = true
        return stat
    }
    
    @objc static func statistic(withName name: String, floatValue: Float) -> XRStatistic {
        let stat = XRStatistic()
        stat.statisticName = name
        stat.setFloat(floatValue)
        return stat
    }
    
    @objc static func statistic(withName name: String, intValue: Int32) -> XRStatistic {
        let stat = XRStatistic()
        stat.statisticName = name
        stat.setInt(intValue)
        return stat
    }
    
    // MARK: - Public API
    
    @objc var ASCIINameString: String {
        ASCIIName ?? statisticName
    }
    
    @objc func setFloat(_ floatValue: Float) {
    isFloat = true
    self.value = NSNumber(value: floatValue)
    if let formatter = formatter {
        valueString = formatter.string(for: self.value) ?? String(format: "%.6f", floatValue)
    } else {
        valueString = String(format: "%.6f", floatValue)
    }
}
    
    @objc func floatValue() -> Float {
        value?.floatValue ?? 0.0
    }
    
    @objc func setInt(_ value: Int32) {
        isFloat = false
        self.value = NSNumber(value: value)
        
        if let formatter = formatter {
            valueString = formatter.string(for: self.value) ?? String(value)
        } else {
            valueString = String(value)
        }
    }
    
    @objc func intValue() -> Int32 {
        value?.int32Value ?? 0
    }
    
    @objc func setFormatter(_ formatter: Formatter) {
        self.formatter = formatter
        if let value = value {
            valueString = formatter.string(for: value) ?? valueString
        }
    }
    
    @objc func setEmpty(_ empty: Bool) {
        isEmpty = empty
    }
}
// swiftlint:enable identifier_name
