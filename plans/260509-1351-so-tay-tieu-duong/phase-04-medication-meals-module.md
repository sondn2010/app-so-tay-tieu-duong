# Phase 04 — Medication & Meals Module (Thuốc & Bữa Ăn)

**Status:** pending  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/medication/` (Agent 2 only)

## Overview

Medication schedule management with daily local notification reminders, plus a simple meal log for carb/calorie tracking.

## Requirements

- CRUD for medications (name, dosage, schedule slots)
- Schedule slots: Sáng / Trưa / Tối / Trước ngủ
- Local notification reminder per slot per active medication
- Meal log: meal type, estimated carbs + calories, timestamp
- History list for both medications and meals

## Implementation Steps

### 1. Repositories

**`src/lib/features/medication/data/medication-repository.dart`**

```dart
class MedicationRepository {
  final Isar _db;
  MedicationRepository(this._db);

  Future<void> addMedication(Medication med) =>
      _db.writeTxn(() => _db.medications.put(med));

  Future<List<Medication>> getActive() =>
      _db.medications.filter().isActiveEqualTo(true).findAll();

  Future<void> updateMedication(Medication med) =>
      _db.writeTxn(() => _db.medications.put(med));

  Future<void> deleteMedication(int id) =>
      _db.writeTxn(() => _db.medications.delete(id));
}
```

**`src/lib/features/medication/data/meal-log-repository.dart`**

```dart
class MealLogRepository {
  final Isar _db;
  MealLogRepository(this._db);

  Future<void> addLog(MealLog log) =>
      _db.writeTxn(() => _db.mealLogs.put(log));

  Future<List<MealLog>> getToday() async {
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    return _db.mealLogs.filter().loggedAtGreaterThan(start).findAll();
  }

  Future<List<MealLog>> getRecent({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db.mealLogs.filter().loggedAtGreaterThan(since)
        .sortByLoggedAtDesc().findAll();
  }
}
```

### 2. Notification Scheduling Logic

When a medication is saved/updated, reschedule its notifications:
```dart
// For each slot in medication.schedule:
//   morning  → 07:00
//   noon     → 12:00
//   evening  → 18:00
//   night    → 21:00
// Notification id = medication.id * 10 + slotIndex (deterministic)
```

When medication deleted or set inactive → cancel its notification IDs.

**`src/lib/features/medication/providers/medication-notification-sync.dart`**
```dart
Future<void> syncMedicationNotifications(Medication med) async {
  final slotTimes = {'morning': Time(7), 'noon': Time(12), 'evening': Time(18), 'night': Time(21)};
  await NotificationService.cancelAll(); // rebuild from all active meds
  final active = await MedicationRepository(isar).getActive();
  for (final m in active) {
    for (var i = 0; i < m.schedule.length; i++) {
      final t = slotTimes[m.schedule[i]]!;
      await NotificationService.scheduleMedicationReminder(
        id: m.id * 10 + i,
        name: m.name,
        dosage: m.dosage,
        time: t,
      );
    }
  }
}
```

### 3. Riverpod Providers

**`src/lib/features/medication/providers/medication-providers.dart`**

```dart
final medicationRepositoryProvider = Provider((ref) => MedicationRepository(isar));
final mealLogRepositoryProvider    = Provider((ref) => MealLogRepository(isar));

final activeMedicationsProvider = FutureProvider(
  (ref) => ref.watch(medicationRepositoryProvider).getActive(),
);

final todayMealsProvider = FutureProvider(
  (ref) => ref.watch(mealLogRepositoryProvider).getToday(),
);
```

### 4. Screens

#### 4a. Medication List Screen
**`src/lib/features/medication/screens/medication-list-screen.dart`**

- List of active medications, each showing name + dosage + schedule chips
- Toggle active/inactive (stops notifications)
- Swipe to delete
- FAB → Add Medication screen

#### 4b. Add/Edit Medication Screen
**`src/lib/features/medication/screens/medication-form-screen.dart`**

Fields:
- `TextField` — medication name
- `TextField` — dosage (e.g. "500mg")
- `MultiSelectChip` — schedule slots (Sáng / Trưa / Tối / Trước ngủ)
- `TextField` — optional note
- Save → `syncMedicationNotifications` → pop + invalidate provider

#### 4c. Meal Log Screen
**`src/lib/features/medication/screens/meal-log-screen.dart`**

Two sections:
1. **Today's summary** — total carbs + calories for today
2. **Add meal entry** — meal type dropdown, carbs slider (0–150g), calories field, note
3. **Recent logs** — last 7 days `ListView`

### 5. Navigation

Tab: `/medication` → `DefaultTabController` with 2 tabs:
- Tab 1: Medications list
- Tab 2: Meal log

## Files to Create

| File | Purpose |
|------|---------|
| `features/medication/data/medication-repository.dart` | CRUD |
| `features/medication/data/meal-log-repository.dart` | CRUD |
| `features/medication/providers/medication-providers.dart` | Riverpod |
| `features/medication/providers/medication-notification-sync.dart` | Notification sync |
| `features/medication/screens/medication-list-screen.dart` | List UI |
| `features/medication/screens/medication-form-screen.dart` | Add/Edit form |
| `features/medication/screens/meal-log-screen.dart` | Meal log UI |

## Todo

- [ ] Implement medication repository
- [ ] Implement meal log repository
- [ ] Implement Riverpod providers
- [ ] Implement notification sync function
- [ ] Implement medication list screen (Stitch MCP scaffold)
- [ ] Implement medication form screen
- [ ] Implement meal log screen
- [ ] Test: add medication → notification fires at correct time
- [ ] Test: delete medication → notification cancelled

## Success Criteria

- [ ] Medication CRUD works without errors
- [ ] Notification scheduled for each active slot
- [ ] Disabling medication cancels its notifications
- [ ] Today meal total carbs/calories calculated correctly
