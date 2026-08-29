import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../models/ayah.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/translation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/audio_manager_service.dart';
import '../tafsir/ayah_tafsir_modal.dart';
import '../bookmarks/edit_ayah_note_dialog.dart';

class AyahActionSheet extends StatelessWidget {
  final Ayah ayah;
  const AyahActionSheet({super.key, required this.ayah});

  static void show(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahActionSheet(ayah: ayah),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final translationProvider = context.read<TranslationProvider>();
    final sNum = ayah.surahNumber ?? 1;
    final aNum = ayah.numberInSurah;
    final isSaved = bookmarkProvider.isBookmarked(sNum, aNum);
    final translationText = translationProvider.getTranslationForAyah(aNum);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ayah.surahEnglishName} : $aNum',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                  Text(
                    ayah.surahName ?? 'سورة',
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Actions
            ListTile(
              leading: const Icon(Icons.play_circle_fill_rounded, color: AppConstants.primaryGreen),
              title: const Text('Listen to Ayah', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Play verse audio recitation'),
              onTap: () {
                Navigator.pop(context);
                final settings = context.read<SettingsProvider>();
                AudioManagerService.instance.playAyah(
                  surahNumber: sNum,
                  ayahNumber: aNum,
                  surahName: ayah.surahEnglishName ?? 'Surah',
                  reciterId: settings.qariId,
                  reciterName: settings.qariName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: AppConstants.primaryGreen),
              title: const Text('Read Tafsir & Commentary', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Scholarly explanation and context of revelation'),
              onTap: () {
                Navigator.pop(context);
                AyahTafsirModal.show(context, ayah);
              },
            ),
            ListTile(
              leading: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved ? AppConstants.gold : AppConstants.primaryGreen,
              ),
              title: Text(isSaved ? 'Remove from Bookmarks' : 'Add to Bookmarks', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isSaved ? 'Saved in favorites' : 'Save verse to a category folder'),
              onTap: () async {
                await bookmarkProvider.toggleBookmark(
                  surahNumber: sNum,
                  ayahNumber: aNum,
                  surahName: ayah.surahName ?? 'سورة',
                  surahEnglishName: ayah.surahEnglishName ?? 'Surah',
                  pageNumber: ayah.page,
                  ayahText: ayah.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? 'Bookmark removed' : 'Ayah $aNum saved to Bookmarks'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: AppConstants.primaryGreen),
              title: const Text('Add / Edit Reflection Note', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Save your personal thoughts or lessons on this verse'),
              onTap: () {
                Navigator.pop(context);
                EditAyahNoteDialog.show(context, ayah);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppConstants.primaryGreen),
              title: const Text('Copy Ayah & Translation', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                final formatted = '${ayah.text}\n\n$translationText\n(${ayah.surahEnglishName} $sNum:$aNum)';
                Clipboard.setData(ClipboardData(text: formatted));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayah copied to clipboard'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppConstants.primaryGreen),
              title: const Text('Share Ayah', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                final formatted = '${ayah.text}\n\n$translationText\n— Holy Quran (${ayah.surahEnglishName} $sNum:$aNum)';
                Share.share(formatted);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
