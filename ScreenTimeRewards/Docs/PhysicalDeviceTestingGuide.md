# Physical Device Testing Guide for Family Controls

This guide provides comprehensive instructions for testing Family Controls integration on physical iOS devices, including known limitations, setup requirements, and validation procedures.

## Overview

Family Controls framework requires physical iOS device testing because:
- iOS Simulator does not support Family Controls authorization
- DeviceActivityMonitor events are not triggered in Simulator
- App discovery and token generation may not work correctly in Simulator
- Authorization dialogs do not appear in Simulator environment

## Prerequisites

### Device Requirements
- [ ] Physical iOS device running iOS 15.0 or later
- [ ] Device not enrolled in Mobile Device Management (MDM) that restricts Family Controls
- [ ] Apple ID signed into the device
- [ ] iCloud enabled and functioning
- [ ] Screen Time not already configured by another Family Controls app

### Development Environment
- [ ] Xcode 15.0 or later with iOS SDK
- [ ] Apple Developer Account with Family Controls entitlement approved
- [ ] Valid provisioning profile with Family Controls capability
- [ ] TestFlight access for distribution testing

### App Configuration
- [ ] Bundle identifier matches provisioning profile
- [ ] Family Controls entitlement properly configured
- [ ] DeviceActivityMonitor extension included in build
- [ ] iCloud container configured and accessible
- [ ] Background App Refresh enabled for the app

## Testing Setup

### 1. Device Preparation

```bash
# Install the app via Xcode or TestFlight
# For Xcode installation:
1. Connect device via USB
2. Select device as deployment target
3. Build and run (⌘+R)
4. Trust developer certificate on device if prompted

# For TestFlight installation:
1. Upload build to App Store Connect
2. Create TestFlight build
3. Invite test users
4. Install via TestFlight app on device
```

### 2. Pre-Test Verification

Before running Family Controls tests, verify:

- [ ] App launches successfully on device
- [ ] No crashes during basic navigation
- [ ] iCloud sync is working (if applicable)
- [ ] Device has apps installed for monitoring tests
- [ ] Device is not in airplane mode or low power mode

## Testing Procedures

### Authorization Flow Testing

#### Test 1: Initial Authorization Request
```
1. Launch app on fresh installation
2. Navigate to Family Controls setup
3. Trigger authorization request
4. VERIFY: System dialog appears asking for Family Controls permission
5. Grant permission
6. VERIFY: App receives .approved authorization status
7. VERIFY: Authorization persists after app restart
```

#### Test 2: Authorization Denial
```
1. Fresh app installation or reset permissions
2. Trigger authorization request
3. Deny permission in system dialog
4. VERIFY: App receives .denied authorization status
5. VERIFY: App provides appropriate user guidance
6. VERIFY: App handles denied state gracefully
```

#### Test 3: Parent/Child Role Detection
```
1. Test with device configured as parent device
2. VERIFY: isParent() returns true for approved authorization
3. VERIFY: isChild() returns false for approved authorization
4. Test with restricted/child device (if available)
5. VERIFY: Appropriate role detection for restricted devices
```

### Device Activity Monitoring Testing

#### Test 4: Monitoring Session Start/Stop
```
1. Ensure Family Controls authorization is granted
2. Configure monitoring for test child profile
3. Start monitoring session
4. VERIFY: No errors thrown during start
5. VERIFY: intervalDidStart callback triggered (check logs)
6. Stop monitoring session
7. VERIFY: intervalDidEnd callback triggered (check logs)
```

#### Test 5: Usage Event Detection
```
1. Start monitoring session with test apps
2. Use monitored apps for specified duration
3. VERIFY: Usage events are detected and logged
4. VERIFY: Event data contains correct app information
5. VERIFY: Time calculations are accurate
```

#### Test 6: Threshold Events
```
1. Configure monitoring with short thresholds (for testing)
2. Use apps until threshold is reached
3. VERIFY: eventDidReachThreshold callback triggered
4. VERIFY: Correct event data is passed to handlers
5. VERIFY: Main app receives notifications properly
```

### Error Handling Testing

#### Test 7: Authorization Errors
```
1. Test authorization request without entitlement (if possible)
2. Test authorization on unsupported device/iOS version
3. VERIFY: Appropriate errors are thrown and handled
4. VERIFY: User-friendly error messages are displayed
```

#### Test 8: Monitoring Errors
```
1. Attempt to start monitoring without authorization
2. Attempt to monitor invalid app selections
3. Test monitoring with malformed configurations
4. VERIFY: Errors are caught and handled gracefully
5. VERIFY: App remains stable after errors
```

