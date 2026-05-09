import 'package:shared_preferences/shared_preferences.dart';

class StepsRepository {
  const StepsRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<int> getTodaySteps() async {
    return _prefs.getInt('steps_${_todayKey()}') ?? 0;
  }

  Future<void> setTodaySteps(int steps) async {
    await _prefs.setInt('steps_${_todayKey()}', steps);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }
}
