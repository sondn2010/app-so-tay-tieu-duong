import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_database.dart';
import '../data/article.dart';
import '../data/article_repository.dart';

final _sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final articleRepoProvider = Provider((ref) {
  final db = ref.watch(isarProvider);
  final prefs = ref.watch(_sharedPrefsProvider).valueOrNull;
  if (prefs == null) throw StateError('SharedPreferences not ready');
  return ArticleRepository(db, Dio(), prefs);
});

const kCategories = [
  'Yêu thích',
  'Tiểu đường là gì',
  'Chỉ số đường huyết',
  'Biến chứng',
  'Cách dùng thuốc',
  'Thực phẩm',
  'Vận động',
];

final selectedCategoryProvider =
    StateProvider<String>((ref) => 'Tất cả');

final searchQueryProvider = StateProvider<String>((ref) => '');

final articlePageOffsetProvider = StateProvider<int>((ref) => 0);

final articlesProvider = FutureProvider<List<Article>>((ref) {
  final repo = ref.watch(articleRepoProvider);
  final cat = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final offset = ref.watch(articlePageOffsetProvider);

  if (query.isNotEmpty) return repo.search(query);
  if (cat == 'Yêu thích') return repo.getFavorites();
  if (cat == 'Tất cả') return repo.getAll(offset: offset);
  return repo.getByCategory(cat, offset: offset);
});
