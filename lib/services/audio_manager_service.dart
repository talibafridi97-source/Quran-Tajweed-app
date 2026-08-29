import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/dua_model.dart';

enum AudioChannel { quran, dua, name }

class AyahAudioMetadata {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final int totalAyahs;
  final bool isBismillah;
  final String title;
  final String subtitle;

  const AyahAudioMetadata({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.totalAyahs,
    this.isBismillah = false,
    required this.title,
    required this.subtitle,
  });
}

class AudioManagerService extends ChangeNotifier {
  static final AudioManagerService _instance = AudioManagerService._internal();

  factory AudioManagerService() => _instance;

  static AudioManagerService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioChannel? _currentChannel;
  String? _currentAudioId;
  String? _currentAudioUrl;
  String? _currentTitle;
  String? _currentSubtitle;
  String? _currentDuaId;
  int? _currentSurahNumber;
  int? _currentAyahNumber;
  int? _totalAyahsInSurah;
  String? _currentSurahName;
  String? _currentReciterId;
  String? _currentReciterName;
  bool _isAyahMode = false;
  bool _isBismillah = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  ProcessingState _processingState = ProcessingState.idle;
  ConcatenatingAudioSource? _currentPlaylist;
  bool _isActionInProgress = false;

  AudioManagerService._internal() {
    // Listen to player state changes (playing / processing state)
    _audioPlayer.playerStateStream.listen((state) {
      _processingState = state.processingState;
      _isPlaying = state.playing;

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _isBismillah = false;
        _isLoading = false;
        notifyListeners();
      } else if (state.processingState == ProcessingState.ready) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    });

