# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

```
src/mobile/                    # Flutter app (diabetes tracking)
├── lib/
│   ├── main.dart             # Entry point, initializes DB, notifications, prefs
│   ├── app.dart             # GoRouter + MaterialApp setup
│   ├── core/               # Shared utilities
│   │   ├── database/      # Isar database initialization
│   │   ├── theme/         # AppTheme, BloodSugarStatus
│   │   ├── widgets/       # Reusable widgets (PaperCard, ErrorView, etc.)
│   │   ├── config/        # AppConfig, enums
│   │   └── notifications/ # Local notifications
│   └── features/          # Feature modules (feature-first architecture)
│       ├── home/         # Dashboard
│       ├── blood_sugar/  # Glucose tracking
│       ├── medication/   # Medication reminders
│       ├── knowledge/   # Health articles
│       ├── profile/    # User profile & settings
│       └── onboarding/
```

## Common Commands

```bash
cd src/mobile
flutter run                      # Run app
flutter build apk --debug       # Build Android debug APK
flutter test                  # Run all tests
flutter test test/path_test.dart # Run single test
dart run build_runner build   # Generate Isar models
flutter analyze              # Lint
```

## Architecture

- **State Management**: Riverpod (flutter_riverpod) with providers in each feature's `providers/` folder
- **Database**: Isar (local NoSQL) - models in `data/` folder, repositories handle CRUD
- **Navigation**: GoRouter with ShellRoute for bottom navigation
- **HTTP**: Dio for remote API calls
- **Notifications**: flutter_local_notifications for medication reminders

### Feature Module Pattern

Each feature follows:
```
features/[name]/
├── data/           # Isar models + repositories
├── providers/     # Riverpod providers
├── screens/       # Screens
└── widgets/      # Feature-specific widgets
```

### Blood Sugar Values

- Units: mg/dL (default) or mmol/L
- Status thresholds defined in `core/theme/blood_sugar_status.dart`
- Display: Badge component shows color-coded status

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization, DB, notifications |
| `lib/app.dart` | Router configuration |
| `core/database/isar_database.dart` | Isar instance |
| `core/notifications/notification_service.dart` | Notification scheduling |
| `features/*/providers/[name]_providers.dart` | Feature state |