# Phase 03 — Blood Sugar Module (Nhật Ký Đường Huyết)

**Status:** pending  
**Priority:** high  
**BlockedBy:** Phase 02

## Overview

Full blood sugar tracking module: entry form, history list, fl_chart LineChart, color-coded alerts. Core value prop of the app.

## Requirements

- Input: value (mg/dL), time, meal context, optional note
- List view: all entries sorted by date, color-coded rows
- Chart: LineChart 7/30/90 day views with threshold reference lines
- Alert: color overlay when value outside normal range
- Delete entry support

## Blood Sugar Status Logic

```
< 70     → LOW        (RED)   Hạ đường huyết
70–99    → NORMAL     (GREEN) Bình thường
100–125  → PREDIABETES(YELLOW) Tiền tiểu đường
≥ 126    → HIGH       (RED)   Tiểu đường cao
```

Source: `core/theme/blood-sugar-status.dart` (Phase 02)

## Implementation Steps

### 1. Repository

**`src/lib/features/blood_sugar/data/blood-sugar-repository.dart`**

```dart
class BloodSugarRepository {
  final Isar _db;
  BloodSugarRepository(this._db);

  Future<void> addEntry(BloodSugarEntry entry) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.put(entry));

  Future<List<BloodSugarEntry>> getEntries({int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db.bloodSugarEntrys
        .filter().measuredAtGreaterThan(since)
        .sortByMeasuredAt()
        .findAll();
  }

  Future<void> deleteEntry(int id) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.delete(id));
}
```

### 2. Riverpod Providers

**`src/lib/features/blood_sugar/providers/blood-sugar-providers.dart`**

```dart
final bloodSugarRepositoryProvider = Provider(
  (ref) => BloodSugarRepository(isar),
);

final bloodSugarEntriesProvider = FutureProvider.family<List<BloodSugarEntry>, int>(
  (ref, days) => ref.watch(bloodSugarRepositoryProvider).getEntries(days: days),
);
```

### 3. Screens

#### 3a. Entry Form Screen
**`src/lib/features/blood_sugar/screens/blood-sugar-entry-screen.dart`**

Fields:
- `NumberInputField` — value in mg/dL (keyboard: `TextInputType.number`)
- `DateTimePicker` — defaults to now
- `DropdownButton` — meal context: Lúc đói / Trước ăn / Sau ăn / Trước ngủ
- `TextField` — optional note
- Submit button → calls `addEntry` → shows `StatusBanner` → `ref.invalidate` → pop

**Status banner logic:**
```dart
final status = getStatus(value);
final color = statusColor(status);
// Show SnackBar with color background + label
```

#### 3b. History List Screen
**`src/lib/features/blood_sugar/screens/blood-sugar-history-screen.dart`**

- `ListView.builder` sorted descending by date
- Each `BloodSugarTile`: value (colored), time, meal context, delete swipe action
- Filter chips: 7 ngày / 30 ngày / 90 ngày
- FAB → navigate to entry form
- Empty state: `EmptyState` widget

#### 3c. Chart Screen
**`src/lib/features/blood_sugar/screens/blood-sugar-chart-screen.dart`**

```dart
LineChart(
  LineChartData(
    lineBarsData: [LineChartBarData(spots: chartSpots, color: AppColors.primary)],
    extraLinesData: ExtraLinesData(horizontalLines: [
      HorizontalLine(y: 70,  color: AppColors.bsDanger, strokeWidth: 1, dashArray: [4]),
      HorizontalLine(y: 126, color: AppColors.bsDanger, strokeWidth: 1, dashArray: [4]),
    ]),
    titlesData: FlTitlesData(...), // date on X, mg/dL on Y
  ),
)
```

Tab bar: 7 ngày | 30 ngày | 90 ngày

### 4. Navigation Integration

Add to go_router (Phase 02 `app.dart`):
- `/blood-sugar` → `BloodSugarHistoryScreen` + `BloodSugarChartScreen` (TabBarView)
- `/blood-sugar/add` → `BloodSugarEntryScreen`

## Files to Create

| File | Purpose |
|------|---------|
| `features/blood_sugar/data/blood-sugar-repository.dart` | Isar CRUD |
| `features/blood_sugar/providers/blood-sugar-providers.dart` | Riverpod |
| `features/blood_sugar/screens/blood-sugar-entry-screen.dart` | Add entry UI |
| `features/blood_sugar/screens/blood-sugar-history-screen.dart` | List + delete |
| `features/blood_sugar/screens/blood-sugar-chart-screen.dart` | fl_chart |

## Todo

- [ ] Implement `BloodSugarRepository`
- [ ] Implement Riverpod providers
- [ ] Implement entry form screen (use Stitch MCP to scaffold)
- [ ] Implement history list with color-coded tiles
- [ ] Implement chart screen with threshold lines
- [ ] Wire navigation in `app.dart`
- [ ] Manual test: add entry → verify color, verify chart updates

## Security / Data Notes

- All data stays on device (Isar local) — no PII leaves device
- No internet required for this module

## Success Criteria

- [ ] Entry saved → immediately visible in list with correct color
- [ ] Chart renders in < 1s with 90 days of data
- [ ] Danger entries (< 70, ≥ 126) show RED, warn show YELLOW
- [ ] Delete swipe works with confirmation
