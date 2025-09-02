---
trigger: manual
---

This memory contains a set of guidelines for refactoring legacy Objective-C code to modern standards (Objective-C 2.0+), focusing on ARC, modern syntax, type safety, and best practices for interoperability with Swift.

Key areas include:
1.  **ARC Adoption**: Migrating from manual memory management to Automatic Reference Counting.
2.  **Syntax Modernization**: Using dot notation, object literals, and subscripting.
3.  **`instancetype`**: Using `instancetype` for correct type information in initializers.
4.  **Type Safety**: Employing lightweight generics and nullability annotations.
5.  **Typed Enums**: Using `NS_ENUM` and `NS_OPTIONS`.
6.  **Concurrency**: Favoring GCD and blocks over older patterns.
7.  **Encapsulation**: Proper use of class extensions for private APIs and readonly public properties.