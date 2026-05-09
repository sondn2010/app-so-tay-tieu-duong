# Phase 08 — Integration, Routing & Polish

**Status:** complete  
**Priority:** medium  
**BlockedBy:** Phase 05, 06, 07  
**Owner:** Coordinator

## Overview

Wire all modules into the final 4-tab shell, complete go_router routes, onboarding, notification permissions, app name branding, final `flutter analyze` + release build.

## Requirements

- 4-tab bottom nav: Trang chủ | Nhật ký | Kiến thức | Hồ sơ
- Onboarding (3 pages) shown once on first install
- Notification permission requested during onboarding (iOS)
- All deep routes wired (medication screens accessible from Home + Profile)
- App name: "Sổ Tay Tiểu Đường" in manifests
- `flutter analyze` 0 errors + `flutter build apk --release` succeeds

## Schema Status (F1 — all schemas finalized in Phase 02)

All schemas (`DoseLog`, `Article.readTimeMinutes`, `Article.isFavorite`) were defined in **Phase 02**. No schema changes needed here. `build_runner` was already run in Phase 02.

## Implementation Steps

### 1. Complete go_router Routes

**`src/lib/app.dart`**

```dart
// V5: onboardedProvider read from ProviderScope override — synchronous, zero I/O per navigation
final _router = GoRouter(
  refreshListenable: ...,  // wire to onboardedProvider if using ChangeNotifier approach
  redirect: (ctx, state) {
    final onboarded = ProviderScope.containerOf(ctx).read(onboardedProvider);
    if (!onboarded && state.matchedLocation != '/onboarding') return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (_, __, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(path: 'medication',       builder: (_, __) => const MedicationListScreen()),
            GoRoute(path: 'medication/add',   builder: (_, __) => MedicationFormScreen(id: null)),
            GoRoute(path: 'medication/:id',   builder: (_, s)  => MedicationFormScreen(id: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'meals',            builder: (_, __) => const MealLogScreen()),
          ],
        ),
        GoRoute(
          path: '/diary',
          builder: (_, __) => const BloodSugarDiaryScreen(),
          routes: [
            GoRoute(path: 'add', builder: (_, __) => const BloodSugarEntryScreen()),
          ],
        ),
        GoRoute(
          path: '/knowledge',
          builder: (_, __) => const ArticleListScreen(),
          routes: [
            GoRoute(path: ':remoteId', builder: (_, s) => ArticleDetailScreen(remoteId: s.pathParameters['remoteId']!)),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileScreen(),
          routes: [
            GoRoute(path: 'edit',      builder: (_, __) => const EditProfileScreen()),
            GoRoute(path: 'sync',      builder: (_, __) => const DataSyncScreen()),
            GoRoute(path: 'help',      builder: (_, __) => const HelpScreen()),
          ],
        ),
      ],
    ),
  ],
);
```

### 2. Onboarding Screen

**`src/lib/features/onboarding/screens/onboarding-screen.dart`**

3 pages (PageView, pencil-paper style):
1. **Trang 1:** Ảnh minh hoạ + "Theo dõi sức khoẻ tiểu đường hàng ngày"
2. **Trang 2:** Icon đường huyết + "Nhập chỉ số, xem biểu đồ, nhận cảnh báo"
3. **Trang 3:** Icon thuốc + "Nhắc uống thuốc đúng giờ, không bao giờ bỏ sót"

Bottom: `PageIndicator` dots + "Bắt đầu" button (last page only)

On "Bắt đầu":
```dart
await NotificationService.requestPermission(); // iOS only
await prefs.setBool('onboarded', true);
ctx.go('/home');
```

### 3. Bottom Nav Shell (4 tabs)

**`src/lib/core/widgets/scaffold-with-bottom-nav.dart`** (created Phase 02, finalize here)

