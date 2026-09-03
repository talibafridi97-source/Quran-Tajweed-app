import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Traditional Indo-Pak Illuminated Mushaf Page Frame
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
    final bool isIlluminated = pageNumber >= 2 && pageNumber <= 3;

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
            color: const Color(0xFF07241C),
            padding: const EdgeInsets.all(4),
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.68, 
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF5), 
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 1. High-Fidelity Floral Border Painter
                      CustomPaint(
                        painter: HighFidelityIndoPakBorderPainter(
                          isIlluminated: isIlluminated,
                        ),
                        size: Size.infinite,
                      ),

                      // 2. Mushaf Content
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isIlluminated ? 22 : 18,
                          isIlluminated ? 26 : 14,
                          isIlluminated ? 22 : 18,
                          isIlluminated ? 26 : 14,
                        ),
                        child: Column(
                          children: [
                            if (!isIlluminated) _buildHeader(pageStr),
                            Expanded(child: child),
                            if (!isIlluminated) _buildFooter(pageStr),
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
      ),
      bottomNavigationBar: showControls ? _buildReadButton(context) : null,
    );
  }

  Widget _buildHeader(String pageStr) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2C7A9E), width: 1.8)),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
    decoration: BoxDecoration(color: const Color(0xFFEADBCE), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD4AF37), width: 1.2)),
    child: Text(t, style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _medallion(String t) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
    alignment: Alignment.center,
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _buildFooter(String pageStr) {
    return Container(
      height: 26,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2C7A9E), width: 1.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('مَنزِل ${_toArabicDigits(manzilNumber)}', style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFF1E6B5C), borderRadius: BorderRadius.circular(4)),
            child: Text('صفحہ $pageStr', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Text('رکوع', style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    color: const Color(0xFF0D3B2E),
    child: SafeArea(child: InkWell(
      onTap: () => onReadChanged?.call(!isRead),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isRead ? const Color(0xFFD4AF37) : const Color(0xFF144738), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD4AF37), width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isRead ? Icons.check_circle : Icons.radio_button_unchecked, color: isRead ? Colors.black87 : Colors.white),
          const SizedBox(width: 12),
          Text(isRead ? 'یہ صفحہ پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا', style: GoogleFonts.notoNastaliqUrdu(color: isRead ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ),
    )),
  );
}

class HighFidelityIndoPakBorderPainter extends CustomPainter {
  final bool isIlluminated;
  HighFidelityIndoPakBorderPainter({required this.isIlluminated});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final Paint gold = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final Paint emerald = Paint()..color = const Color(0xFF1E6B5C)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final Paint blue = Paint()..color = const Color(0xFF2C7A9E)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    canvas.drawRect(rect.deflate(2), gold);
    canvas.drawRect(rect.deflate(8), emerald);
    canvas.drawRect(rect.deflate(14), blue);

    if (isIlluminated) {
      _drawFloralPatterns(canvas, size, true);
    } else {
      _drawFloralPatterns(canvas, size, false);
    }
  }

  void _drawFloralPatterns(Canvas canvas, Size size, bool full) {
    final p = Paint()..color = const Color(0xFF2C7A9E).withValues(alpha: 0.6)..style = PaintingStyle.fill;
    final gp = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.8)..style = PaintingStyle.fill;

    if (full) {
      // Draw simulated floral arch
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 40), p);
      canvas.drawRect(Rect.fromLTWH(0, size.height - 40, size.width, 40), p);
      
      for(double i=0; i<size.width; i+=40) {
        canvas.drawCircle(Offset(i+20, 20), 12, gp);
        canvas.drawCircle(Offset(i+20, size.height-20), 12, gp);
      }
    } else {
      // Draw side ornaments
      for(double i=40; i<size.height-40; i+=60) {
        canvas.drawCircle(Offset(8, i), 3, gp);
        canvas.drawCircle(Offset(size.width-8, i), 3, gp);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
