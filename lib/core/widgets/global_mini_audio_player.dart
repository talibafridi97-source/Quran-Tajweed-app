import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_manager_service.dart';
import '../constants/constants.dart';
import 'full_screen_audio_player_modal.dart';

class GlobalMiniAudioPlayer extends StatefulWidget {
  const GlobalMiniAudioPlayer({super.key});

  @override
  State<GlobalMiniAudioPlayer> createState() => _GlobalMiniAudioPlayerState();
}

class _GlobalMiniAudioPlayerState extends State<GlobalMiniAudioPlayer>
    with SingleTickerProviderStateMixin {
  final _audioManager = AudioManagerService.instance;

  @override
  void initState() {
    super.initState();
    _audioManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveAudio = _audioManager.currentChannel != null ||
        _audioManager.isPlaying ||
        _audioManager.isLoading ||
        _audioManager.processingState != ProcessingState.idle;

    if (!hasActiveAudio) {
      return const SizedBox.shrink();
    }

    final title = _audioManager.currentTitle ?? 'Holy Quran';
    final subtitle = _audioManager.currentSubtitle ?? 'Mishary Rashid Alafasy';
    final isPlaying = _audioManager.isPlaying;
    final isLoading = _audioManager.isLoading ||
        _audioManager.processingState == ProcessingState.loading ||
        _audioManager.processingState == ProcessingState.buffering;
    final isQuran = _audioManager.currentChannel == AudioChannel.quran;
    final surahNum = _audioManager.currentSurahNumber;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D4D4D), Color(0xFF073030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.gold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D4D4D).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => FullScreenAudioPlayerModal.show(context),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Icon / Medallion
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.gold.withOpacity(0.15),
                        border: Border.all(color: AppConstants.gold.withOpacity(0.5), width: 1),
                      ),
                      child: Center(
                        child: isQuran && surahNum != null
                            ? Text(
                                '$surahNum',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppConstants.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                            : const Icon(Icons.music_note_rounded, color: AppConstants.gold, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Reciter Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Controls: Prev, Play/Pause, Next, Close
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isQuran) ...[
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 22),
                            onPressed: (surahNum ?? 1) > 1
                                ? () => _audioManager.playPrevious()
                                : null,
                            tooltip: 'Previous Surah',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ],

                        // Play/Pause
                        if (isLoading)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(color: AppConstants.gold, strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: AppConstants.gold,
                              size: 34,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                _audioManager.pause();
                              } else {
                                _audioManager.resume();
                              }
                            },
                            tooltip: isPlaying ? 'Pause' : 'Play',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),

                        if (isQuran) ...[
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 22),
                            onPressed: (surahNum ?? 1) < 114
                                ? () => _audioManager.playNext()
                                : null,
                            tooltip: 'Next Surah',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ],

                        // Stop/Dismiss
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                          onPressed: () => _audioManager.stop(),
                          tooltip: 'Stop',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Thin Progress Bar on Bottom
              StreamBuilder<Duration>(
                stream: _audioManager.positionStream,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? _audioManager.position;
                  return StreamBuilder<Duration?>(
                    stream: _audioManager.durationStream,
                    builder: (context, durSnap) {
                      final total = durSnap.data ?? _audioManager.duration ?? Duration.zero;
                      final progress = (total.inMilliseconds > 0)
                          ? (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
                          : 0.0;

                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.gold),
                          minHeight: 2.5,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
