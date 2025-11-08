import 'package:hive/hive.dart';
import '../models/memory.dart';
import '../services/hive_service.dart';

/// Repository for memory CRUD operations
class MemoryRepository {
  Box<Memory> get _box => HiveService.memoriesBox;

  /// Create a new memory
  Future<void> create(Memory memory) async {
    await _box.put(memory.id, memory);
  }

  /// Get all memories
  List<Memory> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get memory by ID
  Memory? getById(String id) {
    return _box.get(id);
  }

  /// Update memory
  Future<void> update(Memory memory) async {
    await memory.save();
  }

  /// Delete memory
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Search memories by query
  List<Memory> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((memory) {
      return memory.text.toLowerCase().contains(lowerQuery) ||
          (memory.who?.toLowerCase().contains(lowerQuery) ?? false) ||
          (memory.tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter memories by tags
  List<Memory> filterByTags(List<String> tags) {
    return _box.values.where((memory) {
      return memory.tags?.any((tag) => tags.contains(tag)) ?? false;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter memories by date range
  List<Memory> filterByDateRange(DateTime start, DateTime end) {
    return _box.values.where((memory) {
      return memory.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
          memory.createdAt.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get memories for a specific day
  List<Memory> getMemoriesForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return filterByDateRange(startOfDay, endOfDay);
  }

  /// Get random memories for quiz
  List<Memory> getRandomMemories(int count) {
    final allMemories = getAll();
    final shuffled = List<Memory>.from(allMemories)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Get count of memories
  int get count => _box.length;
}
