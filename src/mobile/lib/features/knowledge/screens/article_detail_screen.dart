import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/article.dart';
import '../providers/knowledge_providers.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.remoteId});

  final String remoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(
      _articleByRemoteIdProvider(remoteId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: articleAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: 'Không tải được bài viết.'),
        data: (article) {
          if (article == null) {
            return ErrorView(message: 'Không tìm thấy bài viết.');
          }
          return _ArticleBody(article: article, ref: ref);
        },
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.article, required this.ref});

  final Article article;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: article.imageUrl != null ? 200 : 0,
          pinned: true,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          flexibleSpace: article.imageUrl != null
              ? FlexibleSpaceBar(
                  background: Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                )
              : null,
          actions: [
            IconButton(
              icon: Icon(
                article.isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    article.isFavorite ? AppColors.error : AppColors.primary,
              ),
              onPressed: () async {
                await ref
                    .read(articleRepoProvider)
                    .toggleFavorite(article.id);
                ref.invalidate(articlesProvider);
                ref.invalidate(_articleByRemoteIdProvider(article.remoteId));
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time_outlined,
                        size: 14, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      '${article.readTimeMinutes} phút đọc',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.outlineVariant),
                const SizedBox(height: 12),
                SelectableText(
                  article.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurface,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Article lookup by remoteId
final _articleByRemoteIdProvider =
    FutureProvider.family<Article?, String>((ref, remoteId) async {
  final repo = ref.watch(articleRepoProvider);
  return repo.getByRemoteId(remoteId);
});
