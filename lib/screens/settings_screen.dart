import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daytrack_provider.dart';
import '../providers/settings_provider.dart';
import '../models/activity_category.dart';
import '../services/time_calculator.dart';
import '../widgets/category_form_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = provider.categories;
    final activeScored = categories.where((c) => c.countsForScore && !c.isArchived).toList();
    final totalWeight = activeScored.fold(0.0, (acc, c) => acc + c.weight);
    final isWeightValid = (totalWeight - 100.0).abs() <= 0.01;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DayTrack 24 Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(settingsProvider.isDarkMode ? 'Dark theme active' : 'Light theme active'),
                  secondary: Icon(
                    settingsProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  value: settingsProvider.isDarkMode,
                  onChanged: (val) {
                    settingsProvider.toggleDarkMode(val);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Productivity Weights Header & Auto-balance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isWeightValid
                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                      : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isWeightValid ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Productivity Weights: ${totalWeight.toStringAsFixed(1)} / 100 pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isWeightValid ? (isDark ? Colors.white : Colors.green[900]) : Colors.red,
                          ),
                        ),
                        if (!isWeightValid)
                          FilledButton.tonal(
                            onPressed: () {
                              provider.saveAutoBalancedWeights();
                            },
                            child: const Text('Auto-balance to 100'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWeightValid
                          ? 'Total weight perfectly equals 100 points.'
                          : 'Warning: Weights of scored categories must total 100 points for valid scoring.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isWeightValid
                            ? (isDark ? Colors.green[200] : Colors.green[800])
                            : (isDark ? Colors.red[200] : Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Management
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories & Goals',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Category'),
                    onPressed: () => _openCategoryDialog(context, provider, null),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...categories.map((cat) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color.withValues(alpha: 0.15),
                      child: Icon(cat.iconData, color: cat.color, size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: cat.isArchived ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (cat.isArchived)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text('(Archived)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      cat.countsForScore
                          ? 'Target: ${TimeCalculator.formatDuration(cat.dailyTargetMinutes ?? 0)} • Weight: ${cat.weight.toStringAsFixed(0)} pts'
                          : 'Maintenance (Accounting only)',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          _openCategoryDialog(context, provider, cat);
                        } else if (val == 'archive') {
                          provider.archiveCategory(cat.id!, !cat.isArchived);
                        } else if (val == 'delete') {
                          _confirmDeleteCategory(context, cat, provider);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'archive',
                          child: Text(cat.isArchived ? 'Unarchive' : 'Archive'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete / Safe Archive', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Routine Templates Management
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Routine Templates',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${provider.templates.length} saved',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.templates.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No routine templates saved yet. You can build a day and tap "Save as Template" on the record screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                )
              else
                ...provider.templates.map((tpl) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.playlist_play_rounded),
                      ),
                      title: Text(tpl.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${tpl.items.length} activities • ${tpl.description.isNotEmpty ? tpl.description : "No description"}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.green),
                            tooltip: 'Apply to Selected Day',
                            onPressed: () async {
                              await provider.applyTemplate(tpl);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Applied "${tpl.name}" as drafts to ${provider.selectedDateString}')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            tooltip: 'Delete Template',
                            onPressed: () {
                              if (tpl.id != null) {
                                provider.deleteTemplate(tpl.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategoryDialog(BuildContext context, DayTrackProvider provider, ActivityCategory? category) {
    showDialog<ActivityCategory>(
      context: context,
      builder: (ctx) => CategoryFormDialog(category: category),
    ).then((cat) {
      if (cat != null) {
        if (category == null) {
          provider.addCategory(cat);
        } else {
          provider.updateCategory(cat);
        }
      }
    });
  }

  void _confirmDeleteCategory(BuildContext context, ActivityCategory category, DayTrackProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${category.name}"?'),
        content: const Text(
          'If this category has past recorded activities, it will be safely ARCHIVED so historical data remains accurate and untouched.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteCategory(category.id!);
            },
            child: const Text('Delete / Archive'),
          ),
        ],
      ),
    );
  }
}
