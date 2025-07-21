import AppKit

// MARK: - Test Arguments

struct CalculateGeometryTestArguments {
    let showLabel: Bool
    let isCore: Bool
    let isPercent: Bool
    let isFixedCount: Bool
    let circleRectForPercentCalled: Bool
    let circleRectForCountCalled: Bool
    let expectedRadiusMethod: String
    let expectedCountMethod: String
}

// MARK: - Test Case Factory

enum TestCaseFactory {
    static func createTestCases() -> [CalculateGeometryTestArguments] {
        [
            createTestCase1(),
            createTestCase2(),
            createTestCase3(),
            createTestCase4(),
            createTestCase5(),
            createTestCase6()
        ]
    }

    private static func createTestCase1() -> CalculateGeometryTestArguments {
        // Show label, not core, percent mode, not fixed count
        CalculateGeometryTestArguments(
            showLabel: true,
            isCore: false,
            isPercent: true,
            isFixedCount: false,
            circleRectForPercentCalled: false,
            circleRectForCountCalled: false,
            expectedRadiusMethod: "radius(ofPercentValue:)",
            expectedCountMethod: "radius(ofCount:)"
        )
    }

    private static func createTestCase2() -> CalculateGeometryTestArguments {
        // Show label, not core, count mode, not fixed count
        CalculateGeometryTestArguments(
            showLabel: true,
            isCore: false,
            isPercent: false,
            isFixedCount: false,
            circleRectForPercentCalled: false,
            circleRectForCountCalled: false,
            expectedRadiusMethod: "radius(ofCount:)",
            expectedCountMethod: "radius(ofCount:)"
        )
    }

    private static func createTestCase3() -> CalculateGeometryTestArguments {
        // Show label, not core, fixed count (should use percent methods regardless of isPercent)
        CalculateGeometryTestArguments(
            showLabel: true,
            isCore: false,
            isPercent: false, // Even though isPercent is false, isFixedCount takes precedence
            isFixedCount: true,
            circleRectForPercentCalled: false, // Not a closed circle, so no circleRect calls
            circleRectForCountCalled: false,
            expectedRadiusMethod: "radius(ofPercentValue:)", // Fixed count uses percent methods
            expectedCountMethod: "radius(ofCount:)"
        )
    }

    private static func createTestCase4() -> CalculateGeometryTestArguments {
        // Don't show label, not core, percent mode, not fixed count
        CalculateGeometryTestArguments(
            showLabel: false,
            isCore: false,
            isPercent: true,
            isFixedCount: false,
            circleRectForPercentCalled: true,
            circleRectForCountCalled: false,
            expectedRadiusMethod: "",
            expectedCountMethod: ""
        )
    }

    private static func createTestCase5() -> CalculateGeometryTestArguments {
        // Core circle, percent mode
        CalculateGeometryTestArguments(
            showLabel: true,
            isCore: true,
            isPercent: true,
            isFixedCount: false,
            circleRectForPercentCalled: true,
            circleRectForCountCalled: false,
            expectedRadiusMethod: "",
            expectedCountMethod: ""
        )
    }

    private static func createTestCase6() -> CalculateGeometryTestArguments {
        // Core circle, count mode - uses circleRect(forCount:) for closed circles
        // Note: For core circles, we don't expect any radius methods to be called
        // because they use circleRect methods instead
        CalculateGeometryTestArguments(
            showLabel: true,
            isCore: true,
            isPercent: false,
            isFixedCount: false,
            circleRectForPercentCalled: false,
            circleRectForCountCalled: true, // Core circles with showLabel=true use circleRect methods
            expectedRadiusMethod: "", // No radius method expected for core circles
            expectedCountMethod: "" // No count method expected for core circles
        )
    }
}
