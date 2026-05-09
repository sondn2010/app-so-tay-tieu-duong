import 'package:isar/isar.dart';

import 'dose_log.dart';
import 'medication.dart';

class DoseLogRepository {
  const DoseLogRepository(this._db);

  final Isar _db;

  Future<void> markDone(int medicationId, String slot) async {
    final log = DoseLog()
      ..medicationId = medicationId
      ..slot = slot
      ..takenAt = DateTime.now()
      ..taken = true;
    await _db.writeTxn(() => _db.doseLogs.put(log));
  }

  Future<({int taken, int total})> todaySummary() async {
    final meds =
        await _db.medications.filter().isActiveEqualTo(true).findAll();
    final total = meds.fold(0, (sum, m) => sum + m.schedule.length);
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final todayLogs =
        await _db.doseLogs.filter().takenAtGreaterThan(dayStart).findAll();
    return (taken: todayLogs.length, total: total);
  }

  // Iterates slots in time order, returns first not yet logged today
  Future<({Medication? med, String? slot})> nextPendingDose() async {
    const orderedSlots = ['morning', 'noon', 'evening', 'night'];
    final meds =
        await _db.medications.filter().isActiveEqualTo(true).findAll();
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final todayLogs =
        await _db.doseLogs.filter().takenAtGreaterThan(dayStart).findAll();
    final loggedKeys =
        todayLogs.map((l) => '${l.medicationId}_${l.slot}').toSet();
    for (final slot in orderedSlots) {
      for (final med in meds) {
        if (med.schedule.contains(slot) &&
            !loggedKeys.contains('${med.id}_$slot')) {
          return (med: med, slot: slot);
        }
      }
    }
    return (med: null, slot: null);
  }

  Future<Set<String>> todayLoggedKeys() async {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final logs =
        await _db.doseLogs.filter().takenAtGreaterThan(dayStart).findAll();
    return logs.map((l) => '${l.medicationId}_${l.slot}').toSet();
  }
}
