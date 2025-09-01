import AppKit
import Numerics
@testable import PaleoRose
import Testing

struct GraphicPetalTests {
    // MARK: - Test Data Structures

    struct PetalGeometryTestParams {
        let increment: Int32
        let value: Int32
        let expected: [CGPoint]
    }

    // MARK: - Test Setup

    private func builtTestObject(controller: MockGraphicGeometrySource, forIncrement: Int32 = 0, forValue: Int32 = 0) throws -> GraphicPetal {
        try #require(GraphicPetal(
            controller: controller,
            forIncrement: forIncrement,
            forValue: forValue as NSNumber
        ))
    }

    private func defaultSettings() -> [AnyHashable: Any] {
        [
            "GraphicType": "Petal",
            "_strokeColor": NSColor.black,
            "_fillColor": NSColor.black,
            "_petalIncrement": "0",
            "_percent": "0.000000",
            "_maxRadius": "0.000000",
            "_lineWidth": "1.000000",
            "_count": "0"
        ]
    }

    // MARK: - Initialization Tests

    @Test("initWithController should initialize with default values and configure")
    func testInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let petal = try builtTestObject(controller: controller)
        let expectedSettings = defaultSettings()

        // Then
        let settings = petal.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

    @Test(
        "calculategeometry given start angle and angle",
        arguments: [
            PetalGeometryTestParams(increment: 0, value: 10, expected: [
                CGPoint.zero,
                CGPoint(x: 0.0, y: 10.0),
                CGPoint(x: 6.123233995736766e-16, y: 10.0),
                CGPoint(x: 0.5821459054468262, y: 10.0),
                CGPoint(x: 1.1631799756009586, y: 9.949166105739186),
                CGPoint(x: 1.7364817766693041, y: 9.84807753012208),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ]),
            PetalGeometryTestParams(increment: 10, value: 10, expected: [
                CGPoint(x: -0.0, y: 0.0),
                CGPoint(x: -9.84807753012208, y: -1.736481776669303),
                CGPoint(x: 9.84807753012208, y: -1.7364817766693128),
                CGPoint(x: 9.746988954504973, y: -2.309783577737662),
                CGPoint(x: 9.596031833876461, y: -2.8731632216875695),
                CGPoint(x: 9.396926207859085, y: -3.420201433256686),
                CGPoint(x: -0.0, y: 0.0),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ]),
            PetalGeometryTestParams(increment: 60, value: 10, expected: [
                CGPoint(x: 0.0, y: -0.0),
                CGPoint(x: 8.660254037844384, y: -5.000000000000004),
                CGPoint(x: -8.660254037844386, y: -5.000000000000001),
                CGPoint(x: -8.951326990567798, y: -4.495846857173957),
                CGPoint(x: -9.197820581841711, y: -3.967239644825799),
                CGPoint(x: -9.396926207859085, y: -3.4202014332566866),
                CGPoint(x: 0.0, y: -0.0),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ])
        ]
    )
    func testCalculateGeometryCountController(params: PetalGeometryTestParams) throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockSectorSize = 10
        controller.mockStartingAngle = 0

        // When
        let petal = try builtTestObject(
            controller: controller,
            forIncrement: params.increment,
            forValue: params.value
        )

        let path = try #require(petal.drawingPath)
        print(path.getPoints())
    }

    @Test(
        "calculategeometry given start angle and angle percent",
        arguments: [
            PetalGeometryTestParams(increment: 0, value: 10, expected: [
                CGPoint.zero,
                CGPoint(x: 0.0, y: 10.0),
                CGPoint(x: 6.123233995736766e-16, y: 10.0),
                CGPoint(x: 0.5821459054468262, y: 10.0),
                CGPoint(x: 1.1631799756009586, y: 9.949166105739186),
                CGPoint(x: 1.7364817766693041, y: 9.84807753012208),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ]),
            PetalGeometryTestParams(increment: 10, value: 10, expected: [
                CGPoint(x: -0.0, y: 0.0),
                CGPoint(x: -9.84807753012208, y: -1.736481776669303),
                CGPoint(x: 9.84807753012208, y: -1.7364817766693128),
                CGPoint(x: 9.746988954504973, y: -2.309783577737662),
                CGPoint(x: 9.596031833876461, y: -2.8731632216875695),
                CGPoint(x: 9.396926207859085, y: -3.420201433256686),
                CGPoint(x: -0.0, y: 0.0),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ]),
            PetalGeometryTestParams(increment: 60, value: 10, expected: [
                CGPoint(x: 0.0, y: -0.0),
                CGPoint(x: 8.660254037844384, y: -5.000000000000004),
                CGPoint(x: -8.660254037844386, y: -5.000000000000001),
                CGPoint(x: -8.951326990567798, y: -4.495846857173957),
                CGPoint(x: -9.197820581841711, y: -3.967239644825799),
                CGPoint(x: -9.396926207859085, y: -3.4202014332566866),
                CGPoint(x: 0.0, y: -0.0),
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero,
                CGPoint.zero
            ])
        ]
    )
    func testCalculateGeometryCountControllerPercent(params: PetalGeometryTestParams) throws {
        // Given
        let controller = MockGraphicGeometrySource()
        controller.mockSectorSize = 10
        controller.mockStartingAngle = 0
        controller.mockIsPercent = true

        // When
        let petal = try builtTestObject(
            controller: controller,
            forIncrement: params.increment,
            forValue: params.value
        )

        let path = try #require(petal.drawingPath)
        print(path.getPoints())
    }
}
