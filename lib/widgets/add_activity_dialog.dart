import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';
import '../providers/daytrack_provider.dart';
import '../services/overlap_detector.dart';
import 'category_form_dialog.dart';

class AddActivityDialog extends StatefulWidget {
  final ActivityRecord? initialRecord;
  final ActivityCategory? preselectedCategory;
  final int? prefilledDurationMinutes;
  final String? prefilledName;

  const AddActivityDialog({
    super.key,
    this.initialRecord,
    this.preselectedCategory,
    this.prefilledDurationMinutes,
    this.prefilledName,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();

  ActivityCategory? _selectedCategory;
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _notesController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    final rec = widget.initialRecord;
    _nameController = TextEditingController(text: rec?.activityName ?? widget.prefilledName ?? '');
    
    int initialDuration = rec?.durationMinutes ?? widget.prefilledDurationMinutes ?? 60;
    _hoursController = TextEditingController(text: (initialDuration ~/ 60).toString());
    _minutesController = TextEditingController(text: (initialDuration % 60).toString());
    _notesController = TextEditingController(text: rec?.notes ?? '');

    if (rec?.startTime != null && rec!.startTime!.isNotEmpty) {
      final parts = rec.startTime!.split(':');
      if (parts.length == 2) {
        _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    if (rec?.endTime != null && rec!.endTime!.isNotEmpty) {
      final parts = rec.endTime!.split(':');
      if (parts.length == 2) {
        _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory == null) {
      final provider = context.read<DayTrackProvider>();
      if (widget.initialRecord != null) {
        _selectedCategory = provider.categories.firstWhere(
          (c) => c.id == widget.initialRecord!.categoryId,
          orElse: () => provider.activeCategories.first,
        );
      } else if (widget.preselectedCategory != null) {
        _selectedCategory = widget.preselectedCategory;
      } else if (provider.activeCategories.isNotEmpty) {
        _selectedCategory = provider.activeCategories.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _calculateDurationFromTimes() {
    if (_startTime != null && _endTime != null) {
      final startStr = _formatTimeOfDay(_startTime!);
      final endStr = _formatTimeOfDay(_endTime!);
      final duration = OverlapDetector.calculateDurationMinutes(startStr, endStr);
      setState(() {
        _hoursController.text = (duration ~/ 60).toString();
        _minutesController.text = (duration % 60).toString();
      });
    }
  }

  Future<void> _createNewCategory() async {
    final newCat = await showDialog<ActivityCategory>(
      context: context,
      builder: (ctx) => const CategoryFormDialog(),
    );
    if (newCat != null && mounted) {
      final provider = context.read<DayTrackProvider>();
      final newId = await provider.addCategory(newCat);
      setState(() {
        _selectedCategory = provider.categories.firstWhere((c) => c.id == newId, orElse: () => newCat);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DayTrackProvider>();
    final activeCategories = provider.activeCategories;
    final suggestions = provider.activitySuggestions;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialRecord == null ? 'Add Activity' : 'Edit Activity',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Category Picker with "+ New Category" button
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ActivityCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: activeCategories.map((c) {
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
                        validator: (val) => val == null ? 'Please select category' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      tooltip: 'New Category',
                      onPressed: _createNewCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Activity Name Autocomplete
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _nameController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return suggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    _nameController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Sync controller text
                    controller.addListener(() {
                      _nameController.text = controller.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Activity Name',
                        hintText: 'e.g. Flutter refactor, Surah Al-Kahf',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter activity name';
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Duration (Hours + Minutes)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          final h = int.tryParse(val ?? '0');
                          if (h == null || h < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          final m = int.tryParse(val ?? '0');
                          if (m == null || m < 0 || m >= 60) return '0..59';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Optional Start & End Time
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(_startTime == null ? 'Start Time' : _formatTimeOfDay(_startTime!)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _startTime = picked);
                            _calculateDurationFromTimes();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_filled, size: 18),
                        label: Text(_endTime == null ? 'End Time' : _formatTimeOfDay(_endTime!)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _endTime = picked);
                            _calculateDurationFromTimes();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_startTime != null && _endTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Auto-calculated: ${OverlapDetector.calculateDurationMinutes(_formatTimeOfDay(_startTime!), _formatTimeOfDay(_endTime!))} min (supports midnight-crossing)',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _selectedCategory != null) {
                          final h = int.tryParse(_hoursController.text.trim()) ?? 0;
                          final m = int.tryParse(_minutesController.text.trim()) ?? 0;
                          final totalMins = (h * 60) + m;
                          if (totalMins <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Duration must be greater than 0')),
                            );
                            return;
                          }

                          final now = DateTime.now().toIso8601String();
                          final rec = ActivityRecord(
                            id: widget.initialRecord?.id,
                            date: widget.initialRecord?.date ?? provider.selectedDateString,
                            categoryId: _selectedCategory!.id!,
                            categoryNameSnapshot: _selectedCategory!.name,
                            activityName: _nameController.text.trim(),
                            durationMinutes: totalMins,
                            startTime: _startTime != null ? _formatTimeOfDay(_startTime!) : null,
                            endTime: _endTime != null ? _formatTimeOfDay(_endTime!) : null,
                            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                            status: ActivityStatus.saved,
                            createdAt: widget.initialRecord?.createdAt ?? now,
                            updatedAt: now,
                          );
                          Navigator.pop(context, rec);
                        }
                      },
                      child: Text(widget.initialRecord == null ? 'Add Entry' : 'Update Entry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