    // Listen to sequence state changes for continuous queue tracking
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final currentItem = sequenceState.currentSource;
      final tag = currentItem?.tag;
      if (tag is AyahAudioMetadata) {
        _currentSurahNumber = tag.surahNumber;
        _currentAyahNumber = tag.isBismillah ? 0 : tag.ayahNumber;
        _isBismillah = tag.isBismillah;
        _currentSurahName = tag.surahName;
        _totalAyahsInSurah = tag.totalAyahs;
        _currentTitle = tag.title;
        _currentSubtitle = tag.subtitle;
        _currentAudioId = tag.isBismillah
            ? 'bismillah_${tag.surahNumber}'
            : 'ayah_${tag.surahNumber}_${tag.ayahNumber}';
        notifyListeners();
      }
    });
  }

  AudioChannel? get currentChannel => _currentChannel;
  String? get currentAudioId => _currentAudioId;
  String? get currentAudioUrl => _currentAudioUrl;
  String? get currentTitle => _currentTitle;
  String? get currentSubtitle => _currentSubtitle;
  String? get currentDuaId => _currentDuaId;
  int? get currentSurahNumber => _currentSurahNumber;
  int? get currentAyahNumber => _currentAyahNumber;
  int? get currentSurah => _currentSurahNumber;
  int? get currentAyah => _currentAyahNumber;
  bool get isBismillah => _isBismillah;
  int? get totalAyahsInSurah =>
      _totalAyahsInSurah ??
      (_currentSurahNumber != null && _currentSurahNumber! >= 1 && _currentSurahNumber! <= 114
          ? surahAyahCounts[_currentSurahNumber! - 1]
          : null);
  String? get currentSurahName => _currentSurahName;
  String? get currentReciterId => _currentReciterId;
  String? get currentReciterName => _currentReciterName ?? 'Mishary Rashid Alafasy';
  String? get currentReciter => currentReciterName;
  bool get isAyahMode => _isAyahMode;
  bool get isPlaying =>
      _isPlaying &&
      _processingState != ProcessingState.completed &&
      _processingState != ProcessingState.idle;
  bool get isPaused =>
      !_isPlaying &&
      _currentAudioId != null &&
      _processingState != ProcessingState.idle &&
      _processingState != ProcessingState.completed;
  bool get isStopped =>
      _currentAudioId == null ||
      (!_isPlaying &&
          (_processingState == ProcessingState.idle ||
              _processingState == ProcessingState.completed));
  bool get isLoading =>
      _isLoading ||
      (_processingState == ProcessingState.loading) ||
      (_processingState == ProcessingState.buffering && !_isPlaying);
  String? get errorMessage => _errorMessage;
  ProcessingState get processingState => _processingState;
  AudioPlayer get player => _audioPlayer;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;

  static const List<int> surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
    5, 4, 5, 6
  ];

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

  static int getGlobalAyahNumber(int surahNumber, int ayahNumberInSurah) {
    if (surahNumber <= 1) return ayahNumberInSurah;
    int count = 0;
    for (int i = 0; i < surahNumber - 1 && i < surahAyahCounts.length; i++) {
      count += surahAyahCounts[i];
    }
    return count + ayahNumberInSurah;
  }

  static String _getEveryAyahFolder(String qariId) {
    switch (qariId) {
      case 'ar.abdulbasitmurattal':
        return 'Abdul_Basit_Murattal_192kbps';
      case 'ar.sudais':
        return 'Abdurrahmaan_As-Sudais_192kbps';
      case 'ar.ghamadi':
        return 'Ghamadi_40kbps';
      case 'ar.husary':
        return 'Husary_128kbps';
      case 'ar.alafasy':
      default:
        return 'Alafasy_128kbps';
    }
  }

  /// Builds a sequential concatenating audio source for a complete Surah.
  ConcatenatingAudioSource _buildSurahPlaylist({
    required int surahNumber,
    required String surahName,
    required int totalAyahs,
    required String reciterId,
    required String reciterName,
    bool includeBismillah = true,
  }) {
    final folder = _getEveryAyahFolder(reciterId);
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    final List<AudioSource> sources = [];

    // Surahs 2..8 and 10..114 have a Bismillah recitation before Ayah 1
    if (includeBismillah && surahNumber != 1 && surahNumber != 9) {
      final bismillahUrl = 'https://everyayah.com/data/$folder/001001.mp3';
      sources.add(
        AudioSource.uri(
          Uri.parse(bismillahUrl),
          tag: AyahAudioMetadata(
            surahNumber: surahNumber,
            ayahNumber: 0,
            surahName: surahName,
            totalAyahs: totalAyahs,
            isBismillah: true,
            title: 'Bismillah • Surah $surahName',
            subtitle: 'Reciter: $reciterName',
          ),
        ),
      );
    }

    // Add each Ayah in sequence
    for (int a = 1; a <= totalAyahs; a++) {
      final paddedAyah = a.toString().padLeft(3, '0');
      final ayahUrl = 'https://everyayah.com/data/$folder/$paddedSurah$paddedAyah.mp3';
      sources.add(
        AudioSource.uri(
          Uri.parse(ayahUrl),
          tag: AyahAudioMetadata(
            surahNumber: surahNumber,
            ayahNumber: a,
            surahName: surahName,
            totalAyahs: totalAyahs,
            isBismillah: false,
            title: 'Ayah $a of $totalAyahs • Surah $surahName',
            subtitle: 'Reciter: $reciterName',
          ),
        ),
      );
    }

    return ConcatenatingAudioSource(
      children: sources,
      useLazyPreparation: true,
    );
  }

  /// Plays a specific Ayah from a Surah, queuing the remainder of the Surah sequentially.
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    int? totalAyahs,
    String? reciterId,
    String? reciterName,
  }) async {
    final total = totalAyahs ??
        (surahNumber >= 1 && surahNumber <= 114 ? surahAyahCounts[surahNumber - 1] : 7);
    final rId = reciterId ?? _currentReciterId ?? 'ar.alafasy';
    final rName = reciterName ?? _currentReciterName ?? 'Mishary Rashid Alafasy';

    final id = 'ayah_${surahNumber}_$ayahNumber';

    // If same Ayah is tapped while active, toggle pause / resume
    if (_currentChannel == AudioChannel.quran &&
        _currentSurahNumber == surahNumber &&
        _currentAyahNumber == ayahNumber &&
        !_isBismillah) {
      if (_isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    final bool hasBismillah = (surahNumber != 1 && surahNumber != 9);
    final int targetIndex = hasBismillah ? ayahNumber : (ayahNumber - 1);

    // If the playlist for this exact surah and reciter is already active in the player,
    // seek directly to the requested Ayah index smoothly.
    if (_currentChannel == AudioChannel.quran &&
        _currentSurahNumber == surahNumber &&
        _currentReciterId == rId &&
        _currentPlaylist != null) {
      try {
        _isLoading = true;
        _isAyahMode = true;
        _isBismillah = false;
        _currentAyahNumber = ayahNumber;
        _currentAudioId = id;
        notifyListeners();

        final validIndex = targetIndex.clamp(0, _currentPlaylist!.length - 1);
        await _audioPlayer.seek(Duration.zero, index: validIndex);
        if (!_isPlaying) {
          await _audioPlayer.play();
        }
      } catch (e) {
        debugPrint('[AudioManager] Error seeking to Ayah $ayahNumber: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    // Otherwise build and set up the full sequential playlist
    _currentChannel = AudioChannel.quran;
    _currentAudioId = id;
    _currentSurahNumber = surahNumber;
    _currentAyahNumber = ayahNumber;
    _totalAyahsInSurah = total;
    _currentSurahName = surahName;
    _currentReciterId = rId;
    _currentReciterName = rName;
    _currentTitle = 'Ayah $ayahNumber of $total • Surah $surahName';
    _currentSubtitle = 'Reciter: $rName';
    _isAyahMode = true;
    _isBismillah = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AudioManager] Initializing Surah $surahNumber playlist starting at Ayah $ayahNumber');
      _currentPlaylist = _buildSurahPlaylist(
        surahNumber: surahNumber,
        surahName: surahName,
        totalAyahs: total,
        reciterId: rId,
        reciterName: rName,
        includeBismillah: hasBismillah,
      );

      final validIndex = targetIndex.clamp(0, _currentPlaylist!.length - 1);
      await _audioPlayer.setAudioSource(
        _currentPlaylist!,
        initialIndex: validIndex,
        initialPosition: Duration.zero,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[AudioManager] Error starting Ayah $ayahNumber: $e');
      _errorMessage = 'Unable to play Ayah audio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Plays a complete Surah continuously from the beginning (Bismillah -> Ayah 1 -> ... -> Last Ayah).
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    int? totalAyahs,
    String? reciterId,
    String? reciterName,
  }) async {
    final total = totalAyahs ??
        (surahNumber >= 1 && surahNumber <= 114 ? surahAyahCounts[surahNumber - 1] : 7);
    final rId = reciterId ?? _currentReciterId ?? 'ar.alafasy';
    final rName = reciterName ?? _currentReciterName ?? 'Mishary Rashid Alafasy';

    // If this Surah is already loaded with the same reciter, toggle or restart
    if (_currentChannel == AudioChannel.quran &&
        _currentSurahNumber == surahNumber &&
        _currentReciterId == rId &&
        _currentPlaylist != null) {
      if (_isPlaying) {
        await pause();
      } else if (isPaused) {
        await resume();
      } else {
        await _audioPlayer.seek(Duration.zero, index: 0);
        await _audioPlayer.play();
      }
      return;
    }

    final bool hasBismillah = (surahNumber != 1 && surahNumber != 9);

    _currentChannel = AudioChannel.quran;
    _currentAudioId = 'surah_$surahNumber';
    _currentSurahNumber = surahNumber;
    _currentAyahNumber = hasBismillah ? 0 : 1;
    _totalAyahsInSurah = total;
    _currentSurahName = surahName;
    _currentReciterId = rId;
    _currentReciterName = rName;
    _isAyahMode = true;
    _isBismillah = hasBismillah;
    _currentTitle = hasBismillah ? 'Bismillah • Surah $surahName' : 'Ayah 1 of $total • Surah $surahName';
    _currentSubtitle = 'Reciter: $rName';
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AudioManager] Playing complete Surah $surahNumber ($surahName)');
      _currentPlaylist = _buildSurahPlaylist(
        surahNumber: surahNumber,
        surahName: surahName,
        totalAyahs: total,
        reciterId: rId,
        reciterName: rName,
        includeBismillah: hasBismillah,
      );

      await _audioPlayer.setAudioSource(
        _currentPlaylist!,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[AudioManager] Error starting Surah $surahNumber playback: $e');
      _errorMessage = 'Unable to play Surah audio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Advances to next Ayah in queue, or next Surah if at the end of the current Surah.
  Future<void> playNext() async {
    await playNextAyah();
  }

  Future<void> playNextAyah() async {
    if (_isActionInProgress) return;
    _isActionInProgress = true;
    try {
      if (_audioPlayer.hasNext) {
        await _audioPlayer.seekToNext();
        if (!_isPlaying) {
          await _audioPlayer.play();
        }
      } else if (_currentChannel == AudioChannel.quran &&
          _currentSurahNumber != null &&
          _currentSurahNumber! < 114) {
        final nextSurah = _currentSurahNumber! + 1;
        final nextName = (nextSurah <= surahNames.length) ? surahNames[nextSurah - 1] : 'Surah $nextSurah';
        final nextTotal = surahAyahCounts[nextSurah - 1];
        await playSurah(
          surahNumber: nextSurah,
          surahName: nextName,
          totalAyahs: nextTotal,
          reciterId: _currentReciterId,
          reciterName: _currentReciterName,
        );
      }
    } catch (e) {
      debugPrint('[AudioManager] playNextAyah error: $e');
    } finally {
      _isActionInProgress = false;
    }
  }

  /// Skips to previous Ayah, or restarts current Ayah if played > 3 seconds.
  Future<void> playPrevious() async {
    await playPreviousAyah();
  }

  Future<void> playPreviousAyah() async {
    if (_isActionInProgress) return;
    _isActionInProgress = true;
    try {
      if (_audioPlayer.position.inSeconds > 3) {
        await _audioPlayer.seek(Duration.zero);
      } else if (_audioPlayer.hasPrevious) {
        await _audioPlayer.seekToPrevious();
        if (!_isPlaying) {
          await _audioPlayer.play();
        }
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    } catch (e) {
      debugPrint('[AudioManager] playPreviousAyah error: $e');
    } finally {
      _isActionInProgress = false;
    }
  }

  /// Plays a specific Masnoon Dua strictly by its unique [duaId].
  Future<void> playDua({
    required String duaId,
    required String audioUrl,
    required String title,
    required String subtitle,
  }) async {
    if (!DuaAudioResolver.validateDuaAudioMapping(duaId, audioUrl)) {
      _errorMessage = 'Audio URL mismatch: The provided audio does not belong to Dua "$duaId".';
      notifyListeners();
      return;
    }

    final id = 'dua_$duaId';

    if (_currentChannel == AudioChannel.dua && _currentAudioId == id && _currentDuaId == duaId) {
      if (_isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    await stop();

    _currentChannel = AudioChannel.dua;
    _currentAudioId = id;
    _currentDuaId = duaId;
    _currentAudioUrl = audioUrl;
    _currentTitle = title;
    _currentSubtitle = subtitle;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AudioManager] Playing Dua [$duaId] with URL: $audioUrl');
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[AudioManager] Error playing Dua [$duaId]: $e');
      _errorMessage = 'Unable to play Dua audio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Plays a standalone audio item (e.g. Tajweed rule audio or 99 Names).
  Future<void> playItem({
    required AudioChannel channel,
    required String id,
    required String url,
    String? fallbackUrl,
    String? title,
    String? subtitle,
    int? surahNumber,
  }) async {
    if (_currentChannel == channel && _currentAudioId == id) {
      if (_isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    await stop();

    _currentChannel = channel;
    _currentAudioId = id;
    _currentAudioUrl = url;
    if (channel != AudioChannel.dua) {
      _currentDuaId = null;
    }
    if (title != null) _currentTitle = title;
    if (subtitle != null) _currentSubtitle = subtitle;
    if (surahNumber != null) _currentSurahNumber = surahNumber;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AudioManager] Playing channel: ${channel.name}, ID: $id with URL: $url');
      await _audioPlayer.setUrl(url);
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
      await _audioPlayer.seek(Duration.zero, index: 0);
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
    _currentDuaId = null;
    _currentTitle = null;
    _currentSubtitle = null;
    _currentSurahNumber = null;
    _currentAyahNumber = null;
    _totalAyahsInSurah = null;
    _currentSurahName = null;
    _isAyahMode = false;
    _isBismillah = false;
    _isPlaying = false;
    _isLoading = false;
    _currentPlaylist = null;
    _errorMessage = null;
    _processingState = ProcessingState.idle;
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

  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    return _currentChannel == AudioChannel.quran &&
        _currentSurahNumber == surahNumber &&
        _currentAyahNumber == ayahNumber &&
        !_isBismillah &&
        _isPlaying &&
        _processingState != ProcessingState.completed;
  }

  bool isAyahActive(int surahNumber, int ayahNumber) {
    return _currentChannel == AudioChannel.quran &&
        _currentSurahNumber == surahNumber &&
        (_currentAyahNumber == ayahNumber || (_isBismillah && ayahNumber == 1)) &&
        _processingState != ProcessingState.completed &&
        _processingState != ProcessingState.idle;
  }

  bool isItemPlaying(AudioChannel channel, String id) {
    return _currentChannel == channel &&
        _currentAudioId == id &&
        _isPlaying &&
        _processingState != ProcessingState.completed;
  }

  bool isItemLoading(AudioChannel channel, String id) {
    return _currentChannel == channel && _currentAudioId == id && isLoading;
  }
}


