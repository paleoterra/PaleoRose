---
trigger: always_on
---

# macOS Development Guidelines

## Code Style & Documentation
- Use Swift's official style guide as the primary reference
- Follow Apple's API Design Guidelines for all public interfaces
- Use `camelCase` for variables and functions, `PascalCase` for types

### Documentation Requirements
- Include the standard open source preamble comments at the top of each new Swift file
- Document all non-private APIs using `///` style documentation
- Include parameter descriptions, return values, and possible errors
- Add `// MARK: -` comments to organize code into logical sections
- Use `// TODO:`, `// FIXME:`, and `// NOTE:` for temporary or important notes

## Testing Requirements
### Unit Testing
- Use Swift Testing framework for all unit tests
- Follow the naming convention: `test_methodName_condition_expectedResult`
- Structure tests with clear Arrange-Act-Assert sections
- Mock all external dependencies
- use parameterization to test multiple cases

### UI & Performance Testing
- Use XCTest for UI and performance testing
- Create UI tests for all critical user flows
- Add performance tests for time-sensitive operations
- Include accessibility tests to ensure compliance

## Architecture & Design
- Follow MVVM architecture pattern for SwiftUI views
- Use dependency injection for better testability
- Keep view models and models independent of the view layer
- Prefer value types (structs) over reference types (classes) when appropriate
- Use protocols to define clear interfaces between components

## User Interface
### Design Principles
- Conform to the latest [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- Support both light and dark mode
- Ensure proper layout for dynamic type sizes
- Make all controls accessible via keyboard navigation
- Support VoiceOver and other accessibility features

### SwiftUI Implementation
- Use `@StateObject` for view model lifecycle
- Prefer `@Binding` over multiple `@State` variables
- Use `@Environment` for system-wide dependencies
- Implement proper error handling and loading states
- Use appropriate animation for state changes

## Technical Constraints
### File Management
- Do not modify or update xib, nib, or storyboard files
- Do not modify Xcode project files directly
- Create new files in the appropriate feature/module directory
- Keep files under 500 lines when possible
- Split large files into logical extensions

### Build & Dependencies
- Use Swift Package Manager for dependencies
- Pin all dependencies to exact versions
- Document all third-party libraries in README.md
- Keep the project building without warnings
- Use `#if DEBUG` for development-only code

## Performance
- Profile with Instruments regularly
- Optimize for performance on older hardware
- Use background queues for expensive operations
- Implement proper memory management
- Use lazy loading for heavy resources

## Security
- Use `SecureField` for password inputs
- Store sensitive data in Keychain
- Validate all user inputs
- Use HTTPS for all network requests
- Follow Apple's security best practices

## Localization
- Use `LocalizedStringKey` for all user-facing strings
- Support right-to-left languages
- Use `formatted()` for numbers, dates, and measurements
- Test with different locale settings

## Error Handling
- Use Swift's `Result` type or `throws` for operations that can fail
- Provide meaningful error messages
- Log errors appropriately
- Implement proper error recovery
- Show user-friendly error messages