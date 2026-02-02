# Kinesa v1.0.4 (Build 14) Release Notes

**Release Date:** February 2026

---

## What's New

### Health Integration Improvements

#### iOS (Apple Health)
- **Fixed:** Health button/tab now responds correctly on the home screen
- **Fixed:** HealthKit permissions flow now works reliably
- **Improved:** Users who previously denied permissions can now easily re-enable them via a new "Open Settings" button
- **Improved:** Relaxed permission checking - app now only requires Steps permission as minimum, allowing partial health data access
- **Fixed:** HealthKit entitlements configuration for proper health-records access

#### Android (Health Connect)
- **New:** Added Health Connect SDK status detection
- **New:** Automatic prompt to install Health Connect if not available on device
- **New:** "Open Health Connect" button to manage permissions directly
- **Improved:** Better error handling and user guidance for Health Connect setup
- **Improved:** Platform-specific UI messaging for clearer user instructions

### Crash Reporting
- **New:** Automatic dSYM upload to Firebase Crashlytics for iOS builds
- **Improved:** Crash reports will now show readable stack traces with file names and line numbers

### Code Quality
- **Fixed:** Test suite improvements for better reliability
- **Fixed:** Linting issues and unused imports cleaned up

---

## App Store / Play Store Description

### Short Description (80 chars)
```
Health tracking fixes, improved permissions flow, better crash reporting
```

### What's New (Release Notes)

#### For App Store (iOS):
```
- Fixed: Health button now responds correctly on home screen
- Fixed: Apple Health permissions work reliably
- New: "Open Settings" button when permissions are denied
- Improved: Better guidance for enabling health permissions
- Improved: Crash reporting now provides detailed diagnostics
```

#### For Play Store (Android):
```
- New: Health Connect integration improvements
- New: Automatic prompt to install Health Connect if needed
- New: Easy access to Health Connect settings
- Improved: Better error handling for health data sync
- Improved: Clearer instructions for setting up health permissions
```

---

## Technical Changes

| Area | Change Type | Description |
|------|-------------|-------------|
| iOS Entitlements | Fix | Added `health-records` to HealthKit access array |
| HealthService | Fix | Relaxed permission check to only require STEPS |
| HealthService | New | Added `openHealthSettings()` for both platforms |
| HealthService | New | Added `getDetailedPermissions()` for granular status |
| HealthDetailsScreen | New | Health Connect SDK status checking (Android) |
| HealthDetailsScreen | New | Install prompt for Health Connect (Android) |
| HealthDetailsScreen | Improved | Platform-specific permission UI |
| Xcode Build | New | Automatic dSYM upload to Crashlytics |
| Tests | Fix | Fixed obscureText test accessing wrong widget |
| Code | Cleanup | Removed unused imports, linting fixes |

---

## Files Changed

- `ios/Runner/Runner.entitlements` - HealthKit configuration
- `lib/features/health/data/services/health_service.dart` - Health service improvements
- `lib/features/health/presentation/screens/health_details_screen.dart` - UI improvements
- `ios/Runner.xcodeproj/project.pbxproj` - Crashlytics dSYM upload script
- `integration_test/app_integration_test.dart` - Test fixes
- Multiple files - Linting cleanup

---

## Upgrade Notes

- **iOS Users:** If you previously denied Health permissions, you can now tap "Open Settings" to re-enable them
- **Android Users:** If Health Connect is not installed, you'll be prompted to install it from the Play Store
- **No breaking changes** - This is a seamless upgrade

---

## Known Issues

- None reported for this release

---

## Coming Soon

- Additional health metrics support
- Enhanced analytics and insights
- Community features
