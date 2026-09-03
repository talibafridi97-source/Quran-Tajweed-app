import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Traditional Indo-Pak Illuminated Mushaf Page Frame.
/// Features high-fidelity floral borders, page-specific illuminated arches (Page 1-3),
/// and authentic 16-line pagination containers with classical Pakistani calligraphy aesthetics.
class MushafPageFrame extends StatelessWidget {
  final int pageNumber;
  final int totalPages;
  final String title;
  final String surahNameArabic;
  final String? juzNameArabic;
  final int manzilNumber;
  final bool isRead;
  final ValueChanged<bool?>? onReadChanged;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onTap;
  final bool showControls;
  final List<Widget>? actions;
  final Widget child;

  const MushafPageFrame({
    super.key,
    required this.pageNumber,
    this.totalPages = 549,
    this.title = 'قرآن مجید',
    required this.surahNameArabic,
    this.juzNameArabic,
    this.manzilNumber = 1,
    this.isRead = false,
    this.onReadChanged,
    this.onBookmarkPressed,
    this.onTap,
    this.showControls = true,
    this.actions,
    required this.child,
  });

  String _toArabicDigits(int number) {
    const arabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '٩'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final pageStr = _toArabicDigits(pageNumber);
    final totalPagesStr = _toArabicDigits(totalPages);
    final bool isIlluminated = pageNumber >= 2 && pageNumber <= 3; // Fatihah and Baqarah opening

    return Scaffold(
      backgroundColor: const Color(0xFF07241C), 
      appBar: showControls
          ? AppBar(
              backgroundColor: const Color(0xFF0D3B2E),
              elevation: 4,
              centerTitle: true,
              leading: const BackButton(color: Colors.white),
              title: Text(
                'صفحہ $pageNumber از $totalPagesStr',
                style: GoogleFonts.notoNastaliqUrdu(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Stack(
                  children: [
                    // 1. High-Resolution Ornamental Mushaf Border
                    CustomPaint(
                      painter: MushafOrnamentalBorderPainter(
                        isIlluminated: isIlluminated,
                      ),
                      size: Size.infinite,
                    ),

                    // 2. Mushaf Content Area
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isIlluminated ? 24 : 14,
                        isIlluminated ? 28 : 12,
                        isIlluminated ? 24 : 14,
                        isIlluminated ? 28 : 12,
                      ),
                      child: Column(
                        children: [
                          // Top Traditional Header (Only on standard pages)
                          if (!isIlluminated && pageNumber > 1) _buildTraditionalTopBar(pageStr),

                          // 16-Line Text Content
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: child,
                            ),
                          ),

                          // Bottom Traditional Footer (Only on standard pages)
                          if (!isIlluminated && pageNumber > 1) _buildTraditionalFooter(pageStr),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: showControls ? _buildProfessionalBottomBar(context) : null,
    );
  }

  Widget _buildTraditionalTopBar(String pageStr) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerBox('سُورَةُ $surahNameArabic'),
          _pageMedallion(pageStr),
          _headerBox(juzNameArabic ?? 'الجزء'),
        ],
      ),
    );
  }

  Widget _headerBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Urdu',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D3B2E),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _pageMedallion(String pageStr) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFCFAF5),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0D3B2E), width: 0.8),
        ),
        alignment: Alignment.center,
        child: Text(
          pageStr,
          style: const TextStyle(
            fontFamily: AppConstants.uthmaniFont,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B2E),
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTraditionalFooter(String pageStr) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Page number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E6B5C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'صفحہ $pageStr',
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),

          // Center: Manzil Marker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2E6),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'مَنزِل ${_toArabicDigits(manzilNumber)}',
              style: const TextStyle(
                fontFamily: 'Urdu',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A6538),
                height: 1.0,
              ),
            ),
          ),

          // Right: "رکوع" marker
          const Text(
            'رکوع',
            style: TextStyle(
              fontFamily: 'Urdu',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A6538),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0D3B2E),
        border: Border(top: BorderSide(color: Color(0xFF174D3E), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => onReadChanged?.call(!isRead),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isRead ? const Color(0xFFD4AF37) : const Color(0xFF144738),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(isRead ? Icons.check_circle : Icons.radio_button_unchecked, color: isRead ? Colors.black87 : Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isRead ? 'یہ صفحہ پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا',
                      style: GoogleFonts.notoNastaliqUrdu(color: isRead ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MushafOrnamentalBorderPainter extends CustomPainter {
  final bool isIlluminated;

  MushafOrnamentalBorderPainter({required this.isIlluminated});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()..color = const Color(0xFFFCFAF5);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), bgPaint);

    final goldPaintHeavy = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final goldPaintThin = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final greenPaint = Paint()
      ..color = const Color(0xFF0D3B2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw multi-layered traditional borders
    canvas.drawRect(rect.deflate(2), goldPaintHeavy);
    canvas.drawRect(rect.deflate(5), goldPaintThin);
    canvas.drawRect(rect.deflate(7.5), greenPaint);
    canvas.drawRect(rect.deflate(9), goldPaintThin);

    if (isIlluminated) {
      _paintIlluminatedFloral(canvas, size);
    } else {
      _paintStandardIndoPak(canvas, size);
    }
  }

  void _paintIlluminatedFloral(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF2C7A9E).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Corner Ornaments
    double s = 60;
    canvas.drawRect(Rect.fromLTWH(8, 8, s, 10), p);
    canvas.drawRect(Rect.fromLTWH(8, 8, 10, s), p);
    
    canvas.drawRect(Rect.fromLTWH(size.width - 8 - s, 8, s, 10), p);
    canvas.drawRect(Rect.fromLTWH(size.width - 18, 8, 10, s), p);

    canvas.drawRect(Rect.fromLTWH(8, size.height - 18, s, 10), p);
    canvas.drawRect(Rect.fromLTWH(8, size.height - 8 - s, 10, s), p);

    canvas.drawRect(Rect.fromLTWH(size.width - 8 - s, size.height - 18, s, 10), p);
    canvas.drawRect(Rect.fromLTWH(size.width - 18, size.height - 8 - s, 10, s), p);
  }

  void _paintStandardIndoPak(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw small traditional dot patterns along the left and right outer border
    for (double i = 24; i < size.height - 24; i += 24) {
      canvas.drawCircle(Offset(4, i), 1.2, p);
      canvas.drawCircle(Offset(size.width - 4, i), 1.2, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
