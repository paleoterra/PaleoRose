---
trigger: always_on
description: Apply when creating any unit test
---

Unit tests must be done with Swift Testing framework
- Do not use XCTest, XCTestCase, etc. and do not use any XCTest asserts, such as XCTAssertTrue
- @docs https://developer.apple.com/documentation/testing
- Use the numerics package to handle floating point equality with accurracy
- Use test arguments instead of multiple tests or tests with loops
- Keep the test files with the files being tested
- Any objective-c file used in the test must be imported into the bridging header: Paleorose-Bridging-Header.h
- All swift test files must import the app: @testable import Paleorose
- conform to Swift style guidelines
- in tests, instead of force unwrapping, use try #require
- in test, instead of guard let, use try #require
- in test, use numerics to check for float equality with accuracy
