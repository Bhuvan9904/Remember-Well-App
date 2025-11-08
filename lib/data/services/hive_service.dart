import 'package:hive_flutter/hive_flutter.dart';
import '../models/memory.dart';
import '../models/recall_plan.dart';
import '../models/recall_attempt.dart';
import '../models/recall_status.dart';
import '../models/training_mode.dart';
import '../models/preferences.dart';
import '../../core/constants/app_constants.dart';

/// Service for Hive database initialization and box access
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MemoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RecallPlanAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecallAttemptAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PreferencesAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(RecallStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(TrainingModeAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Memory>(AppConstants.memoriesBoxName);
    await Hive.openBox<RecallPlan>(AppConstants.recallPlansBoxName);
    await Hive.openBox<RecallAttempt>(AppConstants.recallAttemptsBoxName);
    await Hive.openBox<Preferences>(AppConstants.preferencesBoxName);
  }

  static Box<Memory> get memoriesBox => 
      Hive.box<Memory>(AppConstants.memoriesBoxName);
  
  static Box<RecallPlan> get recallPlansBox => 
      Hive.box<RecallPlan>(AppConstants.recallPlansBoxName);
  
  static Box<RecallAttempt> get recallAttemptsBox => 
      Hive.box<RecallAttempt>(AppConstants.recallAttemptsBoxName);
  
  static Box<Preferences> get preferencesBox => 
      Hive.box<Preferences>(AppConstants.preferencesBoxName);
}


