import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> reciters = [
    {'id': 'ar.alafasy', 'name': 'Mishary Rashid Alafasy'},
    {'id': 'ar.abdulbasitmurattal', 'name': 'Abdul Basit Murattal'},
    {'id': 'ar.sudais', 'name': 'Abdur Rahman As-Sudais'},
    {'id': 'ar.ghamadi', 'name': 'Saad Al-Ghamadi'},
    {'id': 'ar.husary', 'name': 'Mahmoud Khalil Al-Husary'},
  ];

  static const List<Map<String, String>> arabicFonts = [
    {'family': AppConstants.indoPakFont, 'name': 'Indo-Pak Tajweed (شیخ المشائخ)'},
    {'family': 'Uthmani', 'name': 'Uthmani Classic (عثماني)'},
    {'family': 'QuranAmiri', 'name': 'Amiri Naskh (أميري)'},
    {'family': 'Urdu', 'name': 'Nastaliq Script (نستعلیق)'},
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings (الإعدادات)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Appearance & Theme Palettes
          _buildSectionHeader(context, 'Appearance & Themes', Icons.palette),
          _buildCard(
            context,
            [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme Palette',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select from 6 bespoke Islamic color palettes',
                      style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: AppThemePalette.values.length,
                      itemBuilder: (context, index) {
                        final palette = AppThemePalette.values[index];
                        final isSelected = settings.themePalette == palette;

                        return InkWell(
                          onTap: () => settings.setThemePalette(palette),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: palette.primaryPreview,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppConstants.gold : Colors.transparent,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppConstants.gold.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: palette.accentPreview,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        palette.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Center(
                                    child: Icon(Icons.check_circle, color: AppConstants.gold, size: 26),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme for comfortable night reading'),
                value: settings.isDarkMode,
                activeColor: scheme.primary,
                onChanged: (val) => settings.toggleDarkMode(val),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 2: Quran Reading Settings
          _buildSectionHeader(context, 'Quran Reading Preferences', Icons.menu_book),
          _buildCard(
            context,
            [
              // Arabic Font Selector
              ListTile(
                title: const Text('Arabic Script Font'),
                subtitle: Text(
                  arabicFonts.firstWhere(
                    (f) => f['family'] == settings.arabicFontFamily,
                    orElse: () => arabicFonts.first,
                  )['name']!,
                ),
                leading: Icon(Icons.font_download_outlined, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showFontPicker(context, settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('Arabic Font Size'),
                subtitle: Text('${settings.arabicFontSize.round()} pt'),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: settings.arabicFontSize,
                    min: 24,
                    max: 48,
                    divisions: 12,
                    activeColor: scheme.primary,
                    onChanged: (val) => settings.setArabicFontSize(val),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Arabic Line Spacing'),
                subtitle: Text('${settings.lineSpacing.toStringAsFixed(1)}x'),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: settings.lineSpacing,
                    min: 1.5,
                    max: 3.0,
                    divisions: 6,
                    activeColor: scheme.primary,
                    onChanged: (val) => settings.setLineSpacing(val),
                  ),
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Tajweed Colors'),
                subtitle: const Text('Highlight recitation rules in color'),
                value: settings.showTajweed,
                activeColor: scheme.primary,
                onChanged: (val) => settings.toggleTajweed(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Translation Display'),
                subtitle: const Text('Display translations under Quran Ayahs'),
                value: settings.showTranslation,
                activeColor: scheme.primary,
                onChanged: (val) => settings.toggleTranslation(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Auto Scroll'),
                subtitle: const Text('Smoothly scroll Quran text automatically'),
                value: settings.enableAutoScroll,
                activeColor: scheme.primary,
                onChanged: (val) => settings.toggleAutoScroll(val),
              ),
              if (settings.enableAutoScroll) ...[
                ListTile(
                  title: const Text('Auto Scroll Speed'),
                  subtitle: Text(settings.autoScrollSpeed == 1.0
                      ? 'Slow'
                      : settings.autoScrollSpeed == 2.0
                          ? 'Medium'
                          : 'Fast'),
                  trailing: SizedBox(
                    width: 140,
                    child: Slider(
                      value: settings.autoScrollSpeed,
                      min: 1.0,
                      max: 3.0,
                      divisions: 2,
                      activeColor: scheme.primary,
                      onChanged: (val) => settings.setAutoScrollSpeed(val),
                    ),
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                title: const Text('Remember Reading Position'),
                subtitle: const Text('Save last read Ayah & Page on exit'),
                value: settings.rememberLastPosition,
                activeColor: scheme.primary,
                onChanged: (val) => settings.toggleRememberLastPosition(val),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 3: Audio Preferences
          _buildSectionHeader(context, 'Audio Preferences', Icons.volume_up),
          _buildCard(
            context,
            [
              ListTile(
                title: const Text('Default Reciter (Qari)'),
                subtitle: Text(settings.qariName),
                leading: Icon(Icons.record_voice_over, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showQariPicker(context, settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('Sleep Timer'),
                subtitle: Text(settings.sleepTimerMinutes == 0
                    ? 'Off'
                    : '${settings.sleepTimerMinutes} minutes'),
                leading: Icon(Icons.timer_outlined, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showSleepTimerDialog(context, settings),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 4: Islamic Utilities & Learning
          _buildSectionHeader(context, 'Islamic Utilities & Learning', Icons.school),
          _buildCard(
            context,
            [
              ListTile(
                title: const Text('Interactive Tajweed Guide'),
                subtitle: const Text('Learn Ghunnah, Ikhfa, Idgham, Qalqalah & Waqf signs'),
                leading: Icon(Icons.school_rounded, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tajweedRules),
              ),
              const Divider(),
              ListTile(
                title: const Text('Digital Tasbeeh Counter'),
                subtitle: const Text('Count Dhikr, set targets & view history logs'),
                leading: Icon(Icons.fingerprint, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tasbeeh),
              ),
              const Divider(),
              ListTile(
                title: const Text('Replay App Onboarding'),
                subtitle: const Text('View feature walkthrough introduction'),
                leading: Icon(Icons.slideshow_rounded, color: scheme.primary),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, AppRoutes.onboarding),
              ),
              const Divider(),
              ListTile(
                title: const Text('About Application'),
                subtitle: const Text('Tajweed Quran & Hadith v3.0 • Authentic & Offline'),
                leading: Icon(Icons.info_outline, color: scheme.primary),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy'),
                subtitle: const Text('100% Offline calculation & local storage'),
                leading: Icon(Icons.privacy_tip_outlined, color: scheme.primary),
                onTap: () => _showPrivacyDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
      child: Column(children: children),
    );
  }

  void _showFontPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Arabic Font'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: arabicFonts.map((font) {
            final isSelected = settings.arabicFontFamily == font['family'];
            return ListTile(
              title: Text(font['name']!),
              trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryGreen) : null,
              onTap: () {
                settings.setArabicFontFamily(font['family']!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showQariPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Default Reciter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reciters.map((q) {
            final isSelected = settings.qariId == q['id'];
            return ListTile(
              title: Text(q['name']!),
              trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryGreen) : null,
              onTap: () {
                settings.setQari(q['id']!, q['name']!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context, SettingsProvider settings) {
    final timers = [0, 15, 30, 45, 60];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Audio Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timers.map((mins) {
            final isSelected = settings.sleepTimerMinutes == mins;
            return ListTile(
              title: Text(mins == 0 ? 'Off' : '$mins minutes'),
              trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryGreen) : null,
              onTap: () {
                settings.setSleepTimerMinutes(mins);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: AppConstants.primaryGreen),
            SizedBox(width: 10),
            Text('Tajweed Quran & Hadith'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 3.0.0 (Phase 3 Upgrade)'),
            SizedBox(height: 8),
            Text('Developer: Talib Afridi'),
            SizedBox(height: 8),
            Text('Features: 6 Multi-Palette Themes, Interactive Tajweed Rules, 16-Line Quran Mushaf, Smart Digital Tasbeeh with SQLite History, Multi-Translation, Ibn Kathir Tafsir, FTS5 Search & Bookmarks.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const Text(
          'This application respects your privacy. All user preferences, Tasbeeh history, and bookmarks are saved strictly on your local device. GPS location data is used exclusively on-device for calculating Qibla bearing and local prayer times.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
