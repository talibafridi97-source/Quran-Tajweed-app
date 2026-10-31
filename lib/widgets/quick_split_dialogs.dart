import 'package:flutter/material.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';

class QuickAddDialog extends StatefulWidget {
  final List<ActivityCategory> categories;
  final String dateString;

  const QuickAddDialog({
    super.key,
    required this.categories,
    required this.dateString,
  });

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  ActivityCategory? _selectedCategory;
  final TextEditingController _minutesController = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    final active = widget.categories.where((c) => !c.isArchived).toList();
    if (active.isNotEmpty) {
      _selectedCategory = active.first;
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.categories.where((c) => !c.isArchived).toList();

    return AlertDialog(
      title: const Text('Quick Add Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ActivityCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            items: active.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Row(
                  children: [
                    Icon(c.iconData, color: c.color, size: 18),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [15, 30, 45, 60, 90, 120].map((m) {
              return ActionChip(
                label: Text('${m}m'),
                onPressed: () => setState(() => _minutesController.text = m.toString()),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final mins = int.tryParse(_minutesController.text.trim()) ?? 0;
            if (_selectedCategory != null && mins > 0) {
              final now = DateTime.now().toIso8601String();
              final rec = ActivityRecord(
                date: widget.dateString,
                categoryId: _selectedCategory!.id!,
                categoryNameSnapshot: _selectedCategory!.name,
                activityName: _selectedCategory!.name,
                durationMinutes: mins,
                createdAt: now,
                updatedAt: now,
              );
              Navigator.pop(context, rec);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class SplitActivityDialog extends StatefulWidget {
  final ActivityRecord record;
  final List<ActivityCategory> categories;

  const SplitActivityDialog({
    super.key,
    required this.record,
    required this.categories,
  });

  @override
  State<SplitActivityDialog> createState() => _SplitActivityDialogState();
}

class _SplitActivityDialogState extends State<SplitActivityDialog> {
  late List<_SplitItem> _splits;

  @override
  void initState() {
    super.initState();
    final active = widget.categories.where((c) => !c.isArchived).toList();
    final half = widget.record.durationMinutes ~/ 2;
    final otherHalf = widget.record.durationMinutes - half;

    _splits = [
      _SplitItem(
        category: widget.categories.firstWhere((c) => c.id == widget.record.categoryId, orElse: () => active.first),
        name: widget.record.activityName,
        minutes: half,
      ),
      _SplitItem(
        category: active.length > 1 ? active[1] : active.first,
        name: 'Part 2',
        minutes: otherHalf,
      ),
    ];
  }

  int get _totalSplitMinutes => _splits.fold(0, (sum, item) => sum + item.minutes);

  @override
  Widget build(BuildContext context) {
    final active = widget.categories.where((c) => !c.isArchived).toList();
    final remaining = widget.record.durationMinutes - _totalSplitMinutes;

    return AlertDialog(
      title: Text('Split "${widget.record.activityName}" (${widget.record.durationMinutes}m)'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._splits.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<ActivityCategory>(
                          value: item.category,
                          decoration: InputDecoration(
                            labelText: 'Cat ${idx + 1}',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: active.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (cat) {
                            if (cat != null) {
                              setState(() => item.category = cat);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: item.minutes.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (val) {
                            item.minutes = int.tryParse(val) ?? 0;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Total: $_totalSplitMinutes / ${widget.record.durationMinutes} min (${remaining == 0 ? "Balanced" : "$remaining min remaining"})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remaining == 0 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: remaining == 0
              ? () {
                  final now = DateTime.now().toIso8601String();
                  final List<ActivityRecord> results = _splits.map((s) {
                    return ActivityRecord(
                      date: widget.record.date,
                      categoryId: s.category.id!,
                      categoryNameSnapshot: s.category.name,
                      activityName: s.name.isEmpty ? s.category.name : s.name,
                      durationMinutes: s.minutes,
                      createdAt: now,
                      updatedAt: now,
                    );
                  }).toList();
                  Navigator.pop(context, results);
                }
              : null,
          child: const Text('Apply Split'),
        ),
      ],
    );
  }
}

class _SplitItem {
  ActivityCategory category;
  String name;
  int minutes;

  _SplitItem({
    required this.category,
    required this.name,
    required this.minutes,
  });
}
