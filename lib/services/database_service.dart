import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/khatam_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quran_db_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE surahs (
            number INTEGER PRIMARY KEY,
            name TEXT,
            englishName TEXT,
            englishNameTranslation TEXT,
            numberOfAyahs INTEGER,
            revelationType TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE ayahs (
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
          CREATE TABLE khatam_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            startDate TEXT,
            totalDays INTEGER,
            currentAyah INTEGER,
            currentSurah INTEGER,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }

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

  Future<void> saveAyahs(List<Ayah> ayahs, int surahNumber) async {
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
        'surahNumber': surahNumber,
        'surahName': ayah.surahName,
        'surahEnglishName': ayah.surahEnglishName,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'surahNumber = ?',
      whereArgs: [surahNumber],
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  Future<List<Ayah>> getAyahsForJuz(int juzNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'juz = ?',
      whereArgs: [juzNumber],
    );
    return List.generate(maps.length, (i) => Ayah.fromJson(maps[i]));
  }

  // Khatam methods
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
}
