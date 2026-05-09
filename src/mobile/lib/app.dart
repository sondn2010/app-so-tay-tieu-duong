import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/scaffold_with_bottom_nav.dart';
import 'features/blood_sugar/screens/blood_sugar_diary_screen.dart';
import 'features/blood_sugar/screens/blood_sugar_entry_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/knowledge/screens/article_detail_screen.dart';
import 'features/knowledge/screens/article_list_screen.dart';
import 'features/medication/screens/medication_form_screen.dart';
import 'features/medication/screens/medication_list_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/profile/screens/data_sync_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/help_screen.dart';
import 'features/profile/screens/profile_screen.dart';

GoRouter buildRouter(bool onboarded) {
  return GoRouter(
    initialLocation: onboarded ? '/home' : '/onboarding',
    redirect: (ctx, state) {
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');
      final container = ProviderScope.containerOf(ctx);
      final isOnboarded = container.read(onboardedProvider);
      if (!isOnboarded && !isOnboarding) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'medication',
                builder: (_, __) => const MedicationListScreen(),
              ),
              GoRoute(
                path: 'medication/add',
                builder: (_, __) => const MedicationFormScreen(),
              ),
              GoRoute(
                path: 'medication/:id',
                builder: (_, s) => MedicationFormScreen(
                  medicationId: int.tryParse(s.pathParameters['id'] ?? ''),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/diary',
            builder: (_, __) => const BloodSugarDiaryScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const BloodSugarEntryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/knowledge',
            builder: (_, __) => const ArticleListScreen(),
            routes: [
              GoRoute(
                path: ':remoteId',
                builder: (_, s) => ArticleDetailScreen(
                  remoteId: s.pathParameters['remoteId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, __) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'sync',
                builder: (_, __) => const DataSyncScreen(),
              ),
              GoRoute(
                path: 'help',
                builder: (_, __) => const HelpScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class App extends ConsumerWidget {
  const App({super.key, required this.onboarded});

  final bool onboarded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter(onboarded);
    return MaterialApp.router(
      title: 'Sổ Tay Tiểu Đường',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
