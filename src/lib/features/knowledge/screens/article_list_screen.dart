import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/article.dart';
import '../providers/knowledge_providers.dart';

class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Transform.rotate(
                angle: -0.01,
                child: const Text(
                  'Sổ tay kiến thức',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm kiến thức...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            // Category chips
            if (query.isEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _CategoryChip(label: 'Tất cả', selected: selectedCat),
                    ...kCategories.map(
                      (c) => _CategoryChip(label: c, selected: selectedCat),
                    ),
                  ],
                ),
              ),
            // Article grid
            Expanded(
              child: articles.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorView(
                  message: 'Không tải được bài viết.',
                  onRetry: () => ref.invalidate(articlesProvider),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      icon: Icons.menu_book_outlined,
                      message: 'Không tìm thấy bài viết nào.',
                    );
                  }
                  return _ArticleGrid(articles: list);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  const _CategoryChip({required this.label, required this.selected});

  final String label;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = selected == label;
    final isFav = label == 'Yêu thích';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedCategoryProvider.notifier).state = label;
          ref.read(articlePageOffsetProvider.notifier).state = 0;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.outline,
              style: isActive ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFav)
                const Icon(Icons.star, size: 14, color: AppColors.secondary),
              if (isFav) const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleGrid extends ConsumerWidget {
  const _ArticleGrid({required this.articles});

  final List<Article> articles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: articles.length + 1,
      itemBuilder: (ctx, index) {
        if (index == articles.length) {
          return TextButton(
            onPressed: () {
              final offset = ref.read(articlePageOffsetProvider);
              ref.read(articlePageOffsetProvider.notifier).state =
                  offset + 10;
            },
            child: const Text(
              'Xem thêm kiến thức ▼',
              style: TextStyle(color: AppColors.primary),
            ),
          );
        }

        final article = articles[index];
        // Wide card for every 3rd article (index % 5 == 2) with image
        final isWide =
            index % 5 == 2 && article.imageUrl != null;

        if (isWide) {
          return _WideArticleCard(article: article);
        }

        // 2-col grid — pair articles
        if (index % 2 == 0) {
          final next = index + 1 < articles.length ? articles[index + 1] : null;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ArticleCard(article: article, rotation: -0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: next != null
                    ? _ArticleCard(article: next, rotation: 0.8)
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // handled in even index
      },
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  const _ArticleCard({required this.article, this.rotation = 0});

  final Article article;
  final double rotation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/knowledge/${article.remoteId}'),
      child: Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppColors.outline.withOpacity(0.4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2235675B),
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(articleRepoProvider)
                          .toggleFavorite(article.id);
                      ref.invalidate(articlesProvider);
                    },
                    child: Icon(
                      article.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: article.isFavorite
                          ? AppColors.error
                          : AppColors.outline,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                article.category,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '${article.readTimeMinutes} phút',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideArticleCard extends ConsumerWidget {
  const _WideArticleCard({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/knowledge/${article.remoteId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                child: Image.network(
                  article.imageUrl!,
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 100,
                    height: 90,
                    child: Icon(Icons.image_outlined,
                        color: AppColors.outline),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(article.category,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant)),
                    Text('${article.readTimeMinutes} phút',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
