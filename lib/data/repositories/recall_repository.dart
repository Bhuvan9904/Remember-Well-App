import 'package:hive/hive.dart';
import '../models/recall_plan.dart';
import '../models/recall_attempt.dart';
import '../models/recall_status.dart';
import '../services/hive_service.dart';

/// Repository for recall plans and attempts
class RecallRepository {
  Box<RecallPlan> get _plansBox => HiveService.recallPlansBox;
  Box<RecallAttempt> get _attemptsBox => HiveService.recallAttemptsBox;

  /// Recall Plans
  Future<void> createPlan(RecallPlan plan) async {
    await _plansBox.put(plan.id, plan);
  }

  List<RecallPlan> getDuePlans() {
    return _plansBox.values
        .where((plan) => plan.isDue && plan.status == RecallStatus.pending)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<RecallPlan> getPlansByMemoryId(String memoryId) {
    return _plansBox.values
        .where((plan) => plan.memoryId == memoryId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updatePlan(RecallPlan plan) async {
    await plan.save();
  }

  Future<void> deletePlan(String id) async {
    await _plansBox.delete(id);
  }

  /// Recall Attempts
  Future<void> createAttempt(RecallAttempt attempt) async {
    await _attemptsBox.put(attempt.id, attempt);
  }

  List<RecallAttempt> getAttemptsByMemoryId(String memoryId) {
    return _attemptsBox.values
        .where((attempt) => attempt.memoryId == memoryId)
        .toList()
      ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
  }

  List<RecallAttempt> getAllAttempts() {
    return _attemptsBox.values.toList()
      ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
  }

  double getAverageScore() {
    final attempts = getAllAttempts();
    if (attempts.isEmpty) return 0.0;
    final sum = attempts.fold<int>(0, (sum, attempt) => sum + attempt.score);
    return sum / attempts.length;
  }
}
