# Quick Start Guide - Student Expenses Tracker

Get up and running in 5 minutes!

## ⚡ 5-Minute Setup

### 1. Install & Run (2 min)
```bash
# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

### 2. Firebase Setup (3 min)
1. Go to https://console.firebase.google.com
2. Create new project (name: "Student Expenses Tracker")
3. Create Android app with package: `com.studentexpensestracker.app`
4. Create iOS app with bundle: `com.studentexpensestracker.app`
5. Download credentials (auto-placed by Firebase CLI) OR manually add:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
6. Enable Email/Password auth in Firebase Console → Authentication
7. Deploy security rules from `FIREBASE_SETUP.md`

### 3. Test the App
```
1. Open app → See Login Screen (or Dashboard if already signed in)
2. Sign up with test email (e.g., test@example.com)
3. Tap "+" button → Add test expense
4. Tap gear icon → Settings → Manual Sync
5. Sign out to test auth flow
```

Done! 🎉

---

## 📖 Learn More

| Topic | File |
|-------|------|
| Firebase Configuration | `FIREBASE_SETUP.md` |
| Building & Releasing | `RELEASE.md` |
| Design & Branding | `BRANDING.md` |
| Version History | `CHANGELOG.md` |
| Full Documentation | `README.md` |
| Completion Details | `COMPLETION_SUMMARY.md` |

---

## 🔧 Common Tasks

### Add Test Expense
```
Dashboard → "+" button → Fill form → Save
```

### Set Budget
```
Budgets tab → "+" button → Select category → Set amount → Save
```

### Export Data
```
Expenses tab → Menu → Export CSV
```

### Sync to Cloud
```
Settings (gear icon) → Manual Sync button
```

### Sign Out
```
Settings (gear icon) → Scroll down → Sign Out → Confirm
```

---

## 🐛 Troubleshooting

**App won't build?**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Firebase errors?**
- Check Firebase project exists
- Verify credentials files present
- Review security rules in Firestore
- Check console for errors

**Sync not working?**
- Verify internet connection
- Check Firebase auth state (sign in required)
- Review Firestore security rules
- Check Crashlytics for errors

---

## 📞 Need Help?

1. Read `README.md` - Comprehensive guide
2. Check `FIREBASE_SETUP.md` - Firebase issues
3. Review `RELEASE.md` - Build issues
4. Look at code comments in `lib/main.dart`

---

**Version**: 1.0.0  
**Last Updated**: November 11, 2025
