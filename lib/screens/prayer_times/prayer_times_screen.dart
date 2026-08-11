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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNotifyPrayerTime();
    });
  }

  Future<void> _checkAndNotifyPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    final prayerModel = PrayerTimesModel.calculate(date: now);
    final currentPrayer = prayerModel.currentPrayer;

    // Ignore Sunrise since it's not a prayer
    if (currentPrayer == 'Sunrise') return;

    final lastPrayer = prefs.getString('last_notified_prayer');
    final lastDate = prefs.getString('last_notified_date');

    // Trigger notification only ONCE per prayer per day
    if (lastDate != todayStr || lastPrayer != currentPrayer) {
      await prefs.setString('last_notified_prayer', currentPrayer);
      await prefs.setString('last_notified_date', todayStr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.access_time_filled, color: AppConstants.gold),
                const SizedBox(width: 12),
                Text('$currentPrayer prayer time has started.'),
              ],
            ),
            backgroundColor: AppConstants.primaryGreen,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: const Text('Prayer Times & Ramadan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const Text(
            'Daily Prayer Schedule',
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
