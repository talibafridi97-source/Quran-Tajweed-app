import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/surah.dart';
import '../../models/ayah.dart';
import '../../models/translation_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/translation_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../core/widgets/quran_audio_player_widget.dart';
import '../tafsir/ayah_tafsir_modal.dart';
import '../bookmarks/edit_ayah_note_dialog.dart';
import 'ayah_action_sheet.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayah>> _ayahsFuture;
  bool _showAudioPlayer = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranslationProvider>().loadTranslationsForSurah(widget.surah.number);
    });
  }

  void _loadSurahData() {
    final repository = context.read<QuranProvider>().repository;
    _ayahsFuture = repository.getSurahTajweed(widget.surah.number);
  }

  void _showTranslationSelectorDialog() {
    final transProvider = context.read<TranslationProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Select Translation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: TranslationEdition.availableEditions.map((edition) {
              final isSelected = edition.id == transProvider.selectedEditionId;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: isSelected,
                selectedTileColor: AppConstants.primaryGreen.withOpacity(0.1),
                leading: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? AppConstants.primaryGreen : Colors.grey,
                ),
                title: Text(edition.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(edition.author, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  transProvider.setEdition(edition.id, activeSurahNumber: widget.surah.number);
                  Navigator.pop(context);
                  setState(() => _showTranslation = true);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final transProvider = context.watch<TranslationProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          IconButton(
            tooltip: 'Choose Translation',
            onPressed: _showTranslationSelectorDialog,
            icon: const Icon(Icons.translate_rounded),
          ),
          IconButton(
            tooltip: 'View Mode',
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
            icon: Icon(_showTranslation ? Icons.view_agenda_rounded : Icons.menu_book_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final ayahs = snapshot.data ?? [];

          List<Ayah> processedAyahs = ayahs;
          if (widget.surah.number != 1 && ayahs.isNotEmpty) {
            final first = ayahs.first;
            if (first.text.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
              final cleanText = first.text.replaceFirst(RegExp(r'^بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\s*'), '');
              if (cleanText.isNotEmpty) {
                processedAyahs = [
                  Ayah(
                    number: first.number,
                    text: cleanText,
                    numberInSurah: first.numberInSurah,
                    juz: first.juz,
                    manzil: first.manzil,
                    page: first.page,
                    ruku: first.ruku,
                    hizbQuarter: first.hizbQuarter,
                    sajda: first.sajda,
                    surahNumber: first.surahNumber,
                    surahName: first.surahName,
                    surahEnglishName: first.surahEnglishName,
                  ),
                  ...ayahs.skip(1),
                ];
              }
            }
          }

          return LoadingErrorWidget(
            isLoading: isLoading,
            errorMessage: hasError ? snapshot.error.toString() : null,
            onRetry: () => setState(() => _loadSurahData()),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSurahHeader(),
                      const SizedBox(height: 16),
                      if (_showAudioPlayer) ...[
                        QuranAudioPlayerWidget(
                          surahNumber: widget.surah.number,
                          surahName: widget.surah.englishName,
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_showTranslation) ...[
                        // Ayah by Ayah Translation Mode
                        ...processedAyahs.map((a) {
                          final transText = transProvider.getTranslationForAyah(a.numberInSurah);
                          final isBookmarked = bookmarkProvider.isBookmarked(
                            widget.surah.number,
                            a.numberInSurah,
                          );

                          return _buildAyahTranslationCard(
                            context,
                            a,
                            transText,
                            isBookmarked,
                            bookmarkProvider,
                            settings,
                          );
                        }),
                      ] else ...[
                        // Continuous Tajweed Reading Mode
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFAF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C7A9E), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFC9A227), width: 1),
                            ),
                            child: TajweedText(
                              ayahs: processedAyahs,
                              fontSize: settings.arabicFontSize,
                              fontFamily: AppConstants.uthmaniFont,
                              showTajweed: settings.showTajweed,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                _buildModernActionButtons(transProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAyahTranslationCard(
    BuildContext context,
    Ayah ayah,
    String translationText,
    bool isBookmarked,
    BookmarkProvider bookmarkProvider,
    SettingsProvider settings,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: const TextStyle(
                        color: AppConstants.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Tafsir Button
                    IconButton(
                      icon: const Icon(Icons.menu_book_outlined, size: 20, color: AppConstants.primaryGreen),
                      tooltip: 'Ayah Tafsir',
                      onPressed: () => AyahTafsirModal.show(context, ayah),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    // Note Button
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, size: 22, color: AppConstants.primaryGreen),
                      tooltip: 'Ayah Reflection Note',
                      onPressed: () => EditAyahNoteDialog.show(context, ayah),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isBookmarked ? AppConstants.gold : Colors.grey[600],
                      ),
                      tooltip: 'Bookmark',
                      onPressed: () {
                        bookmarkProvider.toggleBookmark(
                          surahNumber: widget.surah.number,
                          ayahNumber: ayah.numberInSurah,
                          surahName: widget.surah.name,
                          surahEnglishName: widget.surah.englishName,
                          pageNumber: ayah.page,
                          ayahText: ayah.text,
                        );
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    // More Actions
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                      tooltip: 'More Actions',
                      onPressed: () => AyahActionSheet.show(context, ayah),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arabic Verse Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.text,
                style: TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: settings.arabicFontSize,
                  height: 2.0,
                  color: AppConstants.textPrimaryLight,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // Translation Body
          if (translationText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                translationText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.surah.name,
            style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 38, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} Ayahs',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (widget.surah.number != 1 && widget.surah.number != 9) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 24),
            const Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 26, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernActionButtons(TranslationProvider transProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showAudioPlayer = !_showAudioPlayer;
              });
            },
            child: _actionItem(Icons.play_circle_fill, _showAudioPlayer ? 'Hide Audio' : 'Listen', AppConstants.softBlue),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
            child: _actionItem(
              _showTranslation ? Icons.menu_book_rounded : Icons.translate_rounded,
              _showTranslation ? 'Arabic View' : 'Translation',
              AppConstants.softPurple,
            ),
          ),
          InkWell(
            onTap: () {
              Share.share('Surah ${widget.surah.englishName} (${widget.surah.name}) — Holy Quran');
            },
            child: _actionItem(Icons.share_rounded, 'Share', AppConstants.vibrantOrange),
          ),
          InkWell(
            onTap: _showTranslationSelectorDialog,
            child: _actionItem(Icons.language_rounded, 'Editions', AppConstants.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600])),
      ],
    );
  }
}
