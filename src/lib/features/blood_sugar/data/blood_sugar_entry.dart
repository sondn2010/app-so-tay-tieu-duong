import 'package:isar/isar.dart';

part 'blood_sugar_entry.g.dart';

@collection
class BloodSugarEntry {
  Id id = Isar.autoIncrement;
  late double value; // always stored in mg/dL
  late DateTime measuredAt;
  late String mealContext; // 'fasting'|'before_meal'|'after_meal'|'bedtime'
  String? note;
}
