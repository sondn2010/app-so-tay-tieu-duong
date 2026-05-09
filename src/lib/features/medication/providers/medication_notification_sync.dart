import 'package:isar/isar.dart';

import '../../../core/notifications/notification_service.dart';
import '../data/medication_repository.dart';

const _slotHours = {
  'morning': 7,
  'noon': 12,
  'evening': 18,
  'night': 21,
};

// Cancel only known medication IDs to avoid destroying non-medication notifications
Future<void> syncMedicationNotifications(Isar db) async {
  final repo = MedicationRepository(db);
  final existing = await repo.getActive();
  for (final m in existing) {
    for (var i = 0; i < m.schedule.length; i++) {
      await NotificationService.cancelReminder(m.id * 10 + i);
    }
  }
  final meds = await repo.getActive();
  for (final m in meds) {
    for (var i = 0; i < m.schedule.length; i++) {
      final hour = _slotHours[m.schedule[i]];
      if (hour == null) continue;
      await NotificationService.scheduleMedicationReminder(
        id: m.id * 10 + i,
        name: m.name,
        dosage: m.dosage,
        hour: hour,
      );
    }
  }
}
