import 'package:hive/hive.dart';
import 'recall_status.dart';

part 'recall_plan.g.dart';

@HiveType(typeId: 1)
class RecallPlan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memoryId;

  @HiveField(2)
  DateTime dueAt;

  @HiveField(3)
  int intervalDays;

  @HiveField(4)
  RecallStatus status;

  @HiveField(5)
  DateTime createdAt;

  // Number of times snoozed (+2h). Capped at 3.
  @HiveField(6)
  int snoozeCount;

  RecallPlan({
    required this.id,
    required this.memoryId,
    required this.dueAt,
    required this.intervalDays,
    this.status = RecallStatus.pending,
    required this.createdAt,
    this.snoozeCount = 0,
  });

  bool get isDue => DateTime.now().isAfter(dueAt);
}
