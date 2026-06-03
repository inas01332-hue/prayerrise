import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'premium_plus_sheet.dart';

class MasjidFinderScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUnlockPremium;
  const MasjidFinderScreen({super.key, required this.isPremium, required this.onUnlockPremium});

  @override
  State<MasjidFinderScreen> createState() => _MasjidFinderScreenState();
}

class _MasjidFinderScreenState extends State<MasjidFinderScreen> with SingleTickerProviderStateMixin {
  int _selectedMasjidIndex = 0;
  bool _isNavigating = false;
  int _navStep = 0;
  Timer? _navTimer;

  // Pulse animation for user dot on map
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _masjids = [
    {
      "name": "Masjid An-Nur",
      "distance": "0.6 km",
      "time": "8 mins walk",
      "coords": const Offset(160, 100),
      "amenities": ["🕌 Women's Area", "💧 Wudu Facility", "🚗 Parking"],
      "jamat": "Fajr: 04:15 AM • Dhuhr: 01:00 PM • Asr: 04:30 PM • Maghrib: 07:15 PM • Isha: 08:45 PM",
      "rating": "4.9 ⭐"
    },
    {
      "name": "Al-Fatih Mosque",
      "distance": "1.2 km",
      "time": "15 mins walk",
      "coords": const Offset(60, 240),
      "amenities": ["💧 Wudu Facility", "🚗 Parking"],
      "jamat": "Fajr: 04:18 AM • Dhuhr: 01:05 PM • Asr: 04:35 PM • Maghrib: 07:18 PM • Isha: 08:50 PM",
      "rating": "4.7 ⭐"
    },
    {
      "name": "Taqwa Islamic Center",
      "distance": "1.8 km",
      "time": "22 mins walk",
      "coords": const Offset(280, 200),
      "amenities": ["🕌 Women's Area", "💧 Wudu Facility"],
      "jamat": "Fajr: 04:20 AM • Dhuhr: 01:10 PM • Asr: 04:40 PM • Maghrib: 07:22 PM • Isha: 08:55 PM",
      "rating": "4.8 ⭐"
    }
  ];

