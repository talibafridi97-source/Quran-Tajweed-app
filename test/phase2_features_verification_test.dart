import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/core/utils/arabic_text_normalizer.dart';
import 'package:tajweed_quran/models/translation_model.dart';
import 'package:tajweed_quran/models/tafsir_model.dart';
import 'package:tajweed_quran/models/bookmark_folder_model.dart';
import 'package:tajweed_quran/models/bookmark_item_model.dart';
import 'package:tajweed_quran/models/ayah_note_model.dart';

void main() {
  group('Phase 2A — ArabicTextNormalizer Tests', () {
    test('Strips all Harakat / diacritics without mutating canonical letters', () {
      const canonicalFatihah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      final normalized = ArabicTextNormalizer.normalize(canonicalFatihah);

      expect(normalized, 'بسم الله الرحمن الرحيم');
      expect(normalized.contains('\u064E'), false); // No Fathah
      expect(normalized.contains('\u0650'), false); // No Kasrah
      expect(normalized.contains('\u0651'), false); // No Shaddah
      expect(normalized.contains('\u0670'), false); // No Dagger Alif
    });

    test('Unifies Alef variants into basic Alif', () {
      const alefVariants = 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ';
      final normalized = ArabicTextNormalizer.normalize(alefVariants);

      expect(normalized, 'اياك نعبد واياك نستعين');
    });

    test('Search query matches normalized verse text', () {
      const userSearchQuery = 'الحمد لله';
      const verseText = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';

      final normalizedQuery = ArabicTextNormalizer.normalize(userSearchQuery);
      final normalizedVerse = ArabicTextNormalizer.normalize(verseText);

      expect(normalizedVerse.startsWith(normalizedQuery), true);
    });
  });

  group('Phase 2B — Multi-Translation & Tafsir Models', () {
    test('TranslationEdition has 4 initial editions with valid identifiers', () {
      expect(TranslationEdition.availableEditions.length, 4);
      expect(TranslationEdition.findById('ur.jalandhry').language, 'Urdu');
      expect(TranslationEdition.findById('en.sahih').language, 'English');
    });

    test('AyahTranslation model serializes to and from DB map correctly', () {
      const trans = AyahTranslation(
        surahNumber: 1,
        ayahNumber: 1,
        editionId: 'en.sahih',
        text: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      );

      final map = trans.toMap();
      final fromDb = AyahTranslation.fromMap(map);

      expect(fromDb.surahNumber, 1);
      expect(fromDb.ayahNumber, 1);
      expect(fromDb.editionId, 'en.sahih');
      expect(fromDb.text, trans.text);
    });

    test('TafsirEdition has Ibn Kathir and Bayan-ul-Quran', () {
      expect(TafsirEdition.availableEditions.length, 3);
      final ibnKathir = TafsirEdition.findById('en-tafisr-ibn-kathir');
      expect(ibnKathir.name, 'Tafsir Ibn Kathir');
    });

    test('AyahTafsir model serializes to and from map', () {
      final now = DateTime.now();
      final tafsir = AyahTafsir(
        surahNumber: 2,
        ayahNumber: 255,
        tafsirId: 'en-tafisr-ibn-kathir',
        authorName: 'Hafiz Ibn Kathir',
        text: 'Ayat-ul-Kursi is the greatest verse in the Quran...',
        language: 'English',
        updatedAt: now,
      );

      final map = tafsir.toMap();
      final fromDb = AyahTafsir.fromMap(map);

      expect(fromDb.surahNumber, 2);
      expect(fromDb.ayahNumber, 255);
      expect(fromDb.authorName, 'Hafiz Ibn Kathir');
    });
  });

  group('Phase 2C — Categorized Bookmarks & Notes Models', () {
    test('BookmarkFolder serializes and copies with new values', () {
      final folder = BookmarkFolder(
        name: 'Hifz Revision',
        colorValue: 0xFF0D4D4D,
        createdAt: DateTime.now(),
      );

      final copy = folder.copyWith(name: 'Completed Hifz');
      expect(copy.name, 'Completed Hifz');
      expect(copy.colorValue, 0xFF0D4D4D);
    });

    test('BookmarkItem references Surah and Ayah accurately', () {
      final item = BookmarkItem(
        surahNumber: 36,
        ayahNumber: 58,
        surahName: 'يس',
        surahEnglishName: 'Ya-Sin',
        pageNumber: 444,
        ayahText: 'سَلَٰمٌ قَوْلًا مِّن رَّبٍّ رَّحِيمٍ',
        createdAt: DateTime.now(),
      );

      final map = item.toMap();
      final fromDb = BookmarkItem.fromMap(map);

      expect(fromDb.surahNumber, 36);
      expect(fromDb.ayahNumber, 58);
      expect(fromDb.pageNumber, 444);
    });

    test('AyahNote CRUD model serialization', () {
      final note = AyahNote(
        surahNumber: 18,
        ayahNumber: 10,
        surahName: 'الكهف',
        surahEnglishName: 'Al-Kahf',
        noteText: 'Duas of the Youth of the Cave for Mercy and Right Guidance.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = note.toMap();
      final fromDb = AyahNote.fromMap(map);

      expect(fromDb.surahNumber, 18);
      expect(fromDb.ayahNumber, 10);
      expect(fromDb.noteText, note.noteText);
    });
  });
}
