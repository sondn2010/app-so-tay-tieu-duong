import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_database.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';

final profileRepoProvider = Provider(
  (ref) => UserProfileRepository(ref.watch(isarProvider)),
);

final userProfileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepoProvider).getOrCreate(),
);

// Consumed by Phase 03 + Phase 07 for custom target range
final bloodSugarTargetProvider =
    FutureProvider<({double min, double max})>((ref) async {
  final p = await ref.watch(userProfileProvider.future);
  return (min: p.targetMin, max: p.targetMax);
});
