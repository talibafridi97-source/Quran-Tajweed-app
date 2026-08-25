import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_manager_service.dart';
import '../constants/constants.dart';

class FullScreenAudioPlayerModal extends StatefulWidget {
  const FullScreenAudioPlayerModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullScreenAudioPlayerModal(),
    );
  }

  @override
  State<FullScreenAudioPlayerModal> createState() => _FullScreenAudioPlayerModalState();
}

class _FullScreenAudioPlayerModalState extends State<FullScreenAudioPlayerModal> {
  final _audioManager = AudioManagerService.instance;
  double _dragPosition = 0.0;
  bool _isDragging = false;

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

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final title = _audioManager.currentTitle ?? 'Holy Quran Recitation';
    final subtitle = _audioManager.currentSubtitle ?? 'Mishary Rashid Alafasy';
    final isPlaying = _audioManager.isPlaying;
    final isLoading = _audioManager.isLoading ||
        _audioManager.processingState == ProcessingState.loading ||
        _audioManager.processingState == ProcessingState.buffering;
    final isQuran = _audioManager.currentChannel == AudioChannel.quran;
    final surahNum = _audioManager.currentSurahNumber;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0A3A3A), // Deep Emerald
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 25,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 30),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Minimize',
                ),
                Text(
                  'NOW PLAYING',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppConstants.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 24),
                  onPressed: () {
                    _audioManager.stop();
                    Navigator.pop(context);
                  },
                  tooltip: 'Stop & Close',
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Illuminated Medallion Art
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppConstants.accentGreen.withOpacity(0.3),
                          AppConstants.primaryGreen,
                          const Color(0xFF062222),
                        ],
                      ),
                      border: Border.all(color: AppConstants.gold.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.accentGreen.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isQuran && surahNum != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_stories_rounded, color: AppConstants.gold, size: 40),
                                const SizedBox(height: 6),
                                Text(
                                  '$surahNum',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Surah',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.music_note_rounded, color: AppConstants.gold, size: 64),
                    ),
                  ),

                  // Metadata Details
                  Column(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Seek Bar & Timestamps
                  StreamBuilder<Duration>(
                    stream: _audioManager.positionStream,
                    builder: (context, posSnap) {
                      final currentPos = posSnap.data ?? _audioManager.position;
                      return StreamBuilder<Duration?>(
                        stream: _audioManager.durationStream,
                        builder: (context, durSnap) {
                          final totalDur = durSnap.data ?? _audioManager.duration ?? Duration.zero;
                          final maxMs = totalDur.inMilliseconds > 0 ? totalDur.inMilliseconds.toDouble() : 1.0;
                          final currentMs = (_isDragging
                                  ? _dragPosition
                                  : currentPos.inMilliseconds.toDouble())
                              .clamp(0.0, maxMs);

                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor: AppConstants.gold,
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayColor: AppConstants.gold.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: currentMs,
                                  min: 0.0,
                                  max: maxMs,
                                  onChanged: (val) {
                                    setState(() {
                                      _isDragging = true;
                                      _dragPosition = val;
                                    });
                                  },
                                  onChangeEnd: (val) {
                                    _audioManager.seek(Duration(milliseconds: val.round()));
                                    setState(() {
                                      _isDragging = false;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_isDragging
                                          ? Duration(milliseconds: _dragPosition.round())
                                          : currentPos),
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                    Text(
                                      _formatDuration(totalDur),
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  // Main Controls: Prev, Rewind 10, Play/Pause, Fwd 10, Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Surah (if Quran)
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 32),
                        onPressed: isQuran && (surahNum ?? 1) > 1
                            ? () => _audioManager.playPrevious()
                            : null,
                        tooltip: 'Previous Surah',
                      ),
                      const SizedBox(width: 8),

                      // Rewind 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                        onPressed: () => _audioManager.seekBackward(seconds: 10),
                        tooltip: 'Rewind 10s',
                      ),
                      const SizedBox(width: 14),

                      // Play/Pause Main Button
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.gold,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.gold.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(color: Color(0xFF0D4D4D), strokeWidth: 3),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: const Color(0xFF0D4D4D),
                                  size: 40,
                                ),
                                onPressed: () {
                                  if (isPlaying) {
                                    _audioManager.pause();
                                  } else {
                                    _audioManager.resume();
                                  }
                                },
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Fast Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                        onPressed: () => _audioManager.seekForward(seconds: 10),
                        tooltip: 'Forward 10s',
                      ),
                      const SizedBox(width: 8),

                      // Next Surah (if Quran)
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 32),
                        onPressed: isQuran && (surahNum ?? 1) < 114
                            ? () => _audioManager.playNext()
                            : null,
                        tooltip: 'Next Surah',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
