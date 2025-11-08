import 'package:hive/hive.dart';
import 'training_mode.dart';

part 'recall_attempt.g.dart';

@HiveType(typeId: 2)
class RecallAttempt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memoryId;

  @HiveField(2)
  DateTime attemptedAt;

  @HiveField(3)
  int score; // 0-100

  @HiveField(4)
  Map<String, dynamic>? answers; // Store question answers

  @HiveField(5)
  String? notes;

  @HiveField(6)
  TrainingMode mode;

  RecallAttempt({
    required this.id,
    required this.memoryId,
    required this.attemptedAt,
    required this.score,
    this.answers,
    this.notes,
    this.mode = TrainingMode.scheduled,
  });

  String get performanceLabel {
    if (score >= 90) return 'Success';
    if (score >= 70) return 'Partial';
    return 'Needs Work';
  }
}


