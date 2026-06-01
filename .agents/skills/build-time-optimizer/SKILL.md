---
description: Analyze and optimize Xcode build times by identifying slow compilation units and suggesting improvements
---

# Build Time Optimizer

Analyze and optimize Xcode build times by identifying slow compilation units and suggesting improvements.

## Capabilities

1. **Build Time Analysis**
   - Measure file-by-file compilation times
   - Identify slowest compilation units
   - Track build time trends
   - Compare incremental vs full builds

2. **Compilation Bottleneck Detection**
   - Find type-checker performance issues
   - Identify expensive expressions
   - Detect slow generics instantiation
   - Find protocol witness table generation overhead

3. **Optimization Suggestions**
   - Suggest type annotation additions
   - Recommend breaking up complex expressions
   - Identify modularization opportunities
   - Propose build settings improvements

4. **Dependency Optimization**
   - Reduce header imports
   - Minimize cross-module dependencies
   - Suggest forward declarations
   - Optimize framework linking

5. **Reporting**
   - Generate build time reports
   - Show compilation timeline
   - Track improvements over time
   - Export analysis data

## Workflow

When invoked, this skill will:

1. **Profile**: Run instrumented build
2. **Analyze**: Parse build logs and timings
3. **Identify**: Find bottlenecks and issues
4. **Recommend**: Suggest specific improvements
5. **Measure**: Verify optimizations

## Usage Instructions

When the user invokes this skill:

1. Ask analysis scope:
   - Full build analysis
   - Incremental build check
   - Specific target
   - Recent changes impact

2. Choose detail level:
   - Quick overview
   - Per-file breakdown
   - Function-level analysis
   - Deep type-checker profiling

3. Run analysis
4. Generate report with recommendations
5. Apply suggested fixes

## Build Time Measurement

### 1. Enable Build Timing

```bash
# Add to Xcode build settings or .xcconfig file
OTHER_SWIFT_FLAGS = -Xfrontend -debug-time-function-bodies -Xfrontend -debug-time-compilation

# For detailed type checking times
OTHER_SWIFT_FLAGS = -Xfrontend -warn-long-function-bodies=100 -Xfrontend -warn-long-expression-type-checking=100
```

### 2. Build and Extract Timing

```bash
#!/bin/bash
# measure-build-time.sh

# Clean build with timing
xcodebuild clean build \
    -project PaleoRose.xcodeproj \
    -scheme PaleoRose \
    -configuration Debug \
    OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-function-bodies" \
    | tee build-log.txt

# Extract timing information
grep "warning.*took" build-log.txt | \
    sed 's/.*warning: //' | \
    sort -t' ' -k3 -n -r | \
    head -20
```

### 3. Parse Build Logs

```swift
#!/usr/bin/swift

import Foundation

struct BuildTimeParser {
    struct CompilationTime {
        let file: String
        let duration: Double
        let warnings: [String]
    }

    struct FunctionTime {
        let function: String
        let file: String
        let line: Int
        let duration: Double
    }

    func parseXcodeBuildLog(_ logPath: String) -> [CompilationTime] {
        guard let content = try? String(contentsOfFile: logPath) else {
            return []
        }

        var times: [CompilationTime] = []

        // Parse compilation times
        let pattern = #"CompileSwift.*?(\S+\.swift).*?(\d+\.\d+) seconds"#
        let regex = try! NSRegularExpression(pattern: pattern)

        let matches = regex.matches(
            in: content,
            range: NSRange(content.startIndex..., in: content)
        )

        for match in matches {
            if let fileRange = Range(match.range(at: 1), in: content),
               let timeRange = Range(match.range(at: 2), in: content) {
                let file = String(content[fileRange])
                let duration = Double(String(content[timeRange])) ?? 0

                times.append(CompilationTime(
                    file: file,
                    duration: duration,
                    warnings: []
                ))
            }
        }

        return times.sorted { $0.duration > $1.duration }
    }

    func parseFunctionTimes(_ logPath: String) -> [FunctionTime] {
        guard let content = try? String(contentsOfFile: logPath) else {
            return []
        }

        var times: [FunctionTime] = []

        // Parse function body compilation warnings
        let pattern = #"(\S+\.swift):(\d+):\d+: warning: .*'(.+?)' took (\d+)ms"#
        let regex = try! NSRegularExpression(pattern: pattern)

        let matches = regex.matches(
            in: content,
            range: NSRange(content.startIndex..., in: content)
        )

        for match in matches {
            if let fileRange = Range(match.range(at: 1), in: content),
               let lineRange = Range(match.range(at: 2), in: content),
               let funcRange = Range(match.range(at: 3), in: content),
               let timeRange = Range(match.range(at: 4), in: content) {

                times.append(FunctionTime(
                    function: String(content[funcRange]),
                    file: String(content[fileRange]),
                    line: Int(String(content[lineRange])) ?? 0,
                    duration: Double(String(content[timeRange])) ?? 0
                ))
            }
        }

        return times.sorted { $0.duration > $1.duration }
    }

    func generateReport(
        files: [CompilationTime],
        functions: [FunctionTime]
    ) -> String {
        var report = "# Build Time Analysis Report\n\n"

        // File compilation times
        report += "## Slowest Files to Compile\n\n"
        for (index, file) in files.prefix(20).enumerated() {
            report += "\(index + 1). \(file.file): \(file.duration)s\n"
        }

        // Function compilation times
        report += "\n## Slowest Functions to Type-Check\n\n"
        for (index, func) in functions.prefix(20).enumerated() {
            report += "\(index + 1). \(func.function) (\(func.file):\(func.line)): \(func.duration)ms\n"
        }

        // Summary stats
        let totalTime = files.reduce(0) { $0 + $1.duration }
        let avgTime = totalTime / Double(files.count)

        report += "\n## Summary\n\n"
        report += "- Total files: \(files.count)\n"
        report += "- Total compilation time: \(totalTime)s\n"
        report += "- Average per file: \(String(format: "%.2f", avgTime))s\n"
        report += "- Slowest file: \(files.first?.file ?? "N/A") (\(files.first?.duration ?? 0)s)\n"

        return report
    }
}

// Usage
let parser = BuildTimeParser()
let files = parser.parseXcodeBuildLog("build-log.txt")
let functions = parser.parseFunctionTimes("build-log.txt")
let report = parser.generateReport(files: files, functions: functions)

print(report)

// Save report
try? report.write(toFile: "build-time-report.md", atomically: true, encoding: .utf8)
```

