# Physical Device Testing Checklist

Use this checklist to systematically validate Family Controls integration on physical iOS devices.

## Pre-Testing Setup

### Device Preparation
- [ ] Physical iOS device running iOS 15.0 or later
- [ ] Device storage > 2GB available
- [ ] Device battery > 50% charged
- [ ] Wi-Fi or cellular data connection active
- [ ] Apple ID signed into device
- [ ] iCloud enabled and syncing properly
- [ ] Screen Time feature not configured by other apps
- [ ] Device not enrolled in restrictive MDM

### Development Environment
- [ ] Xcode 15.0+ with latest iOS SDK installed
- [ ] Apple Developer Account active with Family Controls entitlement
- [ ] Valid provisioning profile with Family Controls capability
- [ ] Bundle identifier matches provisioning profile
- [ ] TestFlight access configured (for distribution testing)

### App Configuration Verification
- [ ] Family Controls entitlement in app's .entitlements file
- [ ] DeviceActivityMonitor extension included in build target
- [ ] iCloud container configured and accessible
- [ ] Background App Refresh enabled for app
- [ ] Console.app or Xcode device console ready for log monitoring

## Testing Scenarios

### Authorization Flow Testing

#### Scenario 1: Fresh Installation Authorization
- [ ] Install app on device (fresh install, no previous data)
- [ ] Launch app and navigate to Family Controls setup
- [ ] Trigger authorization request
- [ ] **Expected:** System authorization dialog appears
- [ ] Grant Family Controls permission
- [ ] **Expected:** Authorization status becomes `.approved`
- [ ] **Expected:** `isParent()` returns `true`, `isChild()` returns `false`
- [ ] Restart app and verify authorization persists
- [ ] **Expected:** No re-authorization required

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 2: Authorization Denial
- [ ] Reset Family Controls permissions (Settings > Privacy & Security > Family Controls)
- [ ] Trigger authorization request in app
- [ ] Deny permission in system dialog
- [ ] **Expected:** Authorization status becomes `.denied`
- [ ] **Expected:** App displays appropriate error message
- [ ] **Expected:** App provides guidance to enable in Settings
- [ ] **Expected:** App remains stable and functional

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 3: Authorization Persistence
- [ ] Grant Family Controls authorization
- [ ] Force quit the app
- [ ] Restart device
- [ ] Launch app again
- [ ] **Expected:** Authorization still granted (no re-prompt)
- [ ] **Expected:** Authorization status remains `.approved`

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

### Device Activity Monitoring Testing

#### Scenario 4: Basic Monitoring Setup
- [ ] Ensure Family Controls authorization is granted
- [ ] Create test child profile in app
- [ ] Configure monitoring for test child with sample apps
- [ ] Start monitoring session
- [ ] **Expected:** No errors during monitoring setup
- [ ] Check device console for monitoring start logs
- [ ] **Expected:** "Started monitoring session" log entries
- [ ] Stop monitoring session
- [ ] **Expected:** "Stopped monitoring session" log entries

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 5: App Usage Detection
- [ ] Start monitoring session with installed test apps
- [ ] Use monitored apps for 2-3 minutes each
- [ ] **Expected:** Usage events logged in console
- [ ] **Expected:** App launch/usage events detected
- [ ] **Expected:** Time tracking appears accurate
- [ ] Switch between monitored and non-monitored apps
- [ ] **Expected:** Only monitored apps generate events

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 6: Threshold Events
- [ ] Configure monitoring with short threshold (e.g., 2 minutes for testing)
- [ ] Use monitored app until threshold is reached
- [ ] **Expected:** `eventDidReachThreshold` callback triggered
- [ ] **Expected:** Threshold event logged in console
- [ ] **Expected:** Main app receives threshold notification
- [ ] Verify correct app and time data in event

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

### Error Handling Testing

#### Scenario 7: Unauthorized Monitoring Attempt
- [ ] Revoke Family Controls permission in device settings
- [ ] Attempt to start monitoring in app
- [ ] **Expected:** Error thrown and caught gracefully
- [ ] **Expected:** User-friendly error message displayed
- [ ] **Expected:** App suggests re-authorizing Family Controls
- [ ] **Expected:** App does not crash or freeze

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 8: Invalid Configuration Handling
- [ ] Attempt to create monitoring with empty app selection
- [ ] Attempt to create monitoring with invalid time ranges
- [ ] **Expected:** Configuration validation catches errors
- [ ] **Expected:** Helpful error messages provided
- [ ] **Expected:** App prevents invalid monitoring setup

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

