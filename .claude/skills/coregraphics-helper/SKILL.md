---
description: Generate and optimize CoreGraphics/AppKit drawing code for complex paths, shapes, and visualizations
---

# CoreGraphics Helper

Generate and optimize CoreGraphics/AppKit drawing code for complex paths, shapes, and visualizations.

## Capabilities

1. **Path Generation**
   - Generate NSBezierPath/CGPath from descriptions
   - Create complex geometric shapes
   - Build parametric curves and arcs
   - Generate rose diagrams and polar plots

2. **Drawing Code Creation**
   - Generate draw() method implementations
   - Create custom shape drawing functions
   - Build reusable graphics utilities
   - Generate transformation matrices

3. **Path Manipulation**
   - Transform paths (scale, rotate, translate)
   - Combine paths (union, intersection, subtraction)
   - Simplify complex paths
   - Calculate path bounds and metrics

4. **Optimization**
   - Reduce path complexity
   - Optimize drawing performance
   - Cache expensive calculations
   - Use appropriate drawing primitives

5. **Mathematical Helpers**
   - Polar-to-cartesian conversions
   - Angle normalization and restrictions
   - Bezier curve calculations
   - Trigonometric utilities

## Workflow

When invoked, this skill will:

1. **Understand**: Parse shape/drawing requirements
2. **Calculate**: Compute necessary geometry
3. **Generate**: Create drawing code
4. **Optimize**: Improve performance
5. **Document**: Add clear comments

## Usage Instructions

When the user invokes this skill:

1. Ask what to create:
   - Specific shape (circle, arc, polygon, etc.)
   - Complex visualization (rose diagram, histogram)
   - Path transformation
   - Drawing optimization

2. Gather parameters:
   - Dimensions and coordinates
   - Angles and rotations
   - Colors and line widths
   - Data values to visualize

3. Generate code with:
   - Clear variable names
   - Step-by-step comments
   - Reusable functions
   - Performance considerations

## Project-Specific Context

Your project specializes in rose diagrams and paleontological visualizations:
- Circular plots with radial data
- Petal diagrams showing directional data
- Histogram overlays
- Vector graphics with precise angles

## Common Patterns

### 1. Rose Diagram Petal

```swift
func createPetalPath(
    center: CGPoint,
    startAngle: CGFloat,
    endAngle: CGFloat,
    innerRadius: CGFloat,
    outerRadius: CGFloat
) -> NSBezierPath {
    let path = NSBezierPath()

    // Convert angles to radians
    let startRad = startAngle * .pi / 180.0
    let endRad = endAngle * .pi / 180.0

    // Start at center
    path.move(to: center)

    // Line to inner arc start
    let innerStart = CGPoint(
        x: center.x + innerRadius * cos(startRad),
        y: center.y + innerRadius * sin(startRad)
    )
    path.line(to: innerStart)

    // Outer arc
    let outerStart = CGPoint(
        x: center.x + outerRadius * cos(startRad),
        y: center.y + outerRadius * sin(startRad)
    )
    let outerEnd = CGPoint(
        x: center.x + outerRadius * cos(endRad),
        y: center.y + outerRadius * sin(endRad)
    )

    path.line(to: outerStart)
    path.appendArc(
        withCenter: center,
        radius: outerRadius,
        startAngle: startAngle,
        endAngle: endAngle,
        clockwise: false
    )

    // Line back to center
    path.line(to: center)
    path.close()

    return path
}
```

### 2. Circular Grid/Circles

```swift
func createConcentricCircles(
    center: CGPoint,
    radii: [CGFloat]
) -> [NSBezierPath] {
    radii.map { radius in
        NSBezierPath(
            ovalIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
        )
    }
}

// Usage
let circles = createConcentricCircles(
    center: CGPoint(x: 200, y: 200),
    radii: [50, 100, 150, 200]
)

circles.forEach { circle in
    NSColor.gray.setStroke()
    circle.lineWidth = 0.5
    circle.stroke()
}
```

### 3. Radial Lines (Spokes)

```swift
func createRadialLines(
    center: CGPoint,
    radius: CGFloat,
    angleCount: Int,
    startAngle: CGFloat = 0
) -> NSBezierPath {
    let path = NSBezierPath()
    let angleIncrement = 360.0 / CGFloat(angleCount)

    for i in 0..<angleCount {
        let angle = (startAngle + CGFloat(i) * angleIncrement) * .pi / 180.0
        let endPoint = CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )

        path.move(to: center)
        path.line(to: endPoint)
    }

    return path
}

// Draw compass rose with 8 directions
let spokes = createRadialLines(
    center: CGPoint(x: 200, y: 200),
    radius: 180,
    angleCount: 8,
    startAngle: 0
)
```

### 4. Kite Diagram (Mirrored Histogram)

