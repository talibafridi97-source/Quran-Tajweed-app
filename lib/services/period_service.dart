import 'package:intl/intl.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';
import 'time_calculator.dart';
import 'score_calculator.dart';

enum PeriodType {
  today,
  last2Days,
  last7Days,
  last30Days,
  custom,
}

class DayReportSummary {
  final String date;
  final bool hasRecords;
  final bool isReviewed;
  final int accountedMinutes;
  final int unaccountedMinutes;
  final double accountingPercentage;
  final double? productivityScore; // null if no record
  final List<ActivityRecord> records;

  const DayReportSummary({
    required this.date,
    required this.hasRecords,
    required this.isReviewed,
    required this.accountedMinutes,
    required this.unaccountedMinutes,
    required this.accountingPercentage,
    required this.productivityScore,
    required this.records,
  });
}

class PeriodReportSummary {
  final PeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int recordedDaysCount;
  final int missingDaysCount;
  final int incompleteDaysCount; // Recorded days < 1440 min
  final int totalAccountedMinutes;
  final int totalUnaccountedMinutes;
  final double averageDailyAccountingPercentage;
  final double? averageDailyProductivityScore; // averaged only over days with records!
  final double? bestDayProductivityScore;
  final String? bestDayDate;
  final Map<int, int> totalMinutesPerCategory;
  final Map<int, double> avgMinutesPerCategory;
  final List<DayReportSummary> daySummaries;

  const PeriodReportSummary({
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.recordedDaysCount,
    required this.missingDaysCount,
    required this.incompleteDaysCount,
    required this.totalAccountedMinutes,
    required this.totalUnaccountedMinutes,
    required this.averageDailyAccountingPercentage,
    required this.averageDailyProductivityScore,
    required this.bestDayProductivityScore,
    required this.bestDayDate,
    required this.totalMinutesPerCategory,
    required this.avgMinutesPerCategory,
    required this.daySummaries,
  });
}

class PeriodService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Generate list of dates [startDate, endDate] inclusive
  static List<String> getDateRange(DateTime start, DateTime end) {
    final List<String> dates = [];
    DateTime curr = DateTime(start.year, start.month, start.day);
    final DateTime last = DateTime(end.year, end.month, end.day);
    while (!curr.isAfter(last)) {
      dates.add(_dateFormat.format(curr));
      curr = curr.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Resolves date range for a given PeriodType based on a reference date (default: now)
  static ({DateTime start, DateTime end}) resolvePeriodDates(PeriodType period, {DateTime? refDate, DateTime? customStart, DateTime? customEnd}) {
    final now = refDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case PeriodType.today:
        return (start: today, end: today);
      case PeriodType.last2Days:
        return (start: today.subtract(const Duration(days: 1)), end: today);
      case PeriodType.last7Days:
        return (start: today.subtract(const Duration(days: 6)), end: today);
      case PeriodType.last30Days:
        return (start: today.subtract(const Duration(days: 29)), end: today);
      case PeriodType.custom:
        return (
          start: customStart ?? today.subtract(const Duration(days: 6)),
          end: customEnd ?? today,
        );
    }
  }

  /// Calculates period report summary given all categories, all records, and daily reviewed map.
  /// Never counts missing days as 0 or 100 productivity score, and never treats missing days as complete.
  static PeriodReportSummary generateReport({
    required PeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
    required List<ActivityCategory> categories,
    required Map<String, List<ActivityRecord>> recordsByDate,
    required Map<String, bool> reviewedDaysByDate,
    Map<String, double>? historicalScoresByDate,
  }) {
    final dateStrings = getDateRange(startDate, endDate);
    final totalDays = dateStrings.length;

    int recordedDays = 0;
    int missingDays = 0;
    int incompleteDays = 0;
    int totalAccountedMinutes = 0;
    int totalUnaccountedMinutes = 0;

    double scoreSum = 0.0;
    int scoredDaysCount = 0;
    double? bestScore;
    String? bestDate;

    final Map<int, int> totalMinutesPerCategory = {};
    final List<DayReportSummary> daySummaries = [];

    for (final dateStr in dateStrings) {
      final records = recordsByDate[dateStr] ?? const [];
      final isReviewed = reviewedDaysByDate[dateStr] ?? false;

      if (records.isEmpty) {
        missingDays++;
        daySummaries.add(DayReportSummary(
          date: dateStr,
          hasRecords: false,
          isReviewed: isReviewed,
          accountedMinutes: 0,
          unaccountedMinutes: 1440,
          accountingPercentage: 0.0,
          productivityScore: null, // No record -> null score!
          records: const [],
        ));
      } else {
        recordedDays++;
        final summary = TimeCalculator.calculateDailySummary(records);
        totalAccountedMinutes += summary.accountedMinutes;
        totalUnaccountedMinutes += summary.remainingMinutes;

        if (summary.accountedMinutes < 1440) {
          incompleteDays++;
        }

        // Add category totals
        summary.categoryMinutes.forEach((catId, mins) {
          totalMinutesPerCategory[catId] = (totalMinutesPerCategory[catId] ?? 0) + mins;
        });

        // Compute or fetch productivity score
        double dayScore;
        if (historicalScoresByDate != null && historicalScoresByDate.containsKey(dateStr)) {
          dayScore = historicalScoresByDate[dateStr]!;
        } else {
          final scoreResult = ScoreCalculator.calculateDailyScore(
            categories: categories,
            records: records,
          );
          dayScore = scoreResult.totalScore;
        }

        scoreSum += dayScore;
        scoredDaysCount++;

        if (bestScore == null || dayScore > bestScore) {
          bestScore = dayScore;
          bestDate = dateStr;
        }

        daySummaries.add(DayReportSummary(
          date: dateStr,
          hasRecords: true,
          isReviewed: isReviewed,
          accountedMinutes: summary.accountedMinutes,
          unaccountedMinutes: summary.remainingMinutes,
          accountingPercentage: summary.accountingPercentage,
          productivityScore: dayScore,
          records: records,
        ));
      }
    }

    // Average daily accounting across all calendar days in period
    final avgDailyAccounting = totalDays > 0 ? (totalAccountedMinutes / (totalDays * 1440)) * 100.0 : 0.0;

    // Average productivity score only over days with records
    final double? avgProductivityScore = scoredDaysCount > 0 ? (scoreSum / scoredDaysCount) : null;

    // Average minutes per category per recorded day (or per total calendar days)
    final Map<int, double> avgMinutesPerCategory = {};
    totalMinutesPerCategory.forEach((catId, mins) {
      avgMinutesPerCategory[catId] = totalDays > 0 ? mins / totalDays : 0.0;
    });

    return PeriodReportSummary(
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      recordedDaysCount: recordedDays,
      missingDaysCount: missingDays,
      incompleteDaysCount: incompleteDays,
      totalAccountedMinutes: totalAccountedMinutes,
      totalUnaccountedMinutes: totalUnaccountedMinutes,
      averageDailyAccountingPercentage: avgDailyAccounting,
      averageDailyProductivityScore: avgProductivityScore,
      bestDayProductivityScore: bestScore,
      bestDayDate: bestDate,
      totalMinutesPerCategory: totalMinutesPerCategory,
      avgMinutesPerCategory: avgMinutesPerCategory,
      daySummaries: daySummaries,
    );
  }
}
