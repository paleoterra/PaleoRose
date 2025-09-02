import AppKit
import Numerics
@testable import PaleoRose
import Testing

@Suite("ArrowHead Tests")
struct ArrowHeadTests {

    @Test("Initialization with valid parameters")
    func testInitialization() {
        let color = NSColor.red
        let size: Float = 1.0
        let type = 0

        let arrowHead = ArrowHead(
            size: size,
            color: color,
            type: Int32(type)
        )

        #expect(arrowHead.arrowColor == color)
    }

    @Test("Initialization with different arrow types", arguments: [0, 1, 2, 4])
    func testInitializationWithDifferentTypes(type: Int) {
        let color = NSColor.blue
        let size: Float = 2.0

        let arrowHead = ArrowHead(size: size, color: color, type: Int32(type))
        #expect(arrowHead.arrowColor == color)
    }

    @Test("Initialization with different sizes", arguments: [0.5, 1.0, 2.0, 10.0])
    func testInitializationWithDifferentSizes(size: Float) {
        let color = NSColor.green
        let type = 0

        let arrowHead = ArrowHead(size: size, color: color, type: Int32(type))

        #expect(arrowHead.arrowColor == color)
    }

    @Test(
        "Initialization with different colors",
        arguments: [NSColor.red, NSColor.blue, NSColor.green, NSColor.black, NSColor.white]
    )
    func testInitializationWithDifferentColors(color: NSColor) {
        let size: Float = 1.0
        let type = 0

        let arrowHead = ArrowHead(size: size, color: color, type: Int32(type))
        #expect(arrowHead.arrowColor == color)
    }

    @Test("Position transform changes after positioning")
    func testPositionTransformChanges() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)
        let initialTransform = arrowHead.positionTransform
        let point = CGPoint(x: 10.0, y: 20.0)
        let angle: Float = 45.0

        arrowHead.position(atLineEndpoint: point, withAngle: angle)

        #expect(arrowHead.positionTransform != initialTransform)
    }

    @Test("Multiple positioning calls update transform", arguments: [0.0, 45.0, 90.0, 180.0, 270.0, 360.0])
    func testMultiplePositioningUpdatesTransform(angle: Float) {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)
        let point1 = CGPoint(x: 15.0, y: 25.0)
        let point2 = CGPoint(x: 30.0, y: 40.0)

        arrowHead.position(atLineEndpoint: point1, withAngle: angle)
        let firstTransform = arrowHead.positionTransform

        arrowHead.position(atLineEndpoint: point2, withAngle: angle + 10.0)
        let secondTransform = arrowHead.positionTransform

        #expect(firstTransform != secondTransform)
    }

    @Test("Position at line endpoint with various points")
    func testPositionAtLineEndpointWithPoints() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)
        let points = [
            CGPoint.zero,
            CGPoint(x: -10.0, y: -10.0),
            CGPoint(x: 100.0, y: 50.0),
            CGPoint(x: -50.0, y: 75.0)
        ]
        let angle: Float = 45.0

        for point in points {
            arrowHead.position(atLineEndpoint: point, withAngle: angle)
        }
    }

    @Test("Draw rect functionality")
    func testDrawRect() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)

        arrowHead.draw(rect)
    }

    @Test("Standard arrow type path creation")
    func testStandardArrowType() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)

        #expect(arrowHead.path.elementCount > 0)
    }

    @Test("Flying arrow type path creation")
    func testFlyingArrowType() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 1)

        #expect(arrowHead.path.elementCount > 0)
    }

    @Test("Half arrow left type path creation")
    func testHalfArrowLeftType() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 2)

        #expect(arrowHead.path.elementCount > 0)
    }

    @Test("Half arrow right type path creation")
    func testHalfArrowRightType() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 4)

        #expect(arrowHead.path.elementCount > 0)
    }

    @Test("Scale transform configuration")
    func testScaleTransformConfiguration() {
        let smallArrow = ArrowHead(size: 0.5, color: NSColor.red, type: 0)
        let largeArrow = ArrowHead(size: 2.0, color: NSColor.red, type: 0)

        #expect(smallArrow.scaleTransform != largeArrow.scaleTransform)
    }

    @Test("Position transform after positioning")
    func testPositionTransformAfterPositioning() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)
        let initialTransform = arrowHead.positionTransform

        arrowHead.position(atLineEndpoint: CGPoint(x: 50.0, y: 100.0), withAngle: 90.0)

        #expect(arrowHead.positionTransform != initialTransform)
    }

    @Test("Multiple repositioning updates transform")
    func testMultipleRepositioning() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 0)

        arrowHead
            .position(atLineEndpoint: CGPoint(x: 10.0, y: 10.0), withAngle: 0.0)
        let firstTransform = arrowHead.positionTransform

        arrowHead
            .position(
                atLineEndpoint: CGPoint(x: 20.0, y: 20.0),
                withAngle: 45.0
            )
        let secondTransform = arrowHead.positionTransform

        #expect(firstTransform != secondTransform)
    }

    @Test("Invalid arrow type defaults gracefully")
    func testInvalidArrowType() {
        let arrowHead = ArrowHead(size: 1.0, color: NSColor.red, type: 999)

        #expect(arrowHead.path.elementCount == 0)
    }
}