```swift
func createKitePath(
    center: CGPoint,
    angle: CGFloat,
    leftValue: CGFloat,
    rightValue: CGFloat,
    maxRadius: CGFloat
) -> NSBezierPath {
    let path = NSBezierPath()
    let rad = angle * .pi / 180.0

    // Perpendicular vector for left/right offset
    let perpX = -sin(rad)
    let perpY = cos(rad)

    // Four corners of kite segment
    let centerFront = CGPoint(
        x: center.x + maxRadius * cos(rad),
        y: center.y + maxRadius * sin(rad)
    )

    let leftPoint = CGPoint(
        x: center.x + leftValue * perpX,
        y: center.y + leftValue * perpY
    )

    let rightPoint = CGPoint(
        x: center.x - rightValue * perpX,
        y: center.y - rightValue * perpY
    )

    let leftFront = CGPoint(
        x: centerFront.x + leftValue * perpX,
        y: centerFront.y + leftValue * perpY
    )

    let rightFront = CGPoint(
        x: centerFront.x - rightValue * perpX,
        y: centerFront.y - rightValue * perpY
    )

    // Build path
    path.move(to: leftPoint)
    path.line(to: leftFront)
    path.line(to: rightFront)
    path.line(to: rightPoint)
    path.close()

    return path
}
```

### 5. Arrow Heads

```swift
func createArrowHead(
    at point: CGPoint,
    angle: CGFloat,
    length: CGFloat,
    width: CGFloat
) -> NSBezierPath {
    let path = NSBezierPath()
    let rad = angle * .pi / 180.0

    // Arrow points backward along angle direction
    let backX = point.x - length * cos(rad)
    let backY = point.y - length * sin(rad)

    // Perpendicular for width
    let perpX = -sin(rad)
    let perpY = cos(rad)

    let left = CGPoint(
        x: backX + width/2 * perpX,
        y: backY + width/2 * perpY
    )

    let right = CGPoint(
        x: backX - width/2 * perpX,
        y: backY - width/2 * perpY
    )

    path.move(to: point)
    path.line(to: left)
    path.line(to: right)
    path.close()

    return path
}
```

## Mathematical Utilities

### Angle Utilities

```swift
extension CGFloat {
    /// Normalize angle to 0-360 range
    func normalizedAngle() -> CGFloat {
        var angle = self
        while angle < 0 {
            angle += 360
        }
        while angle >= 360 {
            angle -= 360
        }
        return angle
    }

    /// Convert degrees to radians
    var radians: CGFloat {
        self * .pi / 180.0
    }

    /// Convert radians to degrees
    var degrees: CGFloat {
        self * 180.0 / .pi
    }
}

extension Float {
    var radians: Float {
        self * .pi / 180.0
    }

    var degrees: Float {
        self * 180.0 / .pi
    }

    func normalizedAngle() -> Float {
        var angle = self
        while angle < 0 {
            angle += 360
        }
        while angle >= 360 {
            angle -= 360
        }
        return angle
    }
}
```

### Polar Coordinates

```swift
struct PolarPoint {
    let angle: CGFloat  // degrees
    let radius: CGFloat

    var cartesian: CGPoint {
        CGPoint(
            x: radius * cos(angle.radians),
            y: radius * sin(angle.radians)
        )
    }

    func cartesian(center: CGPoint) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle.radians),
            y: center.y + radius * sin(angle.radians)
        )
    }
}

extension CGPoint {
    func polar(from center: CGPoint) -> PolarPoint {
        let dx = x - center.x
        let dy = y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx).degrees
        return PolarPoint(angle: angle, radius: radius)
    }
}
```

### Point Interpolation

```swift
extension CGPoint {
    /// Linear interpolation between two points
    func lerp(to: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (to.x - x) * t,
            y: y + (to.y - y) * t
        )
    }

    /// Distance to another point
    func distance(to: CGPoint) -> CGFloat {
        let dx = to.x - x
        let dy = to.y - y
        return sqrt(dx * dx + dy * dy)
    }

    /// Rotate around a center point
    func rotated(
        around center: CGPoint,
        by angle: CGFloat  // degrees
    ) -> CGPoint {
        let rad = angle.radians
        let dx = x - center.x
        let dy = y - center.y

        let rotatedX = dx * cos(rad) - dy * sin(rad)
        let rotatedY = dx * sin(rad) + dy * cos(rad)

        return CGPoint(
            x: center.x + rotatedX,
            y: center.y + rotatedY
        )
    }
}
```

## Drawing Optimization

### 1. Cache Paths

```swift
class GraphicLayer {
    private var cachedPath: NSBezierPath?
    private var lastGeometry: GeometryState?

    func drawingPath() -> NSBezierPath {
        let currentGeometry = currentGeometryState()

        if cachedPath == nil || lastGeometry != currentGeometry {
            cachedPath = calculatePath()
            lastGeometry = currentGeometry
        }

        return cachedPath!
    }
}
```

### 2. Reduce Path Complexity

