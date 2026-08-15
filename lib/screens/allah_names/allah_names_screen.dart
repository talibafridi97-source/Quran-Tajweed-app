import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/constants.dart';
import '../../models/allah_name_model.dart';
import '../../services/audio_manager_service.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  String _searchQuery = '';
  final _audioManager = AudioManagerService();

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
    _audioManager.addListener(_onAudioStateChanged);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _playNameAudio(AllahName name) async {
    final audioId = 'name_${name.number}';
    final audioUrl = 'https://raw.githubusercontent.com/soachishti/Asma-ul-Husna/master/audio/${name.number}.mp3';

    await _audioManager.playItem(
      channel: AudioChannel.name,
      id: audioId,
      url: audioUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('99 Names of Allah (أسماء الله الحسنى)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_audioManager.currentChannel == AudioChannel.name && _audioManager.isPlaying)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              onPressed: () => _audioManager.stop(),
              tooltip: 'Stop Audio',
            ),
        ],
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
                fillColor: Theme.of(context).colorScheme.surface,
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
                childAspectRatio: 0.72,
              ),
              itemCount: _filteredNames.length,
              itemBuilder: (context, index) {
                final name = _filteredNames[index];
                final audioId = 'name_${name.number}';
                final isPlaying = _audioManager.isItemPlaying(AudioChannel.name, audioId);

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPlaying ? AppConstants.primaryGreen : Theme.of(context).colorScheme.outlineVariant,
                      width: isPlaying ? 2 : 1,
                    ),
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
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                              child: Text(
                                '${name.number}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                name.arabic,
                                style: const TextStyle(
                                  fontFamily: AppConstants.uthmaniFont,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name.transliteration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name.urduMeaning,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    final audioId = 'name_${name.number}';
    final isPlaying = _audioManager.isItemPlaying(AudioChannel.name, audioId);

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
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppConstants.primaryGreen,
            ),
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
