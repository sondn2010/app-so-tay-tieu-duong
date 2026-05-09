# Phase 03 — Blood Sugar Module (Nhật Ký Đường Huyết)

**Status:** complete  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/blood_sugar/` (Agent 1 only)  
**UI Reference:** `docs/UI/2_nhatky.png` + `docs/UI/2_nhatky.html`

## Overview

Full blood sugar tracking: custom numpad entry + unit switcher, 7-day SVG-style trend chart, color-coded history list, abnormal value highlights, computed insight note.

## Requirements

- Input: custom numpad (not keyboard), unit toggle mg/dL ↔ mmol/L, meal context, auto-timestamp
- History list: date + meal context + value, abnormal rows highlighted with red border
- Chart: 7-day line with colored dots (green=normal, red=abnormal), threshold reference lines
- Computed insight: short observation when last entry was abnormal
- FAB (+) for quick add
- Delete entry (swipe or long-press)

## Blood Sugar Status Logic (from `core/theme/blood-sugar-status.dart`)

```
< 70     → LOW        (error red  #ba1a1a)
70–99    → NORMAL     (primary    #35675b)
100–125  → PREDIABETES(secondary  #735b26)
≥ 126    → HIGH       (error red  #ba1a1a)
```

## Unit Conversion

```dart
// Store always in mg/dL (canonical)
double mmolToMgdl(double mmol) => mmol * 18.0182;
double mgdlToMmol(double mgdl) => mgdl / 18.0182;
```

State: `unitProvider = StateProvider<BloodSugarUnit>` — initialized from SharedPreferences in `main()` via ProviderScope override (F13). On unit change, persist with `prefs.setString('blood_sugar_unit', unit.name)`.

## Implementation Steps

### 1. Repository

**`src/lib/features/blood_sugar/data/blood-sugar-repository.dart`**

```dart
class BloodSugarRepository {
  final Isar _db;
  BloodSugarRepository(this._db);

  Future<void> addEntry(BloodSugarEntry e) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.put(e));

  Future<List<BloodSugarEntry>> getEntries({int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db.bloodSugarEntrys
        .filter().measuredAtGreaterThan(since)
        .sortByMeasuredAtDesc().findAll();
  }

  Future<BloodSugarEntry?> getLatest() =>
      _db.bloodSugarEntrys.where().sortByMeasuredAtDesc().findFirst();

  Future<void> deleteEntry(int id) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.delete(id));
}
```

### 2. Riverpod Providers

**`src/lib/features/blood_sugar/providers/blood-sugar-providers.dart`**

```dart
enum BloodSugarUnit { mgdl, mmoll }

final bloodSugarUnitProvider = StateProvider<BloodSugarUnit>(
  (ref) => BloodSugarUnit.mgdl,  // load from SharedPrefs on init
);

// V1: use isarProvider — not global isar
final bloodSugarRepoProvider = Provider((ref) => BloodSugarRepository(ref.watch(isarProvider)));

final bloodSugarEntriesProvider = FutureProvider.family<List<BloodSugarEntry>, int>(
  (ref, days) => ref.watch(bloodSugarRepoProvider).getEntries(days: days),
);

final latestEntryProvider = FutureProvider(
  (ref) => ref.watch(bloodSugarRepoProvider).getLatest(),
);

// F10: pass user's custom target range to getStatus()
final chartInsightProvider = Provider<String?>((ref) {
  final latest = ref.watch(latestEntryProvider).valueOrNull;
  if (latest == null) return null;
  final target = ref.watch(bloodSugarTargetProvider).valueOrNull;
  final s = getStatus(
    latest.value,
    targetMin: target?.min ?? 100,
    targetMax: target?.max ?? 126,
  );
  if (s == BloodSugarStatus.normal) return null;
  final time = TimeOfDay.fromDateTime(latest.measuredAt).format(ref.context);
  return 'Chỉ số ${latest.value.round()} mg/dL lúc $time ${statusLabel(s).toLowerCase()}. Hãy theo dõi thêm.';
});
```

### 3. Shared Widget: Custom Numpad

**`src/lib/core/widgets/blood-sugar-numpad.dart`**

A 3×4 grid widget (1–9, ., 0, ⌫) styled with `hand-drawn-border-thin`:
- Each button: `border: 1.5px solid #707975`, Flutter-native approx (F12): `BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(4))`
- Taps update a `ValueNotifier<String>` passed from parent
- Max 4 chars (e.g. "400" or "38.5" for mmol/L)

### 4. Screens

#### 4a. Entry Screen
**`src/lib/features/blood_sugar/screens/blood-sugar-entry-screen.dart`**

Layout (ref: `2_nhatky.html` section "Input Section"):
```
┌─────────────────────────────────┐  hand-drawn-border, rotate 0.2deg
│ Nhập chỉ số         [mg/dL|mmol/L]│
│                                 │
│      [  105  ]                  │  64px bold teal, underline below
│      Hôm nay, 08:30  (italic)   │
│                                 │
│  [ 1 ][ 2 ][ 3 ]               │
│  [ 4 ][ 5 ][ 6 ]               │  hand-drawn-border-thin buttons
│  [ 7 ][ 8 ][ 9 ]               │
│  [ . ][ 0 ][ ⌫ ]               │
│                                 │
│  [  Meal Context Dropdown  ]    │
│  [     Lưu Nhật Ký         ]    │  hand-drawn primary button
└─────────────────────────────────┘
```

- Unit toggle: `mg/dL` active pill (primary bg) | `mmol/L` inactive — updates display in real-time
- Meal context: Lúc đói / Trước ăn / Sau ăn / Trước khi ngủ
- On save: convert to mg/dL if mmol/L, **validate range 20–600 mg/dL** (V3 — reject with error toast if outside range), create entry, invalidate providers, pop

#### 4b. History + Chart Screen (Nhật Ký tab)
**`src/lib/features/blood_sugar/screens/blood-sugar-diary-screen.dart`**

Two sections in a `SingleChildScrollView`:

**Section 1 — Trend Chart:**
```
┌──────────────────────────────────┐  hand-drawn-border, -rotate 0.5deg
│ 📈 Xu hướng 7 ngày              │
│                                  │
│  [SVG LineChart 7 days]          │
│  • Green dot = normal            │
│  • Red circled dot = abnormal    │
│  -- dashed threshold line        │
│  T2  T3  T4  T5  T6  T7  CN     │
│                                  │
│  ⚠ "Chỉ số T6 hơi cao..."       │  error-container/20 bg, border-l-4 error
└──────────────────────────────────┘
```

Chart implementation using `fl_chart` `LineChart`:
- Normal spots: `FlSpot`, color `#35675b`, radius 3
- Abnormal spots: separate `LineChartBarData` with `dotData` color `#ba1a1a`, radius 5
- Threshold lines via `ExtraLinesData.horizontalLines`

**Section 2 — Lịch sử đo:**
- `ListView` items: date column (day/month) + meal context + time + status label | value (right-aligned)
- Abnormal row: `bg-error-container/5` background, value wrapped in `sketch-circle-red` style container
- "Xem toàn bộ lịch sử" text button → show all / paginate

#### 4c. Abnormal Value Widget
**`src/lib/features/blood_sugar/screens/components/blood-sugar-value-badge.dart`**

```dart
// Normal: plain text in AppColors.bsNormal
// Abnormal: F12 — Flutter-native approx for organic circle:
//   DecoratedBox(decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     border: Border.all(color: AppColors.error, width: 2.5),
//   ))
// (CSS "50% 45% 52% 48%/..." elliptical radius not supported in Flutter natively)
class BloodSugarValueBadge extends StatelessWidget {
  final double value;
  final BloodSugarStatus status;
  // ...
}
```

### 5. Navigation

Tab `/diary` → `BloodSugarDiaryScreen` (contains both chart + history)  
Route `/diary/add` → `BloodSugarEntryScreen`  
FAB on diary screen → navigate to `/diary/add`

## Files to Create

| File | Purpose |
|------|---------|
| `features/blood_sugar/data/blood-sugar-repository.dart` | Isar CRUD |
| `features/blood_sugar/providers/blood-sugar-providers.dart` | Riverpod + unit + insight |
| `core/widgets/blood-sugar-numpad.dart` | Custom numpad widget |
| `features/blood_sugar/screens/blood-sugar-entry-screen.dart` | Entry form |
| `features/blood_sugar/screens/blood-sugar-diary-screen.dart` | Chart + history |
| `features/blood_sugar/screens/components/blood-sugar-value-badge.dart` | Abnormal indicator |

## Todo

- [x] Implement `BloodSugarRepository` + unit conversion
- [x] Implement Riverpod providers + computed insight
- [x] Implement `BloodSugarNumpad` widget
- [x] Implement entry screen with numpad + unit toggle (Stitch MCP → ref `2_nhatky.html`)
- [x] Implement diary screen (chart + history)
- [x] Implement `BloodSugarValueBadge` for abnormal highlight
- [x] Wire FAB and navigation in app.dart
- [x] Test: mmol/L input converts correctly to mg/dL on save
- [x] Test: 165 mg/dL entry shows red, 98 shows green
- [x] Test: input 15 mg/dL → rejected with error (V3: below min 20)
- [x] Test: input 650 mg/dL → rejected with error (V3: above max 600)

## Success Criteria

- [x] Entry saved with custom numpad → visible in list < 1s
- [x] Unit toggle updates display without saving again
- [x] Abnormal entries (< 70, ≥ 126) show red circled value
- [x] Chart renders 7 days with correct colors
- [x] Computed insight shown only when latest entry is abnormal
