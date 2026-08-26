import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tajweed_quran/models/dua_model.dart';

void main() {
  group('Quran & Adhkar Audio Stream Verification', () {
    test('Verify primary and fallback Quran audio CDN reachability for Surah Al-Fatihah, Al-Baqarah, An-Nas', () async {
      final testSurahs = [1, 2, 114];

      for (final surah in testSurahs) {
        final padded = surah.toString().padLeft(3, '0');
        final primaryUrl = 'https://server8.mp3quran.net/afs/$padded.mp3';
        final fallbackUrl = 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/$surah.mp3';

        // Check primary stream endpoint
        final primaryRes = await http.head(Uri.parse(primaryUrl)).timeout(const Duration(seconds: 10));
        expect(primaryRes.statusCode, equals(200), reason: 'Primary URL $primaryUrl failed');
        expect(primaryRes.headers['content-type'], contains('audio/mpeg'), reason: 'Wrong content type for $primaryUrl');
        expect(primaryRes.headers['accept-ranges'], equals('bytes'), reason: 'Range requests must be supported');

        // Check secondary stream endpoint
        final fallbackRes = await http.head(Uri.parse(fallbackUrl)).timeout(const Duration(seconds: 10));
        expect(fallbackRes.statusCode, equals(200), reason: 'Fallback URL $fallbackUrl failed');
        expect(fallbackRes.headers['content-type'], contains('audio/mpeg'), reason: 'Wrong content type for $fallbackUrl');
      }
    });

    test('Verify all Masnoon Duas audio endpoints are reachable', () async {
      for (final dua in MasnoonDua.allDuas) {
        final res = await http.get(
          Uri.parse(dua.audioUrl),
          headers: {'Range': 'bytes=0-100', 'User-Agent': 'TajweedQuranApp/1.0'},
        ).timeout(const Duration(seconds: 15));
        expect(
          res.statusCode == 200 || res.statusCode == 206,
          isTrue,
          reason: 'Dua ${dua.id} (${dua.titleEnglish}) URL ${dua.audioUrl} returned ${res.statusCode}',
        );
        expect(res.headers['content-type'], contains('audio/mpeg'), reason: 'Dua ${dua.id} is not audio/mpeg');
      }
    });
  });
}
