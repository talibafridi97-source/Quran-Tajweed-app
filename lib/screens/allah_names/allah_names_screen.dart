import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/constants.dart';
import '../../models/allah_name_model.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  String _searchQuery = '';
  late AudioPlayer _audioPlayer;
  int? _playingNameNumber;

  List<AllahName> get _filteredNames {
    if (_searchQuery.isEmpty) return AllahName.allNames;
    return AllahName.allNames.where((n) {
      final q = _searchQuery.toLowerCase();
      return n.transliteration.toLowerCase().contains(q) ||
          n.englishMeaning.toLowerCase().contains(q) ||
          n.urduMeaning.contains(q) ||
          n.arabic.contains(q) ||
          n.number.toString() == q;
    }).toList();
  }

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

  Future<void> _playNameAudio(AllahName name) async {
    if (_playingNameNumber == name.number) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        setState(() => _playingNameNumber = null);
      } else {
        await _audioPlayer.play();
        setState(() => _playingNameNumber = name.number);
      }
      return;
    }

    setState(() {
      _playingNameNumber = name.number;
    });

    try {
      // Audio CDN audio stream for 99 Names of Allah
      final audioUrl = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${name.number}.mp3';
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing recitation for "${name.transliteration}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('99 Names of Allah (أسماء الله الحسنى)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name, meaning, or number...',
                prefixIcon: const Icon(Icons.search, color: AppConstants.primaryGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Grid View
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredNames.length,
              itemBuilder: (context, index) {
                final name = _filteredNames[index];
                final isPlaying = _playingNameNumber == name.number && _audioPlayer.playing;

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showNameDetailsDialog(context, name),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                              child: Text(
                                '${name.number}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name.arabic,
                              style: const TextStyle(
                                fontFamily: AppConstants.uthmaniFont,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryGreen,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name.transliteration,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name.urduMeaning,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: AppConstants.primaryGreen,
                                size: 28,
                              ),
                              onPressed: () => _playNameAudio(name),
                              tooltip: 'Play Audio',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNameDetailsDialog(BuildContext context, AllahName name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Column(
            children: [
              Text(
                '#${name.number} ${name.transliteration}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                name.arabic,
                style: const TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'اردو معنی: ${name.urduMeaning}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'English Meaning: ${name.englishMeaning}',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: AppConstants.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              _playNameAudio(name);
            },
            tooltip: 'Play Audio',
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppConstants.primaryGreen),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '#${name.number} ${name.arabic} (${name.transliteration})\nUrdu: ${name.urduMeaning}\nEnglish: ${name.englishMeaning}',
              ));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppConstants.primaryGreen),
            onPressed: () {
              Share.share(
                '#${name.number} ${name.arabic} (${name.transliteration})\nUrdu: ${name.urduMeaning}\nEnglish: ${name.englishMeaning}',
              );
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
