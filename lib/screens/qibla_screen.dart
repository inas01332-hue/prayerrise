import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

/// Kaaba coordinates (WGS‑84)
const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

/// Calculate the initial bearing (forward azimuth) from [lat1,lng1] to [lat2,lng2]
/// using the spherical law formula. Returns degrees 0‑360 measured clockwise from
/// true north.
double _calculateQiblaBearing(
    double lat1, double lng1, double lat2, double lng2) {
  final phi1 = lat1 * math.pi / 180;
  final phi2 = lat2 * math.pi / 180;
  final dLambda = (lng2 - lng1) * math.pi / 180;

  final y = math.sin(dLambda) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dLambda);

  final theta = math.atan2(y, x);
  return (theta * 180 / math.pi + 360) % 360;
}

/// Returns the Haversine distance in km between two points.
double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371.0; // Earth radius km
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  // Location state
  double? _userLat;
  double? _userLng;
  double? _qiblaBearing; // true bearing to Kaaba
  double? _distanceKm;
  String _locationStatus = 'Acquiring GPS…';
  bool _locationError = false;

  // Compass state
  double? _compassHeading; // device heading (true north)
  double? _compassAccuracy;
  bool _needsCalibration = false;
  StreamSubscription<CompassEvent>? _compassSub;

  // Smooth animation
  late AnimationController _animController;
  double _animatedNeedleAngle = 0;
  double _targetNeedleAngle = 0;

  // Debug toggle
  bool _showDebug = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_animTick);

    _initLocation();
    _initCompass();

    // Start animation loop
    _animController.repeat();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ── Smooth needle animation ──────────────────────────────────────────────
  void _animTick() {
    // Exponential moving average for smooth rotation
    const smoothing = 0.12;
    double diff = _targetNeedleAngle - _animatedNeedleAngle;

    // Normalize diff to [-180, 180] so it takes the short path
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }

    if (diff.abs() > 0.05) {
      setState(() {
        _animatedNeedleAngle += diff * smoothing;
        _animatedNeedleAngle %= 360;
        if (_animatedNeedleAngle < 0) _animatedNeedleAngle += 360;
      });
    }
  }

  // ── GPS ──────────────────────────────────────────────────────────────────
  Future<void> _initLocation() async {
    try {
      // Check service enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Location services disabled. Please enable GPS.';
            _locationError = true;
          });
        }
        return;
      }

      // Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationStatus = 'Location permission denied.';
              _locationError = true;
            });
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationStatus =
                'Location permanently denied. Please enable in Settings.';
            _locationError = true;
          });
        }
        return;
      }

      // Get position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (mounted) {
        final bearing = _calculateQiblaBearing(
            position.latitude, position.longitude, _kaabaLat, _kaabaLng);
        final dist = _haversineKm(
            position.latitude, position.longitude, _kaabaLat, _kaabaLng);
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _qiblaBearing = bearing;
          _distanceKm = dist;
          _locationStatus =
              '${position.latitude.toStringAsFixed(4)}°, ${position.longitude.toStringAsFixed(4)}°';
          _locationError = false;
        });
      }

      // Also listen for updates to keep position fresh
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen((pos) {
        if (mounted) {
          final bearing = _calculateQiblaBearing(
              pos.latitude, pos.longitude, _kaabaLat, _kaabaLng);
          final dist =
              _haversineKm(pos.latitude, pos.longitude, _kaabaLat, _kaabaLng);
          setState(() {
            _userLat = pos.latitude;
            _userLng = pos.longitude;
            _qiblaBearing = bearing;
            _distanceKm = dist;
            _locationStatus =
                '${pos.latitude.toStringAsFixed(4)}°, ${pos.longitude.toStringAsFixed(4)}°';
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = 'GPS error: $e';
          _locationError = true;
        });
      }
    }
  }

  // ── Compass ─────────────────────────────────────────────────────────────
  void _initCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;

      final heading = event.heading;
      final accuracy = event.accuracy;

      if (heading == null) return;

      setState(() {
        _compassHeading = heading;
        _compassAccuracy = accuracy;
        _needsCalibration = (accuracy != null && accuracy < 15) ||
            accuracy == null; // accuracy in degrees; <15° is low
      });

      // Calculate needle target: how far the Qibla is from current heading
      if (_qiblaBearing != null) {
        _targetNeedleAngle = (_qiblaBearing! - heading + 360) % 360;
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassSize = math.min(size.width * 0.82, 360.0);

    final bool isAligned = _compassHeading != null &&
        _qiblaBearing != null &&
        ((_qiblaBearing! - _compassHeading!).abs() % 360 < 5 ||
            (360 - ((_qiblaBearing! - _compassHeading!).abs() % 360)) < 5);

    return Scaffold(
      backgroundColor: const Color(0xFF060914),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: const Text(
            "QIBLA COMPASS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
              color: _showDebug
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF5D6B82),
            ),
            onPressed: () => setState(() => _showDebug = !_showDebug),
            tooltip: 'Toggle debug info',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Calibration warning ────────────────────────────────
              if (_needsCalibration)
                _buildCalibrationBanner(),

              // ── Location status chip ───────────────────────────────
              _buildLocationChip(),

              const SizedBox(height: 8),

              // ── Distance chip ─────────────────────────────────────
              if (_distanceKm != null)
                Text(
                  '${_distanceKm!.toStringAsFixed(0)} km to the Kaaba',
                  style: const TextStyle(
                    color: Color(0xFF8E9CB2),
                    fontSize: 13,
                  ),
                ),

              const SizedBox(height: 20),

              // ── Compass ring ───────────────────────────────────────
              SizedBox(
                width: compassSize,
                height: compassSize,
                child: _qiblaBearing == null || _compassHeading == null
                    ? _buildLoadingCompass(compassSize)
                    : _buildCompass(compassSize, isAligned),
              ),

              const SizedBox(height: 24),

              // ── Alignment status ───────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isAligned
                    ? _buildAlignedBanner()
                    : _buildDirectionHint(),
              ),

              // ── Debug panel ────────────────────────────────────────
              if (_showDebug) _buildDebugPanel(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub‑widgets ─────────────────────────────────────────────────────────

  Widget _buildCalibrationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFAA00).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFAA00), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compass Calibration Needed',
                  style: TextStyle(
                    color: Color(0xFFFFAA00),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tilt and rotate your phone in a figure‑8 motion several times to improve accuracy.',
                  style: TextStyle(color: Color(0xFFCCAA66), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _locationError
                ? Icons.location_off
                : Icons.location_on_outlined,
            color: _locationError
                ? const Color(0xFFFF6666)
                : const Color(0xFF2ECC71),
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _locationStatus,
              style: TextStyle(
                color: _locationError
                    ? const Color(0xFFFF6666)
                    : const Color(0xFF8E9CB2),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_locationError) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _locationStatus = 'Acquiring GPS…';
                  _locationError = false;
                });
                _initLocation();
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCompass(double size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFFFD700).withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Waiting for GPS & compass…',
            style: TextStyle(color: Color(0xFF5D6B82), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(double size, bool isAligned) {
    final heading = _compassHeading ?? 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring – rotates opposite to heading so N stays at true north
        Transform.rotate(
          angle: -heading * math.pi / 180,
          child: CustomPaint(
            size: Size(size, size),
            painter: _CompassRingPainter(),
          ),
        ),

        // Qibla needle – points toward Kaaba
        Transform.rotate(
          angle: _animatedNeedleAngle * math.pi / 180,
          child: CustomPaint(
            size: Size(size * 0.85, size * 0.85),
            painter: _QiblaNeedlePainter(isAligned: isAligned),
          ),
        ),

        // Center Kaaba icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isAligned
                ? const Color(0xFF1E5B43).withOpacity(0.25)
                : const Color(0xFF131B2E),
            shape: BoxShape.circle,
            border: Border.all(
              color: isAligned
                  ? const Color(0xFF2ECC71).withOpacity(0.5)
                  : const Color(0xFFFFD700).withOpacity(0.2),
              width: 2,
            ),
            boxShadow: isAligned
                ? [
                    BoxShadow(
                      color: const Color(0xFF2ECC71).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: const Center(
            child: Text('🕋', style: TextStyle(fontSize: 28)),
          ),
        ),
      ],
    );
  }

  Widget _buildAlignedBanner() {
    return Container(
      key: const ValueKey('aligned'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E5B43).withOpacity(0.3),
            const Color(0xFF0F1524),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.3),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 22),
          SizedBox(width: 10),
          Text(
            'Facing the Qibla ✓',
            style: TextStyle(
              color: Color(0xFF2ECC71),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionHint() {
    if (_qiblaBearing == null || _compassHeading == null) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }
    double diff = (_qiblaBearing! - _compassHeading! + 360) % 360;
    String hint;
    if (diff > 180) {
      hint = 'Turn left ${(360 - diff).toStringAsFixed(0)}°';
    } else {
      hint = 'Turn right ${diff.toStringAsFixed(0)}°';
    }
    return Container(
      key: const ValueKey('hint'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFF8E9CB2),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEBUG INFO',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          _debugRow('User Lat', _userLat?.toStringAsFixed(6) ?? '—'),
          _debugRow('User Lng', _userLng?.toStringAsFixed(6) ?? '—'),
          _debugRow('Kaaba', '${_kaabaLat.toStringAsFixed(4)}°N, ${_kaabaLng.toStringAsFixed(4)}°E'),
          const Divider(color: Color(0xFF2A3550), height: 16),
          _debugRow('Qibla Bearing',
              _qiblaBearing != null ? '${_qiblaBearing!.toStringAsFixed(2)}°' : '—'),
          _debugRow('Compass Heading',
              _compassHeading != null ? '${_compassHeading!.toStringAsFixed(2)}°' : '—'),
          _debugRow('Needle Angle',
              '${_animatedNeedleAngle.toStringAsFixed(2)}°'),
          _debugRow('Compass Accuracy',
              _compassAccuracy != null ? '±${_compassAccuracy!.toStringAsFixed(1)}°' : '—'),
          _debugRow('Distance',
              _distanceKm != null ? '${_distanceKm!.toStringAsFixed(1)} km' : '—'),
          _debugRow('Calibration', _needsCalibration ? 'NEEDED' : 'OK'),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF5D6B82), fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Custom Painters
// ══════════════════════════════════════════════════════════════════════════════

class _CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Outer ring
    final ringPaint = Paint()
      ..color = const Color(0xFF1A2540)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Degree tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF3A4A68)
      ..strokeWidth = 1;
    final majorTickPaint = Paint()
      ..color = const Color(0xFF8E9CB2)
      ..strokeWidth = 2;

    for (int deg = 0; deg < 360; deg += 5) {
      final isMajor = deg % 30 == 0;
      final isCardinal = deg % 90 == 0;
      final rad = deg * math.pi / 180;
      final tickLen = isCardinal ? 18.0 : (isMajor ? 12.0 : 6.0);
      final outerR = radius - 2;
      final innerR = outerR - tickLen;

      final outer =
          Offset(center.dx + outerR * math.sin(rad), center.dy - outerR * math.cos(rad));
      final inner =
          Offset(center.dx + innerR * math.sin(rad), center.dy - innerR * math.cos(rad));

      canvas.drawLine(inner, outer, isMajor ? majorTickPaint : tickPaint);
    }

    // Cardinal labels
    const cardinals = ['N', 'E', 'S', 'W'];
    const cardinalColors = [
      Color(0xFFFF4444), // N is red
      Color(0xFF8E9CB2),
      Color(0xFF8E9CB2),
      Color(0xFF8E9CB2),
    ];
    for (int i = 0; i < 4; i++) {
      final rad = i * 90 * math.pi / 180;
      final labelR = radius - 32;
      final pos =
          Offset(center.dx + labelR * math.sin(rad), center.dy - labelR * math.cos(rad));

      final textSpan = TextSpan(
        text: cardinals[i],
        style: TextStyle(
          color: cardinalColors[i],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;
  _QiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLen = size.height / 2 - 20;

    // Glow behind needle tip
    final glowPaint = Paint()
      ..color = (isAligned ? const Color(0xFF2ECC71) : const Color(0xFFFFD700))
          .withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final tipY = center.dy - needleLen;
    canvas.drawCircle(Offset(center.dx, tipY), 10, glowPaint);

    // Needle body (pointing up = toward Qibla)
    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isAligned
            ? [const Color(0xFF2ECC71), const Color(0xFF1E5B43)]
            : [const Color(0xFFFFD700), const Color(0xFFD4AF37)],
      ).createShader(Rect.fromCenter(
          center: center, width: 20, height: needleLen * 2))
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(center.dx, tipY) // tip
      ..lineTo(center.dx - 8, center.dy) // left
      ..lineTo(center.dx + 8, center.dy) // right
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFF2A3550)
      ..style = PaintingStyle.fill;
    final tailPath = Path()
      ..moveTo(center.dx, center.dy + needleLen * 0.5)
      ..lineTo(center.dx - 5, center.dy)
      ..lineTo(center.dx + 5, center.dy)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Center dot
    canvas.drawCircle(
        center, 5, Paint()..color = const Color(0xFFFFD700));
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.isAligned != isAligned;
}
