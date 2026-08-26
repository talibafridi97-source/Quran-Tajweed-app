import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../models/tajweed_rule_model.dart';
import '../../services/audio_manager_service.dart';

class TajweedRulesScreen extends StatefulWidget {
  const TajweedRulesScreen({super.key});

  @override
  State<TajweedRulesScreen> createState() => _TajweedRulesScreenState();
}

class _TajweedRulesScreenState extends State<TajweedRulesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TajweedCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TajweedRuleModel> get _filteredRules {
    return TajweedRuleModel.allRules.where((rule) {
      final matchesCategory = _selectedCategory == null || rule.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          rule.titleEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rule.titleArabic.contains(_searchQuery) ||
          rule.titleUrdu.contains(_searchQuery) ||
          rule.explanationEnglish.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<WaqfSymbolModel> get _filteredWaqfSymbols {
    if (_searchQuery.isEmpty) return WaqfSymbolModel.allWaqfSymbols;
    return WaqfSymbolModel.allWaqfSymbols.where((item) {
      return item.symbol.contains(_searchQuery) ||
          item.titleEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.titleArabic.contains(_searchQuery) ||
          item.titleUrdu.contains(_searchQuery) ||
          item.meaning.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tajweed Guide (أحكام التجويد)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.gold,
          indicatorWeight: 3,
          labelColor: scheme.onPrimary,
          unselectedLabelColor: scheme.onPrimary.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Recitation Rules'),
            Tab(icon: Icon(Icons.pan_tool_alt_rounded), text: 'Waqf & Symbols'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Tajweed rules, letters, signs...',
                prefixIcon: Icon(Icons.search, color: scheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),

          // Main Tabs View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRulesTab(context),
                _buildWaqfTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rules = _filteredRules;

    return Column(
      children: [
        // Category Filter Chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: const Text('All Rules'),
                  selected: _selectedCategory == null,
                  selectedColor: scheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: scheme.primary,
                  labelStyle: TextStyle(
                    fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                    color: _selectedCategory == null ? scheme.primary : scheme.onSurface,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                  },
                ),
              ),
              ...TajweedCategory.values
                  .where((c) => c != TajweedCategory.waqfSigns && c != TajweedCategory.quranSymbols)
                  .map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6)),
                    label: Text(cat.titleEnglish),
                    selected: isSelected,
                    selectedColor: scheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: scheme.primary,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? cat : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Rules List
        Expanded(
          child: rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: scheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text('No rules found matching "$_searchQuery"', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    return _buildRuleCard(context, rules[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context, TajweedRuleModel rule) {
    final scheme = Theme.of(context).colorScheme;
    final audioManager = context.watch<AudioManagerService>();
    final isPlaying = audioManager.isPlaying && audioManager.currentAudioId == 'tajweed_${rule.id}';
    final isLoading = audioManager.isLoading && audioManager.currentAudioId == 'tajweed_${rule.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rule.ruleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: rule.ruleColor.withValues(alpha: 0.5)),
            ),
            child: Icon(rule.category.icon, color: rule.ruleColor, size: 22),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.titleEnglish,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${rule.titleArabic} • ${rule.titleUrdu}',
                      style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rule.ruleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rule.ruleColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: rule.ruleColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Tajweed Color',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: rule.ruleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            const Divider(),
            const SizedBox(height: 6),

            // Rule Letters Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.spellcheck, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Letters: ${rule.ruleLetters}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: scheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // English & Urdu Explanations
            Text(
              rule.explanationEnglish,
              style: TextStyle(fontSize: 14, height: 1.4, color: scheme.onSurface.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                rule.explanationUrdu,
                style: TextStyle(fontSize: 13, height: 1.4, color: scheme.onSurface.withValues(alpha: 0.75)),
                textDirection: TextDirection.rtl,
              ),
            ),

            const SizedBox(height: 14),

            // Pronunciation Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.gold.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppConstants.gold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recitation Tip:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppConstants.gold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rule.pronunciationTip,
                          style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Authentic Quranic Example Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_stories, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('Canonical Quran Example:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                Text(
                  rule.surahRef,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.primary),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Verified Quran Arabic Calligraphic Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: rule.ruleColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: rule.ruleColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  TajweedText(
                    rawText: rule.authenticExampleArabic,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  if (rule.audioUrl != null) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        if (isPlaying) {
                          audioManager.pause();
                        } else {
                          audioManager.playItem(
                            channel: AudioChannel.quran,
                            id: 'tajweed_${rule.id}',
                            url: rule.audioUrl!,
                            title: '${rule.titleEnglish} Pronunciation',
                            subtitle: rule.surahRef,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPlaying ? scheme.primary : scheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoading)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                              )
                            else
                              Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.volume_up_rounded,
                                size: 18,
                                color: isPlaying ? scheme.onPrimary : scheme.primary,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              isPlaying ? 'Playing Pronunciation...' : 'Listen Example',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPlaying ? scheme.onPrimary : scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaqfTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final symbols = _filteredWaqfSymbols;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        final sym = symbols[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppConstants.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppConstants.gold.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        sym.symbol,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.gold,
                          fontFamily: AppConstants.uthmaniFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sym.titleEnglish,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${sym.titleArabic} • ${sym.titleUrdu}',
                          style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.65)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sym.meaning,
                style: TextStyle(fontSize: 14, height: 1.4, color: scheme.onSurface.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rule: ${sym.rule}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quran Reference:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(sym.surahRef, style: TextStyle(fontSize: 11, color: scheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
                ),
                child: TajweedText(
                  rawText: sym.authenticQuranExample,
                  fontSize: 20,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
