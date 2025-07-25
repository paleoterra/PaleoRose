import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicPetalTests {
    // MARK: - Test Setup

    private func buildBasicTestObject(controller: MockGraphicGeometrySource) -> XRGraphicPetal {
        XRGraphicPetal(controller: controller)
    }

    private func builtTestObject(controller: MockGraphicGeometrySource, forIncrement: Int32 = 0, forValue: Int32 = 0) throws -> XRGraphicPetal {
        try #require(XRGraphicPetal(
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

    @Test("basic initWithController should initialize with default values")
    func testBasicInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let petal = buildBasicTestObject(controller: controller)
        let expectedSettings = defaultSettings()

        // Then
        let settings = petal.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

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
            (0, 10, [
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 10.0),
                NSPoint(x: 6.123233995736766e-16, y: 10.0),
                NSPoint(x: 0.5821459054468262, y: 10.0),
                NSPoint(x: 1.1631799756009586, y: 9.949166105739186),
                NSPoint(x: 1.7364817766693041, y: 9.84807753012208),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ]),
            (10, 10, [
                NSPoint(x: -0.0, y: 0.0),
                NSPoint(x: -9.84807753012208, y: -1.736481776669303),
                NSPoint(x: 9.84807753012208, y: -1.7364817766693128),
                NSPoint(x: 9.746988954504973, y: -2.309783577737662),
                NSPoint(x: 9.596031833876461, y: -2.8731632216875695),
                NSPoint(x: 9.396926207859085, y: -3.420201433256686),
                NSPoint(x: -0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ]),
            (60, 10, [
                NSPoint(x: 0.0, y: -0.0),
                NSPoint(x: 8.660254037844384, y: -5.000000000000004),
                NSPoint(x: -8.660254037844386, y: -5.000000000000001),
                NSPoint(x: -8.951326990567798, y: -4.495846857173957),
                NSPoint(x: -9.197820581841711, y: -3.967239644825799),
                NSPoint(x: -9.396926207859085, y: -3.4202014332566866),
                NSPoint(x: 0.0, y: -0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ])
        ]
    )
    func testCalculateGeometryCountController(params: (increment: Int32, value: Int32, expected: [NSPoint])) throws {
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
            (0, 10, [
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 10.0),
                NSPoint(x: 6.123233995736766e-16, y: 10.0),
                NSPoint(x: 0.5821459054468262, y: 10.0),
                NSPoint(x: 1.1631799756009586, y: 9.949166105739186),
                NSPoint(x: 1.7364817766693041, y: 9.84807753012208),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ]),
            (10, 10, [
                NSPoint(x: -0.0, y: 0.0),
                NSPoint(x: -9.84807753012208, y: -1.736481776669303),
                NSPoint(x: 9.84807753012208, y: -1.7364817766693128),
                NSPoint(x: 9.746988954504973, y: -2.309783577737662),
                NSPoint(x: 9.596031833876461, y: -2.8731632216875695),
                NSPoint(x: 9.396926207859085, y: -3.420201433256686),
                NSPoint(x: -0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ]),
            (60, 10, [
                NSPoint(x: 0.0, y: -0.0),
                NSPoint(x: 8.660254037844384, y: -5.000000000000004),
                NSPoint(x: -8.660254037844386, y: -5.000000000000001),
                NSPoint(x: -8.951326990567798, y: -4.495846857173957),
                NSPoint(x: -9.197820581841711, y: -3.967239644825799),
                NSPoint(x: -9.396926207859085, y: -3.4202014332566866),
                NSPoint(x: 0.0, y: -0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0),
                NSPoint(x: 0.0, y: 0.0)
            ])
        ]
    )
    func testCalculateGeometryCountControllerPercent(params: (increment: Int32, value: Int32, expected: [NSPoint])) throws {
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