  final List<String> _navigationSteps = [
    "Head North on Al-Huda Boulevard toward Mosque St (200m)",
    "Turn right onto Mosque St (300m)",
    "Pass An-Nur Halal Bakery on your left (100m)",
    "Your destination, Masjid An-Nur, is on the right! Arrived."
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  void _startNavigationSimulation() {
    if (!widget.isPremium) {
      PremiumPlusSheet.show(context, widget.onUnlockPremium);
      return;
    }

    if (_isNavigating) {
      _navTimer?.cancel();
      setState(() {
        _isNavigating = false;
        _navStep = 0;
      });
      return;
    }

    setState(() {
      _isNavigating = true;
      _navStep = 0;
    });

    _navTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (_navStep < _navigationSteps.length - 1) {
          _navStep++;
        } else {
          _navTimer?.cancel();
          _isNavigating = false;
          _navStep = 0;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Arrived safely at the Masjid!")),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final selectedMasjid = _masjids[_selectedMasjidIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Midnight Navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Masjid Finder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Beautiful Mock Map View
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: screenSize.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1524),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MockMapPainter(
                      masjids: _masjids,
                      selectedIdx: _selectedMasjidIndex,
                      pulseVal: _pulseController.value,
                      isNavigating: _isNavigating,
                      navStep: _navStep,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Navigation Steps overlay if active
          if (_isNavigating) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5B43).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, color: Color(0xFF2ECC71)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TURN-BY-TURN ACTIVE ROUTING",
                            style: TextStyle(color: Color(0xFF2ECC71), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _navigationSteps[_navStep],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Main Detail panel or Mosque lists
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Selected Masjid detail card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedMasjid['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              selectedMasjid['rating'],
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${selectedMasjid['distance']} • ${selectedMasjid['time']}",
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),

                      // Jamat timings
                      const Text(
                        "JAMAT PRAYERS TODAY",
                        style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedMasjid['jamat'],
                        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 14),

                      // Amenities row
                      Wrap(
                        spacing: 8,
                        children: (selectedMasjid['amenities'] as List).map<Widget>((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Navigate Action Button
                      ElevatedButton(
                        onPressed: _startNavigationSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isNavigating ? Colors.redAccent : const Color(0xFF1E5B43),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isNavigating ? Icons.stop_rounded : Icons.navigation_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isNavigating ? "STOP ROUTE SIMULATION" : "GET TURN DIRECTIONS",
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isPremium) ...[
                        const SizedBox(height: 8),
                        const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 10),
                              SizedBox(width: 4),
                              Text(
                                "Requires Premium Plus to unlock map routing",
                                style: TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Other masjids list
                const Text(
                  "OTHER PLACES OF WORSHIP",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 10),

                ...List.generate(_masjids.length, (idx) {
                  if (idx == _selectedMasjidIndex) return const SizedBox.shrink();
                  final item = _masjids[idx];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text("${item['distance']} away • ${item['time']}", style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                      onTap: () {
                        setState(() {
                          _selectedMasjidIndex = idx;
                          // If navigating, reset
                          if (_isNavigating) {
                            _navTimer?.cancel();
                            _isNavigating = false;
                            _navStep = 0;
                          }
                        });
                      },
                    ),
                  );
                }),

                const SizedBox(height: 30),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Custom Painter for drawing a vector map showing paths and points
class _MockMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> masjids;
  final int selectedIdx;
  final double pulseVal;
  final bool isNavigating;
  final int navStep;

  _MockMapPainter({
    required this.masjids,
    required this.selectedIdx,
    required this.pulseVal,
    required this.isNavigating,
    required this.navStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset userLocation = Offset(size.width / 2, size.height / 2 + 30);

    // 1. Draw Streets / Blocks (Background layout)
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = const Color(0xFF131B2E).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw some custom mock streets
    // Main vertical street
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), roadPaint);
    // Cross streets
    canvas.drawLine(Offset(0, 100), Offset(size.width, 100), roadPaint);
    canvas.drawLine(Offset(0, 240), Offset(size.width, 240), roadPaint);

    // Blocks details (rectangles representing buildings)
    canvas.drawRect(Rect.fromLTWH(20, 20, 80, 60), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 100, 20, 80, 60), blockPaint);
    canvas.drawRect(Rect.fromLTWH(20, 120, 80, 100), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 100, 120, 80, 100), blockPaint);

    // 2. If navigating, draw glowing route dashed lines to selected masjid
    if (isNavigating) {
      final destCoords = masjids[selectedIdx]['coords'] as Offset;

      final routePaint = Paint()
        ..color = const Color(0xFF2ECC71)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw route segments depending on navigation steps
      final routePath = Path();
      routePath.moveTo(userLocation.dx, userLocation.dy);

      if (navStep >= 0) {
        // Go to intersection
        routePath.lineTo(userLocation.dx, 100);
      }
      if (navStep >= 1) {
        // Turn towards Masjid
        routePath.lineTo(destCoords.dx, 100);
      }
      if (navStep >= 2) {
        // Go straight into destination
        routePath.lineTo(destCoords.dx, destCoords.dy);
      }

      canvas.drawPath(routePath, routePaint);
    }

    // 3. Draw Masjid Pins
    for (int i = 0; i < masjids.length; i++) {
      final coords = masjids[i]['coords'] as Offset;
      final isSel = selectedIdx == i;

      final pinPaint = Paint()
        ..color = isSel ? const Color(0xFFFFD700) : const Color(0xFF8E9CB2)
        ..style = PaintingStyle.fill;

      // Draw pin halo for selected masjid
      if (isSel) {
        final haloPaint = Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(coords, 14 + math.sin(pulseVal * math.pi) * 3, haloPaint);
      }

      // Draw pin circle
      canvas.drawCircle(coords, 8, pinPaint);
      // Small tip/crescent representation
      canvas.drawCircle(coords, 3, Paint()..color = Colors.black);
    }

    // 4. Draw User Location Blue dot with pulsing halo
    final userPaint = Paint()
      ..color = const Color(0xFF3498DB)
      ..style = PaintingStyle.fill;

    final userHaloPaint = Paint()
      ..color = const Color(0xFF3498DB).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(userLocation, 10 + pulseVal * 8, userHaloPaint);
    canvas.drawCircle(userLocation, 6, userPaint);
    canvas.drawCircle(userLocation, 8, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _MockMapPainter oldDelegate) {
    return oldDelegate.selectedIdx != selectedIdx ||
        oldDelegate.pulseVal != pulseVal ||
        oldDelegate.isNavigating != isNavigating ||
        oldDelegate.navStep != navStep;
  }
}