## Common Optimization Strategies

### 1. Add Type Annotations

```swift
// Before: Slow type inference
let graphics = layers
    .filter { $0.isVisible }
    .flatMap { layer in
        (0..<binCount).map { bin in
            createGraphic(layer, bin)  // Complex inference
        }
    }

// After: Explicit types help compiler
let graphics: [Graphic] = layers
    .filter { $0.isVisible }
    .flatMap { (layer: Layer) -> [Graphic] in
        (0..<binCount).map { (bin: Int) -> Graphic in
            createGraphic(layer, bin)
        }
    }
```

### 2. Break Up Complex Expressions

```swift
// Before: Single complex expression (slow to type-check)
let result = data
    .filter { $0.value > threshold && $0.isValid }
    .map { calculateComplexValue($0) }
    .reduce(initialValue) { acc, val in
        acc + val * multiplier - offset
    }

// After: Split into steps
let filtered = data.filter { $0.value > threshold && $0.isValid }
let mapped = filtered.map(calculateComplexValue)
let result = mapped.reduce(initialValue) { acc, val in
    acc + val * multiplier - offset
}
```

### 3. Simplify Generic Constraints

```swift
// Before: Complex generic constraints
func process<T: Codable & Hashable & CustomStringConvertible>(
    items: [T]
) where T: Comparable {
    // ...
}

// After: Create protocol composition
protocol ProcessableItem: Codable, Hashable, CustomStringConvertible, Comparable {}

func process<T: ProcessableItem>(items: [T]) {
    // Faster to compile
}
```

### 4. Use Concrete Types in Internal APIs

```swift
// Before: Generic internal function (slower)
private func formatValue<T: CustomStringConvertible>(_ value: T) -> String {
    return "Value: \(value.description)"
}

// After: Concrete type for internal use
private func formatValue(_ value: String) -> String {
    return "Value: \(value)"
}
```

### 5. Reduce @objc Dynamic Dispatch

```swift
// Before: Unnecessary @objc (bridges to Obj-C runtime)
class GraphicPetal: Graphic {
    @objc var lineWidth: Float = 1.0
    @objc func calculateGeometry() { }
}

// After: Remove if not needed by Obj-C
class GraphicPetal: Graphic {
    var lineWidth: Float = 1.0
    func calculateGeometry() { }
}
```

### 6. Optimize Protocol Witness Tables

```swift
// Before: Many small protocol conformances
extension GraphicPetal: CustomStringConvertible { }
extension GraphicPetal: CustomDebugStringConvertible { }
extension GraphicPetal: Equatable { }
extension GraphicPetal: Hashable { }

// After: Consolidate in main declaration
class GraphicPetal: Graphic,
                    CustomStringConvertible,
                    CustomDebugStringConvertible,
                    Equatable,
                    Hashable {
    // All conformances in one place - faster compilation
}
```

### 7. Module Organization

```swift
// Before: Everything in one target
// PaleoRose target contains:
// - Graphics (100 files)
// - Database (50 files)
// - UI (80 files)
// Total: 230 files rebuild on any change

// After: Separate frameworks
// PaleoRoseGraphics.framework (100 files)
// PaleoRoseDatabase.framework (50 files)
// PaleoRose app (80 files + frameworks)
// Only changed framework rebuilds
```

## Build Settings Optimization

### Xcode Build Settings

