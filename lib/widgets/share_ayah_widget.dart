import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/constants.dart';
import '../core/widgets/tajweed_text.dart';

class ShareAyahWidget extends StatelessWidget {
  final String arabicText;
  final String urduText;
  final String surahName;
  final int ayahNumber;
  final GlobalKey _boundaryKey = GlobalKey();

  ShareAyahWidget({
    super.key,
    required this.arabicText,
    required this.urduText,
    required this.surahName,
    required this.ayahNumber,
  });

  Future<void> _captureAndShare(BuildContext context) async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/quran_ayah_$ayahNumber.png').create();
      await file.writeAsBytes(buffer);

      await Share.shareXFiles([XFile(file.path)], text: 'Surah $surahName • Ayah $ayahNumber');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing text: Surah $surahName Ayah $ayahNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F5257), Color(0xFF0B3C40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Surah $surahName',
                      style: const TextStyle(color: AppConstants.gold, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Ayah $ayahNumber',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                TajweedText(
                  rawText: arabicText,
                  fontSize: 24,
                  defaultColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
                if (urduText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    urduText,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Tajweed Quran & Hadith App',
                  style: TextStyle(color: AppConstants.gold, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _captureAndShare(context),
          icon: const Icon(Icons.image_search),
          label: const Text('Share Ayah Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.gold,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}
