import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicPetalTests {
    // MARK: - Test Setup

    private func buildController() -> MockGeometryController {
        MockGeometryController()
    }

    private func buildBasicTestObject(controller: XRGeometryController) -> XRGraphicPetal {
        XRGraphicPetal(controller: controller)
    }

    private func builtTestObject(controller: XRGeometryController, forIncrement: Int32 = 0, forValue: Int32 = 0) throws -> XRGraphicPetal {
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
        let controller = buildController()

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
        let controller = buildController()

        // When
        let petal = try builtTestObject(controller: controller)
        let expectedSettings = defaultSettings()

        // Then
        let settings = petal.graphicSettings()

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }
}
