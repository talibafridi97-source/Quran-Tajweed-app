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
    this.title = 'قرآن مجید',
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
    const arabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final pageStr = _toArabicDigits(pageNumber);

    return Scaffold(
      backgroundColor: const Color(0xFF144747), // Deep Islamic Green background for reader
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3838),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'صفحہ $pageNumber از ۶۰۴',
          style: GoogleFonts.notoNastaliqUrdu(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isRead ? Icons.bookmark_added : Icons.bookmark_border_rounded,
              color: isRead ? AppConstants.gold : Colors.white,
            ),
            onPressed: onBookmarkPressed,
            tooltip: 'Go to Page / Bookmark',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF5), // Authentic Warm Ivory Parchment
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2C7A9E), // Turquoise Blue Outer Border
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC9A227), // Gold Accent Inset Border
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Mushaf Header (Surah Name, Page Medallion, Juz Name)
                          _buildAuthenticTopHeader(pageStr),

                          // Inner Content Area with Margin Pillar Lines
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                            child: child,
                          ),

                          // Bottom Ornamental Border Footer
                          _buildPageFooter(pageStr),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildCompletionBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticTopHeader(String pageStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F1E5),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2C7A9E), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right: Juz / Para Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8DCC2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFC9A227), width: 1),
            ),
            child: Text(
              juzNameArabic ?? 'الجزء',
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144747),
              ),
            ),
          ),

          // Center: Ornamental Page Medallion
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFCFAF5),
              border: Border.all(color: const Color(0xFF2C7A9E), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A227).withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              pageStr,
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144747),
              ),
            ),
          ),

          // Left: Surah Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8DCC2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFC9A227), width: 1),
            ),
            child: Text(
              surahNameArabic,
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144747),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(String pageStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F1E5),
        border: Border(
          top: BorderSide(color: Color(0xFF2C7A9E), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'منزل',
            style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, color: const Color(0xFF8A7342)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2C7A9E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'صفحہ $pageStr',
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'رکوع',
            style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, color: const Color(0xFF8A7342)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F3838),
        border: Border(top: BorderSide(color: Color(0xFF1D5C5C), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => onReadChanged?.call(!isRead),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFC9A227) : const Color(0xFF1A5959),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC9A227), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRead ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isRead ? Colors.black87 : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRead ? 'یہ صفحہ پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا',
                    style: GoogleFonts.notoNastaliqUrdu(
                      color: isRead ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
