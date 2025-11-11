# Release Guide - Student Expenses Tracker v1.0.0

## Pre-Release Checklist

### Code Quality
- [ ] Run `flutter analyze` - 0 errors, 0 warnings
- [ ] Run `flutter test` - all tests passing
- [ ] Code review completed
- [ ] No TODO comments in production code

### Testing
- [ ] Manual testing on Android device/emulator
- [ ] Manual testing on iOS device/emulator
- [ ] Test sign-in/sign-up flows
- [ ] Test cloud sync functionality
- [ ] Test expense CRUD operations
- [ ] Test budget management
- [ ] Test CSV import/export
- [ ] Test offline behavior (enable airplane mode)

### Firebase Configuration
- [ ] Firebase project created in Firebase Console
- [ ] Android app registered with correct package ID
- [ ] iOS app registered with correct bundle ID
- [ ] Firestore security rules deployed (see `FIREBASE_SETUP.md`)
- [ ] Firebase Authentication configured for email/password
- [ ] Analytics and Crashlytics enabled

### Branding & Assets
- [ ] App icon finalized and placed in `assets/icons/`
- [ ] Splash screen image finalized and placed in `assets/splash/`
- [ ] Review color scheme in `BRANDING.md`
- [ ] Update app name if needed (currently: "Student Expenses Tracker")

### Version & Documentation
- [ ] Version bumped to 1.0.0 in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes
- [ ] `README.md` reflects current features
- [ ] `BRANDING.md` complete with asset guidelines
- [ ] `FIREBASE_SETUP.md` provides setup instructions

---

## Build Instructions

### Android Release Build

```bash
# Generate keystore (one-time, if not already created)
# keytool -genkey -v -keystore ~/student_tracker_keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias student_tracker_key

# Build APK
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release
```

**Output:**
- APK: `build/app/outputs/flutter-app.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS Release Build

```bash
# Build IPA for TestFlight/App Store
flutter build ipa --release

# Optionally, build for simulator testing
flutter build ios --release
```

**Output:**
- IPA: `build/ios/ipa/student_expenses_tracker.ipa`

### Windows Release Build

```bash
flutter build windows --release
```

**Output:** `build/windows/runner/Release/`

### macOS Release Build

```bash
flutter build macos --release
```

**Output:** `build/macos/Build/Products/Release/`

### Linux Release Build

```bash
flutter build linux --release
```

**Output:** `build/linux/x64/release/bundle/`

---

## Deployment Steps

### Google Play Store (Android)

1. Create Google Play Developer account
2. Create app listing in Google Play Console
3. Generate signing certificate and keystore
4. Build App Bundle: `flutter build appbundle --release`
5. Upload bundle to Google Play Console
6. Fill out store listing details, privacy policy, etc.
7. Submit for review

### Apple App Store (iOS)

1. Create Apple Developer account
2. Create app record in App Store Connect
3. Generate iOS distribution certificate and provisioning profile
4. Build IPA: `flutter build ipa --release`
5. Upload using Xcode or Transporter
6. Fill out app information, screenshots, privacy policy, etc.
7. Submit for review

---

## Post-Release

- [ ] Monitor Firebase Crashlytics for errors
- [ ] Monitor Firebase Analytics for user behavior
- [ ] Collect user feedback via reviews
- [ ] Plan next release features
- [ ] Create GitHub release tag: `v1.0.0`

---

## CI/CD Integration

This project includes GitHub Actions workflow (`.github/workflows/flutter.yml`) for automated:
- Code analysis
- Unit tests
- Debug build (Android/iOS)

To enable CI/CD:
1. Push code to GitHub repository
2. Workflows will run automatically on push and pull requests
3. Review workflow results in GitHub Actions tab

---

## Troubleshooting

### Build Failures

```bash
# Clean build cache
flutter clean

# Rebuild from scratch
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build <platform> --release
```

### Firebase Issues

- Verify Firebase project configuration in `FIREBASE_SETUP.md`
- Check Google Services JSON files in `android/app/` and `ios/Runner/`
- Ensure Firestore security rules are correctly deployed

### Signing Issues (Android)

```bash
# Debug keystore info
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## Version History

- **v1.0.0** (2025-11-11) - Initial release with core features, Firebase auth, and cloud sync
