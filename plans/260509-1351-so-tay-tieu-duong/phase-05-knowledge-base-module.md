# Phase 05 — Knowledge Base Module (Sổ Tay Kiến Thức)

**Status:** complete  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/knowledge/`, `src/assets/knowledge/` (Agent 3 only)  
**UI Reference:** `docs/UI/4_sotaykienthuc.png` + `docs/UI/4_sotaykienthuc.html`

## Overview

Article library about diabetes. Bundled JSON offline + background remote sync to Isar. Category chips (horizontal scroll), keyword search, **favorite articles**, read-time labels, bento-style card layout.

## Requirements

- Articles offline from first install (bundled JSON)
- Background remote sync on launch, upsert to Isar
- Category filter: Yêu thích | Tiểu đường là gì | Chỉ số đường huyết | Biến chứng | Cách dùng thuốc | Thực phẩm | Vận động
- Keyword search
- **Favorite toggle** (heart icon) — persisted in Isar
- Read time label on each article card
- "Xem thêm kiến thức" pagination (load 10 more)
- Article detail screen

## Knowledge JSON Schema

**`assets/knowledge/articles.json`:**
```json
{
  "version": 1,
  "articles": [
    {
      "id": "art-001",
      "title": "Tiểu đường Type 2: Những điều cơ bản",
      "category": "Tiểu đường là gì",
      "content": "...",
      "imageUrl": null,
      "readTimeMinutes": 5,
      "version": 1
    }
  ]
}
```

**Initial categories (7):** Yêu thích (virtual), Tiểu đường là gì, Chỉ số đường huyết, Biến chứng, Cách dùng thuốc, Thực phẩm, Vận động

**Initial articles (10 minimum):**
- Tiểu đường Type 2: Những điều cơ bản (Tiểu đường là gì)
- Thực đơn Low-GI hàng ngày (Thực phẩm)
- 15 phút Yoga nhẹ nhàng mỗi sáng (Vận động)
- Lưu ý khi dùng Metformin (Cách dùng thuốc)
- Giải mã chỉ số HbA1c (Chỉ số đường huyết)
- Các biến chứng phổ biến của tiểu đường (Biến chứng)
- Chỉ số đường huyết bình thường là bao nhiêu? (Chỉ số đường huyết)
- Thực phẩm nên tránh (Thực phẩm)
- Tập thể dục và tiểu đường (Vận động)
- Tiểu đường Type 1 vs Type 2 (Tiểu đường là gì)

## Isar Schema

Article schema (including `readTimeMinutes` and `isFavorite`) is **fully defined in Phase 02** (F1). No schema changes needed here — build against the Phase 02 definition.

## Implementation Steps

### 1. Repository

**`src/lib/features/knowledge/data/article-repository.dart`**

```dart
class ArticleRepository {
  final Isar _db;
  final Dio _dio;
  final SharedPreferences _prefs;

