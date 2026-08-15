import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/prayer_times_model.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _alertsEnabled = true;
  bool _silentModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNotifyPrayerTime();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _alertsEnabled = prefs.getBool('prayer_alerts_enabled') ?? true;
      _silentModeEnabled = prefs.getBool('prayer_silent_mode') ?? false;
    });
  }

  Future<void> _checkAndNotifyPrayerTime() async {
    if (!_alertsEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    final prayerModel = PrayerTimesModel.calculate(date: now);
    final currentPrayer = prayerModel.currentPrayer;

    // Ignore Sunrise as it's not a prayer
    if (currentPrayer == 'Sunrise') return;

    final lastPrayer = prefs.getString('last_notified_prayer');
    final lastDate = prefs.getString('last_notified_date');

    // Trigger alert ONLY ONCE per prayer occurrence per day
    if (lastDate != todayStr || lastPrayer != currentPrayer) {
      await prefs.setString('last_notified_prayer', currentPrayer);
      await prefs.setString('last_notified_date', todayStr);

      final message = PrayerTimesModel.getPrayerAlertMessage(currentPrayer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppConstants.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppConstants.primaryGreen,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimes = PrayerTimesModel.calculate();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Prayer Times (اوقات الصلاة)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Location Badge Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: AppConstants.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'Location: Kohat, KPK, Pakistan (PKT UTC+5)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.primaryGreen),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Next Prayer Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  prayerTimes.hijriDateString,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Next Prayer: ${prayerTimes.nextPrayer}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayerTimes.nextPrayerTime,
                  style: const TextStyle(
                    color: AppConstants.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${prayerTimes.timeRemaining.inHours}h ${prayerTimes.timeRemaining.inMinutes % 60}m',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Prayer Settings Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Prayer Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Notify when prayer time enters (Fajr, Dhuhr, Asr, Maghrib, Isha)'),
                  value: _alertsEnabled,
                  activeColor: AppConstants.primaryGreen,
                  onChanged: (val) async {
                    setState(() => _alertsEnabled = val);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('prayer_alerts_enabled', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Silent Mode during prayer', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Reminder to set device to Silent during Jamat'),
                  value: _silentModeEnabled,
                  activeColor: AppConstants.primaryGreen,
                  onChanged: (val) async {
                    setState(() => _silentModeEnabled = val);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('prayer_silent_mode', val);
                    if (val && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Silent Mode reminder enabled for prayer times')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Daily Prayer Schedule (Kohat, KPK)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Prayer Rows
          _buildPrayerTile(context, 'Fajr (فجر)', prayerTimes.fajr, prayerTimes.currentPrayer == 'Fajr'),
          _buildPrayerTile(context, 'Sunrise (اشراق)', prayerTimes.sunrise, prayerTimes.currentPrayer == 'Sunrise'),
          _buildPrayerTile(context, 'Dhuhr (ظهر)', prayerTimes.dhuhr, prayerTimes.currentPrayer == 'Dhuhr'),
          _buildPrayerTile(context, 'Asr (عصر)', prayerTimes.asr, prayerTimes.currentPrayer == 'Asr'),
          _buildPrayerTile(context, 'Maghrib / Iftar (مغرب)', prayerTimes.maghrib, prayerTimes.currentPrayer == 'Maghrib'),
          _buildPrayerTile(context, 'Isha (عشاء)', prayerTimes.isha, prayerTimes.currentPrayer == 'Isha'),

          const SizedBox(height: 24),

          // Ramadan Sehri / Iftar Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.gold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.wb_twilight, color: AppConstants.gold, size: 28),
                    const SizedBox(height: 4),
                    Text('Sehri End (Fajr)', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(prayerTimes.fajr, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                Container(height: 40, width: 1, color: Theme.of(context).colorScheme.outlineVariant),
                Column(
                  children: [
                    const Icon(Icons.nights_stay, color: AppConstants.primaryGreen, size: 28),
                    const SizedBox(height: 4),
                    Text('Iftar (Maghrib)', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(prayerTimes.maghrib, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTile(BuildContext context, String name, String time, bool isCurrent) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrent ? scheme.primary.withOpacity(0.08) : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? scheme.primary : scheme.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCurrent ? Icons.access_time_filled : Icons.access_time,
                color: isCurrent ? scheme.primary : scheme.onSurface.withOpacity(0.45),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  color: isCurrent ? scheme.primary : scheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrent ? scheme.primary : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
