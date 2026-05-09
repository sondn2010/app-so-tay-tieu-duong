# System Architecture - Sổ Tay Tiểu Đường

## Overview

This document describes the system architecture of the Sổ Tay Tiểu Đường Flutter app, covering data flow, layer design, and key technical decisions.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│              UI Layer                   │
│  (Screens, Widgets, GoRouter)          │
├─────────────────────────────────────────┤
│          State Management              │
│         (Riverpod Providers)           │
├─────────────────────────────────────────┤
│           Data Layer                   │
│    (Repositories, Isar Models)        │
├─────────────────────────────────────────┤
│         Infrastructure                │
│  (Isar DB, SharedPreferences, Dio)    │
└─────────────────────────────────────────┘
```

## Data Flow

### Blood Sugar Entry Flow

```
User Input (Numpad)
       ↓
BloodSugarEntryScreen
       ↓
BloodSugarRepository.save()
       ↓
Isar Database
       ↓
BloodSugarProvider (notifies listeners)
       ↓
DiaryScreen updates
```

### Medication Reminder Flow

```
MedicationFormScreen → save()
       ↓
MedicationRepository
       ↓
MedicationNotificationSync (provider)
       ↓
NotificationService.schedule()
       ↓
OS pushes notification
       ↓
User taps → App opens
```

### Knowledge Sync Flow

```
ArticleListScreen (init)
       ↓
ArticleRepository.seedFromAssets()
       ↓
ArticleRepository.syncFromRemote()
       ↓
Dio GET AppConfig.knowledgeRemoteUrl
       ↓
Parse JSON → save to Isar
       ↓
Providers notify → UI updates
```

## Key Components

### 1. Database Layer

**Isar Database** (`lib/core/database/isar_database.dart`)

```dart
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [
      BloodSugarEntrySchema,
      MedicationSchema,
      DoseLogSchema,
      ArticleSchema,
      UserProfileSchema,
    ],
    directory: dir.path,
  );
}
```

**Schema Registration**: All collections registered at app init in `main.dart`.

### 2. State Management

**Riverpod Hierarchy**:

```
isarProvider (root)
    ↓
RepositoryProvider
    ↓
StateNotifierProvider
    ↓
UI ConsumerWidget
```

**Key Providers**:
- `isarProvider` - Database instance (root)
- `bloodSugarUnitProvider` - mg/dL or mmol/L
- `onboardedProvider` - Onboarding state
- `[Feature]Provider` - Feature state

### 3. Navigation

**GoRouter Structure**:

```
/onboarding (outside shell)
    ↓
ShellRoute (ScaffoldWithBottomNav)
    ├── /home (HomeScreen)
    │   └── nested: medication, medication/add, medication/:id
    ├── /diary (BloodSugarDiaryScreen)
    │   └── nested: diary/add
    ├── /knowledge (ArticleListScreen)
    │   └── nested: knowledge/:remoteId
    └── /profile (ProfileScreen)
        └── nested: profile/edit, profile/sync, profile/help
```

**Redirect Logic**: Auto-redirect to `/onboarding` if not onboarded.

### 4. Notifications

**NotificationService** (`lib/core/notifications/notification_service.dart`)

- Initialize in `main.dart` before `runApp()`
- Schedule daily/weekly medication reminders
- Use timezone-aware scheduling

## Feature Interactions

### Home → Blood Sugar

```
HomeScreen
  ├── BloodSugarMiniChart (widget)
  │   └── reads: bloodSugarEntriesProvider
  └── Quick Add FAB → /diary/add
```

### Medication → Notifications

```
MedicationListScreen
  ├── displays: medicationsProvider
  └── MedicationFormScreen
      └── on save → MedicationNotificationSync
                          ↓
                    schedule notifications
```

### Profile → Settings

```
ProfileScreen
  ├── EditProfileScreen (name, target range)
  ├── Unit selector → bloodSugarUnitProvider
  └── DataSyncScreen → ArticleRepository.syncFromRemote()
```

## Data Models

### BloodSugarEntry

```
value: double (mg/dL, always stored as mg/dL)
measuredAt: DateTime
mealContext: String ('fasting'|'before_meal'|'after_meal'|'bedtime')
note: String?
```

**Convert to mmol/L**: `value / 18.0182`

### Medication

```
name: String
dosage: String
schedule: String ('daily'|'weekly')
times: List<DateTime>
enabled: bool
```

### DoseLog

```
medicationId: int
takenAt: DateTime
```

### UserProfile

```
name: String
targetMin: double (mg/dL)
targetMax: double (mg/dL)
```

### Article

```
remoteId: String
title: String
content: String
syncedAt: DateTime
```

## Theme System

**AppTheme** (`lib/core/theme/app_theme.dart`)

- Material 3 enabled
- Custom color scheme with warm paper palette
- `useMaterial3: true`
- Font: BeVietnamPro

**BloodSugarStatus** (`lib/core/theme/blood_sugar_status.dart`)

- Determines color based on glucose value + meal context
- Low: < 70 mg/dL (fasting)
- Normal: 70-100 mg/dL (fasting)
- Prediabetes: 100-125 mg/dL (fasting)
- High: > 125 mg/dL (fasting)

## External Integrations

| Service | Library | Purpose |
|---------|---------|---------|
| Articles | Dio → GitHub Raw | Remote article JSON sync |
| Storage | Isar | Local NoSQL database |
| Preferences | SharedPreferences | Unit, onboarded state |
| Notifications | flutter_local_notifications | Medication reminders |

## Security Considerations

- **Local Only**: No user data sent to external servers
- **Remote Articles**: Read-only from GitHub Raw
- **No Sensitive PII**: Local storage only

## Performance Optimizations

- **Offline First**: All features work without network
- **Isar Indexes**: Indexed by date for fast queries
- **Code Generation**: `.g.dart` files pre-generated

---

*Last updated: 2026-05-09*