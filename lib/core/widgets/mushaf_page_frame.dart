import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Professional Traditional Indo-Pak Illuminated Mushaf Page Frame
/// Features high-fidelity floral borders and responsive 16-line container.
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
              elevation: 0,
              centerTitle: true,
              leading: const BackButton(color: Colors.white),
              title: Text(
                'صفحہ $pageNumber از $totalPagesStr',
                style: GoogleFonts.notoNastaliqUrdu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // High-precision responsive scaling with safety math
              double availableHeight = math.max(100.0, constraints.maxHeight - 8);
              double calculatedWidth = math.min(constraints.maxWidth - 8, availableHeight * 0.64);

              return Center(
                child: SizedBox(
                  width: calculatedWidth,
                  height: availableHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF5), 
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 1. High-Fidelity Floral Border Painter
                        CustomPaint(
                          painter: HighFidelityIndoPakBorderPainter(isIlluminated: isIlluminated),
                          size: Size.infinite,
                        ),

                        // 2. Mushaf Content Area
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isIlluminated ? calculatedWidth * 0.12 : calculatedWidth * 0.1,
                            isIlluminated ? availableHeight * 0.12 : availableHeight * 0.05,
                            isIlluminated ? calculatedWidth * 0.12 : calculatedWidth * 0.1,
                            isIlluminated ? availableHeight * 0.12 : availableHeight * 0.05,
                          ),
                          child: Column(
                            children: [
                              if (!isIlluminated) _buildHeader(pageStr),
                              Expanded(child: ClipRect(child: child)), 
                              if (!isIlluminated) _buildFooter(pageStr),
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

  Widget _buildHeader(String pageStr) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2C7A9E), width: 1.5))),
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
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(color: const Color(0xFFEADBCE), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD4AF37), width: 0.8)),
    child: FittedBox(child: Text(t, style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E)))),
  );

  Widget _medallion(String t) => Container(
    width: 26, height: 26,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFD4AF37), width: 1.5)),
    alignment: Alignment.center,
    child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _buildFooter(String pageStr) {
    return Container(
      height: 24,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2C7A9E), width: 1.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('مَنزِل ${_toArabicDigits(manzilNumber)}', style: GoogleFonts.notoNastaliqUrdu(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFF1E6B5C), borderRadius: BorderRadius.circular(4)),
            child: Text('صفحہ $pageStr', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Text('رکوع', style: GoogleFonts.notoNastaliqUrdu(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isRead ? const Color(0xFFD4AF37) : const Color(0xFF144738), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4AF37), width: 1.2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isRead ? Icons.check_circle : Icons.radio_button_unchecked, color: isRead ? Colors.black87 : Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(isRead ? 'یہ صفحہ پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا', style: GoogleFonts.notoNastaliqUrdu(color: isRead ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
    final Paint gold = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 3.0;
    final Paint emerald = Paint()..color = const Color(0xFF1E6B5C)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final Paint blue = Paint()..color = const Color(0xFF2C7A9E)..style = PaintingStyle.stroke..strokeWidth = 1.0;

    canvas.drawRect(rect.deflate(2), gold);
    canvas.drawRect(rect.deflate(7), emerald);
    canvas.drawRect(rect.deflate(12), blue);

    if (isIlluminated) {
      _drawFloralCorners(canvas, size);
    } else {
      _drawStandardVines(canvas, size);
    }
  }

  void _drawFloralCorners(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF2C7A9E).withValues(alpha: 0.6);
    double s = size.width * 0.15;
    canvas.drawRect(Rect.fromLTWH(0, 0, s, 15), p);
    canvas.drawRect(Rect.fromLTWH(0, 0, 15, s), p);
    canvas.drawRect(Rect.fromLTWH(size.width - s, 0, s, 15), p);
    canvas.drawRect(Rect.fromLTWH(size.width - 15, 0, 20, s), p);
  }

  void _drawStandardVines(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 0.5;
    for (double i = 40; i < size.height - 40; i += 50) {
      canvas.drawCircle(Offset(4, i), 1.5, p);
      canvas.drawCircle(Offset(size.width - 4, i), 1.5, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
