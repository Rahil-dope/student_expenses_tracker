# Student Expenses Tracker

A comprehensive Flutter application for student expense management with cloud sync, Firebase authentication, and offline-first architecture. Track expenses, manage budgets, and sync data across devices seamlessly.

## 🚀 Features

### Core Functionality
- **Expense Management**: Add, edit, and delete expenses with categories
- **Budget Tracking**: Set and monitor spending budgets by category
- **Dashboard**: View monthly spending summary and recent transactions
- **Category Organization**: Predefined expense categories for easy tracking
- **CSV Import/Export**: Import expenses from CSV or export for analysis

### Cloud & Sync (Phase E)
- **Firebase Authentication**: Secure email/password authentication
- **Firestore Cloud Sync**: Real-time bidirectional sync with Firestore
- **Conflict Resolution**: Timestamp-based merging for concurrent edits
- **Soft Delete Support**: Recover deleted expenses from cloud backup
- **Offline-First**: Works seamlessly offline, syncs when online

### Technical Highlights
- **Drift ORM**: Type-safe local database with code generation
- **Riverpod**: Reactive state management with auto-disposal
- **Material 3 Design**: Modern UI with Deep Purple theme
- **Cross-Platform**: Runs on Android, iOS, Windows, macOS, and Linux
- **Firebase Integration**: Analytics, Crashlytics for production monitoring

---

## 📋 Prerequisites

- Flutter SDK: 3.9.2 or higher
- Dart SDK: 3.9.2 or higher
- Android Studio / Xcode (for mobile development)
- Firebase project (for cloud features)

## 🛠️ Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd student_expenses_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Drift models)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Firebase Configuration

See [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) for detailed Firebase setup instructions.

**Quick Steps:**
1. Create Firebase project at https://console.firebase.google.com
2. Register Android app (package: `com.studentexpensestracker.app`)
3. Register iOS app (bundle ID: `com.studentexpensestracker.app`)
4. Enable Email/Password authentication
5. Deploy Firestore security rules from `FIREBASE_SETUP.md`
6. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 5. Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

---

## 📚 Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase init, routing
├── database/                 # Drift ORM schema
│   ├── database.dart        # Table definitions
│   └── database.g.dart      # Generated code
├── providers/               # Riverpod providers
│   ├── auth_provider.dart   # Firebase Auth provider
│   ├── expense_provider.dart # Expense data provider
│   └── sync_provider.dart   # Cloud sync provider
├── repositories/            # Business logic layer
│   ├── expense_repository.dart  # Expense CRUD + sync
│   └── sync_service.dart    # Firestore sync logic
└── screens/                 # UI screens
    ├── dashboard_screen.dart
    ├── expenses_list_screen.dart
    ├── budgets_screen.dart
    ├── quick_add_screen.dart
    ├── settings_screen.dart
    └── auth/                # Authentication screens
        ├── login_screen.dart
        └── signup_screen.dart

test/
└── widget_test.dart         # Widget and UI tests

assets/
├── icons/                   # App icons
└── splash/                  # Splash screen

.github/
└── workflows/
    └── flutter.yml          # CI/CD pipeline
```

---

## 🔄 Cloud Sync & Authentication

### Sign Up / Sign In

```dart
// Via Settings screen or Auth flow
- Navigate to sign-in
- Enter email and password
- Sign up creates new account with Firestore user document
```

### Manual Sync

```dart
// From Settings screen
1. Tap Settings icon (gear) on dashboard
2. Tap "Manual Sync" button
3. App uploads local changes and downloads remote data
4. Status displayed with loading indicator
```

### Automatic Sync

Sync is triggered automatically on:
- Insert/update/delete of expenses
- App initialization (sign-in)
- Manual sync button tap

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Specific Test File

```bash
flutter test test/widget_test.dart
```

---

## 📊 QA Checklist

Before releasing, verify all items:

### Authentication & Security
- [ ] Sign up with new email works
- [ ] Sign in with existing account works
- [ ] Password reset email received
- [ ] Sign out clears all user data
- [ ] Offline login fails gracefully with message
- [ ] Session persists on app restart

### Expense Management
- [ ] Add new expense (all fields populated)
- [ ] Edit existing expense (changes saved)
- [ ] Delete expense (soft delete, recoverable)
- [ ] Filter expenses by category
- [ ] Export to CSV (file downloads)
- [ ] Import from CSV (expenses loaded)
- [ ] Expenses display with correct totals

### Cloud Sync
- [ ] Manual sync button functional
- [ ] Sync status indicator shows loading/success/error
- [ ] Conflicting changes resolve by timestamp
- [ ] Soft-deleted expenses recoverable after sync
- [ ] Offline changes sync when online
- [ ] No data loss on sync

### Budget Management
- [ ] Set budget for category
- [ ] Edit budget amount
- [ ] Dashboard shows remaining budget
- [ ] Budget warnings display (if over budget)
- [ ] Budget syncs to cloud

### Dashboard
- [ ] Monthly summary calculates correctly
- [ ] Recent transactions list updates
- [ ] Settings button navigates to settings
- [ ] All currency displays correct

### Settings Screen
- [ ] Email displays correctly
- [ ] Manual sync button functional
- [ ] Sign out dialog appears
- [ ] Sign out clears session
- [ ] Navigation back works

### Performance
- [ ] App loads in < 3 seconds
- [ ] Scrolling is smooth (60 FPS)
- [ ] No memory leaks (< 500MB)
- [ ] Large CSV imports handle > 1000 rows
- [ ] Sync completes in < 10 seconds

### Error Handling
- [ ] Network errors show user-friendly messages
- [ ] Firebase errors handled gracefully
- [ ] App doesn't crash on unexpected input
- [ ] Sync retries on network failure
- [ ] Logs errors to Crashlytics

### Compatibility
- [ ] Tested on Android 8.0+
- [ ] Tested on iOS 12.0+
- [ ] Tested on 2+ device sizes
- [ ] Works with Android/iOS system dark mode
- [ ] Language: English (can support i18n)

---

## 🚀 Build & Release

### Android

```bash
# APK (for direct install)
flutter build apk --release --split-per-abi

# App Bundle (for Google Play Store)
flutter build appbundle --release
```

### iOS

```bash
# IPA for TestFlight/App Store
flutter build ipa --release
```

### Web / Desktop

```bash
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

See [`RELEASE.md`](RELEASE.md) for detailed deployment instructions.

---

## 📖 Documentation

- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Firebase project configuration and security rules
- **[BRANDING.md](BRANDING.md)** - App branding guidelines, colors, and assets
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and release notes
- **[RELEASE.md](RELEASE.md)** - Build and deployment guide

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Open a pull request

---

## 🐛 Troubleshooting

### Firebase Connection Issues

```
Error: "FirebaseException: [cloud_firestore/permission-denied]"
→ Check Firestore security rules in Firebase Console
→ Verify user is authenticated (check auth state)
```

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --release
```

### Sync Not Working

```
→ Verify Firebase credentials
→ Check internet connection
→ Review Firestore security rules
→ Check user authentication status
→ Look at Crashlytics for error details
```

---

## 📝 License

This project is open source. See LICENSE file for details.

---

## 📧 Support

For issues or questions:
1. Check existing GitHub issues
2. Review documentation files (FIREBASE_SETUP.md, RELEASE.md)
3. Create new issue with detailed description

---

**Last Updated:** November 11, 2025  
**Version:** 1.0.0
