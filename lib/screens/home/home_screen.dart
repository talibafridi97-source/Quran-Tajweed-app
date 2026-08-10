import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
import '../../models/prayer_times_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final prayerTimes = PrayerTimesModel.calculate();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Tajweed Quran & Hadith', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 16),
                  _buildPrayerTimesBanner(context, prayerTimes),
                  const SizedBox(height: 28),
                  const Text(
                    'Explore Quran & Islamic Utility',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildModernGrid(context),
                  const SizedBox(height: 28),
                  _buildDailyVerse(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesBanner(BuildContext context, PrayerTimesModel prayerTimes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled, color: AppConstants.primaryGreen, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next: ${prayerTimes.nextPrayer}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(prayerTimes.hijriDateString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.prayerTimes),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: Text(prayerTimes.nextPrayerTime),
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
        gradient: const LinearGradient(
          colors: [AppConstants.primaryGreen, Color(0xFF006D6D)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.quranPage),
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
                        Text('Last Read Point', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.play_circle_fill, size: 48, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  resume?.surahName ?? 'Surah Al-Fatiha',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  resume != null ? 'Ayah: ${resume.ayahNumber} • Juz: ${resume.juz}' : 'Page 1 • Juz 1',
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
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: [
        _buildModernMenuButton(context, '114 Surahs', Icons.menu_book, AppRoutes.surahList, const Color(0xFFE8F5E9), Colors.green),
        _buildModernMenuButton(context, '30 Paras / Juz', Icons.auto_awesome_motion, AppRoutes.juzList, const Color(0xFFE3F2FD), Colors.blue),
        _buildModernMenuButton(context, 'Quran Pages', Icons.auto_stories_rounded, AppRoutes.quranPage, const Color(0xFFFFF8E1), Colors.amber.shade800),
        _buildModernMenuButton(context, 'Hadith Books', Icons.library_books_rounded, AppRoutes.hadithBooks, const Color(0xFFF3E5F5), Colors.purple),
        _buildModernMenuButton(context, 'Masnoon Duain', Icons.volunteer_activism_rounded, AppRoutes.duas, const Color(0xFFFFF3E0), Colors.orange),
        _buildModernMenuButton(context, '6 Kalmas', Icons.format_quote_rounded, AppRoutes.kalmas, const Color(0xFFE0F2F1), Colors.teal),
        _buildModernMenuButton(context, '99 Names of Allah', Icons.star_rounded, AppRoutes.allahNames, const Color(0xFFFCE4EC), Colors.pink),
        _buildModernMenuButton(context, 'Qibla Finder', Icons.explore_rounded, AppRoutes.qibla, const Color(0xFFE8EAF6), Colors.indigo),
        _buildModernMenuButton(context, 'Prayer Times', Icons.access_alarm_rounded, AppRoutes.prayerTimes, const Color(0xFFE0F7FA), Colors.cyan.shade800),
        _buildModernMenuButton(context, 'Digital Tasbeeh', Icons.touch_app_rounded, AppRoutes.tasbeeh, const Color(0xFFF1F8E9), Colors.lightGreen.shade800),
        _buildModernMenuButton(context, 'Islamic Calendar', Icons.calendar_month_rounded, AppRoutes.calendar, const Color(0xFFFFFDE7), Colors.amber.shade900),
      ],
    );
  }

  Widget _buildModernMenuButton(BuildContext context, String title, IconData icon, String route, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
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
          const Text('Ayah of the Day', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          const Text(
            '\"إِنَّ مَعَ الْعُسْرِ يُسْرًا\"',
            style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 24, fontWeight: FontWeight.bold),
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
