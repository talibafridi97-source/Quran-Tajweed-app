import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/constants/constants.dart';
import '../../providers/tasbeeh_provider.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapCounter(TasbeehProvider provider) {
    _animController.reverse().then((_) => _animController.forward());
    provider.increment();
  }

  @override
  Widget build(BuildContext context) {
    final tasbeeh = context.watch<TasbeehProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Digital Tasbeeh (التسبيح)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(tasbeeh.soundEnabled ? Icons.volume_up : Icons.volume_off),
            tooltip: 'Toggle Click Sound',
            onPressed: () => tasbeeh.toggleSound(!tasbeeh.soundEnabled),
          ),
          IconButton(
            icon: Icon(tasbeeh.hapticEnabled ? Icons.vibration : Icons.smartphone),
            tooltip: 'Toggle Haptic Feedback',
            onPressed: () => tasbeeh.toggleHaptic(!tasbeeh.hapticEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Dhikr History & Statistics',
            onPressed: () => _showHistorySheet(context, tasbeeh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Dhikr Selector Dropdown Card
              _buildDhikrSelector(context, tasbeeh),

              const SizedBox(height: 16),

              // Target Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target: ${tasbeeh.targetGoal > 0 ? tasbeeh.targetGoal : "Continuous"}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: scheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  Text(
                    'Completed: ${tasbeeh.completedCycles} cycles (${tasbeeh.counter} / ${tasbeeh.targetGoal})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: scheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: tasbeeh.progress,
                  minHeight: 8,
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  color: AppConstants.gold,
                ),
              ),

              const Spacer(),

              // Arabic Dhikr Callout
              if (tasbeeh.selectedDua.arabic.isNotEmpty) ...[
                Text(
                  tasbeeh.selectedDua.arabic,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.uthmaniFont,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  tasbeeh.selectedDua.transliteration,
                  style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: 0.65)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

              // Large Interactive Circular Counter
              GestureDetector(
                onTap: () => _onTapCounter(tasbeeh),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${tasbeeh.counter}',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Goal: ${tasbeeh.targetGoal}',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onPrimary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TAP TO COUNT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: scheme.onPrimary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Control Buttons: Undo, Reset, Add Custom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Undo (-1)
                  ElevatedButton.icon(
                    onPressed: tasbeeh.counter > 0 ? () => tasbeeh.decrement() : null,
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Undo (-1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: scheme.onSurface,
                      elevation: 0,
                      side: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reset Counter
                  ElevatedButton.icon(
                    onPressed: tasbeeh.counter > 0 ? () => _confirmReset(context, tasbeeh) : null,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Quick Target Selection Chips
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Target Goal:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...[33, 34, 99, 100, 500, 1000].map((goal) {
                      final isSelected = tasbeeh.targetGoal == goal;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text('$goal'),
                          selected: isSelected,
                          selectedColor: scheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? scheme.onPrimary : scheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) tasbeeh.setTargetGoal(goal);
                          },
                        ),
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.edit, size: 16),
                      label: const Text('Custom'),
                      onPressed: () => _showCustomTargetDialog(context, tasbeeh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrSelector(BuildContext context, TasbeehProvider tasbeeh) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DhikrItem>(
                value: tasbeeh.allPresets.firstWhere(
                  (p) => p.title == tasbeeh.selectedDua.title,
                  orElse: () => tasbeeh.allPresets.first,
                ),
                isExpanded: true,
                items: tasbeeh.allPresets.map((p) {
                  return DropdownMenuItem<DhikrItem>(
                    value: p,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (p.arabic.isNotEmpty)
                          Text(
                            p.arabic,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                              fontFamily: AppConstants.uthmaniFont,
                            ),
                            maxLines: 1,
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) tasbeeh.selectDhikr(val);
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: scheme.primary),
            tooltip: 'Add Custom Dhikr',
            onPressed: () => _showAddCustomDhikrDialog(context, tasbeeh),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, TasbeehProvider tasbeeh) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Counter?'),
        content: Text('Your current count of ${tasbeeh.counter} will be safely saved to your Dhikr history logs.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              tasbeeh.reset();
            },
            child: const Text('Save & Reset'),
          ),
        ],
      ),
    );
  }

  void _showCustomTargetDialog(BuildContext context, TasbeehProvider tasbeeh) {
    final controller = TextEditingController(text: '${tasbeeh.targetGoal}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Custom Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter target count (e.g. 500)',
            suffixText: 'counts',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(controller.text.trim());
              if (target != null && target > 0) {
                tasbeeh.setTargetGoal(target);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Target'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDhikrDialog(BuildContext context, TasbeehProvider tasbeeh) {
    final titleController = TextEditingController();
    final arabicController = TextEditingController();
    final transliterationController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Custom Dhikr / Dua'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Dhikr Title *',
                  hintText: 'e.g. Rabbana Atina',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: arabicController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'Arabic Text (Optional)',
                  hintText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: transliterationController,
                decoration: const InputDecoration(
                  labelText: 'Meaning / Transliteration (Optional)',
                  hintText: 'Our Lord, give us in this world good...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Default Target',
                  hintText: '33',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final target = int.tryParse(targetController.text.trim()) ?? 33;
                tasbeeh.addCustomDhikr(
                  title: title,
                  arabic: arabicController.text.trim(),
                  transliteration: transliterationController.text.trim(),
                  target: target,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Dhikr'),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet(BuildContext context, TasbeehProvider tasbeeh) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tasbeeh Logs & History',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      if (tasbeeh.history.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            tasbeeh.clearHistory();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lifetime Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${tasbeeh.totalLifetimeCount}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                            Text('Total Dhikr Counts', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Container(height: 36, width: 1, color: scheme.outline.withValues(alpha: 0.3)),
                        Column(
                          children: [
                            Text(
                              '${tasbeeh.history.length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                            Text('Sessions Logged', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: tasbeeh.history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 48, color: scheme.onSurface.withValues(alpha: 0.3)),
                                const SizedBox(height: 8),
                                Text('No Dhikr history yet', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: tasbeeh.history.length,
                            itemBuilder: (context, index) {
                              final item = tasbeeh.history[index];
                              final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(item.timestamp);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.dhikrName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dateStr,
                                            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.5)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${item.count} / ${item.target}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: scheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
