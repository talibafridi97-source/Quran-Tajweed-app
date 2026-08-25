import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../models/surah.dart';
import '../../providers/search_provider.dart';
import '../../providers/quran_provider.dart';
import '../surah/surah_detail_screen.dart';

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final quranProvider = context.read<QuranProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Universal Quran Search'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryGreen,
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (val) {
                context.read<SearchProvider>().search(val);
              },
              decoration: InputDecoration(
                hintText: 'Search Arabic with/without Harakat, Surah, or keyword...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.primaryGreen),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Search Suggestions / Chips
          if (_controller.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSearchChip('الحمد', 'Al-Hamd'),
                  _buildSearchChip('الرحمن', 'Ar-Rahman'),
                  _buildSearchChip('الصراط', 'As-Sirat'),
                  _buildSearchChip('الملك', 'Al-Mulk'),
                  _buildSearchChip('Baqarah', 'Al-Baqarah'),
                  _buildSearchChip('Kahf', 'Al-Kahf'),
                  _buildSearchChip('Yasin', 'Ya-Sin'),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Search all 114 Surahs & 6,236 Ayahs',
                    style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Works offline and diacritic-insensitively',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ] else ...[
            // Results Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Results (${searchProvider.results.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppConstants.textPrimaryLight,
                    ),
                  ),
                  if (searchProvider.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryGreen),
                    ),
                ],
              ),
            ),

            // Results List
            Expanded(
              child: searchProvider.results.isEmpty
                  ? Center(
                      child: Text(
                        searchProvider.isLoading ? 'Searching...' : 'No matching Ayahs found.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: searchProvider.results.length,
                      itemBuilder: (context, index) {
                        final res = searchProvider.results[index];
                        return _buildSearchResultCard(context, res, quranProvider);
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchChip(String term, String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Colors.grey[300]!),
      onPressed: () {
        _controller.text = term;
        context.read<SearchProvider>().search(term);
      },
    );
  }

  Widget _buildSearchResultCard(
    BuildContext context,
    QuranSearchResult result,
    QuranProvider quranProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final surahs = quranProvider.surahs;
          final targetSurah = surahs.firstWhere(
            (s) => s.number == result.surahNumber,
            orElse: () => Surah(
              number: result.surahNumber,
              name: result.surahName,
              englishName: result.surahEnglishName,
              englishNameTranslation: '',
              numberOfAyahs: 0,
              revelationType: '',
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailScreen(surah: targetSurah),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${result.surahEnglishName} (${result.surahNumber}:${result.ayahNumber})',
                          style: const TextStyle(
                            color: AppConstants.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    result.surahName,
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Arabic snippet
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  result.canonicalArabic,
                  style: const TextStyle(
                    fontFamily: AppConstants.uthmaniFont,
                    fontSize: 20,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
