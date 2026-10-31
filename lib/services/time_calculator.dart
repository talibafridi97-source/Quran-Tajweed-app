import '../models/activity_record.dart';
import 'overlap_detector.dart';

class DailyTimeSummary {
  final int accountedMinutes;
  final int remainingMinutes;
  final double accountingPercentage; // 0..100
  final bool exceeds24Hours;
  final Map<int, int> categoryMinutes; // categoryId -> total minutes
  final OverlapResult overlapResult;

  const DailyTimeSummary({
    required this.accountedMinutes,
    required this.remainingMinutes,
    required this.accountingPercentage,
    required this.exceeds24Hours,
    required this.categoryMinutes,
    required this.overlapResult,
  });
}

class TimeCalculator {
  static const int totalDayMinutes = 1440;

  /// Calculate summary for a given day's records
  static DailyTimeSummary calculateDailySummary(List<ActivityRecord> records) {
    final overlapResult = OverlapDetector.analyzeIntervals(records);
    final accounted = overlapResult.mergedAccountedMinutes;
    final remaining = (totalDayMinutes - accounted).clamp(0, totalDayMinutes);
    final percentage = (accounted / totalDayMinutes) * 100.0;
    final exceeds24 = accounted > totalDayMinutes;

    final Map<int, int> catMinutes = {};
    for (final r in records) {
      catMinutes[r.categoryId] = (catMinutes[r.categoryId] ?? 0) + r.durationMinutes;
    }

    return DailyTimeSummary(
      accountedMinutes: accounted,
      remainingMinutes: remaining,
      accountingPercentage: percentage,
      exceeds24Hours: exceeds24,
      categoryMinutes: catMinutes,
      overlapResult: overlapResult,
    );
  }

  /// Formats minutes to "Xh Ym" or "Xh" or "Ym"
  static String formatDuration(int minutes) {
    if (minutes < 0) minutes = 0;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Formats minutes to "X.X h"
  static String formatHoursDecimal(int minutes) {
    final hours = minutes / 60.0;
    return '${hours.toStringAsFixed(1)}h';
  }
}
