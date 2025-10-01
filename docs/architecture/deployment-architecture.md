# Deployment Architecture

## Deployment Strategy

**iOS App:**
- Platform: App Store via Xcode Cloud
- Distribution: TestFlight (beta) → App Store (production)

**CloudKit:**
- Schema deployment: Automatic via Xcode
- Environments: Development → Production

## CI/CD Pipeline

```yaml
name: CI
on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: xcodebuild build -workspace ScreenTimeRewards.xcworkspace
      - name: Test
        run: xcodebuild test -workspace ScreenTimeRewards.xcworkspace
      - name: Lint
        run: swiftlint --strict
```

## Environments

| Environment | iOS App | CloudKit | Purpose |
|-------------|---------|----------|---------|
| Development | Debug Build | Dev Schema | Local testing |
| Staging | TestFlight | Dev Schema | Internal testing |
| Production | App Store | Prod Schema | Live users |

---
