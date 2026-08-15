import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings (الإعدادات)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Quran Reading Settings
          _buildSectionHeader(context, 'Quran Reading', Icons.menu_book),
          _buildCard(
            context,
            [
              ListTile(
                title: const Text('Arabic Font Size'),
                subtitle: Text('${settings.arabicFontSize.round()} pt'),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: settings.arabicFontSize,
                    min: 18,
                    max: 36,
                    divisions: 9,
                    activeColor: AppConstants.primaryGreen,
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
                    activeColor: AppConstants.primaryGreen,
                    onChanged: (val) => settings.setLineSpacing(val),
                  ),
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Tajweed Colors'),
                subtitle: const Text('Highlight Quran recitation rules in color'),
                value: settings.showTajweed,
                activeThumbColor: AppConstants.primaryGreen,
                onChanged: (val) => settings.toggleTajweed(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Urdu Translation'),
                subtitle: const Text('Display Urdu translation under Ayahs'),
                value: settings.showTranslation,
                activeThumbColor: AppConstants.primaryGreen,
                onChanged: (val) => settings.toggleTranslation(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Auto Scroll'),
                subtitle: const Text('Smoothly scroll Quran text automatically'),
                value: settings.enableAutoScroll,
                activeThumbColor: AppConstants.primaryGreen,
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
                      activeColor: AppConstants.primaryGreen,
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
                activeThumbColor: AppConstants.primaryGreen,
                onChanged: (val) => settings.toggleRememberLastPosition(val),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 2: Audio Settings
          _buildSectionHeader(context, 'Audio Preferences', Icons.volume_up),
          _buildCard(
            context,
            [
              const ListTile(
                title: Text('Quran Reciter'),
                subtitle: Text('Mishary Rashid Alafasy'),
                leading: Icon(Icons.record_voice_over, color: AppConstants.primaryGreen),
              ),
              const Divider(),
              const ListTile(
                title: Text('Audio Channel Isolation'),
                subtitle: Text('Strict isolation between Quran, Duas, and Allah Names recitations'),
                leading: Icon(Icons.graphic_eq, color: AppConstants.gold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 3: Prayer & Qibla Settings
          _buildSectionHeader(context, 'Prayer & Location', Icons.access_time_filled),
          _buildCard(
            context,
            [
              const ListTile(
                title: Text('Default Location'),
                subtitle: Text('Kohat, KPK, Pakistan (PKT UTC+5)'),
                leading: Icon(Icons.my_location, color: AppConstants.primaryGreen),
              ),
              const Divider(),
              ListTile(
                title: const Text('Calculation Method'),
                subtitle: const Text('University of Islamic Sciences, Karachi (Hanfi)'),
                leading: const Icon(Icons.domain, color: AppConstants.primaryGreen),
                onTap: () => Navigator.pushNamed(context, AppRoutes.prayerTimes),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 4: Appearance
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          _buildCard(
            context,
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme for comfortable night reading'),
                value: settings.isDarkMode,
                activeThumbColor: AppConstants.primaryGreen,
                onChanged: (val) => settings.toggleDarkMode(val),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 5: Learning & General
          _buildSectionHeader(context, 'Learning & General', Icons.school),
          _buildCard(
            context,
            [
              ListTile(
                title: const Text('Tajweed Rules Learning Guide'),
                subtitle: const Text('Learn Ghunnah, Ikhfa, Idgham, Qalqalah & Madd with examples'),
                leading: const Icon(Icons.menu_book_rounded, color: AppConstants.primaryGreen),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tajweedRules),
              ),
              const Divider(),
              ListTile(
                title: const Text('About Application'),
                subtitle: const Text('Tajweed Quran & Hadith v2.0 • Talib Afridi'),
                leading: const Icon(Icons.info_outline, color: AppConstants.primaryGreen),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy'),
                subtitle: const Text('100% Offline calculation & local storage'),
                leading: const Icon(Icons.privacy_tip_outlined, color: AppConstants.primaryGreen),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryGreen, size: 20),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
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
            Text('Version: 2.0.0'),
            SizedBox(height: 8),
            Text('Developer: Talib Afridi'),
            SizedBox(height: 8),
            Text('Features: Color Tajweed Quran, 30 Paras, Authentic Hadiths, Kohat Prayer Times, Qibla Finder, Masnoon Duas, 99 Names of Allah, Zakat Calculator & Khatam Plan Tracker.'),
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
          'This application respects your privacy. All user preferences, Khatam tracker data, and last read positions are saved strictly on your local device. GPS location data is used exclusively on-device for calculating Qibla bearing and local prayer times.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
