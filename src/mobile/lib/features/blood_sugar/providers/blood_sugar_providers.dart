import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_database.dart';
import '../../../core/theme/blood_sugar_status.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/blood_sugar_entry.dart';
import '../data/blood_sugar_repository.dart';

enum BloodSugarUnit { mgdl, mmoll }

// Initialized from SharedPreferences in main() via ProviderScope override
final bloodSugarUnitProvider =
    StateProvider<BloodSugarUnit>((ref) => BloodSugarUnit.mgdl);

final bloodSugarRepoProvider = Provider(
  (ref) => BloodSugarRepository(ref.watch(isarProvider)),
);

final bloodSugarEntriesProvider =
    FutureProvider.family<List<BloodSugarEntry>, int>(
  (ref, days) => ref.watch(bloodSugarRepoProvider).getEntries(days: days),
);

final latestEntryProvider = FutureProvider(
  (ref) => ref.watch(bloodSugarRepoProvider).getLatest(),
);

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
  final hour = latest.measuredAt.hour;
  final minute = latest.measuredAt.minute.toString().padLeft(2, '0');
  return 'Chỉ số ${latest.value.round()} mg/dL lúc $hour:$minute ${statusLabel(s).toLowerCase()}. Hãy theo dõi thêm.';
});
