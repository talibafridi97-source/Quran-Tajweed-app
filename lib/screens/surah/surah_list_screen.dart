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
      backgroundColor: const Color(0xFF002121),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Surah Index',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Decorative Border (Simulation)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFECC146), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFECC146), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFECC146)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: provider.surahs.length,
                  itemBuilder: (context, index) {
                    final surah = provider.surahs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailScreen(surah: surah),
                            ),
                          );
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECC146),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              // Surah Number with decorative frame simulation
                              Positioned(
                                left: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black54, width: 1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${surah.number}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // English Name and Page Info
                              Positioned(
                                left: 65,
                                top: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.englishName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Page: ${index * 2 + 1}', // Placeholder for page number
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Arabic Name
                              Positioned(
                                right: 16,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    surah.name,
                                    style: const TextStyle(
                                      fontFamily: AppConstants.uthmaniFont,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
