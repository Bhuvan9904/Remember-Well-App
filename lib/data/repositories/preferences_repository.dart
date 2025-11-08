import 'package:hive/hive.dart';
import '../models/preferences.dart';
import '../services/hive_service.dart';

/// Repository for app preferences
class PreferencesRepository {
  Box<Preferences> get _box => HiveService.preferencesBox;
  static const String key = 'preferences';

  Preferences get() {
    return _box.get(key) ?? Preferences();
  }

  Future<void> set(Preferences prefs) async {
    await _box.put(key, prefs);
  }

  Future<void> updateOnboardingDone(bool done) async {
    final prefs = get();
    prefs.onboardingDone = done;
    await set(prefs);
  }
}


