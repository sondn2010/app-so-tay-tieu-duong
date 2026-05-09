import 'package:isar/isar.dart';

import 'blood_sugar_entry.dart';

class BloodSugarRepository {
  const BloodSugarRepository(this._db);

  final Isar _db;

  Future<void> addEntry(BloodSugarEntry e) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.put(e));

  Future<List<BloodSugarEntry>> getEntries({int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db.bloodSugarEntrys
        .filter()
        .measuredAtGreaterThan(since)
        .sortByMeasuredAtDesc()
        .findAll();
  }

  Future<BloodSugarEntry?> getLatest() =>
      _db.bloodSugarEntrys.where().sortByMeasuredAtDesc().findFirst();

  Future<void> deleteEntry(int id) =>
      _db.writeTxn(() => _db.bloodSugarEntrys.delete(id));
}

double mmolToMgdl(double mmol) => mmol * 18.0182;
double mgdlToMmol(double mgdl) => mgdl / 18.0182;
