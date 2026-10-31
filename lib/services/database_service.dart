import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/quran_word.dart';
import '../models/khatam_model.dart';
import '../models/translation_model.dart';
import '../models/tafsir_model.dart';
import '../models/bookmark_folder_model.dart';
import '../models/bookmark_item_model.dart';
import '../models/ayah_note_model.dart';
import '../models/tasbeeh_history_model.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';
import '../models/daily_status.dart';
import '../models/routine_template.dart';
import '../core/utils/arabic_text_normalizer.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quran_db_v6.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await _createTablesV1(db);
        await _createTablesV2(db);
        await _createTablesV3(db);
        await _createTablesV4(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTablesV2(db);
        }
        if (oldVersion < 3) {
          await _createTablesV3(db);
        }
        if (oldVersion < 4) {
          await _createTablesV4(db);
        }
        if (oldVersion < 5) {
          await db.delete('ayahs');
        }
      },
    );
  }

  static Future<void> _createTablesV1(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS surahs (
        number INTEGER PRIMARY KEY,
        name TEXT,
        englishName TEXT,
        englishNameTranslation TEXT,
        numberOfAyahs INTEGER,
        revelationType TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayahs (
        number INTEGER PRIMARY KEY,
        text TEXT,
        numberInSurah INTEGER,
        juz INTEGER,
        manzil INTEGER,
        page INTEGER,
        ruku INTEGER,
        hizbQuarter INTEGER,
        sajda INTEGER,
        surahNumber INTEGER,
        surahName TEXT,
        surahEnglishName TEXT,
        FOREIGN KEY (surahNumber) REFERENCES surahs (number)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS qcf_words (
        id INTEGER PRIMARY KEY,
        page_number INTEGER,
        line_number INTEGER,
        position INTEGER,
        code_v2 TEXT,
        text_uthmani TEXT,
        verse_key TEXT,
        char_type_name TEXT,
        audio_url TEXT,
        translation TEXT,
        transliteration TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS khatam_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        startDate TEXT,
        totalDays INTEGER,
        currentAyah INTEGER,
        currentSurah INTEGER,
        isCompleted INTEGER
      )
    ''');
  }

  static Future<void> _createTablesV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmark_folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks_v2 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        surah_english_name TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        folder_id INTEGER,
        ayah_text TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES bookmark_folders (id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayah_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        surah_english_name TEXT NOT NULL,
        note_text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        edition_id TEXT NOT NULL,
        translation_text TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_trans_surah_edition ON translations(surah_number, edition_id)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tafsir_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        tafsir_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        tafsir_text TEXT NOT NULL,
        language TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_tafsir_unique ON tafsir_cache(surah_number, ayah_number, tafsir_id)
    ''');

    // SQLite FTS5 Virtual Search Table
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS quran_search USING fts5(
          surah_number UNINDEXED,
          ayah_number UNINDEXED,
          surah_name,
          surah_english_name,
          normalized_arabic,
          canonical_arabic UNINDEXED,
          translation_text
        )
      ''');
    } catch (_) {
      // Fallback standard search table if FTS5 module is not compiled in environment
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quran_search (
          surah_number INTEGER,
          ayah_number INTEGER,
          surah_name TEXT,
          surah_english_name TEXT,
          normalized_arabic TEXT,
          canonical_arabic TEXT,
          translation_text TEXT
        )
      ''');
    }

    // Insert default Favorites folder if empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM bookmark_folders'),
    );
    if (count == null || count == 0) {
      await db.insert('bookmark_folders', {
        'name': 'Favorites',
        'color_value': 0xFFC9A227, // Gold
        'created_at': DateTime.now().toIso8601String(),
      });
      await db.insert('bookmark_folders', {
        'name': 'Daily Recitation',
        'color_value': 0xFF0D4D4D, // Primary Green
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> _createTablesV3(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasbeeh_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dhikr_name TEXT NOT NULL,
        arabic_text TEXT,
        count INTEGER NOT NULL,
        target INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createTablesV4(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon_name TEXT NOT NULL,
        type TEXT NOT NULL,
        daily_target_minutes INTEGER,
        weight REAL NOT NULL DEFAULT 0.0,
        counts_for_score INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        category_name_snapshot TEXT NOT NULL,
        activity_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        start_time TEXT,
        end_time TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'saved',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_activity_date ON activity_records(date)
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_status (
        date TEXT PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'in_progress',
        reviewed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_score_snapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        score REAL NOT NULL,
        snapshot_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS routine_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS routine_template_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        category_name_snapshot TEXT NOT NULL,
        activity_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        start_time TEXT,
        end_time TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (template_id) REFERENCES routine_templates (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Seed default categories if categories table is empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count == null || count == 0) {
      final now = DateTime.now().toIso8601String();
      final defaultCategories = [
        {'name': 'Coding', 'color': 0xFF2563EB, 'icon': 'code', 'type': 'Productive', 'target': 360, 'weight': 40.0, 'score': 1, 'order': 0},
        {'name': 'Quran', 'color': 0xFF059669, 'icon': 'menu_book', 'type': 'Productive', 'target': 120, 'weight': 20.0, 'score': 1, 'order': 1},
        {'name': 'English Study', 'color': 0xFF7C3AED, 'icon': 'school', 'type': 'Productive', 'target': 60, 'weight': 15.0, 'score': 1, 'order': 2},
        {'name': 'Exercise', 'color': 0xFFEA580C, 'icon': 'fitness_center', 'type': 'Productive', 'target': 30, 'weight': 10.0, 'score': 1, 'order': 3},
        {'name': 'Namaz', 'color': 0xFF0D9488, 'icon': 'mosque', 'type': 'Productive', 'target': 60, 'weight': 10.0, 'score': 1, 'order': 4},
        {'name': 'Personal Care', 'color': 0xFFDB2777, 'icon': 'spa', 'type': 'Productive', 'target': 30, 'weight': 5.0, 'score': 1, 'order': 5},
        {'name': 'Sleep', 'color': 0xFF475569, 'icon': 'bed', 'type': 'Maintenance', 'target': 480, 'weight': 0.0, 'score': 0, 'order': 6},
        {'name': 'Meals', 'color': 0xFFD97706, 'icon': 'restaurant', 'type': 'Maintenance', 'target': 90, 'weight': 0.0, 'score': 0, 'order': 7},
        {'name': 'Family Time', 'color': 0xFF0284C7, 'icon': 'people', 'type': 'Maintenance', 'target': 60, 'weight': 0.0, 'score': 0, 'order': 8},
        {'name': 'Rest', 'color': 0xFF64748B, 'icon': 'weekend', 'type': 'Maintenance', 'target': 60, 'weight': 0.0, 'score': 0, 'order': 9},
        {'name': 'Unallocated', 'color': 0xFF94A3B8, 'icon': 'help_outline', 'type': 'Maintenance', 'target': null, 'weight': 0.0, 'score': 0, 'order': 10},
      ];

      for (final cat in defaultCategories) {
        await db.insert('categories', {
          'name': cat['name'],
          'color_value': cat['color'],
          'icon_name': cat['icon'],
          'type': cat['type'],
          'daily_target_minutes': cat['target'],
          'weight': cat['weight'],
          'counts_for_score': cat['score'],
          'is_archived': 0,
          'sort_order': cat['order'],
          'created_at': now,
        });
      }
    }
  }

  // --- Canonical Quran Methods ---
  Future<void> saveSurahs(List<Surah> surahs) async {
    final db = await database;
    Batch batch = db.batch();
    for (var surah in surahs) {
      batch.insert('surahs', {
        'number': surah.number,
        'name': surah.name,
        'englishName': surah.englishName,
        'englishNameTranslation': surah.englishNameTranslation,
        'numberOfAyahs': surah.numberOfAyahs,
        'revelationType': surah.revelationType,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Surah>> getSurahs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('surahs');
    return List.generate(maps.length, (i) => Surah.fromJson(maps[i]));
  }

  Future<void> saveAyahs(List<Ayah> ayahs) async {
    final db = await database;
    Batch batch = db.batch();
    for (var ayah in ayahs) {
      batch.insert('ayahs', {
        'number': ayah.number,
        'text': ayah.text,
        'numberInSurah': ayah.numberInSurah,
        'juz': ayah.juz,
        'manzil': ayah.manzil,
        'page': ayah.page,
        'ruku': ayah.ruku,
        'hizbQuarter': ayah.hizbQuarter,
        'sajda': ayah.sajda ? 1 : 0,
        'surahNumber': ayah.surahNumber,
        'surahName': ayah.surahName,
        'surahEnglishName': ayah.surahEnglishName,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();

    // Index ayahs asynchronously into search table without blocking
    indexAyahsForSearch(ayahs);
  }

  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'surahNumber = ?',
      whereArgs: [surahNumber],
      orderBy: 'numberInSurah ASC',
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  Future<List<Ayah>> getAyahsForJuz(int juzNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'juz = ?',
      whereArgs: [juzNumber],
      orderBy: 'number ASC',
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  Future<List<Ayah>> getAyahsForPage(int pageNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'page = ?',
      whereArgs: [pageNumber],
      orderBy: 'number ASC',
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  Future<List<Ayah>> getAllAyahs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      orderBy: 'number ASC',
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  Future<void> saveQcfWords(List<QuranWord> words) async {
    final db = await database;
    Batch batch = db.batch();
    for (var word in words) {
      batch.insert('qcf_words', word.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<QuranWord>> getQcfWordsForPage(int pageNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'qcf_words',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      orderBy: 'line_number ASC, position ASC',
    );
    return List.generate(maps.length, (i) => QuranWord.fromDb(maps[i]));
  }

  // --- Multi-Translation Cache Methods ---
  Future<void> saveTranslations(List<AyahTranslation> translations) async {
    final db = await database;
    Batch batch = db.batch();
    for (var trans in translations) {
      batch.insert('translations', trans.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<AyahTranslation>> getTranslationsForSurah(int surahNumber, String editionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'surah_number = ? AND edition_id = ?',
      whereArgs: [surahNumber, editionId],
      orderBy: 'ayah_number ASC',
    );
    return List.generate(maps.length, (i) => AyahTranslation.fromMap(maps[i]));
  }

  // --- Ayah-by-Ayah Tafsir Methods ---
  Future<void> saveTafsir(AyahTafsir tafsir) async {
    final db = await database;
    await db.insert('tafsir_cache', tafsir.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AyahTafsir?> getTafsir(int surahNumber, int ayahNumber, String tafsirId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tafsir_cache',
      where: 'surah_number = ? AND ayah_number = ? AND tafsir_id = ?',
      whereArgs: [surahNumber, ayahNumber, tafsirId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AyahTafsir.fromMap(maps.first);
    }
    return null;
  }

  // --- Universal Search (FTS5 / Normalized Index) ---
  Future<void> indexAyahsForSearch(List<Ayah> ayahs) async {
    if (ayahs.isEmpty) return;
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var a in ayahs) {
        final norm = ArabicTextNormalizer.normalize(a.text);
        batch.insert('quran_search', {
          'surah_number': a.surahNumber ?? 1,
          'ayah_number': a.numberInSurah,
          'surah_name': a.surahName ?? '',
          'surah_english_name': a.surahEnglishName ?? '',
          'normalized_arabic': norm,
          'canonical_arabic': a.text,
          'translation_text': '',
        });
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> searchQuran(String query, {int limit = 60}) async {
    if (query.trim().isEmpty) return [];
    final db = await database;
    final normalizedQuery = ArabicTextNormalizer.normalize(query);
    final rawQuery = '%${query.trim()}%';
    final normLikeQuery = '%$normalizedQuery%';

    try {
      // First try MATCH on FTS5 index
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT surah_number, ayah_number, surah_name, surah_english_name, canonical_arabic, translation_text
        FROM quran_search
        WHERE normalized_arabic MATCH ? OR surah_name MATCH ? OR surah_english_name MATCH ?
        LIMIT ?
      ''', [normalizedQuery, query, query, limit]);

      if (results.isNotEmpty) return results;
    } catch (_) {}

    // Fallback standard LIKE search across search index & canonical ayahs
    final List<Map<String, dynamic>> fallbackResults = await db.rawQuery('''
      SELECT surahNumber as surah_number, numberInSurah as ayah_number, surahName as surah_name, surahEnglishName as surah_english_name, text as canonical_arabic
      FROM ayahs
      WHERE text LIKE ? OR surahName LIKE ? OR surahEnglishName LIKE ?
      LIMIT ?
    ''', [rawQuery, rawQuery, rawQuery, limit]);

    if (fallbackResults.isNotEmpty) return fallbackResults;

    return await db.rawQuery('''
      SELECT surah_number, ayah_number, surah_name, surah_english_name, canonical_arabic, translation_text
      FROM quran_search
      WHERE normalized_arabic LIKE ? OR surah_english_name LIKE ?
      LIMIT ?
    ''', [normLikeQuery, rawQuery, limit]);
  }

  // --- Bookmark Folders CRUD ---
  Future<int> insertFolder(BookmarkFolder folder) async {
    final db = await database;
    return await db.insert('bookmark_folders', folder.toMap());
  }

  Future<List<BookmarkFolder>> getFolders() async {
    final db = await database;
    final maps = await db.query('bookmark_folders', orderBy: 'id ASC');
    return List.generate(maps.length, (i) => BookmarkFolder.fromMap(maps[i]));
  }

  Future<void> updateFolder(BookmarkFolder folder) async {
    final db = await database;
    await db.update('bookmark_folders', folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<void> deleteFolder(int folderId) async {
    final db = await database;
    await db.delete('bookmark_folders', where: 'id = ?', whereArgs: [folderId]);
    await db.delete('bookmarks_v2', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  // --- Categorized Bookmarks CRUD ---
  Future<int> insertBookmark(BookmarkItem bookmark) async {
    final db = await database;
    return await db.insert('bookmarks_v2', bookmark.toMap());
  }

  Future<List<BookmarkItem>> getBookmarks({int? folderId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (folderId != null) {
      maps = await db.query(
        'bookmarks_v2',
        where: 'folder_id = ?',
        whereArgs: [folderId],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('bookmarks_v2', orderBy: 'id DESC');
    }
    return List.generate(maps.length, (i) => BookmarkItem.fromMap(maps[i]));
  }

  Future<void> deleteBookmark(int id) async {
    final db = await database;
    await db.delete('bookmarks_v2', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBookmarkBySurahAyah(int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.delete(
      'bookmarks_v2',
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
  }

  Future<bool> isAyahBookmarked(int surahNumber, int ayahNumber) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks_v2',
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // --- Personal Ayah Notes CRUD ---
  Future<int> insertNote(AyahNote note) async {
    final db = await database;
    return await db.insert('ayah_notes', note.toMap());
  }

  Future<List<AyahNote>> getNotes() async {
    final db = await database;
    final maps = await db.query('ayah_notes', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => AyahNote.fromMap(maps[i]));
  }

  Future<AyahNote?> getNoteForAyah(int surahNumber, int ayahNumber) async {
    final db = await database;
    final maps = await db.query(
      'ayah_notes',
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AyahNote.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateNote(AyahNote note) async {
    final db = await database;
    await db.update('ayah_notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('ayah_notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Khatam Methods ---
  Future<int> insertKhatamPlan(KhatamPlan plan) async {
    final db = await database;
    return await db.insert('khatam_plans', plan.toMap());
  }

  Future<List<KhatamPlan>> getKhatamPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('khatam_plans');
    return List.generate(maps.length, (i) => KhatamPlan.fromMap(maps[i]));
  }

  Future<void> updateKhatamPlan(KhatamPlan plan) async {
    final db = await database;
    await db.update(
      'khatam_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  // --- Tasbeeh History Methods ---
  Future<int> insertTasbeehHistory(TasbeehHistoryModel session) async {
    final db = await database;
    return await db.insert('tasbeeh_history', session.toMap());
  }

  Future<List<TasbeehHistoryModel>> getTasbeehHistory({int limit = 100}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeeh_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => TasbeehHistoryModel.fromMap(maps[i]));
  }

  Future<void> clearTasbeehHistory() async {
    final db = await database;
    await db.delete('tasbeeh_history');
  }

  Future<int> getTotalTasbeehCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT SUM(count) as total FROM tasbeeh_history');
    if (res.isNotEmpty && res.first['total'] != null) {
      return res.first['total'] as int;
    }
    return 0;
  }

  // =====================================================
  // --- DayTrack 24 Methods ---
  // =====================================================

  // --- Categories CRUD ---
  Future<List<ActivityCategory>> getCategories({bool includeArchived = true}) async {
    final db = await database;
    final where = includeArchived ? null : 'is_archived = 0';
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: where,
      orderBy: 'sort_order ASC, id ASC',
    );
    return List.generate(maps.length, (i) => ActivityCategory.fromMap(maps[i]));
  }

  Future<ActivityCategory?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ActivityCategory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCategory(ActivityCategory category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(ActivityCategory category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Archive category instead of removing past records
  Future<int> archiveCategory(int id, bool archive) async {
    final db = await database;
    return await db.update(
      'categories',
      {'is_archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategoryIfUnused(int id) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM activity_records WHERE category_id = ?', [id]),
    );
    if (count != null && count > 0) {
      // Must archive, never remove past records
      return await archiveCategory(id, true);
    } else {
      return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    }
  }

  // --- Activity Records CRUD ---
  Future<List<ActivityRecord>> getRecordsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'start_time ASC, id ASC',
    );
    return List.generate(maps.length, (i) => ActivityRecord.fromMap(maps[i]));
  }

  Future<List<ActivityRecord>> getRecordsForDateRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, start_time ASC, id ASC',
    );
    return List.generate(maps.length, (i) => ActivityRecord.fromMap(maps[i]));
  }

  Future<int> insertActivityRecord(ActivityRecord record) async {
    final db = await database;
    return await db.insert('activity_records', record.toMap());
  }

  Future<int> updateActivityRecord(ActivityRecord record) async {
    final db = await database;
    return await db.update(
      'activity_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteActivityRecord(int id) async {
    final db = await database;
    return await db.delete('activity_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> copyRecordsToDate(String sourceDate, String targetDate) async {
    final db = await database;
    final sources = await getRecordsForDate(sourceDate);
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final s in sources) {
      final copy = s.copyWith(
        id: null,
        date: targetDate,
        status: ActivityStatus.draft,
        createdAt: now,
        updatedAt: now,
      );
      batch.insert('activity_records', copy.toMap());
    }
    await batch.commit(noResult: true);
  }

  // --- Autocomplete & Recent Activities ---
  Future<List<String>> getPastActivityNames({int limit = 30}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT activity_name 
      FROM activity_records 
      WHERE activity_name IS NOT NULL AND TRIM(activity_name) != '' 
      ORDER BY id DESC 
      LIMIT ?
    ''', [limit]);
    return maps.map((m) => m['activity_name'] as String).toList();
  }

  Future<List<ActivityRecord>> getRecentUniqueActivities({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM activity_records 
      WHERE id IN (
        SELECT MAX(id) FROM activity_records 
        GROUP BY category_id, activity_name
      )
      ORDER BY id DESC 
      LIMIT ?
    ''', [limit]);
    return maps.map((m) => ActivityRecord.fromMap(m)).toList();
  }

  // --- Daily Status CRUD ---
  Future<DailyStatus> getDailyStatus(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_status',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isNotEmpty) {
      return DailyStatus.fromMap(maps.first);
    }
    return DailyStatus(date: date, status: 'in_progress');
  }

  Future<Map<String, bool>> getReviewedStatusForRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_status',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
    final Map<String, bool> res = {};
    for (final m in maps) {
      final s = DailyStatus.fromMap(m);
      res[s.date] = s.isReviewed;
    }
    return res;
  }

  Future<void> setDailyStatus(String date, String status) async {
    final db = await database;
    final reviewedAt = status == 'reviewed' ? DateTime.now().toIso8601String() : null;
    await db.insert('daily_status', {
      'date': date,
      'status': status,
      'reviewed_at': reviewedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Daily Score Snapshots ---
  Future<void> saveScoreSnapshot(DailyScoreSnapshot snapshot) async {
    final db = await database;
    await db.insert(
      'daily_score_snapshots',
      snapshot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyScoreSnapshot?> getScoreSnapshot(String date) async {
    final db = await database;
    final maps = await db.query(
      'daily_score_snapshots',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isNotEmpty) {
      return DailyScoreSnapshot.fromMap(maps.first);
    }
    return null;
  }

  Future<Map<String, double>> getHistoricalScoresForRange(String startDate, String endDate) async {
    final db = await database;
    final maps = await db.query(
      'daily_score_snapshots',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
    final Map<String, double> res = {};
    for (final m in maps) {
      final s = DailyScoreSnapshot.fromMap(m);
      res[s.date] = s.score;
    }
    return res;
  }

  // --- Routine Templates CRUD ---
  Future<List<RoutineTemplate>> getRoutineTemplates() async {
    final db = await database;
    final templatesMaps = await db.query('routine_templates', orderBy: 'id ASC');
    final List<RoutineTemplate> result = [];
    for (final tm in templatesMaps) {
      final tId = tm['id'] as int;
      final itemsMaps = await db.query(
        'routine_template_items',
        where: 'template_id = ?',
        whereArgs: [tId],
        orderBy: 'sort_order ASC, id ASC',
      );
      final items = itemsMaps.map((im) => RoutineTemplateItem.fromMap(im)).toList();
      result.add(RoutineTemplate.fromMap(tm, items));
    }
    return result;
  }

  Future<int> insertRoutineTemplate(RoutineTemplate template) async {
    final db = await database;
    return await db.transaction((txn) async {
      final tId = await txn.insert('routine_templates', template.toMap());
      for (final item in template.items) {
        await txn.insert('routine_template_items', item.copyWith(templateId: tId).toMap());
      }
      return tId;
    });
  }

  Future<void> deleteRoutineTemplate(int templateId) async {
    final db = await database;
    await db.delete('routine_template_items', where: 'template_id = ?', whereArgs: [templateId]);
    await db.delete('routine_templates', where: 'id = ?', whereArgs: [templateId]);
  }
}

