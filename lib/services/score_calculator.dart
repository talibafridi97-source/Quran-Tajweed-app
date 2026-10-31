import '../models/activity_category.dart';
import '../models/activity_record.dart';

class CategoryScoreDetail {
  final ActivityCategory category;
  final int actualMinutes;
  final int targetMinutes;
  final double completionPercentage; // 0..100+
  final double pointsEarned;
  final double maxPoints;

  const CategoryScoreDetail({
    required this.category,
    required this.actualMinutes,
    required this.targetMinutes,
    required this.completionPercentage,
    required this.pointsEarned,
    required this.maxPoints,
  });
}

class DayScoreResult {
  final double totalScore; // 0..100
  final List<CategoryScoreDetail> categoryDetails;
  final double totalWeightConfigured;

  const DayScoreResult({
    required this.totalScore,
    required this.categoryDetails,
    required this.totalWeightConfigured,
  });
}

class ScoreCalculator {
  /// Calculate daily productivity score based on scored categories and day records.
  /// Formula per category: points = weight * min(actualMinutes / targetMinutes, 1.0).
  /// Guard against target = 0 or target == null.
  static DayScoreResult calculateDailyScore({
    required List<ActivityCategory> categories,
    required List<ActivityRecord> records,
  }) {
    // Filter only scored categories that are not archived
    final scoredCategories = categories.where((c) => c.countsForScore && c.weight > 0).toList();

    double totalWeight = 0;
    for (final c in scoredCategories) {
      totalWeight += c.weight;
    }

    // Sum actual minutes per category
    final Map<int, int> categoryMinutes = {};
    for (final r in records) {
      categoryMinutes[r.categoryId] = (categoryMinutes[r.categoryId] ?? 0) + r.durationMinutes;
    }

    double totalScore = 0;
    final List<CategoryScoreDetail> details = [];

    for (final cat in scoredCategories) {
      final actual = categoryMinutes[cat.id] ?? 0;
      final target = cat.dailyTargetMinutes ?? 0;

      double completionRatio = 0.0;
      double points = 0.0;

      if (target > 0) {
        completionRatio = actual / target;
        final cappedRatio = completionRatio > 1.0 ? 1.0 : completionRatio;
        points = cat.weight * cappedRatio;
      }

      totalScore += points;

      details.add(CategoryScoreDetail(
        category: cat,
        actualMinutes: actual,
        targetMinutes: target,
        completionPercentage: completionRatio * 100.0,
        pointsEarned: points,
        maxPoints: cat.weight,
      ));
    }

    return DayScoreResult(
      totalScore: totalScore.clamp(0.0, 100.0),
      categoryDetails: details,
      totalWeightConfigured: totalWeight,
    );
  }

  /// Validates whether the weights of scored categories total 100.
  static bool validateWeights(List<ActivityCategory> categories, {double tolerance = 0.01}) {
    final sum = categories
        .where((c) => c.countsForScore && !c.isArchived)
        .fold(0.0, (acc, c) => acc + c.weight);
    return (sum - 100.0).abs() <= tolerance;
  }

  /// Helper to auto-balance weights proportionally to total 100.
  static List<ActivityCategory> autoBalanceWeights(List<ActivityCategory> categories) {
    final activeScored = categories.where((c) => c.countsForScore && !c.isArchived).toList();
    if (activeScored.isEmpty) return categories;

    final currentTotal = activeScored.fold(0.0, (acc, c) => acc + c.weight);
    if (currentTotal <= 0) {
      // Divide evenly
      final share = (100.0 / activeScored.length).roundToDouble();
      double assigned = 0;
      return categories.map((c) {
        if (!c.countsForScore || c.isArchived) return c;
        final isLast = c == activeScored.last;
        final w = isLast ? (100.0 - assigned) : share;
        assigned += w;
        return c.copyWith(weight: w);
      }).toList();
    }

    double assigned = 0;
    return categories.map((c) {
      if (!c.countsForScore || c.isArchived) return c;
      final isLast = c == activeScored.last;
      if (isLast) {
        final remainingWeight = (100.0 - assigned).clamp(0.0, 100.0);
        return c.copyWith(weight: double.parse(remainingWeight.toStringAsFixed(1)));
      } else {
        final newWeight = double.parse(((c.weight / currentTotal) * 100.0).toStringAsFixed(1));
        assigned += newWeight;
        return c.copyWith(weight: newWeight);
      }
    }).toList();
  }
}
