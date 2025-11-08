import '../../core/constants/app_constants.dart';

/// Simplified adaptive spaced repetition algorithm
/// Based on SM-2 algorithm with simplified logic
class AdaptiveAlgorithm {
  /// Calculate next recall interval based on performance
  /// 
  /// [currentInterval] - Current interval in days
  /// [score] - Recall score (0-100)
  /// Returns new interval in days
  static int calculateNextInterval(int currentInterval, int score) {
    // Strong recall (≥90) - increase interval
    if (score >= AppConstants.strongScoreThreshold) {
      return (currentInterval * AppConstants.strongScoreMultiplier).round();
    }
    
    // Weak recall (<70) - decrease interval
    if (score < AppConstants.weakScoreThreshold) {
      final newInterval = (currentInterval * AppConstants.weakScoreMultiplier).round();
      // Ensure minimum interval of 1 day
      return newInterval < 1 ? 1 : newInterval;
    }
    
    // Moderate recall (70-89) - keep same interval
    return currentInterval;
  }
}


