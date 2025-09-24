# Testing Strategy

## Testing Pyramid

```
    E2E (10%)
   /        \
Integration (20%)
/              \
Unit Tests (70%)
```

## Test Examples

**Unit Test:**
```swift
func testCalculatePoints_30MinutesAt20PerHour_Returns10Points() {
    let result = calculator.calculatePoints(duration: 1800, pointsPerHour: 20)
    XCTAssertEqual(result, 10)
}
```

**UI Test:**
```swift
func testParentCanCategorizeApp() {
    app.buttons["Categorize Apps"].tap()
    app.tables.cells.containing(.staticText, identifier: "Duolingo").tap()
    app.buttons["Learning"].tap()
    XCTAssertTrue(app.staticTexts["App categorized successfully"].exists)
}
```

---
