import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/daytrack_provider.dart';
import '../models/activity_record.dart';
import '../models/activity_category.dart';
import '../services/time_calculator.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/quick_split_dialogs.dart';

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final theme = Theme.of(context);
    final summary = provider.dailyTimeSummary;
    final records = provider.selectedDateRecords;
    final status = provider.selectedDateStatus;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('EEEE, MMM d').format(provider.selectedDate),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Pick Date',
            onPressed: () async {
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
          ),
          IconButton(
            icon: Icon(
              status.isReviewed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: status.isReviewed ? Colors.green : null,
            ),
            tooltip: status.isReviewed ? 'Reviewed (Tap to reopen)' : 'Mark as Reviewed',
            onPressed: () => provider.toggleDayReviewed(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live summary card
              Container(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accounted Time',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TimeCalculator.formatDuration(summary.accountedMinutes),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: summary.exceeds24Hours ? Colors.red : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Remaining',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TimeCalculator.formatDuration(summary.remainingMinutes),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (summary.accountedMinutes / 1440).clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        color: summary.exceeds24Hours ? Colors.red : theme.colorScheme.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${summary.accountingPercentage.toStringAsFixed(1)}% of 24h',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (summary.overlapResult.isDurationOnly)
                          Text(
                            'Duration-based (overlap unverified)',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontSize: 11),
                          )
                        else if (summary.overlapResult.hasOverlap)
                          const Text(
                            'Intervals merged',
                            style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    if (summary.exceeds24Hours) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Warning: Total recorded time exceeds 24 hours (1,440 minutes).',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (summary.overlapResult.hasOverlap) ...[
                      const SizedBox(height: 8),
                      ...summary.overlapResult.overlapWarnings.map((warn) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '⚠️ $warn',
                            style: const TextStyle(color: Colors.amber, fontSize: 11),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Helpers Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Yesterday', style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        await provider.copyYesterdayEntries();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied yesterday\'s entries as drafts')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                      label: const Text('Quick Add', style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        final rec = await showDialog<ActivityRecord>(
                          context: context,
                          builder: (ctx) => QuickAddDialog(
                            categories: provider.categories,
                            dateString: provider.selectedDateString,
                          ),
                        );
                        if (rec != null) {
                          provider.addActivityRecord(rec);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Recent Activities Chips
              if (provider.recentUniqueActivities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Recent Activities',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: provider.recentUniqueActivities.map((r) {
                      final cat = provider.categories.firstWhere(
                        (c) => c.id == r.categoryId,
                        orElse: () => provider.categories.first,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(cat.iconData, size: 14, color: cat.color),
                          label: Text('${r.activityName} (${TimeCalculator.formatDuration(r.durationMinutes)})'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AddActivityDialog(
                                preselectedCategory: cat,
                                prefilledName: r.activityName,
                                prefilledDurationMinutes: r.durationMinutes,
                              ),
                            ).then((newRec) {
                              if (newRec is ActivityRecord) {
                                provider.addActivityRecord(newRec);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Account Remaining Time Prompt
              if (summary.remainingMinutes > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${TimeCalculator.formatDuration(summary.remainingMinutes)} unaccounted. Account as Unallocated/Rest?',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final unallocated = provider.categories.firstWhere(
                            (c) => c.name.toLowerCase() == 'unallocated',
                            orElse: () => provider.categories.first,
                          );
                          final now = DateTime.now().toIso8601String();
                          provider.addActivityRecord(ActivityRecord(
                            date: provider.selectedDateString,
                            categoryId: unallocated.id!,
                            categoryNameSnapshot: unallocated.name,
                            activityName: 'Unallocated Time',
                            durationMinutes: summary.remainingMinutes,
                            createdAt: now,
                            updatedAt: now,
                          ));
                        },
                        child: const Text('Account'),
                      ),
                    ],
                  ),
                ),

              // Activity Entries List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recorded Activities (${records.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('Save as Template', style: TextStyle(fontSize: 12)),
                    onPressed: records.isEmpty
                        ? null
                        : () => _showSaveAsTemplateDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (records.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No activities recorded for this day',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Activity'),
                        onPressed: () => _openAddDialog(context, provider),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final cat = provider.categories.firstWhere(
                      (c) => c.id == record.categoryId,
                      orElse: () => ActivityCategory(
                        id: record.categoryId,
                        name: record.categoryNameSnapshot,
                        colorValue: 0xFF2563EB,
                        iconName: 'category',
                        type: CategoryType.productive,
                        createdAt: '',
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cat.color.withValues(alpha: 0.15),
                          child: Icon(cat.iconData, color: cat.color, size: 20),
                        ),
                        title: Text(
                          record.activityName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.categoryNameSnapshot} • ${TimeCalculator.formatDuration(record.durationMinutes)}'
                              '${record.startTime != null && record.endTime != null ? " (${record.startTime} - ${record.endTime})" : ""}',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            if (record.notes != null && record.notes!.isNotEmpty)
                              Text(
                                record.notes!,
                                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              showDialog(
                                context: context,
                                builder: (ctx) => AddActivityDialog(initialRecord: record),
                              ).then((updated) {
                                if (updated is ActivityRecord) {
                                  provider.updateActivityRecord(updated);
                                }
                              });
                            } else if (val == 'duplicate') {
                              provider.duplicateActivityRecord(record);
                            } else if (val == 'split') {
                              showDialog<List<ActivityRecord>>(
                                context: context,
                                builder: (ctx) => SplitActivityDialog(
                                  record: record,
                                  categories: provider.categories,
                                ),
                              ).then((parts) {
                                if (parts != null && parts.isNotEmpty) {
                                  provider.splitRecord(original: record, newParts: parts);
                                }
                              });
                            } else if (val == 'delete') {
                              _confirmDelete(context, record, provider);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                            const PopupMenuItem(value: 'split', child: Text('Split block')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
        onPressed: () => _openAddDialog(context, provider),
      ),
    );
  }

  void _openAddDialog(BuildContext context, DayTrackProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => const AddActivityDialog(),
    ).then((rec) {
      if (rec is ActivityRecord) {
        provider.addActivityRecord(rec);
      }
    });
  }

  void _confirmDelete(BuildContext context, ActivityRecord record, DayTrackProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${record.activityName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              if (record.id != null) {
                provider.deleteActivityRecord(record.id!);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSaveAsTemplateDialog(BuildContext context, DayTrackProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Day as Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Template Name', hintText: 'e.g. Workday Routine'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.saveCurrentDayAsTemplate(nameController.text.trim(), descController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved routine template successfully')),
                );
              }
            },
            child: const Text('Save Template'),
          ),
        ],
      ),
    );
  }
}
