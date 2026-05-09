# Phase 06 — User Profile (Hồ Sơ)

**Status:** complete  
**Priority:** high  
**BlockedBy:** Phase 02  
**File ownership:** `src/lib/features/profile/` (Agent 3 only)  
**UI Reference:** `docs/UI/5_hosonguoidung.png` + `docs/UI/5_hosonguoidung.html`

## Overview

User profile screen: avatar, name, health info (diabetes type, target range, height, weight), account settings menu, sign-out. Profile data persisted in Isar `UserProfile` schema (created Phase 02).

## Requirements

- Avatar: display + edit (camera/gallery pick)
- Name, member-since date
- Health info: Loại bệnh (Type 1/2/Tiền tiểu đường), Mục tiêu range (customizable, default 70–130), Chiều cao, Cân nặng
- Settings menu: Thông tin cá nhân | Nhắc nhở | Đồng bộ dữ liệu | Hỗ trợ
- Sign out (clears SharedPreferences, re-shows onboarding)
- Target range used by `BloodSugarStatus` logic (consumed by Phase 03 + Phase 07)

## Implementation Steps

### 1. Repository

**`src/lib/features/profile/data/user-profile-repository.dart`**

```dart
class UserProfileRepository {
  final Isar _db;

  Future<UserProfile?> getProfile() =>
      _db.userProfiles.where().findFirst();

  Future<void> saveProfile(UserProfile p) =>
      _db.writeTxn(() => _db.userProfiles.put(p));

  Future<UserProfile> getOrCreate() async {
    final existing = await getProfile();
    if (existing != null) return existing;
    final def = UserProfile()
      ..name = 'Người dùng'
      ..diabetesType = 'type2'
      ..targetMin = 70
      ..targetMax = 130
      ..heightCm = 0
      ..weightKg = 0;
    await saveProfile(def);
    return def;
  }
}
```

### 2. Riverpod Providers

**`src/lib/features/profile/providers/profile-providers.dart`**

```dart
// V1: use isarProvider
final profileRepoProvider = Provider((ref) => UserProfileRepository(ref.watch(isarProvider)));

final userProfileProvider = FutureProvider(
  (ref) => ref.watch(profileRepoProvider).getOrCreate(),
);

// Exposed for Phase 03 + Phase 07 to use custom target range
final bloodSugarTargetProvider = FutureProvider<({double min, double max})>((ref) async {
  final p = await ref.watch(userProfileProvider.future);
  return (min: p.targetMin, max: p.targetMax);
});
```

### 3. Avatar Handling

Add dependency: `image_picker: ^1.1.2`

**`src/lib/features/profile/data/avatar-service.dart`**

```dart
class AvatarService {
  static Future<String?> pickAndSave() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);
    if (img == null) return null;
    // Copy to app documents dir with fixed name 'avatar.jpg'
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar.jpg');
    await File(img.path).copy(dest.path);
    return dest.path;
  }
}
```

### 4. Screens

#### 4a. Profile Screen
**`src/lib/features/profile/screens/profile-screen.dart`**

Layout (ref: `5_hosonguoidung.html`):
```
┌─────────────────────────────────┐
│ [avatar 96×96, border primary]  │
│  [✏ edit badge, rotate -12deg]  │  tap → AvatarService.pickAndSave()
│                                 │
│  Nam Nguyễn  (headline-lg)      │
│  Thành viên từ: 15/03/2023      │  italic label-lg outline
│                                 │
│  🏥 Thông tin sức khỏe          │
│  ┌──────────┐  ┌──────────┐    │  2-col hand-drawn-card
│  │ Loại bệnh│  │  Mục tiêu│    │
│  │ Type 2   │  │70–130 dL │    │
│  └──────────┘  └──────────┘    │
│  ┌─────────────────────────┐   │  full-width dashed card
│  │ Chiều cao 172cm │ 68kg  │   │
│  └─────────────────────────┘   │
│                                 │
│  ⚙ Cài đặt tài khoản           │
│  › Thông tin cá nhân            │  → EditProfileScreen
│  ───────────────────────────   │  sketch-line divider
│  › Nhắc nhở                    │  → MedicationListScreen
│  ───────────────────────────   │
│  › Đồng bộ dữ liệu             │  → DataSyncScreen (stub)
│  ───────────────────────────   │
│  › Hỗ trợ                      │  → HelpScreen (stub)
│                                 │
│  [Đăng xuất]  (hand-drawn red) │  confirm dialog → clear prefs → /onboarding
└─────────────────────────────────┘
```

#### 4b. Edit Profile Screen
**`src/lib/features/profile/screens/edit-profile-screen.dart`**

- TextFields: Tên, Chiều cao (cm), Cân nặng (kg)
- DropdownButton: Loại bệnh (Tiểu đường Type 1 / Type 2 / Tiền tiểu đường)
- RangeSlider: Mục tiêu đường huyết (60–200 mg/dL), default 70–130
- Save button → `saveProfile()` → invalidate provider → pop

#### 4c. Stub Screens (simple placeholders)
**`src/lib/features/profile/screens/data-sync-screen.dart`** — "Tính năng sắp ra mắt"  
**`src/lib/features/profile/screens/help-screen.dart`** — Static FAQ text

### 5. Sign-Out Logic

```dart
Future<void> signOut(BuildContext ctx) async {
  final confirmed = await showDialog<bool>(...); // confirm dialog — text must say "Toàn bộ dữ liệu sẽ bị xóa"
  if (confirmed != true) return;
  // F8 + V1: clear Isar via provider (not global)
  final db = ref.read(isarProvider);
  await db.writeTxn(() => db.clear());
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (ctx.mounted) ctx.go('/onboarding');
}
```

## Files to Create

| File | Purpose |
|------|---------|
| `features/profile/data/user-profile-repository.dart` | CRUD |
| `features/profile/data/avatar-service.dart` | Avatar pick + save |
| `features/profile/providers/profile-providers.dart` | Riverpod + target range |
| `features/profile/screens/profile-screen.dart` | Main profile UI |
| `features/profile/screens/edit-profile-screen.dart` | Edit health info |
| `features/profile/screens/data-sync-screen.dart` | Stub |
| `features/profile/screens/help-screen.dart` | Stub |

## Todo

- [x] Add `image_picker` to pubspec.yaml (Coordinator Phase 01/02)
- [x] Implement `UserProfileRepository` + `AvatarService`
- [x] Implement Riverpod providers (profile + target range)
- [x] Implement profile screen (Stitch MCP → ref `5_hosonguoidung.html`)
- [x] Implement edit profile screen with RangeSlider
- [x] Implement sign-out with confirm dialog
- [x] Create stub screens (data sync, help)
- [x] Test: custom target range → Phase 07 Home reflects new range
- [x] Test: avatar change persists after restart

## Success Criteria

- [x] Profile screen matches `5_hosonguoidung.png` layout
- [x] Target range change reflected in blood sugar status calculations
- [x] Sign-out clears data and redirects to onboarding
- [x] Avatar picked from gallery, stored locally, survives restart
