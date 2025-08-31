import AppKit
import Numerics
@testable import PaleoRose
import Testing

struct GraphicKiteTests {
    // MARK: - Test Setup

    private func buildTestObject(controller: MockGraphicGeometrySource, angles: [Double] = [], values: [Double] = []) throws -> GraphicKite {
        try #require(
            GraphicKite(
                controller: controller,
                angles: angles,
                values: values
            )
        )
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "Kite",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.white,
            "_lineWidth": "1.000000"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController should initialize with default values")
    func testInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let kite = try buildTestObject(controller: controller)
        let expectedSettings = defaultSettings()

        let settings = kite.graphicSettings()
        // Then
        #expect(kite.lineWidth == 1.0, "Default lineWidth should be 1.0")

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test("calculate geometry for count no core")
    func testGeometryCalculationNoCore() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockGeometryMaxCount = 10

        let expectedPoints = [
            CGPoint(x: 9.797174393178826e-16, y: 4.0),
            CGPoint(x: 0.0, y: 1.0),
            CGPoint(x: -1.7320508075688774, y: -0.9999999999999997),
            CGPoint(x: 2.598076211353315, y: -1.5000000000000013),
            CGPoint(x: 9.797174393178826e-16, y: 4.0)
        ]

        let kite = try
            buildTestObject(
                controller: controller,
                angles: [0.0, 120.0, 240.0, 360.0],
                values: [10.0, 20.0, 30.0, 40.0]
            )
        let builtPath = try #require(kite.drawingPath)

        let points = builtPath.getPoints()
        try #require(points.count == expectedPoints.count)
        for (index, expectedPoint) in expectedPoints.enumerated() {
            #expect(
                points[index].x
                    .isApproximatelyEqual(to: expectedPoint.x, relativeTolerance: 0.1),
                "Point \(index).x does not match"
            )
            #expect(points[index].y.isApproximatelyEqual(to: expectedPoint.y, relativeTolerance: 0.1), "Point \(index).y does not match")
        }
    }

    @Test("calculate geometry for count with core")
    func testGeometryCalculationWithCore() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockGeometryMaxCount = 10
        controller.mockHollowCoreSize = 0.5

        let expectedPoints: [CGPoint] = [
            CGPoint(x: 9.797174393178826e-16, y: 4.0),
            CGPoint(x: 0.0, y: 1.0),
            CGPoint(x: -1.7320508075688774, y: -0.9999999999999997),
            CGPoint(x: 2.598076211353315, y: -1.5000000000000013),
            CGPoint(x: 9.797174393178826e-16, y: 4.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0)
        ]

        let kite = try
            buildTestObject(
                controller: controller,
                angles: [0.0, 120.0, 240.0, 360.0],
                values: [10.0, 20.0, 30.0, 40.0]
            )
        let builtPath = try #require(kite.drawingPath)

        let points = builtPath.getPoints()

        try #require(points.count == expectedPoints.count)
        for (index, expectedPoint) in expectedPoints.enumerated() {
            #expect(
                points[index].x
                    .isApproximatelyEqual(to: expectedPoint.x, relativeTolerance: 0.1),
                "Point \(index).x does not match"
            )
            #expect(points[index].y.isApproximatelyEqual(to: expectedPoint.y, relativeTolerance: 0.1), "Point \(index).y does not match")
        }
    }

    @Test("calculate geometry for count no core percent")
    func testGeometryCalculationNoCorePercent() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockGeometryMaxPercent = 100.0

        let expectedPoints = [
            CGPoint(x: 9.7971745391681e-17, y: 0.4000000059604645),
            CGPoint(x: 0.0, y: 0.10000000149011612),
            CGPoint(x: -0.17320508333784457, y: -0.10000000149011609),
            CGPoint(x: 0.2598076314591588, y: -0.15000000596046462),
            CGPoint(x: 9.7971745391681e-17, y: 0.4000000059604645)
        ]

        let kite = try
            buildTestObject(
                controller: controller,
                angles: [0.0, 120.0, 240.0, 360.0],
                values: [10.0, 20.0, 30.0, 40.0]
            )
        let builtPath = try #require(kite.drawingPath)

        let points = builtPath.getPoints()
        try #require(points.count == expectedPoints.count)
        for (index, expectedPoint) in expectedPoints.enumerated() {
            #expect(
                points[index].x
                    .isApproximatelyEqual(to: expectedPoint.x, relativeTolerance: 0.1),
                "Point \(index).x does not match"
            )
            #expect(points[index].y.isApproximatelyEqual(to: expectedPoint.y, relativeTolerance: 0.1), "Point \(index).y does not match")
        }
    }

    @Test("calculate geometry for count with core percent")
    func testGeometryCalculationWithCorePercent() throws {
        let controller = MockGraphicGeometrySource()
        controller.mockIsPercent = true
        controller.mockGeometryMaxPercent = 100.0
        controller.mockHollowCoreSize = 0.5

        let expectedPoints = [
            CGPoint(x: 9.7971745391681e-17, y: 0.4000000059604645),
            CGPoint(x: 0.0, y: 0.10000000149011612),
            CGPoint(x: -0.17320508333784457, y: -0.10000000149011609),
            CGPoint(x: 0.2598076314591588, y: -0.15000000596046462),
            CGPoint(x: 9.7971745391681e-17, y: 0.4000000059604645),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 0.0)
        ]

        let kite = try
            buildTestObject(
                controller: controller,
                angles: [0.0, 120.0, 240.0, 360.0],
                values: [10.0, 20.0, 30.0, 40.0]
            )
        let builtPath = try #require(kite.drawingPath)

        let points = builtPath.getPoints()

        print(points)

        try #require(points.count == expectedPoints.count)
        for (index, expectedPoint) in expectedPoints.enumerated() {
            #expect(
                points[index].x
                    .isApproximatelyEqual(to: expectedPoint.x, relativeTolerance: 0.1),
                "Point \(index).x does not match"
            )
            #expect(points[index].y.isApproximatelyEqual(to: expectedPoint.y, relativeTolerance: 0.1), "Point \(index).y does not match")
        }
    }
}
