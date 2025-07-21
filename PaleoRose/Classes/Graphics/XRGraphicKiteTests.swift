import AppKit
import Numerics
@testable import PaleoRose
import Testing

@MainActor
struct XRGraphicKiteTests {
    // MARK: - Test Setup

    private func buildBasicTestObject(controller: MockGraphicGeometrySource) -> XRGraphicKite {
        XRGraphicKite(controller: controller)
    }

    private func buildTestObject(controller: MockGraphicGeometrySource, angles: [Double] = [], values: [Double] = []) throws -> XRGraphicKite {
        try #require(
            XRGraphicKite(
                controller: controller,
                withAngles: angles,
                forValues: values
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

    @Test("basic initWithController should initialize with default values")
    func testBasicInitWithController() throws {
        // Given
        let controller = MockGraphicGeometrySource()

        // When
        let kite = buildBasicTestObject(controller: controller)
        var expectedSettings = defaultSettings()
        expectedSettings["_fillColor"] = NSColor.black

        let settings = kite.graphicSettings()
        // Then
        #expect(kite.lineWidth == 1.0, "Default lineWidth should be 1.0")

        try CommonUtilities.compareGraphicSettings(values: settings, expected: expectedSettings)
    }

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
}
