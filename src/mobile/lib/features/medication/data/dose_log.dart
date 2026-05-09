import 'package:isar/isar.dart';

part 'dose_log.g.dart';

@collection
class DoseLog {
  Id id = Isar.autoIncrement;
  late int medicationId;
  late String slot; // 'morning'|'noon'|'evening'|'night'
  late DateTime takenAt;
  late bool taken;
}
