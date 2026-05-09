import 'package:isar/isar.dart';

part 'medication.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;
  late String name;
  late String dosage;
  late List<String> schedule; // ['morning','noon','evening','night']
  late bool isActive;
  String? note;
}
