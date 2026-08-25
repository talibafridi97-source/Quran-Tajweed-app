import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../models/surah.dart';
import '../../models/bookmark_item_model.dart';
import '../../models/ayah_note_model.dart';
import '../../models/ayah.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/quran_provider.dart';
import '../surah/surah_detail_screen.dart';
import 'create_folder_dialog.dart';
import 'edit_ayah_note_dialog.dart';

class BookmarksNotesHubScreen extends StatefulWidget {
  const BookmarksNotesHubScreen({super.key});

  @override
  State<BookmarksNotesHubScreen> createState() => _BookmarksNotesHubScreenState();
}

class _BookmarksNotesHubScreenState extends State<BookmarksNotesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Saved & Personal Notes'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryGreen,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: AppConstants.primaryGreen,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.bookmarks_rounded, size: 20), text: 'Bookmarks'),
            Tab(icon: Icon(Icons.edit_note_rounded, size: 22), text: 'Ayah Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategorizedBookmarksTab(),
          _AyahNotesTab(),
        ],
      ),
    );
  }
}

class _CategorizedBookmarksTab extends StatelessWidget {
  const _CategorizedBookmarksTab();

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final quranProvider = context.read<QuranProvider>();
    final folders = bookmarkProvider.folders;
    final bookmarks = bookmarkProvider.bookmarks;

    return Column(
      children: [
        // Folders Filter Chips Bar
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // All Chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: bookmarkProvider.selectedFolderId == null,
                  selectedColor: AppConstants.primaryGreen,
                  labelStyle: TextStyle(
                    color: bookmarkProvider.selectedFolderId == null ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => bookmarkProvider.filterByFolder(null),
                ),
              ),

              // Folder Chips
              ...folders.map((f) {
                final isSelected = bookmarkProvider.selectedFolderId == f.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: CircleAvatar(radius: 6, backgroundColor: Color(f.colorValue)),
                    label: Text(f.name),
                    selected: isSelected,
                    selectedColor: AppConstants.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => bookmarkProvider.filterByFolder(f.id),
                  ),
                );
              }),

              // Add Folder Button
              ActionChip(
                avatar: const Icon(Icons.add, size: 16, color: AppConstants.primaryGreen),
                label: const Text('New Folder'),
                onPressed: () => CreateFolderDialog.show(context),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Bookmarks List
        Expanded(
          child: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border_rounded, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No bookmarks in this folder', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Tap the bookmark icon on any Ayah to save it here', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = bookmarks[index];
                    return _buildBookmarkCard(context, item, bookmarkProvider, quranProvider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    BookmarkItem item,
    BookmarkProvider provider,
    QuranProvider quranProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          final surahs = quranProvider.surahs;
          final targetSurah = surahs.firstWhere(
            (s) => s.number == item.surahNumber,
            orElse: () => Surah(
              number: item.surahNumber,
              name: item.surahName,
              englishName: item.surahEnglishName,
              englishNameTranslation: '',
              numberOfAyahs: 0,
              revelationType: '',
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailScreen(surah: targetSurah),
            ),
          );
        },
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${item.ayahNumber}',
              style: const TextStyle(
                color: AppConstants.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          '${item.surahEnglishName} (${item.surahNumber}:${item.ayahNumber})',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'Page ${item.pageNumber} • ${item.surahName}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          onPressed: () {
            if (item.id != null) {
              provider.removeBookmark(item.id!);
            }
          },
        ),
      ),
    );
  }
}

class _AyahNotesTab extends StatelessWidget {
  const _AyahNotesTab();

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final quranProvider = context.read<QuranProvider>();
    final notes = notesProvider.notes;

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No personal notes yet', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            const SizedBox(height: 4),
            Text('Tap "Add Note" on any Ayah to write your thoughts and reflections', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants.gold.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${note.surahEnglishName} (${note.surahNumber}:${note.ayahNumber})',
                        style: const TextStyle(
                          color: AppConstants.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppConstants.primaryGreen),
                          onPressed: () {
                            EditAyahNoteDialog.show(
                              context,
                              Ayah(
                                number: 0,
                                text: '',
                                numberInSurah: note.ayahNumber,
                                juz: 1,
                                manzil: 1,
                                page: 1,
                                ruku: 1,
                                hizbQuarter: 1,
                                sajda: false,
                                surahNumber: note.surahNumber,
                                surahName: note.surahName,
                                surahEnglishName: note.surahEnglishName,
                              ),
                              initialNote: note.noteText,
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () {
                            if (note.id != null) {
                              notesProvider.deleteNote(note.id!);
                            }
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  note.noteText,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    final surahs = quranProvider.surahs;
                    final targetSurah = surahs.firstWhere(
                      (s) => s.number == note.surahNumber,
                      orElse: () => Surah(
                        number: note.surahNumber,
                        name: note.surahName,
                        englishName: note.surahEnglishName,
                        englishNameTranslation: '',
                        numberOfAyahs: 0,
                        revelationType: '',
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surah: targetSurah),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open in Quran',
                        style: TextStyle(color: AppConstants.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 14, color: AppConstants.primaryGreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
