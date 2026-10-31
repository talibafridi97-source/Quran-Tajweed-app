import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/daytrack_provider.dart';
import '../services/time_calculator.dart';
import '../services/period_service.dart';
import '../widgets/time_distribution_bar.dart';
import '../widgets/my_score_card.dart';
import '../widgets/add_activity_dialog.dart';
import 'add_record_screen.dart';
import 'score_breakdown_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final summary = provider.dailyTimeSummary;
    final scoreResult = provider.dailyScoreResult;
    final records = provider.selectedDateRecords;
    final categories = provider.categories;
    final report = provider.currentReport;

    final dateStr = DateFormat('EEE, MMM d, yyyy').format(provider.selectedDate);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header with Name + Tagline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DayTrack 24',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track Your Time. Improve Every Day.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date Switcher Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {
                        provider.setSelectedDate(provider.selectedDate.subtract(const Duration(days: 1)));
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: provider.selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          provider.setSelectedDate(picked);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        provider.setSelectedDate(provider.selectedDate.add(const Duration(days: 1)));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Two Independent Metric Cards
              Row(
                children: [
                  // 1. Time Accounting Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: summary.exceeds24Hours
                              ? Colors.red
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time Accounted',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              Icon(Icons.pie_chart_outline, size: 16, color: theme.colorScheme.primary),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            TimeCalculator.formatDuration(summary.accountedMinutes),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: summary.exceeds24Hours ? Colors.red : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.accountingPercentage.toStringAsFixed(1)}% of 24h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${TimeCalculator.formatDuration(summary.remainingMinutes)} remaining',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 2. Productivity Score Card
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ScoreBreakdownScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Productivity Score',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              records.isEmpty ? 'No record' : '${scoreResult.totalScore.toStringAsFixed(0)}/100',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: records.isEmpty ? Colors.grey : Colors.amber[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Independent Metric',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Text('View breakdown', style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w600)),
                                Icon(Icons.chevron_right, size: 14, color: Colors.indigo),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stacked Distribution Bar
              TimeDistributionBar(
                records: records,
                categories: categories,
                totalAccountedMinutes: summary.accountedMinutes,
              ),

              const SizedBox(height: 16),

              // Navigation Shortcuts (Today's Record / Reports)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Add / Edit Day'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const AddRecordScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.insights_rounded),
                      label: const Text('Reports & Analytics'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ReportsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Period Selector for the Score Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Period Overview',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<PeriodType>(
                    value: provider.selectedPeriod,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: PeriodType.today, child: Text('Today')),
                      DropdownMenuItem(value: PeriodType.last2Days, child: Text('Last 2 Days')),
                      DropdownMenuItem(value: PeriodType.last7Days, child: Text('Last 7 Days')),
                      DropdownMenuItem(value: PeriodType.last30Days, child: Text('Last 30 Days')),
                    ],
                    onChanged: (p) {
                      if (p != null) provider.setPeriod(p);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Score Section at the Bottom
              if (report != null)
                MyScoreCard(
                  report: report,
                  categories: categories,
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const AddActivityDialog(),
          ).then((rec) {
            if (rec != null) {
              provider.addActivityRecord(rec);
            }
          });
        },
      ),
    );
  }
}