```ruby
# .xcconfig or Build Settings

# Parallel compilation
SWIFT_COMPILATION_MODE = wholemodule  # For release
# OR
SWIFT_COMPILATION_MODE = incremental   # For debug (faster incremental)

# Optimization level
SWIFT_OPTIMIZATION_LEVEL = -O          # Release
SWIFT_OPTIMIZATION_LEVEL = -Onone      # Debug (faster compile)

# Module linking
SWIFT_WHOLE_MODULE_OPTIMIZATION = YES  # Release
SWIFT_WHOLE_MODULE_OPTIMIZATION = NO   # Debug

# Parallel build
SWIFT_PARALLEL_COMPILATION = YES

# Index while building
COMPILER_INDEX_STORE_ENABLE = NO       # Faster build, no indexing

# Debug info
DEBUG_INFORMATION_FORMAT = dwarf       # Faster than dwarf-with-dsym for debug
```

### Project-Specific Settings

```ruby
# PaleoRose.xcconfig

# Increase build performance
SWIFT_PARALLEL_COMPILATION = YES
SWIFT_COMPILATION_MODE = incremental

# Only for debug builds
SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug] = DEBUG
SWIFT_OPTIMIZATION_LEVEL[config=Debug] = -Onone

# Optimize release builds
SWIFT_OPTIMIZATION_LEVEL[config=Release] = -O
SWIFT_COMPILATION_MODE[config=Release] = wholemodule
```

## Automated Analysis Tools

### Build Time Tracker Script

```swift
#!/usr/bin/swift

import Foundation

struct BuildTimeTracker {
    let projectPath: String

    func track() {
        print("🔨 Building project...")

        let startTime = Date()

        // Run build
        let result = shell(
            """
            cd \(projectPath) && \
            xcodebuild clean build \
                -project PaleoRose.xcodeproj \
                -scheme PaleoRose \
                -configuration Debug \
                OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-function-bodies" \
                | tee build.log
            """
        )

        let duration = Date().timeIntervalSince(startTime)

        print("✅ Build completed in \(duration)s")

        // Parse and analyze
        analyzeBuildLog()
    }

    func analyzeBuildLog() {
        let parser = BuildTimeParser()
        let files = parser.parseXcodeBuildLog("build.log")

        // Save historical data
        saveHistoricalData(files)

        // Generate report
        generateReport(files)
    }

    func saveHistoricalData(_ files: [BuildTimeParser.CompilationTime]) {
        let data = BuildTimeData(
            date: Date(),
            totalDuration: files.reduce(0) { $0 + $1.duration },
            fileCount: files.count,
            slowestFiles: Array(files.prefix(10))
        )

        // Append to historical log
        // (JSON or SQLite database)
    }

    func generateReport(_ files: [BuildTimeParser.CompilationTime]) {
        print("\n📊 Build Time Report\n")
        print("Top 10 Slowest Files:")

        for (index, file) in files.prefix(10).enumerated() {
            let fileName = URL(fileURLWithPath: file.file).lastPathComponent
            print("\(index + 1). \(fileName): \(file.duration)s")
        }

        // Check for regressions
        checkRegressions(files)
    }

    func checkRegressions(_ files: [BuildTimeParser.CompilationTime]) {
        // Compare against historical baseline
        // Alert if any file >20% slower than average
    }

    private func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

struct BuildTimeData: Codable {
    let date: Date
    let totalDuration: Double
    let fileCount: Int
    let slowestFiles: [BuildTimeParser.CompilationTime]
}
```

### CI Integration

```yaml
# .github/workflows/build-performance.yml

name: Build Performance

on:
  pull_request:
  push:
    branches: [main]

jobs:
  measure-build-time:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Measure Build Time
        run: |
          swift run BuildTimeTracker --project .

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: build-time-report
          path: build-time-report.md

      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('build-time-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '## Build Time Report\n\n' + report
            });
```

## Visualization

### Build Time Trend Chart

```html
<!DOCTYPE html>
<html>
<head>
    <title>Build Time Trends</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <canvas id="buildTimeChart"></canvas>
    <script>
        const ctx = document.getElementById('buildTimeChart');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [{
                    label: 'Build Time (seconds)',
                    data: [120, 115, 108, 95],
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</body>
</html>
```

## Quick Wins Checklist

- [ ] Enable incremental compilation for Debug builds
- [ ] Disable index-while-building for faster iteration
- [ ] Add explicit type annotations to complex expressions
- [ ] Break up files >500 lines
- [ ] Remove unused imports
- [ ] Consolidate protocol conformances
- [ ] Use concrete types for internal APIs
- [ ] Extract slow functions to separate files
- [ ] Consider modularization for large targets
- [ ] Profile and optimize top 10 slowest files

## Configuration

Store optimization settings in `.build-optimizer.json`:
```json
{
  "trackHistory": true,
  "historyPath": "./BuildMetrics/history.json",
  "thresholds": {
    "fileCompilationWarning": 5.0,
    "functionTypeCheckWarning": 100
  },
  "xcodeBuildSettings": {
    "debug": {
      "SWIFT_COMPILATION_MODE": "incremental",
      "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
    },
    "release": {
      "SWIFT_COMPILATION_MODE": "wholemodule",
      "SWIFT_OPTIMIZATION_LEVEL": "-O"
    }
  }
}
```