```dart
NavigationBar(
  destinations: [
    NavigationDestination(icon: Icon(Icons.home_outlined),      selectedIcon: Icon(Icons.home),      label: 'Trang chủ'),
    NavigationDestination(icon: Icon(Icons.edit_note_outlined),  selectedIcon: Icon(Icons.edit_note), label: 'Nhật ký'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined),  selectedIcon: Icon(Icons.menu_book), label: 'Kiến thức'),
    NavigationDestination(icon: Icon(Icons.person_outline),      selectedIcon: Icon(Icons.person),    label: 'Hồ sơ'),
  ],
  backgroundColor: AppColors.surfaceContainerLow,
  // Active tab pill: primary-container bg, ring-2 primary/40, -translate-y-1
)
```

### 4. Knowledge + Profile Seed on Start

In `main.dart` after init:
```dart
Future.microtask(() async {
  // seed + sync knowledge
  final articleRepo = ArticleRepository(isar, Dio());
  await articleRepo.seedFromAssets();
  unawaited(articleRepo.syncFromRemote(AppConfig.knowledgeRemoteUrl));
  // ensure default profile exists
  await UserProfileRepository(isar).getOrCreate();
});
```

### 5. App Branding

**Android** `src/android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Sổ Tay Tiểu Đường"
<!-- F9: required for Android 13+ notification display -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**iOS** `src/ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Sổ Tay Tiểu Đường</string>
```

### 6. Final QA Checklist

```
UI Fidelity
[x] Home screen matches docs/UI/0_home.png
[x] Diary screen matches docs/UI/2_nhatky.png
[x] Knowledge screen matches docs/UI/4_sotaykienthuc.png
[x] Profile screen matches docs/UI/5_hosonguoidung.png
[x] Warm paper background (#FCF9F3) on all screens
[x] Be Vietnam Pro font renders on device

Functionality
[x] Blood sugar entry (numpad) → list → chart updates < 1s
[x] Unit toggle mg/dL ↔ mmol/L works correctly
[x] Abnormal entry shows red circled value
[x] Medication CRUD + XONG → dose counter updates
[x] Knowledge articles offline on fresh install
[x] Favorite article persists across restarts
[x] Profile target range change reflects in blood sugar status
[x] Onboarding shows once, skipped thereafter
[x] Sign-out → back to onboarding

Build
[x] flutter analyze — 0 errors
[x] flutter build apk --release — succeeds
[x] App cold start < 2s on mid-range Android emulator
[x] No crash on happy paths across all 4 tabs
```

## Files to Create / Modify

| File | Action |
|------|--------|
| `lib/app.dart` | Complete all routes + onboarding redirect |
| `features/onboarding/screens/onboarding-screen.dart` | Create (3-page) |
| `core/widgets/scaffold-with-bottom-nav.dart` | Finalize 4-tab nav |
| `lib/main.dart` | Add seed + profile init |
| `android/app/src/main/AndroidManifest.xml` | Update app name |
| `ios/Runner/Info.plist` | Update display name |
| `core/database/isar-database.dart` | Add DoseLogSchema + Article field updates |

## Todo

- [x] Schemas already complete from Phase 02 (F1) — no build_runner re-run needed
- [x] Complete go_router routes in `app.dart` (all nested routes)
- [x] Implement onboarding screen (3 pages)
- [x] Finalize `scaffold-with-bottom-nav.dart` (4 tabs)
- [x] Add seed + profile init in `main.dart`
- [x] Update Android + iOS app name + add POST_NOTIFICATIONS permission to AndroidManifest (F9)
- [x] Full UI fidelity review against all 4 mockups
- [x] Run `flutter analyze` → fix all issues
- [x] Run `flutter build apk --release`
- [x] Manual smoke test on Android emulator (all happy paths)

## Success Criteria

- [x] `flutter analyze` exits 0
- [x] `flutter build apk --release` exits 0
- [x] All 4 screens visually match their mockups
- [x] Full happy-path smoke test passes
