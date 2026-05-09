import 'package:isar/isar.dart';

import 'user_profile.dart';

class UserProfileRepository {
  const UserProfileRepository(this._db);

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
