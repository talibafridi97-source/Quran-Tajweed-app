import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.title = 'Quran Reader',
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
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppConstants.primaryGreen),
        title: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: AppConstants.primaryGreen,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Page $pageNumber of 604',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: AppConstants.primaryGreen),
            onPressed: onBookmarkPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModernTopBanner(context, pageStr),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildCompletionBar(context),
        ],
      ),
    );
  }

  Widget _buildModernTopBanner(BuildContext context, String pageStr) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            juzNameArabic ?? '',
            style: const TextStyle(
              fontFamily: AppConstants.uthmaniFont,
              fontSize: 16,
              color: AppConstants.primaryGreen,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              surahNameArabic,
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            pageStr,
            style: const TextStyle(
              fontFamily: AppConstants.uthmaniFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onReadChanged?.call(!isRead),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isRead ? AppConstants.primaryGreen : AppConstants.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isRead ? Icons.check_circle : Icons.circle_outlined,
                    color: isRead ? Colors.white : AppConstants.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'I have read this page',
                    style: GoogleFonts.plusJakartaSans(
                      color: isRead ? Colors.white : AppConstants.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
