# Phase 02 — Core Infrastructure

**Status:** pending  
**Priority:** critical  
**BlockedBy:** Phase 01  
**Blocks:** Phase 03, 04, 05

## Overview

Build the shared foundation all 3 feature modules depend on: Isar database init, all data schemas, notification service, app theme, navigation skeleton, and shared widgets.

## Requirements

- Isar opens successfully at app start
- All 3 feature schemas registered
- `NotificationService` can schedule/cancel notifications
- `AppTheme` exposes color tokens + typography
- `go_router` skeleton with bottom nav (3 tabs)
- Shared widgets: `LoadingIndicator`, `EmptyState`, `ErrorView`

## Implementation Steps

### 1. Isar Database Setup

**File:** `src/lib/core/database/isar-database.dart`

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/blood_sugar/data/blood-sugar-entry.dart';
import '../../features/medication/data/medication.dart';
import '../../features/medication/data/meal-log.dart';
import '../../features/knowledge/data/article.dart';

late Isar isar;

Future<void> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [BloodSugarEntrySchema, MedicationSchema, MealLogSchema, ArticleSchema],
    directory: dir.path,
  );
}
```

**File:** `src/lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initIsar();
  await initNotifications();
  runApp(const ProviderScope(child: App()));
}
```

### 2. Data Schemas (Isar)

**`src/lib/features/blood_sugar/data/blood-sugar-entry.dart`**
```dart
@collection
class BloodSugarEntry {
  Id id = Isar.autoIncrement;
  late double value;        // mg/dL
  late DateTime measuredAt;
  late String mealContext;  // 'before_meal' | 'after_meal' | 'fasting' | 'bedtime'
  String? note;
}
```

**`src/lib/features/medication/data/medication.dart`**
```dart
@collection
class Medication {
  Id id = Isar.autoIncrement;
  late String name;
  late String dosage;       // e.g. "500mg"
  late List<String> schedule; // ['morning','noon','evening','night']
  late bool isActive;
  String? note;
}
```

**`src/lib/features/medication/data/meal-log.dart`**
```dart
@collection
class MealLog {
  Id id = Isar.autoIncrement;
  late String mealType;     // 'breakfast'|'lunch'|'dinner'|'snack'
  late DateTime loggedAt;
  late int estimatedCarbs;  // grams
  late int estimatedCalories;
  String? note;
}
```

**`src/lib/features/knowledge/data/article.dart`**
```dart
@collection
class Article {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String remoteId;     // stable ID from JSON
  late String title;
  late String category;
  late String content;      // markdown or plain text
  late String? imageUrl;
  late int version;
  late DateTime cachedAt;
}
```

### 3. Notification Service

**File:** `src/lib/core/notifications/notification-service.dart`

```dart
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async { /* init Android + iOS channels */ }
  static Future<void> scheduleMedicationReminder({
    required int id, required String name,
    required String dosage, required Time time,
  }) async { /* daily repeating notification */ }
  static Future<void> cancelReminder(int id) async { /* cancel by id */ }
  static Future<void> cancelAll() async { /* cancel all */ }
}
```

### 4. App Theme

**File:** `src/lib/core/theme/app-theme.dart`

```dart
class AppColors {
  static const primary    = Color(0xFF1976D2);   // Medical blue
  static const background = Color(0xFFF5F5F5);
  static const surface    = Colors.white;

  // Blood sugar status colors
  static const bsNormal   = Color(0xFF4CAF50);   // GREEN  70–99
  static const bsWarn     = Color(0xFFFFC107);   // YELLOW 100–125
  static const bsDanger   = Color(0xFFF44336);   // RED    <70 or ≥126
}

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    useMaterial3: true,
  );
}
```

**File:** `src/lib/core/theme/blood-sugar-status.dart`
```dart
enum BloodSugarStatus { low, normal, prediabetes, high }

BloodSugarStatus getStatus(double value) {
  if (value < 70)  return BloodSugarStatus.low;
  if (value < 100) return BloodSugarStatus.normal;
  if (value < 126) return BloodSugarStatus.prediabetes;
  return BloodSugarStatus.high;
}

Color statusColor(BloodSugarStatus s) => switch (s) {
  BloodSugarStatus.low         => AppColors.bsDanger,
  BloodSugarStatus.normal      => AppColors.bsNormal,
  BloodSugarStatus.prediabetes => AppColors.bsWarn,
  BloodSugarStatus.high        => AppColors.bsDanger,
};
```

### 5. Navigation Skeleton (go_router)

**File:** `src/lib/app.dart`

```dart
final _router = GoRouter(
  initialLocation: '/blood-sugar',
  routes: [
    ShellRoute(
      builder: (ctx, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(path: '/blood-sugar', builder: ...),
        GoRoute(path: '/medication',  builder: ...),
        GoRoute(path: '/knowledge',   builder: ...),
      ],
    ),
  ],
);
```

3 bottom nav tabs: Đường huyết | Thuốc & Ăn | Kiến thức

### 6. Shared Widgets

**`src/lib/core/widgets/loading-indicator.dart`** — `CircularProgressIndicator` centered  
**`src/lib/core/widgets/empty-state.dart`** — icon + message + optional CTA  
**`src/lib/core/widgets/error-view.dart`** — error message + retry button

## Files to Create

| File | Purpose |
|------|---------|
| `core/database/isar-database.dart` | Isar init + open |
| `features/blood_sugar/data/blood-sugar-entry.dart` | Schema |
| `features/medication/data/medication.dart` | Schema |
| `features/medication/data/meal-log.dart` | Schema |
| `features/knowledge/data/article.dart` | Schema |
| `core/notifications/notification-service.dart` | Notification service |
| `core/theme/app-theme.dart` | Theme + colors |
| `core/theme/blood-sugar-status.dart` | Status logic + colors |
| `core/widgets/loading-indicator.dart` | Shared widget |
| `core/widgets/empty-state.dart` | Shared widget |
| `core/widgets/error-view.dart` | Shared widget |
| `lib/app.dart` | Router + app root |
| `lib/main.dart` | Entry point |

## Todo

- [ ] Create all Isar schema files
- [ ] Run `flutter pub run build_runner build` to generate Isar schemas
- [ ] Implement `isar-database.dart` init function
- [ ] Implement `notification-service.dart`
- [ ] Implement `app-theme.dart` + `blood-sugar-status.dart`
- [ ] Implement `app.dart` with go_router + bottom nav shell
- [ ] Implement `main.dart` (init sequence)
- [ ] Create 3 shared widgets
- [ ] `flutter analyze` — 0 errors

## Success Criteria

- `flutter pub run build_runner build` succeeds
- App launches with bottom navigation (3 placeholder screens)
- No Isar init errors in debug console
