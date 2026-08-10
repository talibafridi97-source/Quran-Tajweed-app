import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryGreen.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: 24),
                    _buildModernResumeCard(context, quranProvider),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Holy Quran'),
                    const SizedBox(height: 16),
                    _buildQuranGrid(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Islamic Tools'),
                    const SizedBox(height: 16),
                    _buildToolsGrid(context),
                    const SizedBox(height: 32),
                    _buildDailyInspiration(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      collapsedHeight: 70,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Tajweed Quran',
          style: GoogleFonts.plusJakartaSans(
            color: AppConstants.primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assalamu Alaikum,',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Talib Afridi', // Dynamic name can be added later
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppConstants.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildModernResumeCard(BuildContext context, QuranProvider provider) {
    final resume = provider.resumeData;
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              Icons.auto_stories,
              size: 200,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Last Read',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume?.surahName ?? 'Surah Al-Fatiha',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resume != null
                          ? 'Ayah: ${resume.ayahNumber} • Juz: ${resume.juz}'
                          : 'Page 1 • Juz 1',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.quranPage),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Continue Reading',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppConstants.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppConstants.textPrimaryLight,
          ),
        ),
        Text(
          'See all',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppConstants.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildQuranGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildColorfulCard(
          context,
          '114 Surahs',
          'Read by Surah',
          Icons.format_list_numbered_rtl,
          AppConstants.softBlue,
          AppRoutes.surahList,
        ),
        _buildColorfulCard(
          context,
          '30 Paras',
          'Read by Juz',
          Icons.grid_view_rounded,
          AppConstants.softPurple,
          AppRoutes.juzList,
        ),
        _buildColorfulCard(
          context,
          'Pages',
          'Read by Page',
          Icons.auto_stories_rounded,
          AppConstants.softPink,
          AppRoutes.quranPage,
        ),
        _buildColorfulCard(
          context,
          'Audio',
          'Listen Quran',
          Icons.headset_mic_rounded,
          AppConstants.softOrange,
          AppRoutes.surahList,
        ),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildToolIcon(context, 'Prayer', Icons.access_time_filled, AppConstants.softTeal, AppRoutes.settings),
        _buildToolIcon(context, 'Qibla', Icons.explore, AppConstants.softIndigo, AppRoutes.settings),
        _buildToolIcon(context, 'Tasbeeh', Icons.vibration, AppConstants.vibrantOrange, AppRoutes.settings),
        _buildToolIcon(context, 'Hadith', Icons.library_books, AppConstants.softBlue, AppRoutes.hadithBooks),
        _buildToolIcon(context, 'Duas', Icons.front_hand, AppConstants.gold, AppRoutes.settings),
        _buildToolIcon(context, 'Names', Icons.stars, AppConstants.softPurple, AppRoutes.settings),
      ],
    );
  }

  Widget _buildColorfulCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, String route) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolIcon(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConstants.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyInspiration(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppConstants.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\"The best among you are those who learn the Quran and teach it.\"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppConstants.textPrimaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— Prophet Muhammad (PBUH)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppConstants.primaryGreen.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
