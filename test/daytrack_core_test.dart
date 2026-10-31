import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/models/activity_category.dart';
import 'package:tajweed_quran/models/activity_record.dart';
import 'package:tajweed_quran/services/overlap_detector.dart';
import 'package:tajweed_quran/services/time_calculator.dart';
import 'package:tajweed_quran/services/score_calculator.dart';
import 'package:tajweed_quran/services/period_service.dart';

void main() {
  group('DayTrack 24 Unit Tests', () {
    // 1. 6h coding + 2h Quran + 1h English = 540 minutes accounted.
    test('6h coding + 2h Quran + 1h English = 540 minutes accounted', () {
      final records = [
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Coding',
          activityName: 'Flutter work',
          durationMinutes: 360, // 6h
          createdAt: '',
          updatedAt: '',
        ),
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 2,
          categoryNameSnapshot: 'Quran',
          activityName: 'Recitation',
          durationMinutes: 120, // 2h
          createdAt: '',
          updatedAt: '',
        ),
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 3,
          categoryNameSnapshot: 'English Study',
          activityName: 'Grammar',
          durationMinutes: 60, // 1h
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final summary = TimeCalculator.calculateDailySummary(records);
      expect(summary.accountedMinutes, equals(540));
      expect(summary.remainingMinutes, equals(1440 - 540)); // 900 min (15h)
      expect(summary.exceeds24Hours, isFalse);
    });

    // 2. 20h recorded shows 4h remaining and 83.33%.
    test('20h recorded shows 4h remaining and 83.33%', () {
      final records = [
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Work',
          activityName: 'Long project',
          durationMinutes: 20 * 60, // 1200 min
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final summary = TimeCalculator.calculateDailySummary(records);
      expect(summary.accountedMinutes, equals(1200));
      expect(summary.remainingMinutes, equals(240)); // 4h
      expect(summary.accountingPercentage, closeTo(83.333, 0.01));
    });

    // 3. 25h recorded triggers the validation warning.
    test('25h recorded triggers the validation warning', () {
      final records = [
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Work',
          activityName: 'Overtime',
          durationMinutes: 25 * 60, // 1500 min
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final summary = TimeCalculator.calculateDailySummary(records);
      expect(summary.accountedMinutes, equals(1500));
      expect(summary.exceeds24Hours, isTrue);
    });

    // 4. Multiple coding entries combine correctly.
    test('Multiple coding entries combine correctly', () {
      final records = [
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Coding',
          activityName: 'Session 1',
          durationMinutes: 240, // 4h
          createdAt: '',
          updatedAt: '',
        ),
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Coding',
          activityName: 'Session 2',
          durationMinutes: 120, // 2h
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final summary = TimeCalculator.calculateDailySummary(records);
      expect(summary.accountedMinutes, equals(360)); // 6h total
      expect(summary.categoryMinutes[1], equals(360));
    });

    // 5. Overlapping intervals are detected and counted once.
    test('Overlapping intervals are detected and counted once', () {
      // Slot 1: 10:00 to 12:00 (120m, min 600..720)
      // Slot 2: 11:00 to 13:00 (120m, min 660..780)
      // Overlap: 11:00 to 12:00 (60m). Merged total = 10:00 to 13:00 = 180 min.
      final records = [
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 1,
          categoryNameSnapshot: 'Coding',
          activityName: 'Coding block',
          durationMinutes: 120,
          startTime: '10:00',
          endTime: '12:00',
          createdAt: '',
          updatedAt: '',
        ),
        ActivityRecord(
          date: '2026-10-10',
          categoryId: 2,
          categoryNameSnapshot: 'Meeting',
          activityName: 'Call block',
          durationMinutes: 120,
          startTime: '11:00',
          endTime: '13:00',
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final result = OverlapDetector.analyzeIntervals(records);
      expect(result.hasOverlap, isTrue);
      expect(result.overlapWarnings.length, equals(1));
      expect(result.rawTotalMinutes, equals(240));
      expect(result.mergedAccountedMinutes, equals(180)); // Counted once!
    });

    // 6. Midnight-crossing sleep (22:30-05:00 = 390 min) is correct.
    test('Midnight-crossing sleep (22:30-05:00 = 390 min) is correct', () {
      final duration = OverlapDetector.calculateDurationMinutes('22:30', '05:00');
      expect(duration, equals(390)); // 1.5h before midnight + 5h after midnight = 390 min
    });

    // 7. Score formula: coding 6h of 6h target = 40 pts; 3h = 20 pts; over-target capped at 40.
    test('Score formula: coding 6h of 6h target = 40 pts; 3h = 20 pts; over-target capped at 40', () {
      const codingCategory = ActivityCategory(
        id: 1,
        name: 'Coding',
        colorValue: 0xFF2563EB,
        iconName: 'code',
        type: CategoryType.productive,
        dailyTargetMinutes: 360, // 6h
        weight: 40.0,
        countsForScore: true,
        createdAt: '',
      );

      // Case A: Exactly 6h -> 40 pts
      var result = ScoreCalculator.calculateDailyScore(
        categories: [codingCategory],
        records: [
          ActivityRecord(
            date: '2026-10-10',
            categoryId: 1,
            categoryNameSnapshot: 'Coding',
            activityName: 'Full day',
            durationMinutes: 360,
            createdAt: '',
            updatedAt: '',
          ),
        ],
      );
      expect(result.totalScore, closeTo(40.0, 0.01));

      // Case B: 3h -> 20 pts
      result = ScoreCalculator.calculateDailyScore(
        categories: [codingCategory],
        records: [
          ActivityRecord(
            date: '2026-10-10',
            categoryId: 1,
            categoryNameSnapshot: 'Coding',
            activityName: 'Half day',
            durationMinutes: 180,
            createdAt: '',
            updatedAt: '',
          ),
        ],
      );
      expect(result.totalScore, closeTo(20.0, 0.01));

      // Case C: Over-target 8h (480 min) -> capped at 40 pts
      result = ScoreCalculator.calculateDailyScore(
        categories: [codingCategory],
        records: [
          ActivityRecord(
            date: '2026-10-10',
            categoryId: 1,
            categoryNameSnapshot: 'Coding',
            activityName: 'Overtime',
            durationMinutes: 480,
            createdAt: '',
            updatedAt: '',
          ),
        ],
      );
      expect(result.totalScore, closeTo(40.0, 0.01));
    });

    // 8. Weights not totaling 100 are rejected/warned.
    test('Weights not totaling 100 are rejected/warned', () {
      const cat1 = ActivityCategory(
        id: 1,
        name: 'Coding',
        colorValue: 0,
        iconName: '',
        type: CategoryType.productive,
        dailyTargetMinutes: 60,
        weight: 60.0,
        countsForScore: true,
        createdAt: '',
      );
      const cat2 = ActivityCategory(
        id: 2,
        name: 'Quran',
        colorValue: 0,
        iconName: '',
        type: CategoryType.productive,
        dailyTargetMinutes: 60,
        weight: 30.0, // Total = 90
        countsForScore: true,
        createdAt: '',
      );

      expect(ScoreCalculator.validateWeights([cat1, cat2]), isFalse);

      final balanced = ScoreCalculator.autoBalanceWeights([cat1, cat2]);
      expect(ScoreCalculator.validateWeights(balanced), isTrue);
    });

    // 9. 2/7/30-day reports use the correct dates.
    test('2/7/30-day reports use the correct dates', () {
      final ref = DateTime(2026, 10, 10);
      final range2 = PeriodService.resolvePeriodDates(PeriodType.last2Days, refDate: ref);
      final dates2 = PeriodService.getDateRange(range2.start, range2.end);
      expect(dates2.length, equals(2));
      expect(dates2, equals(['2026-10-09', '2026-10-10']));

      final range7 = PeriodService.resolvePeriodDates(PeriodType.last7Days, refDate: ref);
      final dates7 = PeriodService.getDateRange(range7.start, range7.end);
      expect(dates7.length, equals(7));
      expect(dates7.first, equals('2026-10-04'));
      expect(dates7.last, equals('2026-10-10'));

      final range30 = PeriodService.resolvePeriodDates(PeriodType.last30Days, refDate: ref);
      final dates30 = PeriodService.getDateRange(range30.start, range30.end);
      expect(dates30.length, equals(30));
      expect(dates30.last, equals('2026-10-10'));
    });

    // 10. Missing days are not treated as complete or as perfect scores.
    test('Missing days are not treated as complete or as perfect scores', () {
      final ref = DateTime(2026, 10, 10);
      final range2 = PeriodService.resolvePeriodDates(PeriodType.last2Days, refDate: ref);

      // Only today has a record
      final recordsByDate = {
        '2026-10-10': [
          const ActivityRecord(
            date: '2026-10-10',
            categoryId: 1,
            categoryNameSnapshot: 'Coding',
            activityName: 'Work',
            durationMinutes: 360,
            createdAt: '',
            updatedAt: '',
          )
        ]
      };

      final report = PeriodService.generateReport(
        periodType: PeriodType.last2Days,
        startDate: range2.start,
        endDate: range2.end,
        categories: [
          const ActivityCategory(
            id: 1,
            name: 'Coding',
            colorValue: 0,
            iconName: '',
            type: CategoryType.productive,
            dailyTargetMinutes: 360,
            weight: 100.0,
            countsForScore: true,
            createdAt: '',
          )
        ],
        recordsByDate: recordsByDate,
        reviewedDaysByDate: {},
      );

      expect(report.totalDays, equals(2));
      expect(report.recordedDaysCount, equals(1));
      expect(report.missingDaysCount, equals(1));
      // Missing day score is null, not 0 or 100
      final missingDay = report.daySummaries.firstWhere((d) => d.date == '2026-10-09');
      expect(missingDay.hasRecords, isFalse);
      expect(missingDay.productivityScore, isNull);
      // Average score is only calculated over recorded days!
      expect(report.averageDailyProductivityScore, equals(100.0));
    });

    // 11. DYNAMIC: a newly created custom category is scored without hardcoded names.
    test('DYNAMIC: custom category calculates score dynamically', () {
      const customCategory = ActivityCategory(
        id: 99,
        name: 'Quantum Physics',
        colorValue: 0xFF123456,
        iconName: 'school',
        type: CategoryType.productive,
        dailyTargetMinutes: 120, // 2h target
        weight: 50.0,
        countsForScore: true,
        createdAt: '',
      );

      final scoreResult = ScoreCalculator.calculateDailyScore(
        categories: [customCategory],
        records: [
          const ActivityRecord(
            date: '2026-10-10',
            categoryId: 99,
            categoryNameSnapshot: 'Quantum Physics',
            activityName: 'Reading Papers',
            durationMinutes: 60, // 1h -> 50% completion
            createdAt: '',
            updatedAt: '',
          ),
        ],
      );

      expect(scoreResult.totalScore, closeTo(25.0, 0.01));
    });
  });
}