```swift
extension NSBezierPath {
    /// Simplify path by reducing points within tolerance
    func simplified(tolerance: CGFloat = 1.0) -> NSBezierPath {
        // Douglas-Peucker algorithm or similar
        // Remove points that don't significantly affect shape
        let simplified = NSBezierPath()
        // Implementation...
        return simplified
    }
}
```

### 3. Batch Drawing

```swift
func drawMultiplePetals(
    petals: [PetalData],
    in context: CGContext
) {
    context.saveGState()

    // Set common properties once
    context.setLineWidth(1.0)
    context.setStrokeColor(NSColor.black.cgColor)

    // Draw all petals
    for petal in petals {
        let path = petal.bezierPath.cgPath
        context.addPath(path)
        context.setFillColor(petal.color.cgColor)
        context.drawPath(using: .fillStroke)
    }

    context.restoreGState()
}
```

## Complex Shape Patterns

### Rose Diagram with Data

```swift
func createRoseDiagram(
    center: CGPoint,
    radius: CGFloat,
    data: [DirectionalData],
    binCount: Int = 16
) -> NSBezierPath {
    let path = NSBezierPath()
    let angleSize = 360.0 / CGFloat(binCount)

    // Bin the data
    let bins = binData(data, binCount: binCount)

    // Find max for scaling
    let maxValue = bins.max() ?? 1.0

    for (index, value) in bins.enumerated() {
        let startAngle = CGFloat(index) * angleSize
        let endAngle = startAngle + angleSize

        let petalRadius = radius * (value / maxValue)

        let petal = createPetalPath(
            center: center,
            startAngle: startAngle,
            endAngle: endAngle,
            innerRadius: 0,
            outerRadius: petalRadius
        )

        path.append(petal)
    }

    return path
}
```

### Histogram Overlay

```swift
func createHistogramBars(
    center: CGPoint,
    innerRadius: CGFloat,
    outerRadius: CGFloat,
    values: [CGFloat],
    startAngle: CGFloat = 0
) -> [NSBezierPath] {
    let binWidth = 360.0 / CGFloat(values.count)
    let maxValue = values.max() ?? 1.0

    return values.enumerated().map { index, value in
        let angle = startAngle + CGFloat(index) * binWidth
        let barHeight = (outerRadius - innerRadius) * (value / maxValue)
        let barOuterRadius = innerRadius + barHeight

        return createPetalPath(
            center: center,
            startAngle: angle,
            endAngle: angle + binWidth,
            innerRadius: innerRadius,
            outerRadius: barOuterRadius
        )
    }
}
```

## Performance Tips

1. **Use CGPath for Complex Rendering**
   - NSBezierPath is easier to construct
   - CGPath renders faster
   - Convert when needed: `bezierPath.cgPath`

2. **Minimize State Changes**
   - Batch similar drawing operations
   - Set colors/widths once for multiple shapes
   - Use CGContext state saving

3. **Pre-calculate Geometry**
   - Compute paths once, cache results
   - Invalidate cache only when needed
   - Use lazy properties for expensive calculations

4. **Appropriate Precision**
   - Don't over-subdivide curves
   - Use flatness parameter for quality/speed balance
   - Round coordinates when pixel-perfect isn't needed

## Code Templates

### Generic Shape Drawer

```swift
protocol ShapeDrawer {
    func createPath() -> NSBezierPath
    var strokeColor: NSColor { get }
    var fillColor: NSColor? { get }
    var lineWidth: CGFloat { get }

    func draw()
}

extension ShapeDrawer {
    func draw() {
        let path = createPath()
        strokeColor.setStroke()
        fillColor?.setFill()
        path.lineWidth = lineWidth

        if let _ = fillColor {
            path.fill()
        }
        path.stroke()
    }
}
```

### Parametric Path Generator

```swift
func createParametricPath(
    from: CGFloat,
    to: CGFloat,
    steps: Int,
    transform: (CGFloat) -> CGPoint
) -> NSBezierPath {
    let path = NSBezierPath()
    let stepSize = (to - from) / CGFloat(steps)

    for i in 0...steps {
        let t = from + CGFloat(i) * stepSize
        let point = transform(t)

        if i == 0 {
            path.move(to: point)
        } else {
            path.line(to: point)
        }
    }

    return path
}

// Example: spiral
let spiral = createParametricPath(
    from: 0,
    to: 4 * .pi,
    steps: 100
) { t in
    let radius = t * 10
    return CGPoint(
        x: 200 + radius * cos(t),
        y: 200 + radius * sin(t)
    )
}
```

## Configuration

Store drawing preferences in `.coregraphics-helper.json`:
```json
{
  "defaultCenter": {"x": 200, "y": 200},
  "defaultRadius": 180,
  "defaultLineWidth": 1.0,
  "anglesInDegrees": true,
  "optimizePaths": true,
  "cacheDrawingPaths": true
}
```
