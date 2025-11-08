/// App-wide constants for RememberWell
class AppConstants {
  // Memory limits
  static const int maxMemoryTextLength = 5000;
  static const int minMemoryTextLength = 3;
  static const int maxTagLength = 24;
  static const int maxTagsPerMemory = 12;
  static const int maxAssociationsLength = 200;

  // Attachment limits
  static const int maxImageSizeMB = 15;

  // Recall intervals (in days)
  static const List<int> recallIntervals = [3, 5, 7, 10];
  static const int defaultRecallInterval = 3;
  static const int minCustomInterval = 1;
  static const int maxCustomInterval = 60;

  // Adaptive algorithm thresholds
  static const int strongScoreThreshold = 90;
  static const int weakScoreThreshold = 70;
  static const double strongScoreMultiplier = 1.5;
  static const double weakScoreMultiplier = 0.7;

  // Confidence weighting
  static const int highConfidenceThreshold = 70;
  static const int confidenceAdjustment = 10;

  // Pagination
  static const int itemsPerPage = 50;

  // Debounce times (in milliseconds)
  static const int searchDebounceMs = 300;

  // Default mood value
  static const int defaultMood = 3;

  // File paths
  static const String memoriesBoxName = 'memories';
  static const String recallPlansBoxName = 'recall_plans';
  static const String recallAttemptsBoxName = 'recall_attempts';
  static const String preferencesBoxName = 'preferences';
  static const String badgesBoxName = 'badges';

  // Private constructor to prevent instantiation
  AppConstants._();
}


