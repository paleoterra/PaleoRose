# UI Snapshot Tester Agent

Generate and manage snapshot tests for UI components.

## Purpose
Create reference images of UI and detect visual regressions automatically.

## When to Invoke
- Adding new UI components
- Refactoring view code
- Verifying UI across OS versions
- Preventing visual regressions

## Capabilities
- Generate snapshot tests using Swift Testing
- Capture view hierarchy snapshots
- Compare against reference images
- Detect pixel differences
- Update reference images when intended
- Test different view states
- Support Dark Mode testing
- Test accessibility labels/traits

## Workflow
1. Identify views to test
2. Generate snapshot test code
3. Run tests to capture references
4. Re-run to detect changes
5. Review and approve/reject differences

## Best Practices
- Test various view states (empty, populated, error)
- Include different sizes
- Test Dark/Light modes
- Version control reference images
