import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';

class TimeDistributionBar extends StatelessWidget {
  final List<ActivityRecord> records;
  final List<ActivityCategory> categories;
  final int totalAccountedMinutes;

  const TimeDistributionBar({
    super.key,
    required this.records,
    required this.categories,
    required this.totalAccountedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    const totalDayMinutes = 1440;
    final remainingMinutes = (totalDayMinutes - totalAccountedMinutes).clamp(0, totalDayMinutes);

    // Group minutes by category
    final Map<int, int> catMinutes = {};
    for (final r in records) {
      catMinutes[r.categoryId] = (catMinutes[r.categoryId] ?? 0) + r.durationMinutes;
    }

    final catMap = {for (var c in categories) c.id: c};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24-Hour Time Distribution',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(totalAccountedMinutes / totalDayMinutes * 100).toStringAsFixed(1)}% accounted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  ...catMinutes.entries.map((entry) {
                    final cat = catMap[entry.key];
                    final color = cat?.color ?? Colors.blueGrey;
                    final flex = entry.value;
                    if (flex <= 0) return const SizedBox.shrink();
                    return Expanded(
                      flex: flex,
                      child: Container(
                        color: color,
                        height: 20,
                      ),
                    );
                  }),
                  if (remainingMinutes > 0)
                    Expanded(
                      flex: remainingMinutes,
                      child: Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        height: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Category legends
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              ...catMinutes.entries.map((entry) {
                final cat = catMap[entry.key];
                final name = cat?.name ?? 'Category';
                final color = cat?.color ?? Colors.blueGrey;
                final mins = entry.value;
                final hours = (mins / 60).toStringAsFixed(1);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$name (${hours}h)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                );
              }),
              if (remainingMinutes > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unaccounted (${(remainingMinutes / 60).toStringAsFixed(1)}h)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryDonutChart extends StatelessWidget {
  final List<ActivityRecord> records;
  final List<ActivityCategory> categories;

  const CategoryDonutChart({
    super.key,
    required this.records,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<int, int> catMinutes = {};
    for (final r in records) {
      catMinutes[r.categoryId] = (catMinutes[r.categoryId] ?? 0) + r.durationMinutes;
    }
    final catMap = {for (var c in categories) c.id: c};

    final sections = catMinutes.entries.map((e) {
      final cat = catMap[e.key];
      final color = cat?.color ?? Colors.indigo;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${(e.value / 60).toStringAsFixed(1)}h',
        color: color,
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
