import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/daytrack_provider.dart';
import '../services/time_calculator.dart';

class ScoreBreakdownScreen extends StatelessWidget {
  const ScoreBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final scoreResult = provider.dailyScoreResult;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Breakdown'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                        : [const Color(0xFFE0E7FF), const Color(0xFFEEF2FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Daily Productivity Score',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4338CA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${scoreResult.totalScore.toStringAsFixed(1)} / 100',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF312E81),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat('EEEE, MMM d, yyyy').format(provider.selectedDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Plain English Formula Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'How is your score calculated?',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Each scored category has a target (minutes) and a weight (points).\n\n'
                        'Formula:\n'
                        'Points = Weight × min(Actual Minutes ÷ Target Minutes, 1.0)\n\n'
                        'Daily Score is simply the sum of points earned across your scored goals. Time accounting and productivity are completely separate: registering 24h does NOT give 100 points unless you hit your productive goals.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Category Progress Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (scoreResult.categoryDetails.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('No scored categories configured in Settings.'),
                    ),
                  ),
                )
              else
                ...scoreResult.categoryDetails.map((detail) {
                  final cat = detail.category;
                  final pctStr = detail.completionPercentage.toStringAsFixed(0);
                  final pointsStr = detail.pointsEarned.toStringAsFixed(1);
                  final maxPointsStr = detail.maxPoints.toStringAsFixed(0);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: cat.color.withValues(alpha: 0.2),
                                    child: Icon(cat.iconData, size: 16, color: cat.color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pointsStr / $maxPointsStr pts',
                                  style: TextStyle(
                                    color: cat.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Actual: ${TimeCalculator.formatDuration(detail.actualMinutes)}',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                              Text(
                                'Target: ${TimeCalculator.formatDuration(detail.targetMinutes)}',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                              Text(
                                'Progress: $pctStr%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: detail.actualMinutes >= detail.targetMinutes ? Colors.green : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (detail.actualMinutes / (detail.targetMinutes > 0 ? detail.targetMinutes : 1)).clamp(0.0, 1.0),
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              color: cat.color,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
