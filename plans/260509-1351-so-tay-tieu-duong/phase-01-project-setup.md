# Phase 01 — Project Setup & Flutter Foundation

**Status:** pending  
**Priority:** critical  
**Blocks:** Phase 02

## Overview

Initialize Flutter project under `src/`, configure all dependencies, establish folder structure, and validate the project builds for both iOS and Android.

## Requirements

- Flutter 3.x project inside `src/`
- All pub dependencies declared in `pubspec.yaml`
- Folder structure matching the agreed architecture
- App runs on Android emulator (smoke test)
- Assets directory for bundled knowledge JSON

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.3

  # Navigation
  go_router: ^13.2.0

  # Charts
  fl_chart: ^0.68.0

  # Notifications
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4

  # HTTP
  dio: ^5.4.3

  # Utilities
  shared_preferences: ^2.2.3
  intl: ^0.19.0
  # V4: image_picker added here (Phase 01) — owned by Coordinator, Phase 06 needs it
  image_picker: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  isar_generator: ^3.1.0
  riverpod_generator: ^2.4.3
  flutter_lints: ^3.0.2
```

## Implementation Steps

1. **Create Flutter project**
   ```
   cd C:\Sources\fish\outsource\app-so-tay-tieu-duong
   flutter create src --org com.example.sotaytieududuong --project-name so_tay_tieu_duong
   ```

2. **Update pubspec.yaml** with all dependencies above

3. **Create folder structure** under `src/lib/`:
   ```
   src/lib/
   ├── features/
   │   ├── blood_sugar/
   │   │   ├── data/
   │   │   ├── providers/
   │   │   └── screens/
   │   ├── medication/
   │   │   ├── data/
   │   │   ├── providers/
   │   │   └── screens/
   │   └── knowledge/
   │       ├── data/
   │       ├── providers/
   │       └── screens/
   ├── core/
   │   ├── database/
   │   ├── notifications/
   │   ├── theme/
   │   └── widgets/
   ├── app.dart
   └── main.dart
   ```

4. **Create assets directory** and register in pubspec.yaml:
   ```yaml
   flutter:
     assets:
       - assets/knowledge/
   ```
   Add placeholder `assets/knowledge/articles.json`

5. **Run `flutter pub get`** and verify no errors

6. **Smoke test** — `flutter run` on Android emulator, confirm default app launches

## Files to Create

- `src/pubspec.yaml` (modified)
- `src/lib/main.dart` (stub)
- `src/lib/app.dart` (stub)
- `src/assets/knowledge/articles.json` (empty array `[]`)
- All empty `src/lib/features/*/` and `src/lib/core/*/` directories (`.gitkeep`)

## Todo

- [ ] Run `flutter create src/`
- [ ] Update pubspec.yaml dependencies
- [ ] Create folder structure with `.gitkeep` placeholders
- [ ] Add assets declaration in pubspec.yaml
- [ ] Create `assets/knowledge/articles.json` with `[]`
- [ ] Run `flutter pub get`
- [ ] Smoke test on Android emulator

## Success Criteria

- `flutter pub get` exits 0
- `flutter analyze` exits 0 (no errors)
- App launches on Android emulator (default Flutter counter screen is fine)
