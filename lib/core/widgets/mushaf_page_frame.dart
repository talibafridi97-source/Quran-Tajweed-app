import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mushaf_cover_page.dart';
import 'dart:math' as math;

/// High-Fidelity Traditional Indo-Pak Illuminated Mushaf Page Frame
/// Reproduces the "Taj Company Limited" design standard (549 Pages).
class MushafPageFrame extends StatelessWidget {
  final int pageNumber;
  final int totalPages;
  final String surahNameArabic;
  final String? juzNameArabic;
  final int manzilNumber;
  final bool isRead;
  final ValueChanged<bool?>? onReadChanged;
  final VoidCallback? onTap;
  final bool showControls;
  final List<Widget>? actions;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final Widget child;

  const MushafPageFrame({
    super.key,
    required this.pageNumber,
    this.totalPages = 549,
    required this.surahNameArabic,
    this.juzNameArabic,
    this.manzilNumber = 1,
    this.isRead = false,
    this.onReadChanged,
    this.onTap,
    this.showControls = true,
    this.actions,
    this.onNextPage,
    this.onPreviousPage,
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
    final totalPagesStr = _toArabicDigits(totalPages);
    
    // Page types based on Taj Company Standard
    final bool isCoverPage = pageNumber == 1;
    final bool isSpecialArchPage = pageNumber == 2 || pageNumber == 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8), // Light background to match screenshot
      appBar: showControls
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.bookmark_border, color: Color(0xFF10B981)),
                onPressed: () {},
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'قرآن تلاوت',
                    style: GoogleFonts.notoNastaliqUrdu(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'صفحہ $pageStr از $totalPagesStr',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF10B981), size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double availableHeight = math.max(100.0, constraints.maxHeight - 12);
              double calculatedWidth = math.min(constraints.maxWidth - 8, availableHeight * 0.65);

              return Center(
                child: SizedBox(
                  width: calculatedWidth,
                  height: availableHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 1. High-Fidelity Professional Border Painter
                        CustomPaint(
                          painter: TajCompanyBorderPainter(
                            pageNumber: pageNumber,
                          ),
                          size: Size.infinite,
                        ),

                        // 2. Mushaf Content Area
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isCoverPage ? 20 : (isSpecialArchPage ? 26 : 20),
                            isCoverPage ? 20 : (isSpecialArchPage ? 32 : 18),
                            isCoverPage ? 20 : (isSpecialArchPage ? 26 : 20),
                            isCoverPage ? 20 : (isSpecialArchPage ? 32 : 18),
                          ),
                          child: isCoverPage 
                              ? const MushafCoverPage() 
                              : Column(
                                  children: [
                                    if (!isSpecialArchPage) _buildTraditionalHeader(pageStr),
                                    Expanded(child: ClipRect(child: child)),
                                    if (!isSpecialArchPage) _buildTraditionalFooter(pageStr),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: showControls ? _buildReadButton(context) : null,
    );
  }

  Widget _buildTraditionalHeader(String pageStr) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2C7A9E), width: 2.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _badge('سورة $surahNameArabic'),
          _medallion(pageStr),
          _badge(juzNameArabic ?? 'الجزء'),
        ],
      ),
    );
  }

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFFEADBCE), 
      borderRadius: BorderRadius.circular(4), 
      border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
    ),
    child: Text(t, style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _medallion(String t) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
    alignment: Alignment.center,
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _buildTraditionalFooter(String pageStr) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2C7A9E), width: 2.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('مَنزِل ${_toArabicDigits(manzilNumber)}', style: GoogleFonts.notoNastaliqUrdu(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFF1E6B5C), borderRadius: BorderRadius.circular(4)),
            child: Text('صفحہ $pageStr', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Text('رکوع', style: GoogleFonts.notoNastaliqUrdu(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: const Color(0xFFF7F9F8),
    child: SafeArea(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF10B981)),
              onPressed: onNextPage,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => onReadChanged?.call(!isRead),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isRead ? const Color(0xFF10B981) : Colors.transparent, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isRead ? Icons.check_circle : Icons.radio_button_unchecked, color: isRead ? const Color(0xFF10B981) : Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isRead ? 'یہ صفحہ پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا',
                      style: GoogleFonts.notoNastaliqUrdu(
                        color: isRead ? const Color(0xFF10B981) : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF10B981)),
              onPressed: onPreviousPage,
            ),
          ),
        ],
      ),
    ),
  );
}

class TajCompanyBorderPainter extends CustomPainter {
  final int pageNumber;
  TajCompanyBorderPainter({required this.pageNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bool isSpecial = pageNumber == 2 || pageNumber == 3;

    // 1. Triple Frame System (Outer double teal/blue, middle cream gap, inner gold)
    final Paint outerTeal = Paint()..color = const Color(0xFF007791)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final Paint innerTeal = Paint()..color = const Color(0xFF007791)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final Paint gold = Paint()..color = const Color(0xFFB8860B)..style = PaintingStyle.stroke..strokeWidth = 2.5; // Dark gold
    final Paint creamFill = Paint()..color = const Color(0xFFFDF5E6)..style = PaintingStyle.fill;

    // Fill the space between borders with cream
    canvas.drawRect(rect.deflate(4), creamFill);
    // Overwrite the inner area with white
    canvas.drawRect(rect.deflate(14), Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Draw borders
    canvas.drawRect(rect.deflate(2), outerTeal);
    canvas.drawRect(rect.deflate(6), innerTeal);
    canvas.drawRect(rect.deflate(14), gold);

    if (isSpecial) {
      _drawIlluminatedArch(canvas, size);
    } else if (pageNumber > 1) {
      _drawStandardFloralCorners(canvas, size);
    }
  }

  void _drawIlluminatedArch(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF2C7A9E).withValues(alpha: 0.9)..style = PaintingStyle.fill;
    
    // Draw the massive top arch seen in Fatihah/Baqarah start
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, 60);
    path.quadraticBezierTo(size.width/2, 100, 0, 60);
    path.close();
    canvas.drawPath(path, p);

    // Decorative Floral Nodes (Gold Circles)
    final gp = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill;
    for(double i=0; i<=size.width; i+=40) {
      canvas.drawCircle(Offset(i, 30), 10, gp);
    }
  }

  void _drawStandardFloralCorners(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.8)..style = PaintingStyle.fill;
    double s = 40;
    // Corners
    canvas.drawCircle(const Offset(10, 10), 8, p);
    canvas.drawCircle(Offset(size.width-10, 10), 8, p);
    canvas.drawCircle(Offset(10, size.height-10), 8, p);
    canvas.drawCircle(Offset(size.width-10, size.height-10), 8, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
