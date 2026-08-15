import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/constants/constants.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _userLat;
  double? _userLng;
  double? _deviceHeading;
  bool _isLoadingLocation = true;
  String? _errorMessage;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initQiblaServices();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initQiblaServices() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services (GPS) are disabled on your device. Please turn on GPS.';
          _isLoadingLocation = false;
        });
        return;
      }

      // 2. Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission was denied. Please grant location access to calculate Qibla direction.';
          _isLoadingLocation = false;
        });
        return;
      }

      // 3. Get current position
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        _isLoadingLocation = false;
      });

      // 4. Subscribe to Compass heading events
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted && event.heading != null) {
          setState(() {
            _deviceHeading = event.heading;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to get location. Please verify your GPS signal.';
        _isLoadingLocation = false;
      });
    }
  }

  // Calculate Qibla Bearing to Kaaba (Lat: 21.4225, Lng: 39.8262)
  double get _qiblaBearing {
    if (_userLat == null || _userLng == null) return 0.0;
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    final phi1 = _userLat! * pi / 180.0;
    final phi2 = kaabaLat * pi / 180.0;
    final deltaLambda = (kaabaLng - _userLng!) * pi / 180.0;

    final y = sin(deltaLambda);
    final x = cos(phi1) * tan(phi2) - sin(phi1) * cos(deltaLambda);

    double bearing = atan2(y, x) * 180.0 / pi;
    return (bearing + 360.0) % 360.0;
  }

  double get _distanceToMakkah {
    if (_userLat == null || _userLng == null) return 0.0;
    const double R = 6371;
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    final dLat = (kaabaLat - _userLat!) * pi / 180.0;
    final dLng = (kaabaLng - _userLng!) * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_userLat! * pi / 180.0) * cos(kaabaLat * pi / 180.0) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    final bearing = _qiblaBearing;
    final heading = _deviceHeading ?? 0.0;
    final relativeQiblaAngle = (bearing - heading + 360.0) % 360.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Qibla Finder (قبلہ رخ)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initQiblaServices,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppConstants.primaryGreen),
                  SizedBox(height: 16),
                  Text('Detecting GPS location & Qibla angle...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_rounded, size: 64, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _initQiblaServices,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Enable Location & Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final availableHeight = constraints.maxHeight;
                    final compassSize = (min(availableWidth, availableHeight) * 0.52).clamp(180.0, 260.0);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: max(0, availableHeight - 40)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Location Info Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                                    'Qibla Direction: ${bearing.toStringAsFixed(1)}° True North',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryGreen,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Position: ${_userLat!.toStringAsFixed(4)}°, ${_userLng!.toStringAsFixed(4)}°',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                  Text(
                                    'Distance to Kaaba: ${_distanceToMakkah.toStringAsFixed(0)} km',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Dynamically Scaled Rotatable Compass Dial
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Dial Background
                                  Transform.rotate(
                                    angle: -heading * pi / 180.0,
                                    child: Container(
                                      width: compassSize,
                                      height: compassSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.surface,
                                        border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.3), width: 6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppConstants.primaryGreen.withOpacity(0.15),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned(top: 10, child: Text('N', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red))),
                                          Positioned(bottom: 10, child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                                          Positioned(left: 10, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                                          Positioned(right: 10, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Qibla Pointer Arrow (Rotates directly to Kaaba angle)
                                  Transform.rotate(
                                    angle: relativeQiblaAngle * pi / 180.0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on_rounded, size: compassSize * 0.2, color: AppConstants.gold),
                                        Container(
                                          width: 4,
                                          height: compassSize * 0.28,
                                          color: AppConstants.primaryGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text(
                              _deviceHeading == null
                                  ? 'Rotate device to align with Kaaba indicator.'
                                  : 'Rotate phone until indicator points straight ahead.',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
