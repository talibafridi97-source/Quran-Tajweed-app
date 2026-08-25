import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum AudioChannel { quran, dua, name }

class AudioManagerService extends ChangeNotifier {
  static final AudioManagerService _instance = AudioManagerService._internal();

  factory AudioManagerService() => _instance;

  static AudioManagerService get instance => _instance;

  AudioManagerService._internal() {
    _audioPlayer.playerStateStream.listen((state) {
      _processingState = state.processingState;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentChannel = null;
        _currentAudioId = null;
        _currentAudioUrl = null;
      } else {
        _isPlaying = state.playing;
      }
      notifyListeners();
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioChannel? _currentChannel;
  String? _currentAudioId;
  String? _currentAudioUrl;
  String? _currentTitle;
  String? _currentSubtitle;
  int? _currentSurahNumber;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  ProcessingState _processingState = ProcessingState.idle;

  AudioChannel? get currentChannel => _currentChannel;
  String? get currentAudioId => _currentAudioId;
  String? get currentAudioUrl => _currentAudioUrl;
  String? get currentTitle => _currentTitle;
  String? get currentSubtitle => _currentSubtitle;
  int? get currentSurahNumber => _currentSurahNumber;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProcessingState get processingState => _processingState;
  AudioPlayer get player => _audioPlayer;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;

  static const List<String> surahNames = [
    'Al-Fatihah', 'Al-Baqarah', 'Ali \'Imran', 'An-Nisa', 'Al-Ma\'idah',
    'Al-An\'am', 'Al-A\'raf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya', 'Al-Hajj', 'Al-Mu\'minun', 'An-Nur', 'Al-Furqan',
    'Ash-Shu\'ara', 'An-Naml', 'Al-Qasas', 'Al-\'Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqi\'ah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumu\'ah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Ma\'arij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Nazi\'at', '\'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-A\'la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-\'Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-\'Adiyat',
    'Al-Qari\'ah', 'At-Takathur', 'Al-\'Asr', 'Al-Humazah', 'Al-Fil',
    'Quraysh', 'Al-Ma\'un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas'
  ];

  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
  }) async {
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    final candidateUrls = [
      'https://server8.mp3quran.net/afs/$paddedSurah.mp3',
      'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/$surahNumber.mp3',
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber.mp3',
    ];

    await playItem(
      channel: AudioChannel.quran,
      id: 'surah_$surahNumber',
      url: candidateUrls[0],
      fallbackUrl: candidateUrls[1],
      title: 'Surah $surahName',
      subtitle: 'Mishary Rashid Alafasy',
      surahNumber: surahNumber,
    );
  }

  Future<void> playItem({
    required AudioChannel channel,
    required String id,
    required String url,
    String? fallbackUrl,
    String? title,
    String? subtitle,
    int? surahNumber,
  }) async {
    if (title != null) _currentTitle = title;
    if (subtitle != null) _currentSubtitle = subtitle;
    if (surahNumber != null) _currentSurahNumber = surahNumber;

    // If same item is tapped while playing or paused
    if (_currentChannel == channel && _currentAudioId == id) {
      if (_isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    // Step 1: Stop previous audio & clear state immediately
    await stop();

    _currentChannel = channel;
    _currentAudioId = id;
    _currentAudioUrl = url;
    if (title != null) _currentTitle = title;
    if (subtitle != null) _currentSubtitle = subtitle;
    if (surahNumber != null) _currentSurahNumber = surahNumber;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AudioManager] Playing channel: ${channel.name}, ID: $id with URL: $url');
      // Step 2: Load new item audio
      await _audioPlayer.setUrl(url);
      // Step 3: Play new item
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[AudioManager] Primary URL error for $url: $e');
      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
        try {
          debugPrint('[AudioManager] Attempting fallback URL: $fallbackUrl');
          await _audioPlayer.setUrl(fallbackUrl);
          await _audioPlayer.play();
        } catch (err) {
          debugPrint('[AudioManager] Fallback URL error for $fallbackUrl: $err');
          _errorMessage = 'Unable to play audio: $err';
        }
      } else {
        _errorMessage = 'Unable to play audio: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_processingState == ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
    }
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentChannel = null;
    _currentAudioId = null;
    _currentAudioUrl = null;
    _currentTitle = null;
    _currentSubtitle = null;
    _currentSurahNumber = null;
    _isPlaying = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> seekForward({int seconds = 10}) async {
    final current = _audioPlayer.position;
    final total = _audioPlayer.duration ?? Duration.zero;
    final newPos = current + Duration(seconds: seconds);
    await _audioPlayer.seek(newPos > total ? total : newPos);
  }

  Future<void> seekBackward({int seconds = 10}) async {
    final current = _audioPlayer.position;
    final newPos = current - Duration(seconds: seconds);
    await _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> playNext() async {
    if (_currentChannel == AudioChannel.quran && _currentSurahNumber != null) {
      if (_currentSurahNumber! < 114) {
        final nextSurah = _currentSurahNumber! + 1;
        final name = (nextSurah <= surahNames.length) ? surahNames[nextSurah - 1] : 'Surah $nextSurah';
        await playSurah(surahNumber: nextSurah, surahName: name);
      }
    }
  }

  Future<void> playPrevious() async {
    if (_currentChannel == AudioChannel.quran && _currentSurahNumber != null) {
      if (_currentSurahNumber! > 1) {
        final prevSurah = _currentSurahNumber! - 1;
        final name = (prevSurah <= surahNames.length) ? surahNames[prevSurah - 1] : 'Surah $prevSurah';
        await playSurah(surahNumber: prevSurah, surahName: name);
      }
    }
  }

  bool isItemPlaying(AudioChannel channel, String id) {
    return _currentChannel == channel &&
        _currentAudioId == id &&
        _isPlaying &&
        _processingState != ProcessingState.completed;
  }

  bool isItemLoading(AudioChannel channel, String id) {
    return _currentChannel == channel && _currentAudioId == id && _isLoading;
  }
}
