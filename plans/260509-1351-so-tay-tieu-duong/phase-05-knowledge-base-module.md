# Phase 05 — Knowledge Base Module (Sổ Tay Kiến Thức)

**Status:** pending  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/knowledge/`, `src/assets/knowledge/` (Agent 3 only)

## Overview

Article/content repository about diabetes. Bundled JSON for offline guarantee + background remote fetch to Isar cache. Category filter + search.

## Requirements

- Articles available offline from first install (bundled JSON)
- Background sync from remote URL on app launch
- Isar caches remote content, served from Isar thereafter
- Category filter + keyword search
- Article detail screen (rich text / markdown)
- Versioned JSON schema to handle future format changes

## Knowledge JSON Schema

**`assets/knowledge/articles.json`** (bundled):
```json
{
  "version": 1,
  "articles": [
    {
      "id": "art-001",
      "title": "Tiểu đường type 2 là gì?",
      "category": "Kiến thức cơ bản",
      "content": "...",
      "imageUrl": null,
      "version": 1
    }
  ]
}
```

Remote URL: configurable via `core/config/app-config.dart` (can be GitHub raw URL or CDN).

**Categories (initial):**
- Kiến thức cơ bản
- Chế độ ăn uống
- Vận động & Lối sống
- Thuốc & Điều trị
- Biến chứng & Phòng ngừa

## Implementation Steps

### 1. Repository

**`src/lib/features/knowledge/data/article-repository.dart`**

```dart
class ArticleRepository {
  final Isar _db;
  final Dio _dio;
  ArticleRepository(this._db, this._dio);

  // Load bundled JSON and seed Isar on first launch
  Future<void> seedFromAssets(BuildContext ctx) async {
    if (await _db.articles.count() > 0) return; // already seeded
    final raw = await rootBundle.loadString('assets/knowledge/articles.json');
    final data = jsonDecode(raw);
    final articles = (data['articles'] as List).map(Article.fromJson).toList();
    await _db.writeTxn(() => _db.articles.putAll(articles));
  }

  // Background fetch and upsert
  Future<void> syncFromRemote(String url) async {
    try {
      final resp = await _dio.get(url);
      final articles = (resp.data['articles'] as List).map(Article.fromJson).toList();
      await _db.writeTxn(() => _db.articles.putAll(articles)); // upsert by remoteId
    } catch (_) { /* fail silently — offline fallback */ }
  }

  Future<List<Article>> getAll() => _db.articles.where().findAll();

  Future<List<Article>> getByCategory(String cat) =>
      _db.articles.filter().categoryEqualTo(cat).findAll();

  Future<List<Article>> search(String query) =>
      _db.articles.filter()
          .titleContains(query, caseSensitive: false)
          .findAll();

  Future<Article?> getById(String remoteId) =>
      _db.articles.filter().remoteIdEqualTo(remoteId).findFirst();
}
```

### 2. App Config

**`src/lib/core/config/app-config.dart`**
```dart
class AppConfig {
  static const knowledgeRemoteUrl =
      'https://raw.githubusercontent.com/your-org/so-tay-content/main/articles.json';
}
```

### 3. Riverpod Providers

**`src/lib/features/knowledge/providers/knowledge-providers.dart`**

```dart
final articleRepositoryProvider = Provider(
  (ref) => ArticleRepository(isar, Dio()),
);

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final articlesProvider = FutureProvider<List<Article>>((ref) {
  final repo = ref.watch(articleRepositoryProvider);
  final cat  = ref.watch(selectedCategoryProvider);
  return cat == null ? repo.getAll() : repo.getByCategory(cat);
});

final searchQueryProvider   = StateProvider<String>((ref) => '');
final searchResultsProvider = FutureProvider<List<Article>>((ref) {
  final q = ref.watch(searchQueryProvider);
  if (q.isEmpty) return ref.watch(articlesProvider.future);
  return ref.watch(articleRepositoryProvider).search(q);
});
```

### 4. Screens

#### 4a. Article List Screen
**`src/lib/features/knowledge/screens/article-list-screen.dart`**

Layout:
- `SearchBar` at top
- Horizontal scrollable `CategoryChips` (All + categories)
- `ListView` of `ArticleCard` (title + category badge + first 100 chars preview)
- Pull-to-refresh → `syncFromRemote` in background
- `EmptyState` widget if no results

#### 4b. Article Detail Screen
**`src/lib/features/knowledge/screens/article-detail-screen.dart`**

- Title + category badge
- `SingleChildScrollView` with content (plain text or simple Markdown via `flutter_markdown` if added)
- Optional hero image
- Back button

### 5. Seeding on App Start

In `main.dart`, after Isar init:
```dart
// Fire-and-forget: seed + remote sync
Future.microtask(() async {
  await articleRepo.seedFromAssets(context);
  await articleRepo.syncFromRemote(AppConfig.knowledgeRemoteUrl);
});
```

## Files to Create

| File | Purpose |
|------|---------|
| `assets/knowledge/articles.json` | Bundled articles (initial content) |
| `core/config/app-config.dart` | Remote URL config |
| `features/knowledge/data/article-repository.dart` | CRUD + sync |
| `features/knowledge/providers/knowledge-providers.dart` | Riverpod |
| `features/knowledge/screens/article-list-screen.dart` | List + search + filter |
| `features/knowledge/screens/article-detail-screen.dart` | Detail view |

## Todo

- [ ] Write initial `articles.json` with 5–10 sample articles across categories
- [ ] Implement `ArticleRepository` (seed + sync + queries)
- [ ] Implement Riverpod providers
- [ ] Implement article list screen (Stitch MCP scaffold)
- [ ] Implement article detail screen
- [ ] Wire seed + sync call in `main.dart`
- [ ] Test: offline first launch shows bundled articles
- [ ] Test: online sync updates/adds articles without duplication

## Success Criteria

- [ ] Articles visible offline on fresh install
- [ ] Category filter narrows list correctly
- [ ] Search returns matching titles
- [ ] Remote sync runs silently without blocking UI
- [ ] No duplicate articles after multiple syncs
