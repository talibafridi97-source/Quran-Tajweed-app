import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/constants.dart';
import '../../models/dua_model.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories => [
        'All',
        'Daily',
        'Food',
        'Masjid',
        'Travel',
        'Home',
        'Forgiveness',
        'Knowledge',
        'Family',
        'Distress',
      ];

  List<MasnoonDua> get _filteredDuas {
    if (_selectedCategory == 'All') return MasnoonDua.allDuas;
    return MasnoonDua.allDuas
        .where((d) => d.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Masnoon Duain'),
      ),
      body: Column(
        children: [
          // Category Selector Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppConstants.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected ? AppConstants.primaryGreen : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Duas List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredDuas.length,
              itemBuilder: (context, index) {
                final dua = _filteredDuas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dua.titleEnglish,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGreen,
                            ),
                          ),
                          Text(
                            dua.titleUrdu,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          dua.arabicText,
                          style: TextStyle(
                            fontFamily: AppConstants.uthmaniFont,
                            fontSize: 24,
                            height: 1.9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dua.urduTranslation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.englishTranslation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              dua.reference,
                              style: const TextStyle(fontSize: 11, color: AppConstants.primaryGreen),
                            ),
                            backgroundColor: AppConstants.primaryGreen.withOpacity(0.08),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: '${dua.titleEnglish}\n\n${dua.arabicText}\n\n${dua.urduTranslation}\n\nRef: ${dua.reference}',
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dua copied to clipboard')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                onPressed: () {
                                  Share.share(
                                    '${dua.titleEnglish} (${dua.titleUrdu})\n\n${dua.arabicText}\n\n${dua.urduTranslation}\n\n${dua.englishTranslation}\n\nRef: ${dua.reference}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
