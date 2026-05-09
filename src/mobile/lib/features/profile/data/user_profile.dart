import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;
  late String name;
  late String diabetesType; // 'type1'|'type2'|'prediabetes'
  late double targetMin; // default 70
  late double targetMax; // default 130
  late double heightCm;
  late double weightKg;
  DateTime? dateOfBirth;
  String? avatarPath;
}
