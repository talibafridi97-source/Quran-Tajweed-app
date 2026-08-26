import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/qibla_calculator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _userLat;
  double? _userLng;
  double? _deviceHeading;
  double? _compassAccuracy;
  bool _isLoadingLocation = true;
  bool _hasCompassSensor = true;
  bool _showCalibrationPrompt = false;
  String? _errorMessage;
  bool _wasAligned = false;

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
          _errorMessage = 'Location services (GPS) are disabled on your device. Please enable GPS in device settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      // 2. Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permission was denied. Please grant location access to calculate Qibla direction.';
          _isLoadingLocation = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. Please enable them in App Settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      // 3. Get current position with timeout & last known position fallback
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (_) {
        // Fallback to last known position if timeout occurs indoors
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        setState(() {
          _errorMessage = 'Could not acquire GPS coordinates. Please move outdoors or check device location settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      setState(() {
        _userLat = pos?.latitude;
        _userLng = pos?.longitude;
        _isLoadingLocation = false;
      });

      // 4. Initialize compass heading stream
      _subscribeToCompass();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  void _subscribeToCompass() {
    _compassSubscription?.cancel();

    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      setState(() {
        _hasCompassSensor = false;
      });
      return;
    }

    _compassSubscription = compassEvents.listen(
      (CompassEvent event) {
        if (!mounted) return;

        final heading = event.heading;
        final accuracy = event.accuracy;

        if (heading != null) {
          final qiblaBearing = _qiblaBearing;
          final isCurrentlyAligned = QiblaCalculator.isAligned(
            qiblaBearing: qiblaBearing,
            deviceHeading: heading,
          );

          if (isCurrentlyAligned && !_wasAligned) {
            HapticFeedback.selectionClick();
          }
          _wasAligned = isCurrentlyAligned;

          setState(() {
            _deviceHeading = (heading + 360.0) % 360.0;
            _compassAccuracy = accuracy;
            _hasCompassSensor = true;
            // On Android, accuracy <= 15 or accuracy == null can indicate uncalibrated sensor
            if (accuracy != null && accuracy < 15) {
              _showCalibrationPrompt = true;
            } else if (accuracy != null && accuracy >= 15) {
              _showCalibrationPrompt = false;
            }
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _hasCompassSensor = false;
          });
        }
      },
    );
  }

  double get _qiblaBearing {
    if (_userLat == null || _userLng == null) return 0.0;
    return QiblaCalculator.calculateBearing(
      latitude: _userLat!,
      longitude: _userLng!,
    );
  }

  double get _distanceToKaabaKm {
    if (_userLat == null || _userLng == null) return 0.0;
    return QiblaCalculator.calculateDistanceKm(
      latitude: _userLat!,
      longitude: _userLng!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bearing = _qiblaBearing;
    final heading = _deviceHeading ?? 0.0;
    final relativeQiblaAngle = QiblaCalculator.calculateRelativeAngle(
      qiblaBearing: bearing,
      deviceHeading: heading,
    );
    final isAligned = _hasCompassSensor &&
        _deviceHeading != null &&
        QiblaCalculator.isAligned(
          qiblaBearing: bearing,
          deviceHeading: heading,
        );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Qibla Finder (قبلہ رخ)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initQiblaServices,
            tooltip: 'Refresh GPS Location',
          ),
        ],
      ),
      body: _isLoadingLocation
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppConstants.primaryGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Detecting GPS location & computing Qibla...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                  ),
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
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Location Detection'),
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
                    final compassSize = (min(availableWidth, availableHeight) * 0.60).clamp(200.0, 280.0);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: max(0, availableHeight - 32)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Calibration Notice (if required)
                            if (_showCalibrationPrompt && _hasCompassSensor)
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.screen_rotation_rounded, color: Colors.amber, size: 22),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Compass needs calibration: Move phone in a figure-8 motion.',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      onPressed: () {
                                        setState(() => _showCalibrationPrompt = false);
                                      },
                                    )
                                  ],
                                ),
                              ),

                            // Sensor Missing Warning
                            if (!_hasCompassSensor)
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Magnetometer sensor unavailable on this device. Use the calculated True North bearing to orient manually.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Location & Qibla Angle Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isAligned ? AppConstants.primaryGreen : Theme.of(context).colorScheme.outlineVariant,
                                  width: isAligned ? 2.0 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isAligned ? AppConstants.primaryGreen : Colors.black).withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                                        color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Qibla: ${bearing.toStringAsFixed(1)}° True North',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isAligned ? AppConstants.primaryGreen : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Coordinates: ${_userLat!.toStringAsFixed(4)}° N, ${_userLng!.toStringAsFixed(4)}° E',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Distance to Makkah: ${_distanceToKaabaKm.toStringAsFixed(0)} km  •  Heading: ${_deviceHeading != null ? "${_deviceHeading!.toStringAsFixed(0)}°" : "--"}${_compassAccuracy != null ? " (acc: ${_compassAccuracy!.toStringAsFixed(0)}°)" : ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Phone Top Reference Indicator (12 o'clock)
                            Column(
                              children: [
                                Icon(
                                  Icons.arrow_drop_up_rounded,
                                  size: 34,
                                  color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                ),
                                Text(
                                  'TOP OF PHONE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: isAligned ? AppConstants.primaryGreen : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Dynamic Compass Stack
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Compass Dial (Rotates -heading to maintain True North alignment)
                                  Transform.rotate(
                                    angle: -heading * pi / 180.0,
                                    child: Container(
                                      width: compassSize,
                                      height: compassSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.surface,
                                        border: Border.all(
                                          color: isAligned
                                              ? AppConstants.primaryGreen
                                              : AppConstants.primaryGreen.withValues(alpha: 0.35),
                                          width: isAligned ? 5 : 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isAligned ? AppConstants.primaryGreen : Colors.black).withValues(alpha: 0.12),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Cardinal points
                                          const Positioned(
                                            top: 10,
                                            child: Text('N', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.redAccent)),
                                          ),
                                          const Positioned(
                                            bottom: 10,
                                            child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                                          ),
                                          const Positioned(
                                            left: 10,
                                            child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                                          ),
                                          const Positioned(
                                            right: 10,
                                            child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                                          ),
                                          // Minor ticks
                                          Positioned(
                                            top: compassSize * 0.22,
                                            child: Container(width: 2, height: 8, color: Colors.grey.withValues(alpha: 0.4)),
                                          ),
                                          Positioned(
                                            bottom: compassSize * 0.22,
                                            child: Container(width: 2, height: 8, color: Colors.grey.withValues(alpha: 0.4)),
                                          ),
                                          Positioned(
                                            left: compassSize * 0.22,
                                            child: Container(width: 8, height: 2, color: Colors.grey.withValues(alpha: 0.4)),
                                          ),
                                          Positioned(
                                            right: compassSize * 0.22,
                                            child: Container(width: 8, height: 2, color: Colors.grey.withValues(alpha: 0.4)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Qibla Direction Indicator Arrow (Rotates relative to phone top)
                                  Transform.rotate(
                                    angle: relativeQiblaAngle * pi / 180.0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Kaaba Indicator Badge
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isAligned ? AppConstants.primaryGreen : AppConstants.gold).withValues(alpha: 0.4),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.mosque_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 4,
                                          height: compassSize * 0.30,
                                          decoration: BoxDecoration(
                                            color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Central Pivot Pin
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Alignment Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAligned
                                    ? AppConstants.primaryGreen.withValues(alpha: 0.15)
                                    : Theme.of(context).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isAligned
                                      ? AppConstants.primaryGreen
                                      : Theme.of(context).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAligned ? Icons.check_circle : Icons.navigation_rounded,
                                    size: 16,
                                    color: isAligned ? AppConstants.primaryGreen : AppConstants.gold,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAligned
                                        ? 'You are facing the Kaaba (قبلہ رخ)'
                                        : 'Rotate phone until Kaaba points straight up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isAligned ? AppConstants.primaryGreen : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
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
