import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // Default coordinates (e.g. Karachi / Makkah direction baseline)
  final double _userLat = 24.8607;
  final double _userLng = 67.0011;

  double get _qiblaBearing {
    // Kaaba location: 21.4225° N, 39.8262° E
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    final phi1 = _userLat * pi / 180.0;
    final phi2 = kaabaLat * pi / 180.0;
    final deltaLambda = (kaabaLng - _userLng) * pi / 180.0;

    final y = sin(deltaLambda);
    final x = cos(phi1) * tan(phi2) - sin(phi1) * cos(deltaLambda);

    double bearing = atan2(y, x) * 180.0 / pi;
    return (bearing + 360.0) % 360.0;
  }

  double get _distanceToMakkah {
    const double R = 6371; // Earth radius in km
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    final dLat = (kaabaLat - _userLat) * pi / 180.0;
    final dLng = (kaabaLng - _userLng) * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_userLat * pi / 180.0) * cos(kaabaLat * pi / 180.0) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    final bearing = _qiblaBearing;
    final distance = _distanceToMakkah;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('Qibla Finder (قبلہ رخ)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Qibla Angle: ${bearing.toStringAsFixed(1)}° from North',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Distance to Kaaba: ${distance.toStringAsFixed(0)} km',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Compass Dial Graphic
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.3), width: 8),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryGreen.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),

                  // Cardinal Direction Labels
                  const Positioned(top: 16, child: Text('N', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red))),
                  const Positioned(bottom: 16, child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                  const Positioned(left: 16, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                  const Positioned(right: 16, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),

                  // Qibla Pointer Arrow
                  Transform.rotate(
                    angle: bearing * pi / 180.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, size: 50, color: AppConstants.gold),
                        Container(
                          width: 4,
                          height: 70,
                          color: AppConstants.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                'Point the top of your device in the direction of the Kaaba icon.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
