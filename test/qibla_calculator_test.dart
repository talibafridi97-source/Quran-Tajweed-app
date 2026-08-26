import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/core/utils/qibla_calculator.dart';

void main() {
  group('QiblaCalculator — Mathematical Bearing & Orientation Verification', () {
    test('Target Test Location: Kohat, Khyber Pakhtunkhwa, Pakistan calculates accurate Qibla bearing', () {
      // Kohat coordinates
      const double kohatLat = 33.5857;
      const double kohatLng = 71.4414;

      final double bearing = QiblaCalculator.calculateBearing(
        latitude: kohatLat,
        longitude: kohatLng,
      );

      final double distance = QiblaCalculator.calculateDistanceKm(
        latitude: kohatLat,
        longitude: kohatLng,
      );

      // Bearing from Kohat to Kaaba must be approximately 254.97° (West-South-West)
      expect(bearing, closeTo(254.97, 0.5));
      // Distance is ~3,365 km
      expect(distance, closeTo(3365.0, 50.0));
    });

    test('Global Landmark Coordinates produce mathematically authentic Qibla bearings', () {
      final testCases = <String, Map<String, dynamic>>{
        'London, UK': {'lat': 51.5074, 'lng': -0.1278, 'expectedBearing': 118.98},
        'New York, USA': {'lat': 40.7128, 'lng': -74.0060, 'expectedBearing': 58.48},
        'Tokyo, Japan': {'lat': 35.6762, 'lng': 139.6503, 'expectedBearing': 293.02},
        'Cairo, Egypt': {'lat': 30.0444, 'lng': 31.2357, 'expectedBearing': 136.63},
        'Jakarta, Indonesia': {'lat': -6.2088, 'lng': 106.8456, 'expectedBearing': 295.15},
        'Istanbul, Turkey': {'lat': 41.0082, 'lng': 28.9784, 'expectedBearing': 152.05},
      };

      for (final entry in testCases.entries) {
        final cityName = entry.key;
        final data = entry.value;
        final double calculated = QiblaCalculator.calculateBearing(
          latitude: data['lat'] as double,
          longitude: data['lng'] as double,
        );
        final double expected = data['expectedBearing'] as double;
        expect(
          calculated,
          closeTo(expected, 0.5),
          reason: 'Failed Qibla bearing calculation for $cityName',
        );
      }
    });

    test('Relative Qibla angle aligns correctly with physical phone heading', () {
      const double qiblaBearing = 255.0; // Kohat Qibla

      // Phone pointing North (0°) -> Arrow points 255° (WSW)
      expect(
        QiblaCalculator.calculateRelativeAngle(qiblaBearing: qiblaBearing, deviceHeading: 0.0),
        closeTo(255.0, 0.01),
      );

      // Phone rotated to face exactly Qibla (255°) -> Arrow points straight UP (0° / 360°)
      expect(
        QiblaCalculator.calculateRelativeAngle(qiblaBearing: qiblaBearing, deviceHeading: 255.0),
        closeTo(0.0, 0.01),
      );

      // Phone facing South (180°) -> Arrow points 75° (to the right of phone top)
      expect(
        QiblaCalculator.calculateRelativeAngle(qiblaBearing: qiblaBearing, deviceHeading: 180.0),
        closeTo(75.0, 0.01),
      );

      // Phone facing West (270°) -> Arrow points 345° (slightly to the left of phone top)
      expect(
        QiblaCalculator.calculateRelativeAngle(qiblaBearing: qiblaBearing, deviceHeading: 270.0),
        closeTo(345.0, 0.01),
      );
    });

    test('isAligned method accurately detects when phone is aligned within tolerance', () {
      const double qiblaBearing = 255.0;

      // Exactly aligned
      expect(QiblaCalculator.isAligned(qiblaBearing: qiblaBearing, deviceHeading: 255.0), isTrue);

      // Within +/- 3 degrees
      expect(QiblaCalculator.isAligned(qiblaBearing: qiblaBearing, deviceHeading: 253.0), isTrue);
      expect(QiblaCalculator.isAligned(qiblaBearing: qiblaBearing, deviceHeading: 257.5), isTrue);

      // Outside tolerance
      expect(QiblaCalculator.isAligned(qiblaBearing: qiblaBearing, deviceHeading: 240.0), isFalse);
      expect(QiblaCalculator.isAligned(qiblaBearing: qiblaBearing, deviceHeading: 270.0), isFalse);
    });
  });
}
