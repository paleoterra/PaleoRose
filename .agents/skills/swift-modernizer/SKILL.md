---
description: Modernize Swift code to use the latest language features and best practices
---

# Swift Modernizer

Modernize Swift code to use the latest language features and best practices.

## Capabilities

1. **Async/Await Migration**
   - Convert completion handlers to async/await
   - Update delegate patterns to use async sequences
   - Modernize GCD usage to structured concurrency

2. **Modern Swift Syntax**
   - Use result builders where applicable
   - Convert `if let` chains to `if let` shorthand
   - Apply `guard` statements for early returns
   - Use property wrappers (@Published, @AppStorage, etc.)

3. **Protocol-Oriented Programming**
   - Suggest protocol extraction from classes
   - Replace inheritance with composition
   - Identify opportunities for protocol extensions

4. **Type Safety Improvements**
   - Replace stringly-typed APIs with enums
   - Add type-safe builders and DSLs
   - Suggest opaque return types (`some View`)

5. **SwiftUI Modernization**
   - Convert AppKit/UIKit patterns to SwiftUI equivalents
   - Update to latest SwiftUI modifiers and APIs
   - Suggest observable pattern usage

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan the specified Swift files or directories
2. **Report**: List all modernization opportunities with:
   - Current pattern found
   - Suggested modern replacement
   - File location and line numbers
   - Impact assessment (breaking change, safe refactor, etc.)
3. **Apply**: Optionally apply suggested changes
4. **Test**: Run tests to verify changes don't break functionality

## Usage Instructions

When the user invokes this skill:

1. Ask which files/directories to analyze (default: all .swift files)
2. Ask what modernization level to apply:
   - **Conservative**: Only safe, non-breaking changes
   - **Moderate**: Include minor API changes that are clearly better
   - **Aggressive**: All modernization opportunities including breaking changes
3. Scan for patterns and generate a report
4. Ask user which changes to apply
5. Apply changes and run tests

## Example Transformations

### Before: Completion Handler
```swift
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(data!))
    }.resume()
}
```

### After: Async/Await
```swift
func fetchData() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

### Before: Optional Binding
```swift
if let name = person.name {
    if let age = person.age {
        print("\(name) is \(age)")
    }
}
```

### After: Modern Syntax
```swift
if let name = person.name,
   let age = person.age {
    print("\(name) is \(age)")
}
```

## Configuration

Check for a `.swift-modernizer.json` config file in the project root for:
- Excluded patterns
- Minimum deployment target
- Enabled/disabled modernization rules
