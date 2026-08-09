import '../models/hadith_model.dart';
import '../services/hadith_api_service.dart';

class HadithRepository {
  final HadithApiService _hadithApiService;

  HadithRepository(this._hadithApiService);

  List<HadithBook> getAvailableBooks() => HadithBook.availableBooks;

  Future<List<HadithChapter>> getChaptersForBook(HadithBook book) =>
      _hadithApiService.getChaptersForBook(book);

  Future<List<HadithItem>> getHadithsForChapter({
    required HadithBook book,
    required HadithChapter chapter,
  }) =>
      _hadithApiService.getHadithsForChapter(book: book, chapter: chapter);
}
