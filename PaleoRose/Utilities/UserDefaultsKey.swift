//
// UserDefaultsKey.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2025 to present Thomas L. Moore.
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
import SwiftUICore

/// A type-safe enumeration of keys used to access values in UserDefaults.
///
/// This enum provides a centralized and type-safe way to access UserDefaults values
/// throughout the application, reducing the risk of typos and making it easier to
/// maintain and refactor the codebase.
///
/// ## Usage
///
/// ### Setting a value:
/// ```swift
/// UserDefaults.standard.set(true, forKey: .isEqualArea)
/// ```
///
/// ### Getting a value:
/// ```swift
/// let isEqualArea = UserDefaults.standard.bool(forKey: .isEqualArea)
/// ```
///
/// ### With @AppStorage:
/// ```swift
/// @AppStorage(UserDefaultsKey.isEqualArea.rawValue) var isEqualArea = false
/// ```
///
/// ### With @DefaultsStorage:
/// ```swift
/// @DefaultsStorage(.isEqualArea, defaultValue: false) var isEqualArea
/// ```
///
/// - Note: All keys are prefixed with their respective component to avoid naming conflicts.
public enum UserDefaultsKey: String, CaseIterable {
    // swiftlint:disable sorted_enum_cases

    // MARK: - Vector Calculation

    case vectorCalculationMethod

    // MARK: - Geometry Settings

    case isEqualArea = "XRGeometryDefaultKeyEqualArea"
    case isPercent = "XRGeometryDefaultKeyPercent"
    case sectorSize = "XRGeometryDefaultKeySectorSize"
    case startingAngle = "XRGeometryDefaultKeyStartingAngle"

    // MARK: - Layer Grid Settings

    case spokeCount = "XRLayerGridDefaultSpokeCount"
    case spokeAngle = "XRLayerGridDefaultSpokeAngle"
    case ringCountIncrement = "XRLayerGridDefaultRingCount"
    case fixedRingCount = "XRLayerGridDefaultRingFixedCount"
    case ringPercentIncrement = "XRLayerGridDefaultRingPercent"
    case isRingCountFixed = "XRLayerGridDefaultRingFixed"
    case isSpokeSectorLocked = "XRLayerGridDefaultSectorLock"
    case gridLineWidth = "XRLayerGridDefaultLineWidth"

    // MARK: - Layer Data Settings

    case layerDataType = "XRLayerDataDefaultKeyType"
    // swiftlint:enable sorted_enum_cases
}
