# Phase 02 — Core Infrastructure

**Status:** pending  
**Priority:** critical  
**BlockedBy:** Phase 01  
**Blocks:** Phase 03, 04, 05, 06

## Overview

Shared foundation for all feature modules: Isar init + all schemas, notification service, "Pencil & Paper" theme (from `docs/UI/DESIGN.md`), 4-tab go_router skeleton, and shared widgets.

**UI Reference:** `docs/UI/DESIGN.md`

## Requirements

- Isar opens successfully at app start
- All feature schemas registered (BloodSugarEntry, Medication, DoseLog, Article, UserProfile) — MealLog removed (deferred to v2)
- `NotificationService` can schedule/cancel daily reminders
- `AppTheme` matches DESIGN.md exactly (colors, typography, spacing)
- go_router with 4-tab bottom nav shell: Trang chủ | Nhật ký | Kiến thức | Hồ sơ
- Shared widgets: `LoadingIndicator`, `EmptyState`, `ErrorView`, `PaperCard`

## Implementation Steps

### 1. Isar Database Setup

**`src/lib/core/database/isar-database.dart`**

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
// import all schemas:
import '../../features/blood_sugar/data/blood-sugar-entry.dart';
import '../../features/medication/data/medication.dart';
import '../../features/medication/data/dose-log.dart';
import '../../features/knowledge/data/article.dart';
import '../../features/profile/data/user-profile.dart';

// V1: isarProvider — Riverpod-managed, testable, migration-safe
// Override in ProviderScope after initIsar() returns
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError('override required'));

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
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

### 2. All Isar Schemas

**`src/lib/features/blood_sugar/data/blood-sugar-entry.dart`**
```dart
@collection
class BloodSugarEntry {
  Id id = Isar.autoIncrement;
  late double value;        // mg/dL
  late DateTime measuredAt;
  late String mealContext;  // 'fasting'|'before_meal'|'after_meal'|'bedtime'
  String? note;
}
```

**`src/lib/features/medication/data/medication.dart`**
```dart
@collection
class Medication {
  Id id = Isar.autoIncrement;
  late String name;
  late String dosage;
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
  late String mealType;       // 'breakfast'|'lunch'|'dinner'|'snack'
  late DateTime loggedAt;
  late int estimatedCarbs;    // grams
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
  late String remoteId;
  late String title;
  late String category;
  late String content;
  String? imageUrl;
  late int version;
  late DateTime cachedAt;
  // F1: full final fields here — not deferred to Phase 08
  late int readTimeMinutes;   // default 5
  late bool isFavorite;       // default false — local-only, never overwritten by remote sync
}
```

**`src/lib/features/medication/data/dose-log.dart`** (F1: defined here in Phase 02)
```dart
@collection
class DoseLog {
  Id id = Isar.autoIncrement;
  late int medicationId;
  late String slot;         // 'morning'|'noon'|'evening'|'night'
  late DateTime takenAt;
  late bool taken;
}
```

**`src/lib/features/profile/data/user-profile.dart`**
```dart
@collection
class UserProfile {
  Id id = Isar.autoIncrement;
  late String name;
  late String diabetesType;   // 'type1'|'type2'|'prediabetes'
  late double targetMin;      // default 70
  late double targetMax;      // default 140
  late double heightCm;
  late double weightKg;
  DateTime? dateOfBirth;
  String? avatarPath;
}
```

### 3. App Theme — "Pencil & Paper"

**`src/lib/core/theme/app-theme.dart`**

