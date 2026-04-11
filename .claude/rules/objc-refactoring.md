# Objective-C → Swift Refactoring

Active migration in progress. Migrate ObjC to Swift only when asked — don't refactor opportunistically.

## What to Convert
- Direct SQL operations → `DocumentModel` methods
- `NSObject` subclasses → Swift structs where behavior doesn't require reference semantics
- `NSMutableArray`/`NSDictionary` → typed Swift collections
- Informal ObjC delegates → Swift protocols with nullability annotations

## What to Preserve
- `@objc` on anything called from ObjC
- Existing ObjC initializer signatures when the bridge requires it
- `.m` category files that are ObjC categories on Swift classes (e.g., `XRGeometryController`)

## Key Patterns
```swift
// Expose Swift to ObjC with controlled selector names
@objc(setGeometryController:)
func setGeometryController(_ controller: XRGeometryController) { ... }

// Nullability in bridging header
NS_ASSUME_NONNULL_BEGIN
- (nullable XRLayer *)activeLayerWithPoint:(NSPoint)point;
NS_ASSUME_NONNULL_END
```

## Don't
- Don't remove `geometryController` from ObjC layers without auditing the notification observer system
- Don't convert XIB-backed controllers to SwiftUI without a dedicated task scoped to that work
- Don't strip `@objc` from public layer APIs — ObjC callers depend on them
- Don't use `@objc dynamic` unless KVO is required
