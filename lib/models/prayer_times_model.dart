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

  // Calculate prayer times dynamically using astronomical solar position equations
  factory PrayerTimesModel.calculate({
    double lat = 33.5869,
    double lng = 71.4426,
    DateTime? date,
    double? timeZoneOffsetHours,
    bool isHanafi = false,
  }) {
    final now = date ?? DateTime.now();

    // Timezone offset in hours (+5.0 for PKT / Kohat)
    final tz = timeZoneOffsetHours ??
        ((lat == 33.5869 && lng == 71.4426) || (lat >= 23.5 && lat <= 37.0 && lng >= 60.0 && lng <= 77.0)
            ? 5.0
            : (now.timeZoneOffset.inMinutes / 60.0));

    // Target location local date and time
    final locationNow = now.toUtc().add(Duration(minutes: (tz * 60).round()));
    final d = locationNow.day;
    final m = locationNow.month;
    final y = locationNow.year;

    // Islamic Hijri Date calculation
    final julianDay = _gregorianToJD(y, m, d);
    final hijriData = _jdToHijri(julianDay);

    // Astronomical Calculation
    final double dayOfYear = DateTime(y, m, d).difference(DateTime(y, 1, 1)).inDays + 1.0;

    // Solar declination (in degrees)
    final double declination = 23.44 * sin(_toRadians(360 / 365.24 * (dayOfYear - 81)));

    // Equation of time (in minutes)
    final double eqOfTime = 9.87 * sin(_toRadians(2 * 360 / 365.24 * (dayOfYear - 81))) -
        7.53 * cos(_toRadians(360 / 365.24 * (dayOfYear - 81)));

    // Solar noon in minutes from midnight
    final double solarNoonMinutes = 720.0 + (tz * 60.0) - (lng * 4.0) - eqOfTime;

    // Helper to calculate hour angle H for a target sun altitude angle (in degrees)
    double? calculateHourAngle(double angleDeg) {
      final latRad = _toRadians(lat);
      final decRad = _toRadians(declination);
      final angleRad = _toRadians(angleDeg);

      final cosH = (sin(angleRad) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad));
      if (cosH < -1.0 || cosH > 1.0) return null;
      return acos(cosH) * 180.0 / pi * 4.0; // convert degrees to minutes (1 deg = 4 mins)
    }

    // Sunrise / Maghrib: Sun is 0.833 degrees below horizon
    final sunRiseSetMinutes = calculateHourAngle(-0.833) ?? 340.0;
    final sunriseMinutes = solarNoonMinutes - sunRiseSetMinutes;
    final maghribMinutes = solarNoonMinutes + sunRiseSetMinutes;

    // Fajr: Sun is 18 degrees below horizon (Karachi / Pakistan Standard)
    final fajrMinutesOffset = calculateHourAngle(-18.0) ?? (sunRiseSetMinutes + 90.0);
    final fajrMinutes = solarNoonMinutes - fajrMinutesOffset;

    // Isha: Sun is 18 degrees below horizon (Karachi / Pakistan Standard)
    final ishaMinutesOffset = calculateHourAngle(-18.0) ?? (sunRiseSetMinutes + 90.0);
    final ishaMinutes = solarNoonMinutes + ishaMinutesOffset;

    // Dhuhr: Solar noon + 1 minute
    final dhuhrMinutes = solarNoonMinutes + 1.0;

    // Asr: Shadow factor N = 1 (Standard Shafi/Maliki/Hanbali) or N = 2 (Hanafi)
    final shadowFactor = isHanafi ? 2.0 : 1.0;
    final latDecDiffRad = _toRadians((lat - declination).abs());
    final asrAngleRad = atan(1.0 / (shadowFactor + tan(latDecDiffRad)));
    final asrAngleDeg = asrAngleRad * 180.0 / pi;
    final asrMinutesOffset = calculateHourAngle(asrAngleDeg) ?? 230.0;
    final asrMinutes = solarNoonMinutes + asrMinutesOffset;

    final fajrTime = _formatTime(fajrMinutes);
    final sunriseTime = _formatTime(sunriseMinutes);
    final dhuhrTime = _formatTime(dhuhrMinutes);
    final asrTime = _formatTime(asrMinutes);
    final maghribTime = _formatTime(maghribMinutes);
    final ishaTime = _formatTime(ishaMinutes);

    // Determine current & next prayer
    final currentMinutes = locationNow.hour * 60 + locationNow.minute;
    String current = 'Isha';
    String next = 'Fajr';
    String nextTimeStr = fajrTime;
    int targetMinutes = fajrMinutes.toInt();

    if (currentMinutes < fajrMinutes) {
      current = 'Isha';
      next = 'Fajr';
      nextTimeStr = fajrTime;
      targetMinutes = fajrMinutes.toInt();
    } else if (currentMinutes < sunriseMinutes) {
      current = 'Fajr';
      next = 'Sunrise';
      nextTimeStr = sunriseTime;
      targetMinutes = sunriseMinutes.toInt();
    } else if (currentMinutes < dhuhrMinutes) {
      current = 'Sunrise';
      next = 'Dhuhr';
      nextTimeStr = dhuhrTime;
      targetMinutes = dhuhrMinutes.toInt();
    } else if (currentMinutes < asrMinutes) {
      current = 'Dhuhr';
      next = 'Asr';
      nextTimeStr = asrTime;
      targetMinutes = asrMinutes.toInt();
    } else if (currentMinutes < maghribMinutes) {
      current = 'Asr';
      next = 'Maghrib';
      nextTimeStr = maghribTime;
      targetMinutes = maghribMinutes.toInt();
    } else if (currentMinutes < ishaMinutes) {
      current = 'Maghrib';
      next = 'Isha';
      nextTimeStr = ishaTime;
      targetMinutes = ishaMinutes.toInt();
    } else {
      current = 'Isha';
      next = 'Fajr';
      nextTimeStr = fajrTime;
      targetMinutes = fajrMinutes.toInt() + (24 * 60);
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

  static String getPrayerAlertMessage(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 'Fajr prayer time has started.';
      case 'Dhuhr':
        return 'Dhuhr prayer time has started.';
      case 'Asr':
        return 'Asr prayer time has started.';
      case 'Maghrib':
        return 'Maghrib prayer time has started.';
      case 'Isha':
        return 'Isha prayer time has started.';
      default:
        return '$prayerName prayer time has started.';
    }
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

  static List<String> _jdToHijri(double jd, {int offsetDays = 1}) {
    // Kuwaiti algorithm for Gregorian to Hijri date conversion
    double z = (jd + 0.5).floorToDouble() - 1948440 + offsetDays;
    double i = (z / 10631.0).floorToDouble();
    double f = z - 10631.0 * i;
    double j = ((f - 1.0) / 354.366).floorToDouble();
    if (j > 29) j = 29;
    double h = (f - 1.0) - (354.366 * j).floorToDouble();
    double month = ((h + 29.5) / 29.5).floorToDouble();
    double day = h - (29.5 * (month - 1.0)).roundToDouble() + 1.0;
    double year = 30.0 * i + j + 1.0;

    const hijriMonths = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];

    int mIdx = (month.toInt() - 1).clamp(0, 11);
    int dayVal = day.toInt().clamp(1, 30);
    int yearVal = year.toInt();

    return ['$dayVal', hijriMonths[mIdx], '$yearVal'];
  }
}