## Debugging Tools

### Console Logging

Enable detailed logging to monitor Family Controls behavior:

```swift
// In development builds, enable debug logging
#if DEBUG
import OSLog

let logger = Logger(subsystem: "com.screentimerewards", category: "family-controls")
logger.debug("Authorization status: \(authorizationService.authorizationStatus)")
#endif
```

### Monitoring Tools

Use these tools to verify Family Controls behavior:

1. **Console.app** - View system and app logs
2. **Device Settings > Screen Time** - Check Family Controls permissions
3. **Xcode Device Console** - Real-time logging during development
4. **TestFlight Feedback** - Collect user reports for distributed testing

### Log Patterns to Monitor

Watch for these log patterns during testing:

```
Family Controls Authorization:
✅ "Requesting Family Controls authorization"
✅ "Authorization request completed with status: approved"
❌ "Authorization request failed: ..."

Device Activity Monitoring:
✅ "Started monitoring session for child: ..."
✅ "Device activity interval started: ..."
❌ "Failed to start monitoring: ..."

Event Detection:
✅ "Device activity event reached threshold: ..."
✅ "Sent Darwin notification: ..."
❌ "Event processing failed: ..."
```

## Common Issues and Solutions

### Issue: Authorization Dialog Never Appears
**Symptoms:** Authorization request returns immediately without user interaction
**Causes:**
- App running in iOS Simulator
- Missing Family Controls entitlement
- Invalid provisioning profile

**Solutions:**
- Test only on physical devices
- Verify entitlement in Apple Developer Console
- Regenerate provisioning profiles

### Issue: Monitoring Events Not Triggered
**Symptoms:** DeviceActivityMonitor callbacks never execute
**Causes:**
- App not properly installed (Xcode deployment vs App Store/TestFlight)
- DeviceActivityMonitor extension not included in build
- Background app refresh disabled

**Solutions:**
- Install via TestFlight for full functionality
- Verify extension is included in build target
- Enable background app refresh in Settings

### Issue: Inconsistent Authorization Status
**Symptoms:** Authorization status changes unexpectedly
**Causes:**
- Family Controls settings modified in System Settings
- Multiple Family Controls apps conflicting
- Device management policies interfering

**Solutions:**
- Check System Settings > Screen Time
- Test with single Family Controls app only
- Verify device is not MDM-managed

## Test Scenarios Checklist

### Basic Functionality
- [ ] App launches on physical device
- [ ] Authorization request shows system dialog
- [ ] Authorization approval is detected correctly
- [ ] Authorization denial is handled gracefully
- [ ] Parent/child role detection works
- [ ] Authorization persists across app restarts

### Monitoring Features
- [ ] Device activity monitoring starts without errors
- [ ] App usage events are detected and logged
- [ ] Time thresholds trigger appropriate callbacks
- [ ] Monitoring can be stopped cleanly
- [ ] Multiple monitoring sessions can be managed

### Error Handling
- [ ] Authorization errors are caught and displayed
- [ ] Monitoring errors don't crash the app
- [ ] Network/iCloud errors are handled
- [ ] Invalid configurations are rejected safely

### Performance
- [ ] Authorization requests complete within 5 seconds
- [ ] Monitoring setup doesn't block UI
- [ ] Event processing doesn't impact app performance
- [ ] Memory usage remains stable during monitoring

### Edge Cases
- [ ] App handles device restart during monitoring
- [ ] Authorization works after iOS version update
- [ ] Monitoring continues after app backgrounding
- [ ] Works correctly with multiple user profiles

## Reporting Test Results

When reporting test results, include:

1. **Device Information**
   - iOS version
   - Device model
   - Available storage
   - iCloud account status

2. **App Information**
   - App version/build number
   - Installation method (Xcode/TestFlight)
   - Family Controls entitlement status
   - Bundle identifier

3. **Test Results**
   - Which tests passed/failed
   - Error messages encountered
   - Console logs for failures
   - Screenshots of issues

4. **Environment**
   - Other Family Controls apps installed
   - Screen Time configuration
   - Parental Controls settings
   - MDM enrollment status

## Next Steps

After successful physical device testing:

1. **Document any device-specific behaviors**
2. **Update error handling based on real-world scenarios**
3. **Create automated test scripts where possible**
4. **Prepare for App Store submission testing**
5. **Plan beta testing program with actual families**

---

**Important:** Physical device testing is mandatory for Family Controls features. Do not rely solely on Simulator testing as it will not accurately represent production behavior.