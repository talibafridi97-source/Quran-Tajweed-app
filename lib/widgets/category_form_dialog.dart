import 'package:flutter/material.dart';
import '../models/activity_category.dart';

class CategoryFormDialog extends StatefulWidget {
  final ActivityCategory? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetMinutesController;
  late TextEditingController _weightController;

  late CategoryType _type;
  late int _colorValue;
  late String _iconName;
  late bool _countsForScore;

  final List<int> _palette = const [
    0xFF2563EB, // Blue
    0xFF059669, // Emerald
    0xFF7C3AED, // Purple
    0xFFEA580C, // Orange
    0xFF0D9488, // Teal
    0xFFDB2777, // Pink
    0xFFDC2626, // Red
    0xFF475569, // Slate
    0xFFD97706, // Amber
    0xFF0284C7, // Sky
    0xFF64748B, // Grey
    0xFF4F46E5, // Indigo
  ];

  final List<Map<String, dynamic>> _availableIcons = const [
    {'name': 'code', 'icon': Icons.code_rounded},
    {'name': 'menu_book', 'icon': Icons.menu_book_rounded},
    {'name': 'school', 'icon': Icons.school_rounded},
    {'name': 'fitness_center', 'icon': Icons.fitness_center_rounded},
    {'name': 'mosque', 'icon': Icons.mosque_rounded},
    {'name': 'spa', 'icon': Icons.spa_rounded},
    {'name': 'bed', 'icon': Icons.bed_rounded},
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded},
    {'name': 'people', 'icon': Icons.people_alt_rounded},
    {'name': 'weekend', 'icon': Icons.weekend_rounded},
    {'name': 'work', 'icon': Icons.work_rounded},
    {'name': 'computer', 'icon': Icons.computer_rounded},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer_rounded},
    {'name': 'help_outline', 'icon': Icons.help_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _targetMinutesController = TextEditingController(
      text: c?.dailyTargetMinutes != null ? c!.dailyTargetMinutes.toString() : '60',
    );
    _weightController = TextEditingController(
      text: c != null ? c.weight.toString() : '10.0',
    );
    _type = c?.type ?? CategoryType.productive;
    _colorValue = c?.colorValue ?? _palette.first;
    _iconName = c?.iconName ?? 'category';
    _countsForScore = c?.countsForScore ?? (_type == CategoryType.productive);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetMinutesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      widget.category == null ? 'Create Category' : 'Edit Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Deep Work, Language Study',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter a category name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoryType>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: CategoryType.productive,
                      child: Text('Productive (Can be scored)'),
                    ),
                    DropdownMenuItem(
                      value: CategoryType.maintenance,
                      child: Text('Maintenance (Accounting only)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _type = val;
                        if (_type == CategoryType.maintenance) {
                          _countsForScore = false;
                        }
                      });
                    }
                  },
                ),
                if (_type == CategoryType.productive) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Count toward Productivity Score'),
                    subtitle: const Text('Include in daily 100-point score'),
                    value: _countsForScore,
                    onChanged: (val) => setState(() => _countsForScore = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_countsForScore) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _targetMinutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Daily Target (min)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              final n = int.tryParse(val ?? '');
                              if (n == null || n <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Weight (pts)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              final n = double.tryParse(val ?? '');
                              if (n == null || n < 0) return 'Must be >= 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text('Select Color', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _palette.map((c) {
                    final isSelected = _colorValue == c;
                    return GestureDetector(
                      onTap: () => setState(() => _colorValue = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(c).withValues(alpha: 0.8),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Select Icon', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((item) {
                    final isSelected = _iconName == item['name'];
                    return InkWell(
                      onTap: () => setState(() => _iconName = item['name']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(item['icon'] as IconData, size: 22),
                      ),
                    );
                  }).toList(),
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
                        if (_formKey.currentState!.validate()) {
                          final cat = ActivityCategory(
                            id: widget.category?.id,
                            name: _nameController.text.trim(),
                            colorValue: _colorValue,
                            iconName: _iconName,
                            type: _type,
                            dailyTargetMinutes: _type == CategoryType.productive && _countsForScore
                                ? int.tryParse(_targetMinutesController.text.trim())
                                : null,
                            weight: _type == CategoryType.productive && _countsForScore
                                ? double.tryParse(_weightController.text.trim()) ?? 0.0
                                : 0.0,
                            countsForScore: _type == CategoryType.productive && _countsForScore,
                            isArchived: widget.category?.isArchived ?? false,
                            sortOrder: widget.category?.sortOrder ?? 0,
                            createdAt: widget.category?.createdAt ?? DateTime.now().toIso8601String(),
                          );
                          Navigator.pop(context, cat);
                        }
                      },
                      child: const Text('Save Category'),
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
