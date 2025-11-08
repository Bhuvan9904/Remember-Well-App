import 'package:hive/hive.dart';

part 'preferences.g.dart';

@HiveType(typeId: 3)
class Preferences extends HiveObject {
  @HiveField(0)
  int defaultIntervalDays;

  @HiveField(1)
  bool allowPerMemoryOverride;

  @HiveField(2)
  bool onboardingDone;

  @HiveField(3)
  bool adaptiveEnabled;

  @HiveField(4)
  bool isPremium;

  Preferences({
    this.defaultIntervalDays = 3,
    this.allowPerMemoryOverride = true,
    this.onboardingDone = false,
    this.adaptiveEnabled = true,
    this.isPremium = false,
  });
}