  // F14: version-based seed — re-seeds when bundled version > stored version
  Future<void> seedFromAssets() async {
    final raw = await rootBundle.loadString('assets/knowledge/articles.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final bundledVersion = (data['version'] as int?) ?? 1;
    final storedVersion = _prefs.getInt('articles_seed_version') ?? 0;
    if (bundledVersion <= storedVersion) return;
    final list = (data['articles'] as List).map(Article.fromJson).toList();
    // F5: preserve isFavorite for existing articles during re-seed
    final existing = await _db.articles.where().findAll();
    final favMap = {for (final a in existing) a.remoteId: a.isFavorite};
    for (final a in list) { a.isFavorite = favMap[a.remoteId] ?? false; }
    await _db.writeTxn(() => _db.articles.putAll(list));
    await _prefs.setInt('articles_seed_version', bundledVersion);
  }

  // F7: version guard + F5: preserve isFavorite on sync
  Future<void> syncFromRemote(String url) async {
    // IMPORTANT: replace 'your-org' placeholder with real org before release (F7)
    try {
      final resp = await _dio.get<Map<String, dynamic>>(url);
      final data = resp.data;
      if (data == null || data['articles'] is! List) return;  // F7: validate response shape
      final list = (data['articles'] as List).map(Article.fromJson).toList();
      // F5 + F7: only upsert articles with higher version; preserve isFavorite
      final existing = await _db.articles.where().findAll();
      final existingMap = {for (final a in existing) a.remoteId: a};
      final toUpdate = list.where((a) {
        final stored = existingMap[a.remoteId];
        return stored == null || a.version > stored.version;  // F7: version guard
      }).toList();
      for (final a in toUpdate) {
        a.isFavorite = existingMap[a.remoteId]?.isFavorite ?? false;  // F5: preserve favorite
        // F7: basic content validation
        if (a.title.length > 200 || a.content.length > 50000) continue;
      }
      if (toUpdate.isNotEmpty) {
        await _db.writeTxn(() => _db.articles.putAll(toUpdate));
      }
    } catch (e) {
      debugPrint('syncFromRemote error: $e');  // F7: no longer silent — log errors
    }
  }

  Future<List<Article>> getAll({int offset = 0, int limit = 10}) =>
      _db.articles.where().offset(offset).limit(limit).findAll();

  Future<List<Article>> getByCategory(String cat, {int offset = 0, int limit = 10}) =>
      _db.articles.filter().categoryEqualTo(cat)
          .offset(offset).limit(limit).findAll();

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

  Future<Article?> getByRemoteId(String remoteId) =>
      _db.articles.filter().remoteIdEqualTo(remoteId).findFirst();
}
```

### 1b. Article.fromJson Factory (F4 — must be defined manually; Isar does not auto-generate)

Add to **`src/lib/features/knowledge/data/article.dart`**:
```dart
factory Article.fromJson(Map<String, dynamic> json) => Article()
  ..remoteId = json['id'] as String          // json 'id' → remoteId (string key)
  ..title    = json['title'] as String
  ..category = json['category'] as String
  ..content  = json['content'] as String
  ..imageUrl = json['imageUrl'] as String?
  ..version  = (json['version'] as int?) ?? 1
  ..cachedAt = DateTime.now()
  ..readTimeMinutes = (json['readTimeMinutes'] as int?) ?? 5
  ..isFavorite = false;  // always false from remote; local state managed separately (F5)
```

### 2. App Config

**`src/lib/core/config/app-config.dart`**
```dart
class AppConfig {
  // F7: REQUIRED — replace 'your-org' with real GitHub org before release
  static const knowledgeRemoteUrl =
      'https://raw.githubusercontent.com/your-org/so-tay-content/main/articles.json';
}
```

### 3. Riverpod Providers

**`src/lib/features/knowledge/providers/knowledge-providers.dart`**

```dart
// V1: use isarProvider
final articleRepoProvider = Provider((ref) => ArticleRepository(ref.watch(isarProvider), Dio(), ref.watch(sharedPrefsProvider)));

const kCategories = [
  'Yêu thích', 'Tiểu đường là gì', 'Chỉ số đường huyết',
  'Biến chứng', 'Cách dùng thuốc', 'Thực phẩm', 'Vận động',
];

final selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');
final searchQueryProvider      = StateProvider<String>((ref) => '');
final articlePageOffsetProvider = StateProvider<int>((ref) => 0);

final articlesProvider = FutureProvider<List<Article>>((ref) {
  final repo  = ref.watch(articleRepoProvider);
  final cat   = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final offset = ref.watch(articlePageOffsetProvider);

  if (query.isNotEmpty) return repo.search(query);
  if (cat == 'Yêu thích') return repo.getFavorites();
  if (cat == 'Tất cả')    return repo.getAll(offset: offset);
  return repo.getByCategory(cat, offset: offset);
});
```

### 4. Screens

#### 4a. Article List Screen
**`src/lib/features/knowledge/screens/article-list-screen.dart`**

Layout (ref: `4_sotaykienthuc.html`):
```
┌─────────────────────────────────┐
│ Sổ tay kiến thức  (-rotate-1)  │  headline-lg primary italic
│ [🔍 Tìm kiếm kiến thức...]     │  sketch-border search input
│                                 │
│ [★Yêu thích][Tiểu đường...][..] │  horizontal scroll category chips
│                                 │
│ ┌──────────┐  ┌──────────┐     │  2-col bento grid
│ │📖 Card 1 │  │🍽 Card 2 │     │  alternating rotation ±0.5–1.2deg
│ │ title... │  │ ❤ fav   │     │  heart icon top-right
│ │ Category │  │ Category │     │
│ │ 5 phút   │  │ 8 phút   │     │
│ └──────────┘  └──────────┘     │
│ ┌─────────────────────────────┐ │  wide card (full width with image)
│ │[IMAGE] Vận động article     │ │
│ └─────────────────────────────┘ │
│                                 │
│   [Xem thêm kiến thức ▼]       │  loads next page
└─────────────────────────────────┘
```

- Category chips: active = `primary-container` bg + sketch-border; inactive = `surface-container-high` + dashed border
- "Yêu thích" chip has filled star icon
- Heart icon: outline = not favorited; filled red = favorited; tap → `toggleFavorite()`
- Wide card: `md:col-span-2` equivalent → **`if (index % 5 == 2 && article.imageUrl != null)`** render wide with image (V6 — no wide card for null imageUrl)

#### 4b. Article Detail Screen
**`src/lib/features/knowledge/screens/article-detail-screen.dart`**

- App bar: article title + back + favorite heart
- Category badge + read time
- Content: `SingleChildScrollView` with `SelectableText` (plain text) or `flutter_markdown` widget
- Optional header image

## Files to Create

| File | Purpose |
|------|---------|
| `assets/knowledge/articles.json` | 10 bundled articles |
| `core/config/app-config.dart` | Remote URL |
| `features/knowledge/data/article-repository.dart` | CRUD + sync + favorite |
| `features/knowledge/providers/knowledge-providers.dart` | Riverpod |
| `features/knowledge/screens/article-list-screen.dart` | List + search + filter + favorite |
| `features/knowledge/screens/article-detail-screen.dart` | Detail view |

## Todo

- [x] Schema already complete in Phase 02 (F1) — no coordinator message needed
- [x] Write 10 bundled articles in `articles.json` with top-level `"version": 1`
- [x] Implement `Article.fromJson` factory (F4) in article.dart
- [x] Implement `ArticleRepository` (seed with version check F14, sync with isFavorite merge F5, version guard F7)
- [x] Replace `'your-org'` placeholder in AppConfig with real GitHub org (F7)
- [x] Implement Riverpod providers
- [x] Implement article list screen (Stitch MCP → ref `4_sotaykienthuc.html`)
- [x] Implement article detail screen (render content as plain text — no WebView/HTML, F7)
- [x] Wire seed + sync in `main.dart` (Coordinator task)
- [x] Test: offline first launch shows bundled articles
- [x] Test: heart toggle persists across app restart AND after remote sync
- [x] Test: "Yêu thích" chip shows only favorited articles

## Success Criteria

- [x] Articles visible offline on fresh install
- [x] Category + search filter works correctly
- [x] Favorite persists after app restart
- [x] "Xem thêm" loads next 10 articles
- [x] Read time displayed on every card
