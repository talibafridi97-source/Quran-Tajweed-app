import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/daytrack_provider.dart';
import '../services/period_service.dart';
import '../services/time_calculator.dart';
import '../widgets/my_score_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<PeriodType> _tabs = [
    PeriodType.today,
    PeriodType.last2Days,
    PeriodType.last7Days,
    PeriodType.last30Days,
    PeriodType.custom,
  ];

  @override
  void initState() {
    super.initState();
    final current = context.read<DayTrackProvider>().selectedPeriod;
    final initialIndex = _tabs.indexOf(current).clamp(0, _tabs.length - 1);
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final period = _tabs[_tabController.index];
        context.read<DayTrackProvider>().setPeriod(period);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange(DayTrackProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: provider.customStartDate ?? DateTime.now().subtract(const Duration(days: 6)),
        end: provider.customEndDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      provider.setPeriod(PeriodType.custom, customStart: picked.start, customEnd: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final report = provider.currentReport;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time & Productivity Reports'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Last 2 Days'),
            Tab(text: 'Last 7 Days'),
            Tab(text: 'Last 30 Days'),
            Tab(text: 'Custom Range'),
          ],
        ),
      ),
      body: SafeArea(
        child: report == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Header Card
                    if (report.periodType == PeriodType.custom)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range_rounded),
                          label: Text(
                            '${DateFormat('MMM d, yyyy').format(report.startDate)} - ${DateFormat('MMM d, yyyy').format(report.endDate)} (Change Range)',
                          ),
                          onPressed: () => _pickCustomRange(provider),
                        ),
                      ),

                    // Metrics Grid Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildMetricItem(
                                context,
                                'Total Accounted',
                                TimeCalculator.formatDuration(report.totalAccountedMinutes),
                                Icons.timer_outlined,
                                theme.colorScheme.primary,
                              ),
                              _buildMetricItem(
                                context,
                                'Total Unaccounted',
                                TimeCalculator.formatDuration(report.totalUnaccountedMinutes),
                                Icons.hourglass_empty_rounded,
                                Colors.blueGrey,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              _buildMetricItem(
                                context,
                                'Daily Avg Accounting',
                                '${report.averageDailyAccountingPercentage.toStringAsFixed(1)}%',
                                Icons.pie_chart_outline_rounded,
                                Colors.indigo,
                              ),
                              _buildMetricItem(
                                context,
                                'Daily Avg Score',
                                report.averageDailyProductivityScore != null
                                    ? '${report.averageDailyProductivityScore!.toStringAsFixed(1)}/100'
                                    : 'No records',
                                Icons.star_outline_rounded,
                                Colors.amber[700]!,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              _buildMetricItem(
                                context,
                                'Days with Records',
                                '${report.recordedDaysCount} of ${report.totalDays} days',
                                Icons.calendar_today_rounded,
                                Colors.green,
                              ),
                              _buildMetricItem(
                                context,
                                'Missing / Incomplete',
                                '${report.missingDaysCount} missing • ${report.incompleteDaysCount} < 24h',
                                Icons.warning_amber_rounded,
                                Colors.orange,
                              ),
                            ],
                          ),
                          if (report.bestDayProductivityScore != null) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                _buildMetricItem(
                                  context,
                                  'Best Recorded Day',
                                  '${report.bestDayProductivityScore!.toStringAsFixed(1)} pts (${report.bestDayDate})',
                                  Icons.emoji_events_outlined,
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Day-by-Day Comparison Bar Chart (via fl_chart)
                    Text(
                      'Day-by-Day Accounting & Score',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDayByDayChart(context, report),

                    const SizedBox(height: 20),

                    // Category Breakdown Table / Distribution
                    Text(
                      'Category Breakdown (All Dynamic Categories)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...provider.categories.map((cat) {
                      final totalMins = report.totalMinutesPerCategory[cat.id] ?? 0;
                      final avgMins = report.avgMinutesPerCategory[cat.id] ?? 0.0;
                      if (totalMins == 0 && cat.isArchived) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cat.color.withValues(alpha: 0.15),
                            child: Icon(cat.iconData, color: cat.color, size: 20),
                          ),
                          title: Row(
                            children: [
                              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (cat.isArchived)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Text('(Archived)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Daily Avg: ${TimeCalculator.formatDuration(avgMins.toInt())} / day',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                TimeCalculator.formatDuration(totalMins),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${(totalMins / 60).toStringAsFixed(1)} hours',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Score Section at the Bottom
                    MyScoreCard(
                      report: report,
                      categories: provider.categories,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayByDayChart(BuildContext context, PeriodReportSummary report) {
    if (report.daySummaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaries = report.daySummaries;

    // Show last max 14 days in bar chart for readable UI
    final visible = summaries.length > 14 ? summaries.sublist(summaries.length - 14) : summaries;

    final barGroups = visible.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final accountedHours = day.accountedMinutes / 60.0;
      final score = day.productivityScore ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: accountedHours.clamp(0.0, 24.0),
            color: day.hasRecords ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: (score / 100.0) * 24.0, // Scale 0..100 score onto 24h axis for comparison
            color: day.hasRecords ? Colors.amber : Colors.transparent,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 16, right: 16, left: 8, bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 8, height: 8, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              const Text('Hours Accounted', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 12),
              Container(width: 8, height: 8, color: Colors.amber),
              const SizedBox(width: 4),
              const Text('Score (scaled)', style: TextStyle(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 24,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}h', style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < visible.length) {
                          final date = DateTime.parse(visible[idx].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(DateFormat('d').format(date), style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 6,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
