# Firebase Setup (Phase E)

Follow these steps to set up Firebase for the app (Authentication + Firestore):

1. Create Firebase Project
   - Go to https://console.firebase.google.com and create a new project.

2. Enable Authentication
   - In the Firebase console, go to "Authentication" -> "Get started".
   - Enable Email/Password provider.

3. Enable Firestore
   - In the Firebase console, go to "Firestore Database" -> Create database.
   - Start in "test mode" while developing, then configure rules before production.

4. Add Android App
   - Register your Android app (package name must match `applicationId` in `android/app/build.gradle.kts`).
   - Download `google-services.json` and place it into `android/app/`.
   - Add Firebase Gradle plugin: in `android/build.gradle` add classpath for google-services.
   - Apply plugin in `android/app/build.gradle` (apply plugin: 'com.google.gms.google-services').

5. Add iOS App (optional)
   - Register iOS app and download `GoogleService-Info.plist` into `ios/Runner` and add it to Xcode.

6. Firestore Security Rules (example)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

7. Local testing & OAuth
   - Use Firebase Authentication emulator for local testing (recommended).

8. Notes on sync
   - Store user data under `/users/{uid}/expenses`, `/users/{uid}/budgets`, `/users/{uid}/categories`.
   - Use `updatedAt` timestamp and a `deleted` flag to handle conflicts and soft deletes.

9. Additional (optional)
   - Enable Crashlytics and Analytics in the console and follow platform setup steps.

10. Troubleshooting
   - If using FlutterFire CLI, run `flutterfire configure` to generate `firebase_options.dart` and use `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` instead of the default call.
