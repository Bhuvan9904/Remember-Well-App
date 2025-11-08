/// Fuzzy string matching using Levenshtein distance
class FuzzyMatch {
  /// Calculate the similarity between two strings (0.0 to 1.0)
  static double similarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    s1 = s1.toLowerCase().trim();
    s2 = s2.toLowerCase().trim();

    // Direct match
    if (s1 == s2) return 1.0;

    // Check if one string contains the other
    if (s1.contains(s2) || s2.contains(s1)) return 0.8;

    // Calculate Levenshtein distance
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    // Convert distance to similarity (0.0 to 1.0)
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.length > s2.length) {
      // Swap to ensure s1 is shorter
      final temp = s1;
      s1 = s2;
      s2 = temp;
    }

    final m = s1.length;
    final n = s2.length;

    // Edge cases
    if (m == 0) return n;
    if (n == 0) return m;

    // Create distance matrix
    final matrix = List.generate(m + 1, (i) => List.filled(n + 1, 0));

    // Initialize first row and column
    for (var i = 0; i <= m; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      matrix[0][j] = j;
    }

    // Fill matrix
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // Deletion
          matrix[i][j - 1] + 1, // Insertion
          matrix[i - 1][j - 1] + cost, // Substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[m][n];
  }
}


