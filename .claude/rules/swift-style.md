# Swift Style Rules

## Naming
- `camelCase` for variables and functions, `PascalCase` for types
- Follow [Apple's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

## Documentation
- All new Swift files must include the standard MIT license preamble
- Document all non-private APIs with `///` comments including parameters, returns, and throws
- Use `// MARK: - Section Name` to organize code sections within files

## File Organization
- Keep files under 500 lines; split into focused extensions when larger
- Group related functionality with MARK comments

## Code Constraints
- **Never** modify XIB, NIB, or Storyboard files
- **Never** edit `.xcodeproj` directly
- Use Swift Package Manager for all dependencies; pin to exact versions
- Build must produce zero warnings
- Use `#if DEBUG` for development-only code

## Patterns
- Prefer value types (structs) over reference types (classes)
- Use protocols to define interfaces between components
- Use `Result` or `throws` for operations that can fail — provide meaningful error messages
- Use `[weak self]` in closures that could create retain cycles
