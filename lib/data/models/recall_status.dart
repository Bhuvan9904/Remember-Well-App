import 'package:hive/hive.dart';

part 'recall_status.g.dart';

@HiveType(typeId: 4)
enum RecallStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  skipped,
  @HiveField(3)
  missed,
}
