# Phase 04 — Medication & Meals Module (Thuốc & Bữa Ăn)

**Status:** pending  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/medication/` (Agent 2 only)  
**UI Reference:** `docs/UI/0_home.png` (medication banner + dose counter sections)

## Overview

Medication schedule management with local notification reminders and dose completion tracking. The medication UI is surfaced primarily on the **Trang chủ** (Home) dashboard — this module provides data and actions consumed by the Home widget.

> **F11 — MealLog removed from MVP.** `MealLog` schema, repository, screen, and provider deferred to v2 (no screen consumes the data in this version). Removed from Isar schema registration.

## Requirements

- CRUD medications (name, dosage, schedule slots: Sáng/Trưa/Tối/Trước ngủ)
- **Mark dose as done** (XONG button) — per-dose per-day completion tracking (idempotent)
- **Daily dose counter** "Đã uống X / Y liều" for Home dashboard
- Local notification per active slot (daily repeating)
- Expose providers consumed by Home dashboard Phase 07

## Data Model

**`src/lib/features/medication/data/dose-log.dart`** — already defined and registered in **Phase 02** (F1).

> `DoseLog` schema is in `isar-database.dart` from Phase 02. No schema changes needed here.

## Implementation Steps

### 1. Repositories

**`src/lib/features/medication/data/medication-repository.dart`**

```dart
class MedicationRepository {
  final Isar _db;

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

**`src/lib/features/medication/data/dose-log-repository.dart`**

```dart
class DoseLogRepository {
  final Isar _db;

  Future<void> markDone(int medicationId, String slot) async {
    final log = DoseLog()
      ..medicationId = medicationId ..slot = slot
      ..takenAt = DateTime.now() ..taken = true;
    await _db.writeTxn(() => _db.doseLogs.put(log));
  }

  // Returns count taken today and total slots today
  Future<({int taken, int total})> todaySummary() async {
    final meds = await _db.medications.filter().isActiveEqualTo(true).findAll();
    final total = meds.fold(0, (sum, m) => sum + m.schedule.length);
    final today = DateTime.now();
    final todayLogs = await _db.doseLogs
        .filter().takenAtGreaterThan(DateTime(today.year, today.month, today.day))
        .findAll();
    return (taken: todayLogs.length, total: total);
  }

  // F6: algorithm — iterate slots in time order, return first not yet logged today
  Future<({Medication? med, String? slot})> nextPendingDose() async {
    const orderedSlots = ['morning', 'noon', 'evening', 'night'];
    final meds = await _db.medications.filter().isActiveEqualTo(true).findAll();
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final todayLogs = await _db.doseLogs
        .filter().takenAtGreaterThan(dayStart).findAll();
    final loggedKeys = todayLogs.map((l) => '${l.medicationId}_${l.slot}').toSet();
    for (final slot in orderedSlots) {
      for (final med in meds) {
        if (med.schedule.contains(slot) && !loggedKeys.contains('${med.id}_$slot')) {
          return (med: med, slot: slot);
        }
      }
    }
    return (med: null, slot: null);  // all done
  }
}
```

**`src/lib/features/medication/data/meal-log-repository.dart`**

```dart
class MealLogRepository {
  final Isar _db;

  Future<void> addLog(MealLog log) =>
      _db.writeTxn(() => _db.mealLogs.put(log));
  Future<List<MealLog>> getToday() async {
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    return _db.mealLogs.filter().loggedAtGreaterThan(start).findAll();
  }
}
```

### 2. Notification Sync

**`src/lib/features/medication/providers/medication-notification-sync.dart`**

```dart
// F3: use int hour, not Time — NotificationService.scheduleMedicationReminder accepts int hour
const _slotHours = {'morning': 7, 'noon': 12, 'evening': 18, 'night': 21};

// V1: accepts Isar instance (not global) — call with ref.read(isarProvider)
Future<void> syncMedicationNotifications(Isar db) async {
  // F15: cancel only known medication notification IDs, not cancelAll()
  // This prevents race conditions and avoids destroying non-medication notifications
  // V1: pass isar via parameter instead of global
  final existing = await MedicationRepository(db).getActive();
  for (final m in existing) {
    for (var i = 0; i < m.schedule.length; i++) {
      await NotificationService.cancelReminder(m.id * 10 + i);
    }
  }
  // Now reschedule
  final meds = await MedicationRepository(db).getActive();
  for (final m in meds) {
    for (var i = 0; i < m.schedule.length; i++) {
      await NotificationService.scheduleMedicationReminder(
        id: m.id * 10 + i,
        name: m.name,
        dosage: m.dosage,
        hour: _slotHours[m.schedule[i]]!,
      );
    }
  }
}
```

Call `syncMedicationNotifications()` after any CRUD on Medication.

### 3. Riverpod Providers

**`src/lib/features/medication/providers/medication-providers.dart`**

```dart
// V1: use isarProvider — not global isar
final medicationRepoProvider  = Provider((ref) => MedicationRepository(ref.watch(isarProvider)));
final doseLogRepoProvider     = Provider((ref) => DoseLogRepository(ref.watch(isarProvider)));
// F11: mealLogRepoProvider removed — MealLog deferred to v2

final activeMedicationsProvider = FutureProvider(
  (ref) => ref.watch(medicationRepoProvider).getActive(),
);

// Consumed by Home dashboard
final todayDoseSummaryProvider = FutureProvider(
  (ref) => ref.watch(doseLogRepoProvider).todaySummary(),
);

final nextPendingDoseProvider = FutureProvider(
  (ref) => ref.watch(doseLogRepoProvider).nextPendingDose(),
);
```

### 4. Medication Banner Widget (used by Home)

**`src/lib/features/medication/widgets/medication-reminder-banner.dart`**

```
┌────────────────────────────────────┐  bg: secondary-container/30, border-secondary
│ 💊  Nhắc nhở thuốc               │
│     Uống Metformin sau bữa tối    │  [XONG] → calls markDone()
└────────────────────────────────────┘
```

Exposed as a public widget, consumed by `HomeScreen` (Phase 07).

### 5. Screens (standalone medication management)

#### 5a. Medication List Screen
**`src/lib/features/medication/screens/medication-list-screen.dart`**
- List of active medications, name + dosage + schedule chips
- Today's dose log per med (ticked slots)
- Swipe to delete → `syncMedicationNotifications()`
- FAB → Add Medication

#### 5b. Medication Form Screen
**`src/lib/features/medication/screens/medication-form-screen.dart`**
- TextField: name, dosage
- MultiSelectChip: Sáng / Trưa / Tối / Trước ngủ
- Save → `syncMedicationNotifications()`

> Note: Medication list/form accessed via Home screen or profile settings Nhắc nhở → no dedicated bottom nav tab.
> F11: MealLogScreen removed from MVP. No route added in Phase 08.

## Files to Create

| File | Purpose |
|------|---------|
| `features/medication/data/medication-repository.dart` | CRUD |
| `features/medication/data/dose-log-repository.dart` | Dose completion |
| `features/medication/providers/medication-providers.dart` | Riverpod |
| `features/medication/providers/medication-notification-sync.dart` | Notification sync (F15 fix) |
| `features/medication/widgets/medication-reminder-banner.dart` | Home widget |
| `features/medication/screens/medication-list-screen.dart` | List UI |
| `features/medication/screens/medication-form-screen.dart` | Add/Edit |
| ~~meal-log-repository.dart / meal-log-screen.dart~~ | F11: deferred to v2 |

## Todo

- [ ] DoseLog schema already in isar-database.dart from Phase 02 (F1) — no coordinator msg needed
- [ ] Implement repositories (medication, dose-log)
- [ ] Implement Riverpod providers
- [ ] Implement notification sync with targeted cancel (F15)
- [ ] Implement `MedicationReminderBanner` widget
- [ ] Implement medication list + form screens (Stitch MCP → ref `0_home.html` medication banner)
- [ ] Test: mark XONG → todaySummary increments (idempotent — double tap stays at 1)
- [ ] Test: add medication → notification scheduled
- [ ] Test: nextPendingDose() returns null after all doses marked done

## Success Criteria

- [ ] XONG button marks dose done + updates counter
- [ ] Daily dose summary `todayDoseSummaryProvider` returns correct X/Y
- [ ] `MedicationReminderBanner` widget usable by Home dashboard
- [ ] Medication CRUD + notification sync works end-to-end
