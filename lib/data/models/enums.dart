/// Recall status enum
enum RecallStatus {
  pending,
  completed,
  skipped,
  missed,
}

/// Training mode enum for recall attempts
enum TrainingMode {
  scheduled, // Regular scheduled recall
  replay, // Replay mode (flashcards)
  random, // Random recall
  battle, // Battle mode
  guided, // Guided paths
}

/// Mood level for memories
enum Mood {
  terrible(1),
  bad(2),
  okay(3),
  good(4),
  great(5);

  const Mood(this.value);
  final int value;

  static Mood fromValue(int value) {
    return Mood.values.firstWhere((mood) => mood.value == value, orElse: () => Mood.okay);
  }
}

/// Sensory cue types
enum SensoryType {
  smell,
  sound,
  taste,
  color,
  texture,
}

extension SensoryTypeExtension on SensoryType {
  String get label {
    switch (this) {
      case SensoryType.smell:
        return 'Smell';
      case SensoryType.sound:
        return 'Sound';
      case SensoryType.taste:
        return 'Taste';
      case SensoryType.color:
        return 'Color';
      case SensoryType.texture:
        return 'Texture';
    }
  }
}


