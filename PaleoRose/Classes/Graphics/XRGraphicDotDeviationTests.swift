import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicDotDeviationTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: MockGraphicGeometrySource, forIncrement: Int32 = 3, totalCount: Int32 = 32, valueCount: Int32 = 0, mean: Float = 0.0) throws -> XRGraphicDotDeviation {
        try #require(
            XRGraphicDotDeviation(
                controller: controller,
                forIncrement: forIncrement,
                valueCount: valueCount,
                totalCount: totalCount,
                statistics: ["mean": mean]
            )
        )
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "DotDeviation",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.black,
            "_lineWidth": "1.000000",
            "_angleIncrement": "0",
            "_totalCount": "0",
            "_count": "0",
            "_dotSize": "0.000000",
            "_mean": "0.000000"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController:ForIncrement:valueCount:statics should initialize with correct values")
    func testInitWithControllerforIncrement() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let dotDeviation = try buildTestObject(controller: controller)

        var expectedSettings = defaultSettings()
        expectedSettings["_angleIncrement"] = "3"
        expectedSettings["_totalCount"] = "32"
        expectedSettings["_dotSize"] = "4.000000"
        let settings = dotDeviation.graphicSettings()

        // Then
        #expect(dotDeviation.lineWidth == 1.0, "Default lineWidth should be 1.0")
        #expect(dotDeviation.strokeColor == .black, "Default strokeColor should be black")

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    // MARK: - Property Tests

    @Test("setLineWidth should update line width")
    func testSetLineWidth() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let dotDeviation = try buildTestObject(controller: controller)
        let testWidth: Float = 2.5

        // When
        dotDeviation.lineWidth = testWidth

        // Then
        #expect(
            dotDeviation.lineWidth.isApproximatelyEqual(to: testWidth, relativeTolerance: 0.001),
            "lineWidth should be \(testWidth) after setting"
        )
    }

    // MARK: - Graphic Settings Tests

    @Test("graphicSettings should return correct settings dictionary")
    func testGraphicSettings() throws {
        // Given
        let controller = MockGraphicGeometrySource()
        let dotDeviation = try buildTestObject(controller: controller)

        // Configure some custom values
        dotDeviation.lineWidth = 2.0
        dotDeviation.strokeColor = .red
        var expectedSettings = defaultSettings()
        expectedSettings["_angleIncrement"] = "3"
        expectedSettings["_totalCount"] = "32"
        expectedSettings["_dotSize"] = "4.000000"
        expectedSettings["_lineWidth"] = "2.000000"
        expectedSettings["_strokeColor"] = NSColor.red
        // When
        let settings = dotDeviation.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    // MARK: - Set dot size

    @Test(
        "Set dot size accessor",
        arguments: [
            10.0,
            1000.0,
            -3.0
        ]
    )
    func testSetDotSize(dotSize: Float) throws {
        let controller = MockGraphicGeometrySource()
        let dotDeviation = try buildTestObject(controller: controller)

        dotDeviation.dotSize = dotSize

        #expect(dotDeviation.dotSize.isApproximatelyEqual(to: dotSize, relativeTolerance: 0.001))
    }

    struct CalculateGeometryParams {
        let mockIsPercent: Bool
        let forIncrement: Int32
        let valueCount: Int32
        let totalCount: Int32
        let mean: Float
        let expectedRect: CGRect
    }

    @Test(
        "Calculate Geometry basic test",
        arguments: [
            CalculateGeometryParams(
                mockIsPercent: false,
                forIncrement: 10,
                valueCount: 20,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: 16.0, width: 4.0, height: 6.0)
            ),
            CalculateGeometryParams(
                mockIsPercent: false,
                forIncrement: 10,
                valueCount: 5,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: 3.0, width: 4.0, height: 15.0)
            ),
            CalculateGeometryParams(
                mockIsPercent: false,
                forIncrement: 10,
                valueCount: 17,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)
            ),
            CalculateGeometryParams(
                mockIsPercent: true,
                forIncrement: 10,
                valueCount: 20,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)
            ),
            CalculateGeometryParams(
                mockIsPercent: true,
                forIncrement: 10,
                valueCount: 5,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)
            ),
            CalculateGeometryParams(
                mockIsPercent: true,
                forIncrement: 10,
                valueCount: 17,
                totalCount: 50,
                mean: 17.0,
                expectedRect: CGRect(x: -2.0, y: -2.0, width: 4.0, height: 4.0)
            )
        ]
    )
    func testCalculateGeometryBasic(params: CalculateGeometryParams) throws {
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = params.mockIsPercent
        let dotDeviation = try #require(
            XRGraphicDotDeviation(
                controller: controller,
                forIncrement: params.forIncrement,
                valueCount: params.valueCount,
                totalCount: params.totalCount,
                statistics: ["mean": params.mean]
            )
        )

        dotDeviation.calculateGeometry()

        let path = try #require(dotDeviation.drawingPath)
        let bounds = path.bounds
        #expect(
            bounds.origin.x.isApproximatelyEqual(
                to: params.expectedRect.origin.x,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.origin.y.isApproximatelyEqual(
                to: params.expectedRect.origin.y,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.width.isApproximatelyEqual(
                to: params.expectedRect.size.width,
                absoluteTolerance: 0.01
            )
        )
        #expect(
            bounds.size.height.isApproximatelyEqual(
                to: params.expectedRect.size.height,
                absoluteTolerance: 0.01
            )
        )
    }
}
