import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/database/isar_database.dart';
import 'core/notifications/notification_service.dart';
import 'features/blood_sugar/providers/blood_sugar_providers.dart';
import 'features/knowledge/data/article_repository.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/profile/data/user_profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await initIsar();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final unitStr = prefs.getString('blood_sugar_unit') ?? 'mgdl';
  final initialUnit =
      unitStr == 'mmoll' ? BloodSugarUnit.mmoll : BloodSugarUnit.mgdl;
  final onboarded = prefs.getBool('onboarded') ?? false;

  // Seed knowledge + ensure profile exists in background
  Future.microtask(() async {
    final articleRepo = ArticleRepository(db, Dio(), prefs);
    await articleRepo.seedFromAssets();
    // ignore: unawaited_futures
    articleRepo.syncFromRemote(AppConfig.knowledgeRemoteUrl);
    await UserProfileRepository(db).getOrCreate();
  });

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(db),
        bloodSugarUnitProvider.overrideWith((ref) => initialUnit),
        onboardedProvider.overrideWith((ref) => onboarded),
      ],
      child: App(onboarded: onboarded),
    ),
  );
}
