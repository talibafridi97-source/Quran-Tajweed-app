import 'package:flutter/material.dart';
import '../constants/constants.dart';

class MushafPageFrame extends StatelessWidget {
  final int pageNumber;
  final String title;
  final String surahNameArabic;
  final String? revelationType;
  final int? totalAyahs;
  final int? totalRukus;
  final String? juzNameArabic;
  final bool isRead;
  final ValueChanged<bool?>? onReadChanged;
  final VoidCallback? onBookmarkPressed;
  final Widget child;

  const MushafPageFrame({
    super.key,
    required this.pageNumber,
    this.title = 'قرآن ریڈر',
    required this.surahNameArabic,
    this.revelationType,
    this.totalAyahs,
    this.totalRukus,
    this.juzNameArabic,
    this.isRead = false,
    this.onReadChanged,
    this.onBookmarkPressed,
    required this.child,
  });

  // Convert number to Arabic digits
  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final pageStr = _toArabicDigits(pageNumber);

    return Scaffold(
      backgroundColor: const Color(0xFF0F3D3E), // Dark Teal Header Background matching screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D3E),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'صفحہ $pageNumber از 604',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            onPressed: onBookmarkPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mushaf Page Canvas with Border & Header matching screenshots
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5), // Traditional Mushaf paper background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0288D1), // Cyan/Blue border frame as in screenshots
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Ornate Surah Header Banner (Matching attached screenshots!)
                    _buildTopSurahBanner(context, pageStr),
                    
                    // Main Quran Ayahs Content
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Read Completion Action Bar ("میں نے یہ پڑھ لیا")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isRead,
                  activeColor: AppConstants.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: onReadChanged,
                ),
                GestureDetector(
                  onTap: () {
                    if (onReadChanged != null) {
                      onReadChanged!(!isRead);
                    }
                  },
                  child: const Text(
                    'میں نے یہ پڑھ لیا',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: AppConstants.urduFont,
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

  Widget _buildTopSurahBanner(BuildContext context, String pageStr) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Surah Name Title Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                juzNameArabic ?? '',
                style: const TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  surahNameArabic,
                  style: const TextStyle(
                    fontFamily: AppConstants.uthmaniFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                pageStr,
                style: const TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
            ],
          ),
          
          if (revelationType != null || totalAyahs != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (totalRukus != null)
                  Text(
                    'ركوعاتها $totalRukus',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                if (revelationType != null)
                  Text(
                    revelationType == 'Meccan' ? 'مَكَّيَّةٌ' : 'مَدَنِيَّةٌ',
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (totalAyahs != null)
                  Text(
                    'آياتها $totalAyahs',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
