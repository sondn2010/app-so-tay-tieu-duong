import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'article.dart';

class ArticleRepository {
  const ArticleRepository(this._db, this._dio, this._prefs);

  final Isar _db;
  final Dio _dio;
  final SharedPreferences _prefs;

  // Version-based seed — re-seeds when bundled version > stored version
  Future<void> seedFromAssets() async {
    final raw =
        await rootBundle.loadString('assets/knowledge/articles.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final bundledVersion = (data['version'] as int?) ?? 1;
    final storedVersion = _prefs.getInt('articles_seed_version') ?? 0;
    if (bundledVersion <= storedVersion) return;

    final list = (data['articles'] as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();

    // Preserve isFavorite for existing articles during re-seed
    final existing = await _db.articles.where().findAll();
    final favMap = {for (final a in existing) a.remoteId: a.isFavorite};
    for (final a in list) {
      a.isFavorite = favMap[a.remoteId] ?? false;
    }

    await _db.writeTxn(() => _db.articles.putAll(list));
    await _prefs.setInt('articles_seed_version', bundledVersion);
  }

  // Version guard + preserve isFavorite on sync
  Future<void> syncFromRemote(String url) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(url);
      final data = resp.data;
      if (data == null || data['articles'] is! List) return;

      final list = (data['articles'] as List)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();

      final existing = await _db.articles.where().findAll();
      final existingMap = {for (final a in existing) a.remoteId: a};

      final toUpdate = list.where((a) {
        final stored = existingMap[a.remoteId];
        return stored == null || a.version > stored.version;
      }).toList();

      for (final a in toUpdate) {
        a.isFavorite = existingMap[a.remoteId]?.isFavorite ?? false;
        // Basic content validation
        if (a.title.length > 200 || a.content.length > 50000) continue;
      }

      if (toUpdate.isNotEmpty) {
        await _db.writeTxn(() => _db.articles.putAll(toUpdate));
      }
    } catch (e) {
      debugPrint('syncFromRemote error: $e');
    }
  }

  Future<List<Article>> getAll({int offset = 0, int limit = 10}) =>
      _db.articles.where().offset(offset).limit(limit).findAll();

  Future<List<Article>> getByCategory(
    String cat, {
    int offset = 0,
    int limit = 10,
  }) =>
      _db.articles
          .filter()
          .categoryEqualTo(cat)
          .offset(offset)
          .limit(limit)
          .findAll();

  Future<List<Article>> getFavorites() =>
      _db.articles.filter().isFavoriteEqualTo(true).findAll();

  Future<List<Article>> search(String q) =>
      _db.articles.filter().titleContains(q, caseSensitive: false).findAll();

  Future<void> toggleFavorite(int id) async {
    final a = await _db.articles.get(id);
    if (a == null) return;
    a.isFavorite = !a.isFavorite;
    await _db.writeTxn(() => _db.articles.put(a));
  }

  Future<Article?> getById(int id) => _db.articles.get(id);

  Future<Article?> getByRemoteId(String remoteId) =>
      _db.articles.filter().remoteIdEqualTo(remoteId).findFirst();
}
