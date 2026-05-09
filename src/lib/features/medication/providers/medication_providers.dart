import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_database.dart';
import '../data/dose_log_repository.dart';
import '../data/medication.dart';
import '../data/medication_repository.dart';

final medicationRepoProvider = Provider(
  (ref) => MedicationRepository(ref.watch(isarProvider)),
);

final doseLogRepoProvider = Provider(
  (ref) => DoseLogRepository(ref.watch(isarProvider)),
);

final activeMedicationsProvider = FutureProvider<List<Medication>>(
  (ref) => ref.watch(medicationRepoProvider).getActive(),
);

final allMedicationsProvider = FutureProvider<List<Medication>>(
  (ref) => ref.watch(medicationRepoProvider).getAll(),
);

final todayDoseSummaryProvider =
    FutureProvider<({int taken, int total})>(
  (ref) => ref.watch(doseLogRepoProvider).todaySummary(),
);

final nextPendingDoseProvider =
    FutureProvider<({Medication? med, String? slot})>(
  (ref) => ref.watch(doseLogRepoProvider).nextPendingDose(),
);

final todayLoggedKeysProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(doseLogRepoProvider).todayLoggedKeys(),
);
