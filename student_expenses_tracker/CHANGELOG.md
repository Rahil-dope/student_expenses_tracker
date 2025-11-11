# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-11

### Added
- **Initial Release** - Student Expenses Tracker with core features:
  - Local expense and budget management with Drift ORM
  - Firebase Authentication (email/password sign-in and sign-up)
  - Bidirectional cloud sync with Firestore (Phase E)
  - Timestamp-based conflict resolution for merged changes
  - Soft delete support for data recovery
  - Dashboard with monthly spending summary
  - Expense list view with filtering by category
  - Budget management screen
  - CSV import/export functionality
  - Settings screen with manual sync and sign-out
  - Material 3 design with Deep Purple theme
  - Riverpod for reactive state management
  - Firebase Analytics and Crashlytics integration

### Technical Details
- **Platforms:** Android, iOS, Linux, macOS, Windows
- **Framework:** Flutter 3.9.2
- **Database:** Drift ORM with sqflite backend
- **State Management:** Riverpod 3.0.3
- **Backend:** Firebase (Auth, Firestore, Analytics, Crashlytics)

---

## Planned Features for Future Releases

- [ ] Recurring expense automation
- [ ] Receipt OCR scanning
- [ ] Multi-currency support with exchange rates
- [ ] Spending trends and analytics
- [ ] Dark mode support
- [ ] Expense splitting between users
- [ ] Monthly budget notifications
- [ ] Transaction search and advanced filtering
- [ ] Data export to multiple formats (PDF, Excel)
