# Phase 07 — Home Dashboard (Trang Chủ)

**Status:** complete  
**Priority:** high  
**BlockedBy:** Phase 03, Phase 04  
**Owner:** Coordinator  
**File ownership:** `src/lib/features/home/` (Coordinator only)  
**UI Reference:** `docs/UI/0_home.png` + `docs/UI/0_home.html`

## Overview

Dashboard aggregating data from all 3 modules into a single "health today" view. Reads from existing providers in Phase 03 (blood sugar) and Phase 04 (medication). No new Isar writes — purely a composition screen.

## Requirements (from `0_home.html`)

- Header: avatar + user name + lightbulb icon (top bar)
- "Sức khỏe hôm nay" welcome card with greeting + star icon
- **Blood sugar widget**: today's latest value + status badge + 7-day mini bar chart
- **Medication reminder banner**: next pending dose + XONG action (from Phase 04 widget)
- **Daily summary grid**: "Đã uống X/Y liều" + "Vận động X bước"
- **Featured quote/image**: "Gợi ý hôm nay" with inspirational quote + food image
- Steps counter: manual entry (no HealthKit dependency for MVP)

## Steps Data

Keep it simple — manual step tracking via SharedPreferences (no HealthKit/Google Fit for MVP):
```dart
// StepsProvider: read/write today's step count from SharedPreferences
// Displayed on home, editable via a simple tap-to-edit dialog
```

**`src/lib/features/home/data/steps-repository.dart`**

```dart
class StepsRepository {
  final SharedPreferences _prefs;

  Future<int> getTodaySteps() async {
    final key = 'steps_${_todayKey()}';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> setTodaySteps(int steps) async {
    final key = 'steps_${_todayKey()}';
    await _prefs.setInt(key, steps);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }
}
```

## Inspirational Quotes

Bundled list of 30 health/wellness Vietnamese quotes, selected by `dayOfYear % 30`:
```dart
// src/lib/features/home/data/daily-quotes.dart
const kDailyQuotes = [
  'Mỗi bữa ăn lành mạnh là một bước tiến gần hơn đến sự cân bằng.',
  'Một bước chân mỗi ngày, sức khỏe sẽ đến.',
  // ... 28 more
];

String getDailyQuote() {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return kDailyQuotes[dayOfYear % kDailyQuotes.length];
}
```

## Implementation Steps

### 1. Riverpod Providers

**`src/lib/features/home/providers/home-providers.dart`**

// F2: use FutureProvider — Provider with async body returns Future<T> not T
final stepsRepoProvider = FutureProvider<StepsRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return StepsRepository(prefs);
});

final todayStepsProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(stepsRepoProvider.future);
  return repo.getTodaySteps();
});

final dailyQuoteProvider = Provider<String>((_) => getDailyQuote());
```

Reuse from other phases:
- `latestEntryProvider` (Phase 03) — today's blood sugar value + status
- `bloodSugarEntriesProvider(7)` (Phase 03) — 7-day data for mini bar chart
- `bloodSugarTargetProvider` (Phase 06) — pass to `getStatus()` for correct color (F10)
- `nextPendingDoseProvider` (Phase 04) — medication banner
- `todayDoseSummaryProvider` (Phase 04) — X/Y liều counter
- `userProfileProvider` (Phase 06) — user name + avatar

### 2. Home Screen

**`src/lib/features/home/screens/home-screen.dart`**

Layout (ref: `0_home.html`):

```
┌─────────────────────────────────┐
│ [Avatar] Tâm AI   [💡 icon]    │  sticky header, bg surface-container-low
│─────────────────────────────────│
│                                 │
│ ┌─────────────────────────────┐ │  sketch-card rotate(0.2deg)
│ │ Chào buổi sáng, {name}! 🌿 │ │  label-lg outline italic
│ │ Sức khỏe hôm nay            │ │  headline-lg-mobile
│ │                         ⭐  │ │  star icon secondary
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │  sketch-card, bg white
│ │ 💧 ĐƯỜNG HUYẾT  [BÌNH TX]  │ │  status badge (primary border pill)
│ │     110  mg/dL              │ │  4xl bold primary
│ │ [mini bar chart 7 days]     │ │  7 bars, today = filled primary
│ │  T2  T3  T4  T5  T6  T7 CN │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │  if nextPendingDose != null
│ │ 💊 Nhắc nhở thuốc          │ │  → MedicationReminderBanner (Phase 04)
│ │ Uống Metformin sau bữa tối  │ │
│ │                      [XONG] │ │
│ └─────────────────────────────┘ │
│                                 │
│  ┌──────────┐  ┌──────────┐    │  2-col grid
│  │💊 Đã uống│  │🚶Vận động│    │
│  │  2/3 liều│  │3,240 bước│    │  tap steps → edit dialog
│  └──────────┘  └──────────┘    │
│                                 │
│ ┌─────────────────────────────┐ │  featured image + quote
│ │ [food illustration image]   │ │  grayscale(20%) object-cover
│ │ Gợi ý hôm nay               │ │  label-lg primary
│ │ "Mỗi bữa ăn lành mạnh..."  │ │  italic body-md on-surface-variant
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### Mini Bar Chart Widget
**`src/lib/features/home/widgets/blood-sugar-mini-chart.dart`**

```dart
// 7 bars from bloodSugarEntriesProvider(7)
// Each bar: height proportional to value (60–200 range)
// Today bar: filled primary; others: primary/20 bg with hatching
// No labels on bars, just day labels below (T2–CN)
// Built with Row + Flexible + Container (no fl_chart dependency here)
class BloodSugarMiniChart extends ConsumerWidget { ... }
```

#### Steps Edit Dialog
Tap on "Vận động" tile → `showDialog` with a number input field → saves to `StepsRepository`.

### 3. Daily Greet Logic

```dart
String greetByTime() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}
```

## Files to Create

| File | Purpose |
|------|---------|
| `features/home/data/steps-repository.dart` | Manual steps store |
| `features/home/data/daily-quotes.dart` | 30 bundled quotes |
| `features/home/providers/home-providers.dart` | Steps + quote providers |
| `features/home/screens/home-screen.dart` | Dashboard screen |
| `features/home/widgets/blood-sugar-mini-chart.dart` | 7-day mini bar chart |

## Todo

- [x] Write 30 Vietnamese health quotes in `daily-quotes.dart`
- [x] Implement `StepsRepository` (SharedPreferences)
- [x] Implement Riverpod providers
- [x] Implement `BloodSugarMiniChart` widget
- [x] Implement `HomeScreen` composing all widgets (Stitch MCP → ref `0_home.html`)
- [x] Wire greeting by time-of-day
- [x] Wire `MedicationReminderBanner` from Phase 04
- [x] Steps tap → edit dialog
- [x] Test: XONG on banner → banner disappears (nextPendingDose changes)
- [x] Test: blood sugar widget shows correct color per status

## Success Criteria

- [x] Home screen matches `0_home.png` layout
- [x] Blood sugar widget reflects latest entry with correct color
- [x] Medication banner shows/hides based on pending doses
- [x] Dose counter shows correct X/Y
- [x] Daily quote changes each day
- [x] Steps editable via tap dialog
