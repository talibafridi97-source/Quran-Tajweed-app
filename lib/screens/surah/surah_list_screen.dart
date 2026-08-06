import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../core/constants/constants.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuranProvider>().fetchSurahs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Surah Index')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.surahs.length,
              itemBuilder: (context, index) {
                final surah = provider.surahs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryGreen,
                    child: Text('${surah.number}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(surah.englishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${surah.revelationType} • ${surah.numberOfAyahs} Ayahs'),
                  trailing: Text(
                    surah.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
