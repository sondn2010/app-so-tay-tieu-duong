# Codebase Summary - Sổ Tay Tiểu Đường

## Overview

This document summarizes the Sổ Tay Tiểu Đường Flutter codebase structure, organized for maintainability and feature discovery.

- **Total Files**: 52 Dart files
- **Lines of Code**: ~9,643 LOC
- **Location**: `src/mobile/lib/`

## Directory Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                 # GoRouter + MaterialApp
├── core/                    # Shared utilities
│   ├── config/
│   ├── database/
│   ├── notifications/
│   ├── theme/
│   └── widgets/
└── features/               # Feature modules
    ├── blood_sugar/
    ├── medication/
    ├── knowledge/
    ├── profile/
    ├── home/
    └── onboarding/
```

## Core Modules

### `lib/main.dart`
Entry point - initializes:
- Isar database via `initIsar()`
- Flutter local notifications
- SharedPreferences
- Riverpod providers

### `lib/app.dart`
Router setup with GoRouter:
- Redirect logic based on onboarded state
- ShellRoute for bottom navigation
- Feature routes under shell

### `lib/core/`

| Module | Purpose | Key Files |
|--------|---------|-----------|
| `config/` | App constants | `app_config.dart` |
| `database/` | Isar init | `isar_database.dart` |
| `notifications/` | Local notifications | `notification_service.dart` |
| `theme/` | AppTheme, colors | `app_theme.dart`, `blood_sugar_status.dart` |
| `widgets/` | Shared widgets | `paper_card.dart`, `error_view.dart`, `scaffold_with_bottom_nav.dart`, `blood_sugar_numpad.dart` |

## Feature Modules

### `blood_sugar/`
Blood glucose tracking - 10 files

```
blood_sugar/
├── data/
│   ├── blood_sugar_entry.dart      # Isar model
│   ├── blood_sugar_entry.g.dart   # Generated
│   └── blood_sugar_repository.dart
├── providers/
│   └── blood_sugar_providers.dart
├── screens/
│   ├── blood_sugar_entry_screen.dart
│   ├── blood_sugar_diary_screen.dart
│   └── components/
│       └── blood_sugar_value_badge.dart
└── widgets/ (none yet)
```

**Key Patterns**:
- `BloodSugarEntry` Isar model with `value` (mg/dL), `measuredAt`, `mealContext`, `note`
- Repository pattern for data access
- Riverpod providers for state

### `medication/`
Medication reminders - 9 files

```
medication/
├── data/
│   ├── medication.dart, .g.dart
│   ├── dose_log.dart, .g.dart
│   ├── medication_repository.dart
│   └── dose_log_repository.dart
├── providers/
│   ├── medication_providers.dart
│   └── medication_notification_sync.dart
├── screens/
│   ├── medication_list_screen.dart
│   └── medication_form_screen.dart
└── widgets/
    └── medication_reminder_banner.dart
```

**Key Patterns**:
- `Medication` model: name, dosage, schedule (daily/weekly)
- `DoseLog` model: tracks when doses taken
- Notification sync provider for reminders

### `knowledge/`
Health articles - 5 files

```
knowledge/
├── data/
│   ├── article.dart, .g.dart
│   └── article_repository.dart
├── providers/
│   └── knowledge_providers.dart
└── screens/
    ├── article_list_screen.dart
    └── article_detail_screen.dart
```

**Key Patterns**:
- Remote sync from `AppConfig.knowledgeRemoteUrl`
- Seed from bundled assets
- Dio HTTP client

### `profile/`
User profile - 6 files

```
profile/
├── data/
│   ├── user_profile.dart, .g.dart
│   ├── user_profile_repository.dart
│   └── avatar_service.dart
├── providers/
│   └── profile_providers.dart
└── screens/
    ├── profile_screen.dart
    ├── edit_profile_screen.dart
    ├── data_sync_screen.dart
    └── help_screen.dart
```

**Key Patterns**:
- Profile with name, target glucose range
- Unit preference (mg/dL or mmol/L)
- Unit conversion handled by providers

### `home/`
Dashboard - 4 files

```
home/
├── data/
│   ├── steps_repository.dart
│   └── daily_quotes.dart
├── providers/
│   └── home_providers.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    └── blood_sugar_mini_chart.dart
```

### `onboarding/`
First-launch flow - 1 file

```
onboarding/
└── screens/
    └── onboarding_screen.dart
```

## Shared Widgets

| Widget | Purpose |
|--------|---------|
| `PaperCard` | Elevated card with paper aesthetic |
| `ErrorView` | Error state with retry |
| `EmptyState` | Empty list placeholder |
| `LoadingIndicator` | Loading spinner |
| `ScaffoldWithBottomNav` | Bottom navigation shell |
| `BloodSugarNumpad` | Number input for glucose |

## State Management

Riverpod providers organized by feature:

- `bloodSugarUnitProvider` - Current unit (mg/dL or mmol/L)
- `onboardedProvider` - Onboarding state
- `isarProvider` - Database instance
- Feature providers wrap repositories

## Database Models

All models use Isar with code generation:

```dart
@collection
class BloodSugarEntry {
  Id id = Isar.autoIncrement;
  late double value;
  late DateTime measuredAt;
  late String mealContext;
  String? note;
}
```

Generated files (`*.g.dart`) committed to repo.

## Navigation

GoRouter with ShellRoute:
- `/onboarding` - First launch
- `/home` - Dashboard (default)
- `/diary` - Blood sugar diary
- `/knowledge` - Articles
- `/profile` - User settings

Nested routes for feature forms.

## Theme

Custom Material 3 theme:
- Warm paper backgrounds (#FCF9F3)
- Soft teal-green primary (#35675B)
- Muted yellow secondary (#735B26)
- Custom blood sugar status colors

## Testing Notes

- No test files yet in codebase
- Follow TDD for new features
- Repository tests with in-memory Isar

---

*Last updated: 2026-05-09*