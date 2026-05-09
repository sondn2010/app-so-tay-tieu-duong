# Phase 06 — Integration, Routing & Polish

**Status:** pending  
**Priority:** medium  
**BlockedBy:** Phase 03, 04, 05  
**Owner:** Coordinator Agent

## Overview

Wire all 3 feature modules into the final app shell: complete go_router routes, onboarding, notification permission request, app icon, final `flutter analyze` + smoke test on both platforms.

## Requirements

- Bottom navigation correctly routes to all 3 modules
- Onboarding screen shown on first launch only
- Notification permission requested on first launch (iOS)
- All modules integrated and cross-navigate correctly
- `flutter analyze` 0 errors
- App builds in release mode for Android

## Implementation Steps

### 1. Complete go_router Routes

**`src/lib/app.dart`** — fill all stub routes:

```dart
GoRoute(path: '/blood-sugar', builder: (_, __) => const BloodSugarHistoryScreen(),
  routes: [
    GoRoute(path: 'add', builder: (_, __) => const BloodSugarEntryScreen()),
    GoRoute(path: 'chart', builder: (_, __) => const BloodSugarChartScreen()),
  ]
),
GoRoute(path: '/medication', builder: (_, __) => const MedicationListScreen(),
  routes: [
    GoRoute(path: 'add',  builder: (_, s) => MedicationFormScreen(id: null)),
    GoRoute(path: ':id',  builder: (_, s) => MedicationFormScreen(id: int.parse(s.pathParameters['id']!))),
    GoRoute(path: 'meals', builder: (_, __) => const MealLogScreen()),
  ]
),
GoRoute(path: '/knowledge', builder: (_, __) => const ArticleListScreen(),
  routes: [
    GoRoute(path: ':remoteId', builder: (_, s) => ArticleDetailScreen(remoteId: s.pathParameters['remoteId']!)),
  ]
),
GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
```

### 2. Onboarding Screen

**`src/lib/features/onboarding/screens/onboarding-screen.dart`**

- 3 pages (PageView): app intro + blood sugar + medication reminders
- "Bắt đầu" button → request notification permission → save `prefs.setBool('onboarded', true)` → navigate to `/blood-sugar`

**First-launch check in `app.dart`:**
```dart
final prefs = await SharedPreferences.getInstance();
final onboarded = prefs.getBool('onboarded') ?? false;
initialLocation: onboarded ? '/blood-sugar' : '/onboarding',
```

### 3. Notification Permission (iOS)

Inside `OnboardingScreen` "Bắt đầu" action:
```dart
await NotificationService.requestPermission(); // iOS only, no-op on Android
```

`NotificationService.requestPermission()`:
```dart
static Future<void> requestPermission() async {
  await _plugin
    .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, sound: true);
}
```

### 4. Bottom Navigation Shell

**`src/lib/core/widgets/scaffold-with-bottom-nav.dart`**

```dart
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  // ...
  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.bloodtype), label: 'Đường huyết'),
        NavigationDestination(icon: Icon(Icons.medication), label: 'Thuốc & Ăn'),
        NavigationDestination(icon: Icon(Icons.menu_book), label: 'Kiến thức'),
      ],
      selectedIndex: _selectedIndex(context),
      onDestinationSelected: (i) => _navigate(context, i),
    ),
  );
}
```

### 5. App Config & Branding

- App name: "Sổ tay tiểu đường" in `AndroidManifest.xml` + `Info.plist`
- Primary color: `Color(0xFF1976D2)` (medical blue)
- Replace default Flutter icon with app icon (placeholder SVG → flutter_launcher_icons if time allows)

### 6. Final QA Checklist

```
[ ] flutter analyze — 0 errors, 0 warnings
[ ] flutter build apk --release — succeeds
[ ] Cold start < 2s on mid-range Android emulator
[ ] Blood sugar: add → list → chart flow works end-to-end
[ ] Medication: add med → notification scheduled → delete → cancelled
[ ] Knowledge: articles visible offline, search works, detail screen renders
[ ] Onboarding shows on fresh install, skipped on subsequent launches
[ ] Bottom nav switches tabs correctly, no state loss
```

## Files to Create / Modify

| File | Action |
|------|--------|
| `lib/app.dart` | Complete all route stubs |
| `features/onboarding/screens/onboarding-screen.dart` | Create |
| `core/widgets/scaffold-with-bottom-nav.dart` | Create |
| `core/notifications/notification-service.dart` | Add `requestPermission()` |
| `android/app/src/main/AndroidManifest.xml` | Update app name |
| `ios/Runner/Info.plist` | Update app name |

## Todo

- [ ] Complete go_router routes in `app.dart`
- [ ] Implement onboarding screen (3 pages)
- [ ] Add first-launch check → onboarding redirect
- [ ] Add notification permission request on onboarding complete
- [ ] Implement bottom nav shell widget
- [ ] Update app name in Android + iOS manifests
- [ ] Run `flutter analyze`
- [ ] Run `flutter build apk --release`
- [ ] Full manual smoke test (all 3 modules)

## Success Criteria

- [ ] `flutter analyze` exits 0
- [ ] `flutter build apk --release` succeeds
- [ ] All 3 modules navigable from bottom nav
- [ ] Onboarding fires once, skipped thereafter
