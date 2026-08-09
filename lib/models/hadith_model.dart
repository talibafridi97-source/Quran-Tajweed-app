class HadithBook {
  final String id; // e.g. 'bukhari', 'muslim', 'abudawud'
  final String name; // e.g. 'Sahih al-Bukhari'
  final String nameArabic; // e.g. 'صحيح البخاري'
  final String author;
  final int totalHadiths;

  const HadithBook({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.author,
    required this.totalHadiths,
  });

  static const List<HadithBook> availableBooks = [
    HadithBook(
      id: 'bukhari',
      name: 'Sahih al-Bukhari',
      nameArabic: 'صحيح البخاري',
      author: 'Imam al-Bukhari',
      totalHadiths: 7563,
    ),
    HadithBook(
      id: 'muslim',
      name: 'Sahih Muslim',
      nameArabic: 'صحيح مسلم',
      author: 'Imam Muslim',
      totalHadiths: 7500,
    ),
    HadithBook(
      id: 'abudawud',
      name: 'Sunan Abu Dawud',
      nameArabic: 'سنن أبي داود',
      author: 'Imam Abu Dawud',
      totalHadiths: 5274,
    ),
    HadithBook(
      id: 'tirmidhi',
      name: 'Jami at-Tirmidhi',
      nameArabic: 'جامع الترمذي',
      author: 'Imam at-Tirmidhi',
      totalHadiths: 3956,
    ),
    HadithBook(
      id: 'nasai',
      name: 'Sunan an-Nasa\'i',
      nameArabic: 'سنن النسائي',
      author: 'Imam an-Nasa\'i',
      totalHadiths: 5758,
    ),
    HadithBook(
      id: 'ibnmajah',
      name: 'Sunan Ibn Majah',
      nameArabic: 'سنن ابن ماجه',
      author: 'Imam Ibn Majah',
      totalHadiths: 4341,
    ),
    HadithBook(
      id: 'malik',
      name: 'Muwatta Malik',
      nameArabic: 'موطأ مالك',
      author: 'Imam Malik',
      totalHadiths: 1858,
    ),
  ];
}

class HadithChapter {
  final String id; // chapter / section number as String e.g. '1'
  final String title; // English chapter title
  final String bookId;
  final int hadithFirst;
  final int hadithLast;

  HadithChapter({
    required this.id,
    required this.title,
    required this.bookId,
    required this.hadithFirst,
    required this.hadithLast,
  });
}

class HadithItem {
  final int hadithNumber;
  final int arabicNumber;
  final String textArabic;
  final String textUrdu;
  final String bookName;
  final String chapterTitle;
  final String? grade;

  HadithItem({
    required this.hadithNumber,
    required this.arabicNumber,
    required this.textArabic,
    required this.textUrdu,
    required this.bookName,
    required this.chapterTitle,
    this.grade,
  });

  factory HadithItem.fromJson({
    required Map<String, dynamic> arabicJson,
    required Map<String, dynamic> urduJson,
    required String bookName,
    required String chapterTitle,
  }) {
    String gradeText = '';
    if (arabicJson['grades'] != null && (arabicJson['grades'] as List).isNotEmpty) {
      gradeText = arabicJson['grades'][0]['grade'] ?? '';
    }

    return HadithItem(
      hadithNumber: arabicJson['hadithnumber'] ?? urduJson['hadithnumber'] ?? 0,
      arabicNumber: arabicJson['arabicnumber'] ?? 0,
      textArabic: arabicJson['text']?.toString() ?? '',
      textUrdu: urduJson['text']?.toString() ?? '',
      bookName: bookName,
      chapterTitle: chapterTitle,
      grade: gradeText.isNotEmpty ? gradeText : null,
    );
  }
}
