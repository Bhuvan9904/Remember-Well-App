import 'package:hive/hive.dart';

part 'training_mode.g.dart';

@HiveType(typeId: 5)
enum TrainingMode {
  @HiveField(0)
  scheduled, // Regular scheduled recall
  @HiveField(1)
  replay, // Replay mode (flashcards)
  @HiveField(2)
  random, // Random recall
  @HiveField(3)
  battle, // Battle mode
  @HiveField(4)
  guided, // Guided paths
}
