import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(25),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildResumeCard(context, quranProvider),
            const SizedBox(height: 20),
            _buildGridMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, QuranProvider provider) {
    final resume = provider.resumeData;
    return Card(
      color: AppConstants.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bookmark, color: Colors.white),
                SizedBox(width: 8),
                Text('Last Read', style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              resume?.surahName ?? 'Start Reading',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              resume != null ? 'Ayah No: ${resume.ayahNumber}' : 'Tap to explore the Quran',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.surahList);
              },
              child: const Text('Continue Reading'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMenuButton(context, 'Surah Index', Icons.list, AppRoutes.surahList),
        _buildMenuButton(context, 'Juz Index', Icons.grid_view, AppRoutes.juzList),
        _buildMenuButton(context, 'Bookmarks', Icons.bookmark_border, AppRoutes.surahList),
        _buildMenuButton(context, 'Settings', Icons.settings_outlined, AppRoutes.settings),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, String route) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppConstants.primaryGreen),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
