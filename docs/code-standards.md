# Code Standards - Sổ Tay Tiểu Đường

## Overview

This document establishes coding standards for the Sổ Tay Tiểu Đường Flutter app. All contributors should follow these standards.

## Dart/Flutter Standards

### File Organization

```
lib/
├── main.dart                    # Entry point
├── app.dart                   # App widget + router
├── core/                      # Shared utilities
│   ├── config/               # App config, constants
│   ├── database/             # Database init
│   ├── notifications/        # Notification service
│   ├── theme/               # Theme, colors
│   └── widgets/             # Shared widgets
└── features/               # Feature modules
    └── {feature}/
        ├── data/            # Models, repositories
        ├── providers/      # Riverpod providers
        ├── screens/        # Screen widgets
        └── widgets/       # Feature widgets
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `blood_sugar_entry.dart` |
| Classes | PascalCase | `BloodSugarEntry` |
| Methods | camelCase | `getEntriesByDate()` |
| Variables | camelCase | `bloodSugarEntries` |
| Constants | camelCase | `maxGlucoseValue` |
| Isar collections | PascalCase | `@collection class BloodSugarEntry` |

### Feature Structure

Each feature follows the data/repository/providers/screens/widgets pattern:

```dart
// data/model.dart - Isar model
@collection
class ModelName {
  Id id = Isar.autoIncrement;
  late String field;
}

// data/repository.dart - Data access
class ModelRepository {
  final Isar _db;
  // CRUD methods
}

// providers/providers.dart - Riverpod providers
final modelProvider = ...
```

### Import Organization

```dart
// Flutter/Dart packages first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Local packages
import 'core/config/app_config.dart';
import 'features/feature/data/model.dart';
```

## Isar Database

### Model Definition

```dart
part 'model.g.dart';

@collection
class ModelName {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  late String field;
  
  @enumerated
  late EnumType enumField;
  
  String? optionalField;
}
```

### Generated Files

- Generate with: `dart run build_runner build`
- Commit generated `.g.dart` files to repo
- Include in `pubspec.yaml`: `isar: ^3.1.0`, dev: `isar_generator`, `build_runner`

### Database Init

```dart
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [BloodSugarEntrySchema, ...],
    directory: dir.path,
  );
}
```

## Riverpod

### Provider Types

```dart
// Simple provider
final provider = Provider<T>((ref) => T());

// Repository provider
final repoProvider = Provider<Repo>((ref) {
  final db = ref.watch(isarProvider);
  return Repo(db);
});

// State notifier
final notifierProvider = StateNotifierProvider<Notifier, State>((ref) {
  return Notifier(ref.watch(repoProvider));
});

// Future provider
final futureProvider = FutureProvider<T>((ref) async {
  return await ref.watch(repoProvider).fetch();
});
```

### Provider Scoping

- Feature providers in feature directory
- Shared providers in `core/` or `main.dart`
- Use `ProviderScope` at app root

## GoRouter Navigation

### Route Definition

```dart
GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/route', builder: (_, __) => Screen()),
    ShellRoute(
      builder: (_, state, child) => Shell(child: child),
      routes: [...],
    ),
  ],
)
```

### Route Parameters

```dart
GoRoute(
  path: '/route/:id',
  builder: (_, state) {
    final id = state.pathParameters['id'];
    return Screen(id: id);
  },
)
```

## Error Handling

### Try-Catch Pattern

```dart
try {
  final result = await repository.operation();
} catch (e) {
  ref.read(errorProvider.notifier).state = e.toString();
}
```

### Widget Error States

```dart
// Use shared ErrorView widget
ErrorView(
  message: error.message,
  onRetry: () => ref.refresh(provider),
)
```

## UI Components

### Screen Structure

```dart
class FeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text('Title')),
      body: switch (state) {
        AsyncData(:final data) => Body(data: data),
        AsyncError(:final error, _) => ErrorView(error: error),
        _ => const LoadingIndicator(),
      },
    );
  }
}
```

### Card Widget

```dart
PaperCard(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...],
    ),
  ),
)
```

## Testing Standards

### Test Structure

```
test/
├── features/
│   └── {feature}/
│       ├── repository_test.dart
│       └── providers_test.dart
└── widgets/
    └── widget_test.dart
```

### Test Setup

```dart
late Isar db;
late Repo repo;

setUp(() async {
  db = await Isar.open(
    [Schema],
    directory: '', // in-memory
  );
  repo = Repo(db);
});
```

### Test Patterns

```dart
test('operation returns expected', () async {
  final result = await repo.operation();
  expect(result, expected);
});
```

## Git Conventions

### Commit Messages

- `feat: add blood sugar diary view`
- `fix: medication reminder notification`
- `docs: update codebase summary`
- `refactor: extract shared widgets`

### Branch Naming

- `feature/blood-sugar-export`
- `fix/medication-notification-timing`
- `docs/code-standards`

---

*Last updated: 2026-05-09*