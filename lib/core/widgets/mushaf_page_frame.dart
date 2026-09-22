import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Professional Luxury Mushaf Page Frame.
/// Features:
/// - High-fidelity Intricate Floral Borders.
/// - Parchment paper texture effect.
/// - Luxury Gold & Emerald color palette.
/// - Integrated Navigation Controls.
class MushafPageFrame extends StatelessWidget {
  final int pageNumber;
  final int totalPages;
  final String surahNameArabic;
  final String? juzNameArabic;
  final int manzilNumber;
  final bool isRead;
  final ValueChanged<bool?>? onReadChanged;
  final VoidCallback? onTap;
  final VoidCallback? onNextPage; // New parameter
  final VoidCallback? onPreviousPage; // New parameter
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
    this.onNextPage,
    this.onPreviousPage,
    this.showControls = true,
    this.actions,
    required this.child,
  });

  String _toArabicDigits(int number) {
    const arabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '٦', '۷', '۸', '۹'];
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
              double availableHeight = math.max(100.0, constraints.maxHeight - 16);
              double calculatedWidth = math.min(constraints.maxWidth - 12, availableHeight * 0.64);

              return Center(
                child: Hero(
                  tag: 'page_$pageNumber',
                  child: Container(
                    width: calculatedWidth,
                    height: availableHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF5), 
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 1. Intricate Professional Border Painter
                        CustomPaint(
                          painter: LuxuryIndoPakBorderPainter(isIlluminated: isIlluminated),
                          size: Size.infinite,
                        ),

                        // 2. Mushaf Content
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            calculatedWidth * 0.1,
                            availableHeight * 0.04,
                            calculatedWidth * 0.1,
                            availableHeight * 0.04,
                          ),
                          child: Column(
                            children: [
                              if (!isIlluminated) _buildLuxuryHeader(pageStr, context),
                              Expanded(child: ClipRect(child: child)),
                              if (!isIlluminated) _buildLuxuryFooter(pageStr, context),
                            ],
                          ),
                        ),

                        // 3. Navigation Arrows (Professional Overlay)
                        if (showControls) ...[
                          Positioned(
                            left: 4,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildNavArrow(Icons.chevron_left_rounded, onPreviousPage),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildNavArrow(Icons.chevron_right_rounded, onNextPage),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: showControls ? _buildLuxuryBottomBar(context) : null,
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: AppConstants.primaryGreen, size: 28),
        ),
      ),
    );
  }

  Widget _buildLuxuryHeader(String pageStr, BuildContext context) {
    return Container(
      height: 34,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2C7A9E), width: 1.5)),
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFEADBCE), Color(0xFFF7F2E6)]),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFD4AF37), width: 1),
    ),
    child: Text(t, style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))),
  );

  Widget _medallion(String t) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
    ),
    alignment: Alignment.center,
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0D3B2E))),
  );

  Widget _buildLuxuryFooter(String pageStr, BuildContext context) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2C7A9E), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('مَنزِل ${_toArabicDigits(manzilNumber)}', style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E6B5C), Color(0xFF0D3B2E)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('صفحہ $pageStr', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Text('رکوع', style: GoogleFonts.notoNastaliqUrdu(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF7A6538))),
        ],
      ),
    );
  }

  Widget _buildLuxuryBottomBar(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xFF0D3B2E),
      border: Border(top: BorderSide(color: Color(0xFF174D3E), width: 1)),
    ),
    child: SafeArea(
      child: Row(
        children: [
          // 1. Navigation Arrows in Bottom Bar (Backup)
          IconButton(
            onPressed: onPreviousPage,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          ),
          const Spacer(),
          // 2. Main Action Button
          InkWell(
            onTap: () => onReadChanged?.call(!isRead),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRead ? [const Color(0xFFD4AF37), const Color(0xFFC5A059)] : [const Color(0xFF144738), const Color(0xFF0A2E23)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isRead ? Icons.verified_rounded : Icons.radio_button_unchecked, color: isRead ? Colors.black87 : Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    isRead ? 'پڑھ لیا ہے' : 'میں نے یہ پڑھ لیا',
                    style: GoogleFonts.notoNastaliqUrdu(color: isRead ? Colors.black87 : Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 3. Navigation Arrows in Bottom Bar (Backup)
          IconButton(
            onPressed: onNextPage,
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
    ),
  );
}

class LuxuryIndoPakBorderPainter extends CustomPainter {
  final bool isIlluminated;
  LuxuryIndoPakBorderPainter({required this.isIlluminated});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Frames
    final Paint gold = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final Paint emerald = Paint()..color = const Color(0xFF1E6B5C)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final Paint blue = Paint()..color = const Color(0xFF2C7A9E)..style = PaintingStyle.stroke..strokeWidth = 1.0;

    canvas.drawRect(rect.deflate(3), gold);
    canvas.drawRect(rect.deflate(10), emerald);
    canvas.drawRect(rect.deflate(16), blue);

    if (isIlluminated) {
      _drawIntricateFloralArch(canvas, size);
    } else {
      _drawCornerOrnaments(canvas, size);
    }
  }

  void _drawIntricateFloralArch(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF2C7A9E).withValues(alpha: 0.8)..style = PaintingStyle.fill;
    final gp = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill;

    // Artistic top/bottom banner
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 35), p);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 35, size.width, 35), p);

    for (double i = 20; i < size.width; i += 40) {
      canvas.drawCircle(Offset(i, 17), 8, gp);
      canvas.drawCircle(Offset(i, size.height - 17), 8, gp);
    }
  }

  void _drawCornerOrnaments(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.8)..style = PaintingStyle.fill;
    double s = 15;
    
    // Draw classic floral corners
    _drawLeaf(canvas, Offset(s, s), 0, p);
    _drawLeaf(canvas, Offset(size.width - s, s), math.pi / 2, p);
    _drawLeaf(canvas, Offset(s, size.height - s), -math.pi / 2, p);
    _drawLeaf(canvas, Offset(size.width - s, size.height - s), math.pi, p);
  }

  void _drawLeaf(Canvas canvas, Offset center, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    Path path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(10, -10, 20, 0)
      ..quadraticBezierTo(10, 10, 0, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
