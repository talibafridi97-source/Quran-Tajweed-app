import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_manager_service.dart';
import '../constants/constants.dart';
import 'full_screen_audio_player_modal.dart';

/// Modern Luxury Floating Capsule Mini Audio Player
/// Features glassmorphism backdrop, live audio wave animation,
/// pulsing play/pause button, and full-screen bottom sheet modal expansion.
class GlobalMiniAudioPlayer extends StatefulWidget {
  const GlobalMiniAudioPlayer({super.key});

  @override
  State<GlobalMiniAudioPlayer> createState() => _GlobalMiniAudioPlayerState();
}

class _GlobalMiniAudioPlayerState extends State<GlobalMiniAudioPlayer>
    with SingleTickerProviderStateMixin {
  final _audioManager = AudioManagerService.instance;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _audioManager.addListener(_onStateChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onStateChanged);
    _pulseController.dispose();
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
    final isLoading = _audioManager.isLoading;
    final isQuran = _audioManager.currentChannel == AudioChannel.quran;
    final surahNum = _audioManager.currentSurahNumber;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppConstants.deepEmerald.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppConstants.gold.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.deepEmerald.withValues(alpha: 0.96),
                  const Color(0xFF07261E).withValues(alpha: 0.94),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppConstants.gold.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => FullScreenAudioPlayerModal.show(context),
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // 1. Icon / Medallion Badge
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppConstants.goldLight, AppConstants.gold],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.gold.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Center(
                              child: isQuran && surahNum != null
                                  ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          '$surahNum',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.audiotrack_rounded, color: Colors.black87, size: 18),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 2. Title, Subtitle & Live Audio Wave Bars
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        title,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPlaying) ...[
                                      const SizedBox(width: 6),
                                      _buildLiveAudioWave(),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 4),

                          // 3. Compact Audio Controls (Previous, Play/Pause, Next, Close)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isQuran) ...[
                                IconButton(
                                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 20),
                                  onPressed: (surahNum ?? 1) > 1
                                      ? () => _audioManager.playPrevious()
                                      : null,
                                  tooltip: 'Previous Surah',
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: const EdgeInsets.all(4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],

                              // Play/Pause with subtle glow
                              if (isLoading)
                                const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Padding(
                                    padding: EdgeInsets.all(7.0),
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
                                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                  padding: const EdgeInsets.all(2),
                                  visualDensity: VisualDensity.compact,
                                ),

                              if (isQuran) ...[
                                IconButton(
                                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 20),
                                  onPressed: (surahNum ?? 1) < 114
                                      ? () => _audioManager.playNext()
                                      : null,
                                  tooltip: 'Next Surah',
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: const EdgeInsets.all(4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],

                              // Stop/Dismiss
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 17),
                                onPressed: () => _audioManager.stop(),
                                tooltip: 'Stop',
                                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                padding: const EdgeInsets.all(4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Thin Gold Progress Bar on Bottom
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
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
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
          ),
        ),
      ),
    );
  }

  Widget _buildLiveAudioWave() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWaveBar(5 + 7 * val),
            const SizedBox(width: 2),
            _buildWaveBar(11 - 5 * val),
            const SizedBox(width: 2),
            _buildWaveBar(4 + 8 * val),
          ],
        );
      },
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 2.2,
      height: height.clamp(3.5, 12.0),
      decoration: BoxDecoration(
        color: AppConstants.gold,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
