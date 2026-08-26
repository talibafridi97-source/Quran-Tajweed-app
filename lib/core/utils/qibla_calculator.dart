import 'dart:math';

/// Mathematical utility for high-precision Qibla direction, bearing, and distance calculations.
class QiblaCalculator {
  // Kaaba coordinates (standard WGS84 coordinates)
  static const double kaabaLatitude = 21.422524;
  static const double kaabaLongitude = 39.826182;
  static const double earthRadiusKm = 6371.0;

  /// Calculates the initial great-circle Qibla bearing in degrees (0° - 360° clockwise from True North)
  /// from the user's geographic coordinates [latitude] and [longitude] to the Kaaba.
  static double calculateBearing({
    required double latitude,
    required double longitude,
  }) {
    final double phi1 = latitude * pi / 180.0;
    final double phi2 = kaabaLatitude * pi / 180.0;
    final double deltaLambda = (kaabaLongitude - longitude) * pi / 180.0;

    final double y = sin(deltaLambda) * cos(phi2);
    final double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

    final double bearingRad = atan2(y, x);
    final double bearingDeg = (bearingRad * 180.0 / pi + 360.0) % 360.0;

    return bearingDeg;
  }

  /// Calculates the Great Circle distance from the user's coordinates to the Kaaba in kilometers.
  static double calculateDistanceKm({
    required double latitude,
    required double longitude,
  }) {
    final double phi1 = latitude * pi / 180.0;
    final double phi2 = kaabaLatitude * pi / 180.0;
    final double deltaPhi = (kaabaLatitude - latitude) * pi / 180.0;
    final double deltaLambda = (kaabaLongitude - longitude) * pi / 180.0;

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1.0 - a));
    return earthRadiusKm * c;
  }

  /// Calculates the relative Qibla angle (in degrees 0° - 360°) relative to the phone's front/top heading.
  /// When [deviceHeading] is 0° (phone pointing True North), the relative angle equals the Qibla bearing.
  /// When relative angle is ~0° (e.g. 357° - 3°), the phone's top edge is pointing directly at the Kaaba.
  static double calculateRelativeAngle({
    required double qiblaBearing,
    required double deviceHeading,
  }) {
    return (qiblaBearing - deviceHeading + 360.0) % 360.0;
  }

  /// Checks if the device's front/top is aligned with the Qibla within [toleranceDegrees].
  static bool isAligned({
    required double qiblaBearing,
    required double deviceHeading,
    double toleranceDegrees = 4.0,
  }) {
    final double diff = (qiblaBearing - deviceHeading + 360.0) % 360.0;
    return diff <= toleranceDegrees || diff >= (360.0 - toleranceDegrees);
  }
}
