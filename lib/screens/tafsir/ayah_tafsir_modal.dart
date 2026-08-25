import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../models/ayah.dart';
import '../../models/tafsir_model.dart';
import '../../providers/quran_provider.dart';

class AyahTafsirModal extends StatefulWidget {
  final Ayah ayah;
  const AyahTafsirModal({super.key, required this.ayah});

  static void show(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahTafsirModal(ayah: ayah),
    );
  }

  @override
  State<AyahTafsirModal> createState() => _AyahTafsirModalState();
}

class _AyahTafsirModalState extends State<AyahTafsirModal> {
  String _selectedTafsirId = 'en-tafisr-ibn-kathir';
  late Future<AyahTafsir?> _tafsirFuture;

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  void _loadTafsir() {
    final repo = context.read<QuranProvider>().repository;
    _tafsirFuture = repo.getAyahTafsir(
      surahNumber: widget.ayah.surahNumber ?? 1,
      ayahNumber: widget.ayah.numberInSurah,
      tafsirId: _selectedTafsirId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahName = widget.ayah.surahEnglishName ?? 'Surah';
    final surahAr = widget.ayah.surahName ?? 'سورة';
    final ayahNum = widget.ayah.numberInSurah;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$surahName : $ayahNum',
                            style: const TextStyle(
                              color: AppConstants.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          surahAr,
                          style: const TextStyle(
                            fontFamily: AppConstants.uthmaniFont,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ayah Tafsir & Commentary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tafsir Scholar Selector Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: TafsirEdition.availableEditions.length,
              itemBuilder: (context, index) {
                final edition = TafsirEdition.availableEditions[index];
                final isSelected = edition.id == _selectedTafsirId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(edition.name),
                    selected: isSelected,
                    selectedColor: AppConstants.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTafsirId = edition.id;
                          _loadTafsir();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 24),

          // Content
          Expanded(
            child: FutureBuilder<AyahTafsir?>(
              future: _tafsirFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppConstants.primaryGreen),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'Tafsir commentary unavailable offline.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please check your internet connection to fetch and cache this Tafsir.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _loadTafsir()),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tafsir = snapshot.data!;
                final isUrdu = tafsir.language.toLowerCase() == 'urdu';

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Original Arabic snippet
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFAF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppConstants.gold.withOpacity(0.4)),
                      ),
                      child: Text(
                        widget.ayah.text,
                        style: const TextStyle(
                          fontFamily: AppConstants.uthmaniFont,
                          fontSize: 22,
                          height: 1.9,
                          color: AppConstants.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Author Banner
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppConstants.gold),
                        const SizedBox(width: 6),
                        Text(
                          'Author: ${tafsir.authorName}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tafsir Text Body
                    SelectableText(
                      tafsir.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.7,
                        color: AppConstants.textPrimaryLight,
                      ),
                      textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
