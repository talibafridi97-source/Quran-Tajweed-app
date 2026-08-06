import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Quran Page Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Arabic Font Size'),
            subtitle: Slider(
              value: settings.arabicFontSize,
              min: 20,
              max: 40,
              onChanged: (value) => settings.setArabicFontSize(value),
            ),
            trailing: Text(settings.arabicFontSize.toInt().toString()),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleDarkMode(value),
          ),
          SwitchListTile(
            title: const Text('Show Translation'),
            value: settings.showTranslation,
            onChanged: (value) => settings.toggleTranslation(value),
          ),
          const Divider(),
          const ListTile(
            title: Text('General', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('About App'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
