import 'dart:math';

class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final Duration timeRemaining;
  final String hijriDateString;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.timeRemaining,
    required this.hijriDateString,
  });

  // Calculate prayer times for default or user lat/lng
  factory PrayerTimesModel.calculate({double lat = 24.8607, double lng = 67.0011, DateTime? date}) {
    final now = date ?? DateTime.now();
    final d = now.day;
    final m = now.month;
    final y = now.year;

    // Approximate Islamic Hijri Date calculation
    // Gregorian 2026 conversion baseline
    final julianDay = _gregorianToJD(y, m, d);
    final hijriData = _jdToHijri(julianDay);

    // Astronomical Prayer Time approximation
    final double dayOfYear = now.difference(DateTime(y, 1, 1)).inDays.toDouble();
    final double eqOfTime = 9.87 * sin(_toRadians(2 * 360 / 365 * (dayOfYear - 81))) - 7.53 * cos(_toRadians(360 / 365 * (dayOfYear - 81)));

    final double noonMinutes = 720 - (lng * 4) - eqOfTime + (5 * 60); // GMT+5 default

    final fajrTime = _formatTime(noonMinutes - 90);
    final sunriseTime = _formatTime(noonMinutes - 72);
    final dhuhrTime = _formatTime(noonMinutes + 15);
    final asrTime = _formatTime(noonMinutes + 130);
    final maghribTime = _formatTime(noonMinutes + 200);
    final ishaTime = _formatTime(noonMinutes + 275);

    // Determine current & next prayer
    final currentMinutes = now.hour * 60 + now.minute;
    String current = 'Isha';
    String next = 'Fajr';
    String nextTimeStr = fajrTime;
    int targetMinutes = (noonMinutes - 90).toInt();

    if (currentMinutes < (noonMinutes - 90)) {
      current = 'Isha';
      next = 'Fajr';
      nextTimeStr = fajrTime;
      targetMinutes = (noonMinutes - 90).toInt();
    } else if (currentMinutes < (noonMinutes - 72)) {
      current = 'Fajr';
      next = 'Sunrise';
      nextTimeStr = sunriseTime;
      targetMinutes = (noonMinutes - 72).toInt();
    } else if (currentMinutes < (noonMinutes + 15)) {
      current = 'Sunrise';
      next = 'Dhuhr';
      nextTimeStr = dhuhrTime;
      targetMinutes = (noonMinutes + 15).toInt();
    } else if (currentMinutes < (noonMinutes + 130)) {
      current = 'Dhuhr';
      next = 'Asr';
      nextTimeStr = asrTime;
      targetMinutes = (noonMinutes + 130).toInt();
    } else if (currentMinutes < (noonMinutes + 200)) {
      current = 'Asr';
      next = 'Maghrib';
      nextTimeStr = maghribTime;
      targetMinutes = (noonMinutes + 200).toInt();
    } else if (currentMinutes < (noonMinutes + 275)) {
      current = 'Maghrib';
      next = 'Isha';
      nextTimeStr = ishaTime;
      targetMinutes = (noonMinutes + 275).toInt();
    } else {
      current = 'Isha';
      next = 'Fajr';
      nextTimeStr = fajrTime;
      targetMinutes = (noonMinutes - 90).toInt() + (24 * 60);
    }

    final remainingMins = (targetMinutes - currentMinutes) % (24 * 60);

    return PrayerTimesModel(
      fajr: fajrTime,
      sunrise: sunriseTime,
      dhuhr: dhuhrTime,
      asr: asrTime,
      maghrib: maghribTime,
      isha: ishaTime,
      currentPrayer: current,
      nextPrayer: next,
      nextPrayerTime: nextTimeStr,
      timeRemaining: Duration(minutes: max(0, remainingMins)),
      hijriDateString: '${hijriData[0]} ${hijriData[1]} ${hijriData[2]} AH',
    );
  }

  static double _toRadians(double degree) => degree * pi / 180.0;

  static String _formatTime(double minutes) {
    int totalMins = minutes.round() % (24 * 60);
    int hours = totalMins ~/ 60;
    int mins = totalMins % 60;
    String period = hours >= 12 ? 'PM' : 'AM';
    int h12 = hours % 12;
    if (h12 == 0) h12 = 12;
    String mStr = mins < 10 ? '0$mins' : '$mins';
    return '$h12:$mStr $period';
  }

  static double _gregorianToJD(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    double a = (year / 100).floorToDouble();
    double b = 2 - a + (a / 4).floorToDouble();
    return (365.25 * (year + 4716)).floorToDouble() + (30.6001 * (month + 1)).floorToDouble() + day + b - 1524.5;
  }

  static List<String> _jdToHijri(double jd) {
    double l = jd - 1948440 + 10632;
    double n = ((l - 1) / 10631).floorToDouble();
    l = l - 10631 * n + 354;
    double j = (((10985 - l) / 5316)).floorToDouble() * (((50 * l) / 17719)).floorToDouble() + ((l / 5670)).floorToDouble() * (((43 * l) / 15238)).floorToDouble();
    l = l - (((30 - j) / 15)).floorToDouble() * (((17719 * j) / 50)).floorToDouble() - ((j / 16)).floorToDouble() * (((15238 * j) / 43)).floorToDouble() + 29;
    double month = ((24 * l) / 709).floorToDouble();
    double day = l - ((709 * month) / 24).floorToDouble();
    double year = 30 * n + j - 30;

    const hijriMonths = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];

    int mIdx = (month.toInt() - 1).clamp(0, 11);
    return ['${day.toInt()}', hijriMonths[mIdx], '${year.toInt()}'];
  }
}
