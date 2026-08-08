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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Tajweed Quran', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppConstants.primaryGreen, Color(0xFF006D6D)],
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.castle, size: 200, color: Colors.white10),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernResumeCard(context, quranProvider),
                  const SizedBox(height: 30),
                  const Text(
                    'Explore Quran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildModernGrid(context),
                  const SizedBox(height: 30),
                  _buildDailyVerse(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernResumeCard(BuildContext context, QuranProvider provider) {
    final resume = provider.resumeData;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          colors: [AppConstants.primaryGreen, AppConstants.primaryGreen.withOpacity(0.8)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.surahList),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Continue Reading', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Last Read', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.play_circle_fill, size: 48, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  resume?.surahName ?? 'Surah Al-Fatiha',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  resume != null ? 'Ayah: ${resume.ayahNumber} • Juz: ${resume.juz}' : 'Ayah: 1 • Page: 1',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildModernMenuButton(context, 'Surah Index', Icons.menu_book, AppRoutes.surahList, const Color(0xFFE8F5E9), Colors.green),
        _buildModernMenuButton(context, 'Juz Index', Icons.auto_awesome_motion, AppRoutes.juzList, const Color(0xFFE3F2FD), Colors.blue),
        _buildModernMenuButton(context, 'Bookmarks', Icons.collections_bookmark, AppRoutes.surahList, const Color(0xFFFFF3E0), Colors.orange),
        _buildModernMenuButton(context, 'Settings', Icons.tune, AppRoutes.settings, const Color(0xFFF3E5F5), Colors.purple),
      ],
    );
  }

  Widget _buildModernMenuButton(BuildContext context, String title, IconData icon, String route, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyVerse(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Verse', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          const Text(
            '\"Indeed, with hardship [will be] ease.\"',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Surah Ash-Sharh 94:6',
            style: TextStyle(color: AppConstants.primaryGreen.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