```dart
// Colors from docs/UI/DESIGN.md
class AppColors {
  // Backgrounds (warm paper)
  static const background           = Color(0xFFFCF9F3);
  static const surface              = Color(0xFFFCF9F3);
  static const surfaceContainerLow  = Color(0xFFF6F3ED);
  static const surfaceContainer     = Color(0xFFF0EEE8);
  static const surfaceContainerHigh = Color(0xFFEBE8E2);
  static const surfaceDim           = Color(0xFFDCDAD4);

  // Primary (soft teal-green)
  static const primary              = Color(0xFF35675B);
  static const onPrimary            = Color(0xFFFFFFFF);
  static const primaryContainer     = Color(0xFF6B9E90);
  static const onPrimaryContainer   = Color(0xFF00342A);

  // Secondary (muted yellow)
  static const secondary            = Color(0xFF735B26);
  static const secondaryContainer   = Color(0xFFFDDC9A);

  // Tertiary / danger (soft red)
  static const tertiary             = Color(0xFF8B4C50);
  static const tertiaryContainer    = Color(0xFFC98083);
  static const error                = Color(0xFFBA1A1A);

  // Text
  static const onSurface            = Color(0xFF1C1C18);
  static const onSurfaceVariant     = Color(0xFF404946);
  static const outline              = Color(0xFF707975);
  static const outlineVariant       = Color(0xFFC0C8C4);

  // Blood sugar status (mapped to theme)
  static const bsLow          = Color(0xFFBA1A1A);  // error red
  static const bsNormal       = Color(0xFF35675B);  // primary teal
  static const bsPrediabetes  = Color(0xFF735B26);  // secondary amber
  static const bsHigh         = Color(0xFFBA1A1A);  // error red
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'BeVietnamPro',
    colorScheme: const ColorScheme.light(
      primary:          AppColors.primary,
      onPrimary:        AppColors.onPrimary,
      secondary:        AppColors.secondary,
      tertiary:         AppColors.tertiary,
      error:            AppColors.error,
      surface:          AppColors.surface,
      onSurface:        AppColors.onSurface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surfaceContainerLow,
  );
}
```

**`src/lib/core/theme/blood-sugar-status.dart`**
```dart
enum BloodSugarStatus { low, normal, prediabetes, high }

// F10: accepts explicit thresholds so callers can pass user's custom target range
BloodSugarStatus getStatus(double value, {double low = 70, double targetMin = 100, double targetMax = 126}) {
  if (value < low)        return BloodSugarStatus.low;
  if (value < targetMin)  return BloodSugarStatus.normal;
  if (value < targetMax)  return BloodSugarStatus.prediabetes;
  return BloodSugarStatus.high;
}
// Usage: getStatus(entry.value, low: 70, targetMin: profile.targetMin, targetMax: profile.targetMax)

Color statusColor(BloodSugarStatus s) => switch (s) {
  BloodSugarStatus.low         => AppColors.bsLow,
  BloodSugarStatus.normal      => AppColors.bsNormal,
  BloodSugarStatus.prediabetes => AppColors.bsPrediabetes,
  BloodSugarStatus.high        => AppColors.bsHigh,
};

String statusLabel(BloodSugarStatus s) => switch (s) {
  BloodSugarStatus.low         => 'Hạ đường huyết',
  BloodSugarStatus.normal      => 'Bình thường',
  BloodSugarStatus.prediabetes => 'Tiền tiểu đường',
  BloodSugarStatus.high        => 'Cao',
};
```

### 4. Font Setup

Add `Be Vietnam Pro` to `pubspec.yaml`:
```yaml
fonts:
  - family: BeVietnamPro
    fonts:
      - asset: assets/fonts/BeVietnamPro-Regular.ttf
      - asset: assets/fonts/BeVietnamPro-Medium.ttf   weight: 500
      - asset: assets/fonts/BeVietnamPro-SemiBold.ttf weight: 600
      - asset: assets/fonts/BeVietnamPro-Bold.ttf     weight: 700
```
Download from Google Fonts → `assets/fonts/`.

### 5. Notification Service

**`src/lib/core/notifications/notification-service.dart`**

```dart
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(requestAlertPermission: false);
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  // F3 + F9: request permission for both iOS and Android 13+
  static Future<void> requestPermission() async {
    await _plugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, sound: true);
    await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  }

  static Future<void> scheduleMedicationReminder({
    required int id, required String name, required String dosage, required int hour,
  }) async {
    await _plugin.zonedSchedule(
      id,
      'Nhắc uống thuốc',
      '$name — $dosage',
      _nextInstanceOf(hour),  // F3: defined below
      const NotificationDetails(
        android: AndroidNotificationDetails('medication', 'Thuốc', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // F3: compute next occurrence of given hour (today if future, tomorrow if past)
  static TZDateTime _nextInstanceOf(int hour) {
    final now = TZDateTime.now(local);
    var scheduled = TZDateTime(local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  static Future<void> cancelReminder(int id) => _plugin.cancel(id);
  // F15: prefer cancelReminder() by known IDs; cancelAll() only for full reset
  static Future<void> cancelAll() => _plugin.cancelAll();
}
```

### 6. Shared Widgets

**`src/lib/core/widgets/paper-card.dart`** — Card styled as paper scrap:
```dart
// Warm surface container background, subtle outline border, slight corner radius (8px)
// Optional: slight rotation via Transform.rotate for personality
class PaperCard extends StatelessWidget { ... }
```

