# Development Workflow

## Local Development Setup

```bash
# Prerequisites
xcode-select --install
brew install swiftlint swiftformat

# Setup
git clone <repo-url>
cd ScreenTimeRewards
open ScreenTimeRewards.xcworkspace

# Build
xcodebuild -workspace ScreenTimeRewards.xcworkspace \
  -scheme ScreenTimeRewards build

# Run tests
xcodebuild test \
  -workspace ScreenTimeRewards.xcworkspace \
  -scheme ScreenTimeRewards \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Environment Configuration

```bash
# Development
CLOUDKIT_CONTAINER_ID=iCloud.com.yourcompany.screentimerewards
DEBUG_LOGGING=true
ENABLE_MOCK_DATA=true

# Production
DEBUG_LOGGING=false
ENABLE_MOCK_DATA=false
ENABLE_LIVE_ACTIVITIES=true
```

---
