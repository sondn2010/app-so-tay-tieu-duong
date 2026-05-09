import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/blood_sugar/data/blood_sugar_entry.dart';
import '../../features/knowledge/data/article.dart';
import '../../features/medication/data/dose_log.dart';
import '../../features/medication/data/medication.dart';
import '../../features/profile/data/user_profile.dart';

// Riverpod-managed, testable, migration-safe — override in ProviderScope after initIsar()
final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError('isarProvider requires ProviderScope override'),
);

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      BloodSugarEntrySchema,
      MedicationSchema,
      DoseLogSchema,
      ArticleSchema,
      UserProfileSchema,
    ],
    directory: dir.path,
  );
}
