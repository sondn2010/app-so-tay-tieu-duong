# Project Overview - Sổ Tay Tiểu Đường

## Project Summary

**Sổ Tay Tiểu Đường** (Diabetes Handbook) is a Flutter mobile application for diabetes health tracking, designed for Vietnamese users. The app enables offline-first blood glucose monitoring, medication reminders, and health knowledge access.

- **Type**: Flutter mobile app (iOS/Android)
- **Language**: Dart
- **Target Users**: Vietnamese people with diabetes or prediabetes
- **Scale**: 52 Dart files, ~9,643 LOC

## Problem Statement

Vietnamese diabetic patients need a simple, offline-capable mobile app to:
- Track blood glucose levels with context (fasting, before/after meal, bedtime)
- Set medication reminders with local notifications
- Access health education articles
- Maintain profile with personalized diabetic goals

## Product Development Requirements (PDR)

### Core Features

#### 1. Blood Sugar Tracking
- **F1.1**: Log glucose via numpad input (mg/dL or mmol/L)
- **F1.2**: Select meal context (fasting, before meal, after meal, bedtime)
- **F1.3**: View diary with daily/weekly entries
- **F1.4**: Mini chart on dashboard
- **F1.5**: Convert between mg/dL and mmol/L

#### 2. Medication Management
- **F2.1**: Add/edit medications with name, dosage, schedule
- **F2.2**: Set daily/weekly reminders
- **F2.3**: Local push notifications
- **F2.4**: Log dose when taken

#### 3. Knowledge Articles
- **F3.1**: Display list of health articles
- **F3.2**: Sync from remote JSON URL
- **F3.3**: Article detail view

#### 4. User Profile
- **F4.1**: Create/edit profile (name, age, target glucose range)
- **F4.2**: Configure units (mg/dL or mmol/L)
- **F4.3**: Data sync screen
- **F4.4**: Help screen

#### 5. Onboarding
- **F5.1**: First-launch onboarding flow
- **F5.2**: Set preferred language/unit
- **F5.3**: Mark as onboarded in SharedPreferences

### Non-Functional Requirements

- **Offline First**: All core features work without internet
- **Performance**: < 100ms UI response time
- **Storage**: Local Isar database
- **Notifications**: Flutter local notifications for reminders

## Technology Stack

| Component | Library | Version |
|-----------|----------|---------|
| State | flutter_riverpod | ^2.5.1 |
| Database | isar | ^3.1.0 |
| Navigation | go_router | ^13.2.0 |
| HTTP | dio | ^5.4.3 |
| Notifications | flutter_local_notifications | ^17.2.2 |
| Charts | fl_chart | ^0.68.0 |
| Preferences | shared_preferences | ^2.2.3 |

## Architecture Pattern

Feature-first architecture following:
```
features/{feature}/
├── data/           # Models, repositories
├── providers/     # Riverpod providers
├── screens/        # Screen widgets
└── widgets/       # Feature-specific widgets
```

## User Journey

1. **First Launch**: Onboarding screen → Set unit preference
2. **Home**: Dashboard with mini chart, quick add button
3. **Diary**: Blood sugar entries with date filter
4. **Knowledge**: Article list with remote sync
5. **Profile**: Settings, units, help

## Success Metrics

- Average daily opens: Track via analytics
- Blood sugar entries per user: Target 3+ daily
- Medication reminder response rate: Target 80%+
- Offline usage ratio: Target >90%

## Dependencies

- `package:isar/isar.dart` - Local NoSQL database
- `package:flutter_riverpod` - State management
- `package:go_router` - Declarative routing
- `package:dio` - HTTP client for remote sync
- `package:flutter_local_notifications` - Push notifications

## Next Steps

- [ ] Implement analytics tracking
- [ ] Add data export/import
- [ ] Consider cloud backup
- [ ] Add reminder snooze functionality

---

*Last updated: 2026-05-09*