### Performance and Stability Testing

#### Scenario 9: Background Operation
- [ ] Start monitoring session
- [ ] Background the app (press home button)
- [ ] Use monitored apps while main app is backgrounded
- [ ] **Expected:** Monitoring continues in background
- [ ] **Expected:** Events still detected and logged
- [ ] Return to app after 5-10 minutes
- [ ] **Expected:** App loads normally with monitoring still active

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 10: Extended Monitoring Session
- [ ] Start monitoring session
- [ ] Leave monitoring active for 30+ minutes
- [ ] Periodically check console for errors or memory warnings
- [ ] **Expected:** No memory leaks or excessive resource usage
- [ ] **Expected:** Monitoring remains stable throughout session
- [ ] **Expected:** All events continue to be detected accurately

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

### Integration Testing

#### Scenario 11: Multiple Child Profiles
- [ ] Create 2-3 test child profiles
- [ ] Configure different monitoring settings for each
- [ ] Start monitoring for all profiles simultaneously
- [ ] **Expected:** All monitoring sessions start successfully
- [ ] **Expected:** Events correctly attributed to proper child
- [ ] Stop monitoring for one child, continue others
- [ ] **Expected:** Only specified monitoring stops

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 12: App Categories and Points
- [ ] Configure educational apps for points earning
- [ ] Configure recreational apps with time limits
- [ ] Use both types of apps during monitoring
- [ ] **Expected:** Educational app usage generates points events
- [ ] **Expected:** Recreational app usage respects time limits
- [ ] **Expected:** Different event types handled correctly

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

## Debug Tools Testing

#### Scenario 13: Debug Information Accuracy
- [ ] Enable debug mode in app
- [ ] Use `FamilyControlsDebugTools.printAuthorizationStatus()`
- [ ] **Expected:** Accurate authorization information displayed
- [ ] Use `FamilyControlsDebugTools.printMonitoringStatus()`
- [ ] **Expected:** Correct monitoring session information
- [ ] Generate debug report
- [ ] **Expected:** Comprehensive system and status information

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

## Edge Cases and Stress Testing

#### Scenario 14: Device Restart During Monitoring
- [ ] Start monitoring session
- [ ] Restart device while monitoring is active
- [ ] Launch app after restart
- [ ] **Expected:** App handles restart gracefully
- [ ] **Expected:** Monitoring can be restarted without errors
- [ ] **Expected:** No data corruption or crashes

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

#### Scenario 15: iOS Version Compatibility
- [ ] Test on lowest supported iOS version (15.0)
- [ ] Test on latest iOS version available
- [ ] **Expected:** Consistent behavior across iOS versions
- [ ] **Expected:** No version-specific crashes or errors
- [ ] **Expected:** All features work as designed

**Result:** ✅ PASS / ❌ FAIL
**Notes:** _________________________

## Final Validation

### Overall System Integration
- [ ] All authorization flows work correctly
- [ ] Device activity monitoring functions properly
- [ ] Error handling is comprehensive and user-friendly
- [ ] Performance is acceptable (no significant battery drain)
- [ ] Debug tools provide accurate information
- [ ] App remains stable under various conditions

### Documentation Accuracy
- [ ] Physical device testing guide matches actual behavior
- [ ] Known limitations are accurately documented
- [ ] Setup instructions are complete and correct
- [ ] Troubleshooting steps resolve common issues

## Test Results Summary

**Total Scenarios:** 15
**Passed:** _____ / 15
**Failed:** _____ / 15
**Success Rate:** _____%

### Critical Issues Found
_List any issues that prevent core functionality:_

1. _________________________
2. _________________________
3. _________________________

### Non-Critical Issues Found
_List any minor issues or improvements needed:_

1. _________________________
2. _________________________
3. _________________________

### Recommendations
_Based on testing results:_

1. _________________________
2. _________________________
3. _________________________

---

**Tester:** ________________
**Date:** ________________
**Device:** _______________
**iOS Version:** __________
**App Version:** __________

**Overall Assessment:**
☐ Ready for production deployment
☐ Requires minor fixes before deployment
☐ Requires major fixes before deployment
☐ Not ready for deployment