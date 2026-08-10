import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../models/prayer_times_model.dart';

class IslamicCalendarScreen extends StatelessWidget {
  const IslamicCalendarScreen({super.key});

  static const List<Map<String, String>> islamicEvents = [
    {'event': '1st Muharram', 'title': 'Islamic New Year'},
    {'event': '10th Muharram', 'title': 'Day of Ashura'},
    {'event': '12th Rabi al-Awwal', 'title': 'Mawlid an-Nabi'},
    {'event': '27th Rajab', 'title': 'Isra and Mi\'raj'},
    {'event': '15th Sha\'ban', 'title': 'Shab-e-Baraat'},
    {'event': '1st Ramadan', 'title': 'First Day of Ramadan'},
    {'event': '27th Ramadan', 'title': 'Laylat al-Qadr'},
    {'event': '1st Shawwal', 'title': 'Eid al-Fitr'},
    {'event': '8th-13th Dhu al-Hijjah', 'title': 'Hajj Pilgrimage Days'},
    {'event': '9th Dhu al-Hijjah', 'title': 'Day of Arafah'},
    {'event': '10th Dhu al-Hijjah', 'title': 'Eid al-Adha'},
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prayerModel = PrayerTimesModel.calculate(date: now);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('Islamic Calendar (التقويم الهجري)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Date Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryGreen, Color(0xFF006D6D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                const Text('Today\'s Hijri Date', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  prayerModel.hijriDateString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${now.day}/${now.month}/${now.year} Gregorian',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Important Islamic Dates & Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...islamicEvents.map((evt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_note, color: AppConstants.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evt['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        evt['event'] ?? '',
                        style: const TextStyle(color: AppConstants.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
