import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/khatam_provider.dart';
import '../../core/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class KhatamTrackerScreen extends StatelessWidget {
  const KhatamTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khatamProvider = context.watch<KhatamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khatam Tracker'),
      ),
      body: khatamProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : khatamProvider.plans.isEmpty
              ? _buildEmptyState(context)
              : _buildPlansList(context, khatamProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(context, khatamProvider),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Khatam plans yet',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Create a plan to track your Quran journey.'),
        ],
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, KhatamProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.plans.length,
      itemBuilder: (context, index) {
        final plan = provider.plans[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.1, // Placeholder
                  backgroundColor: Colors.grey[200],
                  color: AppConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target: ${plan.totalDays} Days'),
                    Text('Surah: ${plan.currentSurah}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPlanDialog(BuildContext context, KhatamProvider provider) {
    final titleController = TextEditingController();
    final daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Khatam Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Plan Title (e.g. Ramadan 2026)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Target Days (e.g. 30)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && daysController.text.isNotEmpty) {
                provider.addPlan(titleController.text, int.parse(daysController.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
