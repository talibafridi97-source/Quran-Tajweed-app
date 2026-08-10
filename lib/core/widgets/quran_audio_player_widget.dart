import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/constants.dart';

class QuranAudioPlayerWidget extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranAudioPlayerWidget({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranAudioPlayerWidget> createState() => _QuranAudioPlayerWidgetState();
}

class _QuranAudioPlayerWidgetState extends State<QuranAudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isLoading = true);
      try {
        // AlQuran Cloud CDN MP3 audio stream for Mishary Rashid Alafasy (edition: ar.alafasy)
        final audioUrl = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${widget.surahNumber}.mp3';
        
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recitation: Mishary Alafasy',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  'Surah ${widget.surahName}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
                size: 36,
              ),
              onPressed: _toggleAudio,
            ),
        ],
      ),
    );
  }
}