**`src/lib/core/widgets/loading-indicator.dart`** — Centered `CircularProgressIndicator` with primary color  
**`src/lib/core/widgets/empty-state.dart`** — Icon + Vietnamese message + optional CTA  
**`src/lib/core/widgets/error-view.dart`** — Error message + "Thử lại" button

### 7. 4-Tab Navigation Skeleton

**`src/lib/app.dart`**
```dart
final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/onboarding', builder: ...),
    ShellRoute(
      builder: (ctx, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(path: '/home',       builder: ...),  // Trang chủ
        GoRoute(path: '/diary',      builder: ...),  // Nhật ký
        GoRoute(path: '/knowledge',  builder: ...),  // Kiến thức
        GoRoute(path: '/profile',    builder: ...),  // Hồ sơ
      ],
    ),
  ],
);
```

**`src/lib/core/widgets/scaffold-with-bottom-nav.dart`**
```dart
NavigationBar(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home_outlined),     label: 'Trang chủ'),
    NavigationDestination(icon: Icon(Icons.edit_note),         label: 'Nhật ký'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined),label: 'Kiến thức'),
    NavigationDestination(icon: Icon(Icons.person_outline),    label: 'Hồ sơ'),
  ],
)
```

### 8. main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();  // F3: required before any TZDateTime usage
  final db = await initIsar();  // V1: returns Isar instance, not global
  await NotificationService.init();
  // F13: load persisted unit preference once
  final prefs = await SharedPreferences.getInstance();
  final unitStr = prefs.getString('blood_sugar_unit') ?? 'mgdl';
  final initialUnit = unitStr == 'mmoll' ? BloodSugarUnit.mmoll : BloodSugarUnit.mgdl;
  // V5: load onboarded flag once — used by router redirect synchronously
  final onboarded = prefs.getBool('onboarded') ?? false;
  runApp(ProviderScope(
    overrides: [
      isarProvider.overrideWithValue(db),                    // V1
      bloodSugarUnitProvider.overrideWith((ref) => initialUnit),  // F13
      onboardedProvider.overrideWith((ref) => onboarded),   // V5
    ],
    child: const App(),
  ));
}
```

Add to `core/config/` or `app.dart`:
```dart
// V5: onboarding gate — read once in main(), never causes per-navigation I/O
final onboardedProvider = StateProvider<bool>((ref) => false);
```

## Files to Create

| File | Purpose |
|------|---------|
| `core/database/isar-database.dart` | Isar init |
| `features/blood_sugar/data/blood-sugar-entry.dart` | Schema |
| `features/medication/data/medication.dart` | Schema |
| `features/medication/data/meal-log.dart` | Schema |
| `features/knowledge/data/article.dart` | Schema |
| `features/profile/data/user-profile.dart` | Schema |
| `core/theme/app-theme.dart` | Pencil & Paper theme |
| `core/theme/blood-sugar-status.dart` | Status logic |
| `core/notifications/notification-service.dart` | Notifications |
| `core/widgets/paper-card.dart` | Branded card |
| `core/widgets/loading-indicator.dart` | Loading state |
| `core/widgets/empty-state.dart` | Empty state |
| `core/widgets/error-view.dart` | Error state |
| `core/widgets/scaffold-with-bottom-nav.dart` | 4-tab shell |
| `lib/app.dart` | go_router |
| `lib/main.dart` | Entry point |
| `assets/fonts/BeVietnamPro-*.ttf` | Font files |

## Todo

- [ ] Create all Isar schema files including DoseLog (F1: all schemas finalized here)
- [ ] Run `flutter pub run build_runner build`
- [ ] Download Be Vietnam Pro fonts → `assets/fonts/`
- [ ] Implement `app-theme.dart` with DESIGN.md colors
- [ ] Implement `blood-sugar-status.dart`
- [ ] Implement `notification-service.dart`
- [ ] Implement shared widgets (paper-card, loading, empty, error)
- [ ] Implement `scaffold-with-bottom-nav.dart` (4 tabs)
- [ ] Implement `app.dart` + `main.dart`
- [ ] `flutter analyze` — 0 errors
- [ ] App launches with warm paper background + 4 bottom tabs

## Success Criteria

- `flutter pub run build_runner build` succeeds
- App shows warm `#FCF9F3` background with teal `#35675B` nav active state
- 4 tabs navigate to placeholder screens
- Be Vietnam Pro font renders correctly
