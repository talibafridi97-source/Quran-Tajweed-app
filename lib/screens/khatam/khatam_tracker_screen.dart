import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/khatam_provider.dart';
import '../../models/khatam_model.dart';
import '../../core/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class KhatamTrackerScreen extends StatelessWidget {
  const KhatamTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khatamProvider = context.watch<KhatamProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        title: const Text('Quran Khatam Tracker (ختم القرآن)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: khatamProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen))
          : khatamProvider.plans.isEmpty
              ? _buildEmptyState(context, khatamProvider)
              : _buildPlansList(context, khatamProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(context, khatamProvider),
        icon: const Icon(Icons.add),
        label: const Text('Create Plan'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, KhatamProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories, size: 72, color: AppConstants.primaryGreen),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quran Completion Plan Yet',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a target (e.g. 30 Days or 60 Days) to complete reading the Holy Quran with daily tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPlanDialog(context, provider),
              icon: const Icon(Icons.add_task),
              label: const Text('Start 30-Day Ramadan Khatam'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, KhatamProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.plans.length,
      itemBuilder: (context, index) {
        final plan = provider.plans[index];
        return _buildPlanCard(context, provider, plan);
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, KhatamProvider provider, KhatamPlan plan) {
    const totalPages = 604;
    final dailyTargetPages = (totalPages / plan.totalDays).ceil();
    final daysElapsed = DateTime.now().difference(plan.startDate).inDays + 1;
    final expectedPages = (daysElapsed * dailyTargetPages).clamp(0, totalPages);
    final completedPages = (plan.currentSurah * 5.3).round().clamp(0, totalPages); // Approximate conversion or page tracker
    final remainingPages = totalPages - completedPages;
    final daysRemaining = (plan.totalDays - daysElapsed).clamp(0, plan.totalDays);
    final expectedEndDate = plan.startDate.add(Duration(days: plan.totalDays));
    final progressRatio = (completedPages / totalPages).clamp(0.0, 1.0);

    String statusText;
    Color statusColor;
    if (completedPages >= expectedPages) {
      if (completedPages == expectedPages) {
        statusText = "Today's target completed.";
        statusColor = AppConstants.primaryGreen;
      } else {
        final ahead = completedPages - expectedPages;
        statusText = "You are $ahead pages ahead of schedule!";
        statusColor = AppConstants.primaryGreen;
      }
    } else {
      final behind = expectedPages - completedPages;
      statusText = "$behind pages behind schedule.";
      statusColor = Colors.orange[800]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.title,
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen),
              ),
              Chip(
                label: Text('${(progressRatio * 100).toStringAsFixed(1)}%'),
                backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppConstants.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${plan.totalDays} Days • Starts ${DateFormat('MMM d, yyyy').format(plan.startDate)}',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Dynamic Schedule Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  completedPages >= expectedPages ? Icons.check_circle : Icons.warning_rounded,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 12,
              backgroundColor: AppConstants.primaryGreen.withOpacity(0.12),
              color: AppConstants.primaryGreen,
            ),
          ),

          const SizedBox(height: 16),

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statTile('Daily Target', '$dailyTargetPages pgs'),
              _statTile('Completed', '$completedPages / 604 pgs'),
              _statTile('Remaining', '$remainingPages pgs'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statTile('Days Elapsed', '$daysElapsed d'),
              _statTile('Days Remaining', '$daysRemaining d'),
              _statTile('Target Date', DateFormat('MMM d').format(expectedEndDate)),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Progress Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final nextSurah = (plan.currentSurah + 1).clamp(1, 114);
                  provider.updateProgress(plan, nextSurah, 1);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('+1 Surah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryGreen,
                  side: const BorderSide(color: AppConstants.primaryGreen),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final nextSurah = (plan.currentSurah + 4).clamp(1, 114);
                  provider.updateProgress(plan, nextSurah, 1);
                },
                icon: const Icon(Icons.check),
                label: const Text('Log Today Target'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _showAddPlanDialog(BuildContext context, KhatamProvider provider) {
    final titleController = TextEditingController(text: '30-Day Ramadan Khatam');
    final daysController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Quran Khatam Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                hintText: 'e.g. 30-Day Khatam or 60-Day Plan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Days',
                hintText: 'e.g. 30 or 60',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && daysController.text.isNotEmpty) {
                final days = int.tryParse(daysController.text) ?? 30;
                provider.addPlan(titleController.text, days);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }
}
