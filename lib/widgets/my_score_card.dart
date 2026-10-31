import 'package:flutter/material.dart';
import '../services/period_service.dart';
import '../services/time_calculator.dart';
import '../models/activity_category.dart';

class MyScoreCard extends StatelessWidget {
  final PeriodReportSummary report;
  final List<ActivityCategory> categories;

  const MyScoreCard({
    super.key,
    required this.report,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build plain English summary text
    final scoredCategories = categories.where((c) => c.countsForScore && !c.isArchived).toList();
    final List<String> activitiesParts = [];

    for (final cat in scoredCategories) {
      final totalMins = report.totalMinutesPerCategory[cat.id] ?? 0;
      if (totalMins > 0) {
        activitiesParts.add('${TimeCalculator.formatDuration(totalMins)} ${cat.name.toLowerCase()}');
      }
    }

    String periodTitle;
    switch (report.periodType) {
      case PeriodType.today:
        periodTitle = 'Today';
        break;
      case PeriodType.last2Days:
        periodTitle = 'In the last 2 days';
        break;
      case PeriodType.last7Days:
        periodTitle = 'In the last 7 days';
        break;
      case PeriodType.last30Days:
        periodTitle = 'In the last 30 days';
        break;
      case PeriodType.custom:
        periodTitle = 'In this selected period';
        break;
    }

    final scoreText = report.averageDailyProductivityScore != null
        ? '${report.averageDailyProductivityScore!.toStringAsFixed(1)}/100'
        : 'No records';

    final narrative = activitiesParts.isNotEmpty
        ? '$periodTitle you recorded ${activitiesParts.join(', ')}.'
        : '$periodTitle no scored activities were recorded.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'My Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scoreText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            narrative,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Text(
            'Goals Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Goal Progress Bars
          ...scoredCategories.map((cat) {
            final targetTotal = (cat.dailyTargetMinutes ?? 0) * report.totalDays;
            final actualTotal = report.totalMinutesPerCategory[cat.id] ?? 0;
            final progress = targetTotal > 0 ? (actualTotal / targetTotal).clamp(0.0, 1.0) : 0.0;
            final pct = (progress * 100).toStringAsFixed(0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(cat.iconData, size: 14, color: cat.color),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${TimeCalculator.formatDuration(actualTotal)} / ${TimeCalculator.formatDuration(targetTotal)} ($pct%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      color: cat.color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
