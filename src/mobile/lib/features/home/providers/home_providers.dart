import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/daily_quotes.dart';
import '../data/steps_repository.dart';

final stepsRepoProvider = FutureProvider<StepsRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return StepsRepository(prefs);
});

final todayStepsProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(stepsRepoProvider.future);
  return repo.getTodaySteps();
});

final dailyQuoteProvider = Provider<String>((_) => getDailyQuote());
