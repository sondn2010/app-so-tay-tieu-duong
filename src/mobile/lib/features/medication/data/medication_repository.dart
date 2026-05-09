import 'package:isar/isar.dart';

import 'medication.dart';

class MedicationRepository {
  const MedicationRepository(this._db);

  final Isar _db;

  Future<void> addMedication(Medication med) =>
      _db.writeTxn(() => _db.medications.put(med));

  Future<List<Medication>> getActive() =>
      _db.medications.filter().isActiveEqualTo(true).findAll();

  Future<List<Medication>> getAll() => _db.medications.where().findAll();

  Future<void> updateMedication(Medication med) =>
      _db.writeTxn(() => _db.medications.put(med));

  Future<void> deleteMedication(int id) =>
      _db.writeTxn(() => _db.medications.delete(id));
}
