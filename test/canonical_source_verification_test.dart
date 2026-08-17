import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Verify canonical quran-uthmani dataset availability and structure', () async {
    print('Testing /surah/1/quran-uthmani...');
    final s1 = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/1/quran-uthmani'));
    expect(s1.statusCode, 200);
    final s1Data = json.decode(s1.body)['data'];
    expect(s1Data['numberOfAyahs'], 7);

    print('Testing /juz/30/quran-uthmani...');
    final j30 = await http.get(Uri.parse('https://api.alquran.cloud/v1/juz/30/quran-uthmani'));
    expect(j30.statusCode, 200);
    final j30Ayahs = json.decode(j30.body)['data']['ayahs'] as List;
    expect(j30Ayahs.isNotEmpty, true);

    print('Testing /page/604/quran-uthmani...');
    final p604 = await http.get(Uri.parse('https://api.alquran.cloud/v1/page/604/quran-uthmani'));
    expect(p604.statusCode, 200);
    final p604Ayahs = json.decode(p604.body)['data']['ayahs'] as List;
    expect(p604Ayahs.isNotEmpty, true);

    print('Canonical quran-uthmani endpoints verified successfully!');
  });
}
