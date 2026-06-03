import 'qibla_screen.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'premium_plus_sheet.dart';
import 'tajweed_rules_screen.dart';
import 'names_of_allah_screen.dart';
import 'kids_zone_screen.dart';
import 'masjid_finder_screen.dart';
import 'halal_finder_screen.dart';
import 'islamic_cards_screen.dart';
import '../services/prayer_time_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  bool _isPremium = true;
  int _activeTab = 0; // 0: Qibla Radar, 1: Tasbih Counter

  // Compass Heading (Simulated alignment)
  double _compassHeading = 45.0;
  bool _isAutoCompass = true;
  Timer? _compassTimer;

  double _makkahDistance = 0.0;
  double _qiblaAngle = 125.0;
  bool _showCalibrationTip = true;

  Future<void> _calculateQiblaAndDistance() async {
    final service = PrayerTimeService();
    final coords = await service.getEffectiveCoordinates();
    double lat = coords.latitude;
    double long = coords.longitude;

    debugPrint("[Qibla Diagnostics] Calculating Qibla from ($lat, $long)");

    const double meccaLat = 21.4225;
    const double meccaLng = 39.8262;

    const double earthRadius = 6371.0; // km
    final double dLat = (meccaLat - lat) * math.pi / 180.0;
    final double dLng = (meccaLng - long) * math.pi / 180.0;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * math.pi / 180.0) *
            math.cos(meccaLat * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    final double latRad = lat * math.pi / 180.0;
    final double meccaLatRad = meccaLat * math.pi / 180.0;
    final double lngDiffRad = (meccaLng - long) * math.pi / 180.0;

    final double y = math.sin(lngDiffRad) * math.cos(meccaLatRad);
    final double x = math.cos(latRad) * math.sin(meccaLatRad) -
        math.sin(latRad) * math.cos(meccaLatRad) * math.cos(lngDiffRad);

    double qiblaBearing = math.atan2(y, x) * 180.0 / math.pi;
    qiblaBearing = (qiblaBearing + 360.0) % 360.0;

    debugPrint("[Qibla Diagnostics] Bearing: ${qiblaBearing.toStringAsFixed(2)}°, Distance: ${distance.toStringAsFixed(0)} km");

    if (mounted) {
      setState(() {
        _makkahDistance = distance;
        _qiblaAngle = qiblaBearing;
      });
    }
  }

  // Dhikr Counter state
  int _tasbihCount = 0;
  int _activeDhikrIndex = -1; // -1 indicates selection screen
  bool _hasSelectedDhikr = false;
  
  final List<int> _limits = [33, 99, 100, 333, 1000];
  int _activeLimitIndex = 0;

  final List<Map<String, String>> _dhikrPresets = const [
    {
      "arabic": "سُبْحَانَ ٱللَّٰهِ",
      "translit": "SubhanAllah",
      "meaning": "Glory be to Allah",
      "benefit": "Planted a tree in Paradise, erases sins as abundant as foam of the sea."
    },
    {
      "arabic": "ٱلْحَمْدُ لِلَّٰهِ",
      "translit": "Alhamdulillah",
      "meaning": "Praise be to Allah",
      "benefit": "Fills the scale of good deeds, instills immediate gratitude."
    },
    {
      "arabic": "ٱللَّٰهُ أَكْبَرُ",
      "translit": "AllahuAkbar",
      "meaning": "Allah is the Greatest",
      "benefit": "Reminds the soul of the supreme majesty of Allah over all anxiety."
    },
    {
      "arabic": "أَسْتَغْفِرُ ٱللَّٰهَ",
      "translit": "Astaghfirullah",
      "meaning": "I seek forgiveness from Allah",
      "benefit": "Opens gates of provision, relief, wealth, and clears spiritual guilt."
    },
    {
      "arabic": "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
      "translit": "La ilaha illallah",
      "meaning": "There is no deity except Allah",
      "benefit": "The absolute weightiest statement on the scale, key to Paradise."
    },
    {
      "arabic": "سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ",
      "translit": "SubhanAllahi wa bihamdihi",
      "meaning": "Glory be to Allah and His praise",
      "benefit": "Sins are forgiven even if they are as abundant as foam of the ocean."
    },
    {
      "arabic": "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ",
      "translit": "La hawla wa la quwwata illa billah",
      "meaning": "There is no strength nor power except with Allah",
      "benefit": "A treasure from beneath the Throne of Allah, cures 99 illnesses."
    },
    {
      "arabic": "حَسْبُنَا ٱللَّٰهُ وَنِعْمَ ٱلْوَكِيلُ",
      "translit": "Hasbunallahu wa ni'mal wakeel",
      "meaning": "Sufficient for us is Allah, and [He is] the best Disposer of affairs",
      "benefit": "Recited by Prophet Ibrahim (AS) in the fire. Comfort in times of crisis."
    },
    {
      "arabic": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ",
      "translit": "Allahumma salli 'ala Muhammad",
      "meaning": "O Allah, send blessings upon Muhammad",
      "benefit": "Salawat on the Prophet (PBUH); Allah sends ten blessings upon you in return."
    },
    {
      "arabic": "سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ ، سُبْحَانَ ٱللَّٰهِ ٱلْعَظِيمِ",
      "translit": "SubhanAllahi wa bihamdihi, SubhanAllahil Adheem",
      "meaning": "Glory be to Allah and His praise, Glory be to Allah the Supreme",
      "benefit": "Two phrases light on the tongue, heavy on scales, beloved to the Most Merciful."
    },
    {
      "arabic": "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ ٱلظَّالِمِينَ",
      "translit": "La ilaha illa anta subhanaka inni kuntu minad-dhalimeen",
      "meaning": "There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers",
      "benefit": "Dua of Prophet Yunus (AS); relieves intense distress and ensures answers to prayers."
    },
  ];

  // Dynamic Hijri calendar variables
  late int _currentHijriDay;
  late String _currentHijriMonth;
  late int _currentHijriYear;
  late double _illumination;
  late String _phaseName;

  final List<String> _months = const [
    "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
    "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
    "Ramadan", "Shawwal", "Dhu al-Qa'dah", "Dhu al-Hijjah"
  ];

  // Animation controllers
  late AnimationController _radarController;
  late AnimationController _tasbihScaleController;
  late AnimationController _starfieldController;

  @override
  void initState() {
    super.initState();

    // Radar pulse animation
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Tasbih counter scale click bounce
    _tasbihScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;

    // Starfield rotation animation
    _starfieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();

    // Calculate dynamic authentic Hijri date
    _calculateHijriCalendar();

    // Calculate dynamic Qibla and Makkah distance
    _calculateQiblaAndDistance();

    // Auto-compass rotation simulation
    _startCompassSimulation();
  }

  void _calculateHijriCalendar() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = (a / 4).floor();
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();
    double jd = c + day + e + f - 1524.5;
    int jdRound = jd.round();
    
    int l = jdRound - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor()) + 
            (((l) / 5670).floor() * ((43 * l) / 15238).floor());
    l = l - (((30 - j).floor() * (17719 * j).floor() / 50).floor()) - 
        (((j).floor() * (15238 * j).floor() / 43).floor()) + 29;
    
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    if (hMonth < 1) hMonth = 1;
    if (hMonth > 12) hMonth = 12;

    _currentHijriDay = hDay;
    _currentHijriMonth = _months[hMonth - 1];
    _currentHijriYear = hYear;
    
    _calculateMoonPhase(hDay);
  }

  void _calculateMoonPhase(int day) {
    if (day <= 1) {
      _illumination = 0.01;
      _phaseName = "New Moon";
    } else if (day < 8) {
      _illumination = (day / 7.0) * 0.5;
      _phaseName = "Waxing Crescent";
    } else if (day == 8) {
      _illumination = 0.5;
      _phaseName = "First Quarter";
    } else if (day < 14) {
      _illumination = 0.5 + ((day - 8) / 6.0) * 0.5;
      _phaseName = "Waxing Gibbous";
    } else if (day == 14 || day == 15) {
      _illumination = 1.0;
      _phaseName = "Full Moon";
    } else if (day < 23) {
      _illumination = 1.0 - ((day - 15) / 7.0) * 0.5;
      _phaseName = "Waning Gibbous";
    } else if (day == 23) {
      _illumination = 0.5;
      _phaseName = "Third Quarter";
    } else {
      _illumination = 0.5 - ((day - 23) / 7.0) * 0.5;
      _phaseName = "Waning Crescent";
    }
  }

  void _startCompassSimulation() {
    _compassTimer?.cancel();
    _compassTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (_isAutoCompass && mounted) {
        setState(() {
          _compassHeading = (115.0 + math.sin(DateTime.now().millisecondsSinceEpoch / 1500.0) * 16.0) % 360;
        });
      }
    });
  }

  @override
  void dispose() {
    _compassTimer?.cancel();
    _radarController.dispose();
    _tasbihScaleController.dispose();
    _starfieldController.dispose();
    super.dispose();
  }

  void _unlockPremium() {
    setState(() {
      _isPremium = true;
    });
  }

  void _incrementTasbih() {
    _tasbihScaleController.forward(from: 0.9).then((_) {
      _tasbihScaleController.animateTo(1.0, duration: const Duration(milliseconds: 100), curve: Curves.easeOutBack);
    });

    setState(() {
      _tasbihCount++;
      int currentLimit = _limits[_activeLimitIndex];
      if (_tasbihCount > currentLimit) {
        _tasbihCount = 1;
      }
    });
  }

  void _resetTasbih() {
    setState(() {
      _tasbihCount = 0;
    });
  }

  void _selectDhikr(int index) {
    setState(() {
      _activeDhikrIndex = index;
      _hasSelectedDhikr = true;
      _tasbihCount = 0;
    });
  }

  void _cycleLimit() {
    setState(() {
      _activeLimitIndex = (_activeLimitIndex + 1) % _limits.length;
      _tasbihCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    final double targetHeading = _qiblaAngle;
    final double diff = (targetHeading - _compassHeading).abs();
    final bool isQiblaLocked = diff < 5.0 || diff > 355.0;

    return Scaffold(
      backgroundColor: const Color(0xFF04060E),
      body: Stack(
        children: [
          // 1. Cosmic Rotating Starfield Background
          AnimatedBuilder(
            animation: _starfieldController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(screenSize.width, screenSize.height),
                painter: CosmicStarfieldPainter(rotation: _starfieldController.value),
              );
            },
          ),

          // 2. Translucent Ambient Glow Top & Bottom
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E5B43).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.04),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom Premium Navigation Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
                          ),
                        ),
                        Column(
                          children: [
                            const Text(
                              "EXPLORE MORE",
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Sacred Tools Hub",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!_isPremium) {
                              PremiumPlusSheet.show(context, _unlockPremium);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: _isPremium
                                  ? const LinearGradient(colors: [Color(0xFF1E5B43), Color(0xFF0F1524)])
                                  : const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isPremium ? const Color(0xFF2ECC71) : const Color(0xFFFFD700)).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isPremium ? Icons.verified_user_rounded : Icons.star_rounded,
                                  color: _isPremium ? Colors.white : Colors.black,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPremium ? "PREMIUM" : "UPGRADE",
                                  style: TextStyle(
                                    color: _isPremium ? Colors.white : Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SECTION 1: Dynamic TRUE Astronomical Moon Phase & Hijri HUD
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B1528), Color(0xFF050814)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Custom Painter Moon Globe
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: MoonPhaseGlobePainter(
                                illumination: _illumination,
                                phaseName: _phaseName,
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "LUNAR CALENDAR HUD • TRUE TIME",
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "$_currentHijriDay $_currentHijriMonth $_currentHijriYear AH",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2ECC71),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$_phaseName (${(_illumination * 100).toInt()}% Lit)",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SECTION 2: Dynamic Tabs for Qibla Radar & Tasbih Counter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0 ? const Color(0xFF1E5B43).withOpacity(0.6) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _activeTab == 0 ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.explore_rounded,
                                      color: _activeTab == 0 ? Colors.white : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Qibla Radar",
                                      style: TextStyle(
                                        color: _activeTab == 0 ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1 ? const Color(0xFF1E5B43).withOpacity(0.6) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _activeTab == 1 ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.plus_one_rounded,
                                      color: _activeTab == 1 ? Colors.white : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Dhikr Tasbih",
                                      style: TextStyle(
                                        color: _activeTab == 1 ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SECTION 3: Tab Views
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _activeTab == 0 ? _buildQiblaRadar(isQiblaLocked) : _buildTasbihCounter(),
                  ),
                ),

                // Premium Banner
                if (!_isPremium) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: _buildPremiumBanner(),
                    ),
                  ),
                ],

                // SECTION 4: Features Grid List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: const [
                        Icon(Icons.library_books_rounded, color: Color(0xFFFFD700), size: 18),
                        SizedBox(width: 10),
                        Text(
                          "COMPANION ACADEMY & SACRED UTILITIES",
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      _buildAcademyFeatureCard(
                        category: "KNOWLEDGE & RECITATION",
                        icon: "🎓",
                        title: "Tajweed Rules",
                        subtitle: "Learn Quran Pronunciation",
                        metric: "Lesson 4/12 (33% Complete)",
                        progress: 0.33,
                        borderColor: Colors.tealAccent.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TajweedRulesScreen(
                                isPremium: _isPremium,
                                onUnlockPremium: _unlockPremium,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildAcademyFeatureCard(
  category: "TOOLS",
  icon: "🧭",
  title: "Qibla Finder",
  subtitle: "Find Direction of Kaaba",
  metric: "Live Compass",
  progress: 1.0,
  borderColor: Colors.orange.withOpacity(0.1),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QiblaScreen(),
      ),
    );
  },
),
                      _buildCalligraphyFeatureCard(
                        category: "SACRED NAMES",
                        icon: "📜",
                        title: "99 Names Library",
                        subtitle: "Divine Attributes of Allah",
                        arabicPreview: "الرَّحْمَنُ",
                        arabicTranslit: "Ar-Rahman",
                        borderColor: const Color(0xFFFFD700).withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NamesOfAllahScreen(),
                            ),
                          );
                        },
                      ),
                      _buildStatusFeatureCard(
                        category: "FAMILY & STORIES",
                        icon: "🧸",
                        title: "Kids Zone",
                        subtitle: "Illustrated Audio Tales",
                        statusText: "New Story Added",
                        statusColor: Colors.deepPurpleAccent,
                        details: "The Ark of Prophet Nuh (AS)",
                        borderColor: Colors.deepPurpleAccent.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KidsZoneScreen(),
                            ),
                          );
                        },
                      ),
                      _buildStatusFeatureCard(
                        category: "SACRED SPACES",
                        icon: "🕌",
                        title: "Masjid Finder",
                        subtitle: "Navigate local Mosques",
                        statusText: "Active Navigation",
                        statusColor: const Color(0xFF2ECC71),
                        details: "3 Masjids found within 5km",
                        borderColor: const Color(0xFF2ECC71).withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MasjidFinderScreen(
                                isPremium: _isPremium,
                                onUnlockPremium: _unlockPremium,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildStatusFeatureCard(
                        category: "DAILY HALAL COMPANION",
                        icon: "🥗",
                        title: "Halal Finder",
                        subtitle: "Dining & Ingredient Scanner",
                        statusText: "Scanner Enabled",
                        statusColor: Colors.amber,
                        details: "AI Barcode Scan Ready",
                        borderColor: Colors.amber.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HalalFinderScreen(
                                isPremium: _isPremium,
                                onUnlockPremium: _unlockPremium,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildStatusFeatureCard(
                        category: "CREATIVE & BLESSINGS",
                        icon: "💌",
                        title: "Islamic Cards",
                        subtitle: "Custom Card Generator",
                        statusText: "4K High Exports",
                        statusColor: Colors.blueAccent,
                        details: "Customize blessed templates",
                        borderColor: Colors.blueAccent.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IslamicCardsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB CONTENT 1: Advanced Sonar Qibla Radar
  Widget _buildQiblaRadar(bool isLocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLocked ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.white.withOpacity(0.04),
          width: isLocked ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "INTELLIGENT RADAR COMPASS",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${_compassHeading.toStringAsFixed(1)}° SE",
                        style: TextStyle(
                          color: isLocked ? const Color(0xFFFFD700) : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLocked ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLocked ? "LOCK-ON" : "SCANNING",
                          style: TextStyle(
                            color: isLocked ? const Color(0xFFFFD700) : Colors.white60,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAutoCompass = !_isAutoCompass;
                    if (_isAutoCompass) {
                      _startCompassSimulation();
                    } else {
                      _compassTimer?.cancel();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isAutoCompass ? const Color(0xFF1E5B43).withOpacity(0.2) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAutoCompass ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAutoCompass ? Icons.videogame_asset_rounded : Icons.swipe_rounded,
                        color: _isAutoCompass ? const Color(0xFF2ECC71) : Colors.white60,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isAutoCompass ? "AUTO SIM" : "MANUAL DRAG",
                        style: TextStyle(
                          color: _isAutoCompass ? const Color(0xFF2ECC71) : Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: QiblaRadarPainter(
                      heading: _compassHeading,
                      pulseVal: _radarController.value,
                      isLocked: isLocked,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 25),

          Text(
            isLocked 
                ? "Perfect! Directly facing the Kaaba (Distance: ${_makkahDistance.toStringAsFixed(0)} km)."
                : "Rotate your device to align with the golden Kaaba needle marker at ${_qiblaAngle.toStringAsFixed(1)}° (Distance: ${_makkahDistance.toStringAsFixed(0)} km).",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? const Color(0xFFFFD700) : Colors.white60,
              fontSize: 12,
              height: 1.4,
              fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          // Compass Calibration Guidance
          if (_showCalibrationTip) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E5B43).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2ECC71), size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Compass Calibration",
                          style: TextStyle(color: Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "For accurate direction, wave your device in a figure-8 pattern to calibrate the compass sensor.",
                          style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showCalibrationTip = false),
                    child: const Icon(Icons.close_rounded, color: Colors.white30, size: 16),
                  ),
                ],
              ),
            ),
          ],

          if (!_isAutoCompass) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.screen_rotation_rounded, color: Colors.white30, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: isLocked ? const Color(0xFFFFD700) : const Color(0xFF2ECC71),
                      inactiveTrackColor: Colors.white.withOpacity(0.05),
                      thumbColor: isLocked ? const Color(0xFFFFD700) : Colors.white,
                      overlayColor: const Color(0xFFFFD700).withOpacity(0.1),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: 360.0,
                      value: _compassHeading,
                      onChanged: (val) {
                        setState(() {
                          _compassHeading = val;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  "${_compassHeading.toInt()}°",
                  style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // TAB CONTENT 2: Premium Dhikr Tasbih Counter Console with choose-first list
  Widget _buildTasbihCounter() {
    if (!_hasSelectedDhikr) {
      // DHIKR SELECTION CATALOG DASHBOARD FIRST!
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.library_books_rounded, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Text(
                  "SELECT AD-DHIKR TO COMMENCE",
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Structured catalog lists
            SizedBox(
              height: 380,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _dhikrPresets.length,
                itemBuilder: (context, idx) {
                  final preset = _dhikrPresets[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1524).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.02)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _selectDhikr(idx),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset['translit']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    preset['meaning']!,
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "✨ Benefit: ${preset['benefit']!}",
                                    style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 9, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                preset['arabic']!,
                                style: const TextStyle(
                                  fontFamily: 'QuranFont',
                                  color: Color(0xFFFFD700),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // TASBIH CIRCULAR ORB DECK
    final activeDhikr = _dhikrPresets[_activeDhikrIndex];
    int currentLimit = _limits[_activeLimitIndex];
    double progress = _tasbihCount / currentLimit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _hasSelectedDhikr = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back_rounded, color: Color(0xFF2ECC71), size: 14),
                      SizedBox(width: 6),
                      Text(
                        "Change Supplication",
                        style: TextStyle(color: Color(0xFF2ECC71), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.plus_one_rounded, color: Color(0xFFFFD700), size: 18),
            ],
          ),
          const SizedBox(height: 18),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                activeDhikr['translit']!,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                activeDhikr['meaning']!,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _incrementTasbih,
            child: ScaleTransition(
              scale: _tasbihScaleController,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1524), Color(0xFF070B14)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 155,
                      height: 155,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4.0,
                        backgroundColor: Colors.white.withOpacity(0.03),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activeDhikr['arabic']!,
                          style: const TextStyle(
                            fontFamily: 'QuranFont',
                            color: Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$_tasbihCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "GOAL: $currentLimit",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _cycleLimit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.outlined_flag_rounded, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "GOAL: $currentLimit",
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _resetTasbih,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8B8B).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF8B8B).withOpacity(0.15)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.refresh_rounded, color: Color(0xFFFF8B8B), size: 16),
                      SizedBox(width: 8),
                      Text(
                        "RESET",
                        style: TextStyle(color: Color(0xFFFF8B8B), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () {
        PremiumPlusSheet.show(context, _unlockPremium);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PrayerRise Premium Plus",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Unlock AI recitation feedback, Qibla AR radar, barcode scanner, and card creators.",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademyFeatureCard({
    required String category,
    required String icon,
    required String title,
    required String subtitle,
    required String metric,
    required double progress,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  metric,
                  style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 8, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalligraphyFeatureCard({
    required String category,
    required String icon,
    required String title,
    required String subtitle,
    required String arabicPreview,
    required String arabicTranslit,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Featured: $arabicTranslit",
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    arabicPreview,
                    style: const TextStyle(
                      fontFamily: 'QuranFont',
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFeatureCard({
    required String category,
    required String icon,
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
    required String details,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MoonPhaseGlobePainter extends CustomPainter {
  final double illumination;
  final String phaseName;

  MoonPhaseGlobePainter({required this.illumination, required this.phaseName});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.12)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 2, glowPaint);

    final shadowPaint = Paint()
      ..color = const Color(0xFF0F1524)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, shadowPaint);

    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 12, center.dy - 10), 12, texturePaint);
    canvas.drawCircle(Offset(center.dx + 16, center.dy + 8), 10, texturePaint);
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 12), 8, texturePaint);

    final litPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1);

    final path = Path();
    if (phaseName == "Full Moon") {
      canvas.drawCircle(center, radius, litPaint);
    } else if (phaseName == "New Moon") {
      // Completely shadowed
    } else if (phaseName.contains("Crescent")) {
      double direction = phaseName.contains("Waxing") ? 1.0 : -1.0;
      path.addArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi);
      path.quadraticBezierTo(
        center.dx + (radius * 0.4 * direction), center.dy,
        center.dx, center.dy + radius,
      );
      path.close();
      canvas.drawPath(path, litPaint);
    } else if (phaseName.contains("Quarter")) {
      double direction = phaseName.contains("First") ? 1.0 : -1.0;
      path.addArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, direction * math.pi);
      path.close();
      canvas.drawPath(path, litPaint);
    } else if (phaseName.contains("Gibbous")) {
      double direction = phaseName.contains("Waxing") ? 1.0 : -1.0;
      path.addArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, direction * math.pi);
      path.close();
      canvas.drawPath(path, litPaint);
      
      final bulgerPath = Path();
      bulgerPath.moveTo(center.dx, center.dy - radius);
      bulgerPath.quadraticBezierTo(
        center.dx - (radius * 0.4 * direction), center.dy,
        center.dx, center.dy + radius,
      );
      bulgerPath.quadraticBezierTo(
        center.dx + (radius * direction), center.dy,
        center.dx, center.dy - radius,
      );
      canvas.drawPath(bulgerPath, litPaint);
    }

    final shinePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.25), Colors.transparent],
        center: const Alignment(-0.35, -0.35),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shinePaint);
  }

  @override
  bool shouldRepaint(covariant MoonPhaseGlobePainter oldDelegate) {
    return oldDelegate.illumination != illumination || oldDelegate.phaseName != phaseName;
  }
}

class QiblaRadarPainter extends CustomPainter {
  final double heading;
  final double pulseVal;
  final bool isLocked;

  QiblaRadarPainter({required this.heading, required this.pulseVal, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF090D1A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final gridPaint = Paint()
      ..color = isLocked 
          ? const Color(0xFFFFD700).withOpacity(0.08) 
          : const Color(0xFF2ECC71).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(center, radius * 0.35, gridPaint);
    canvas.drawCircle(center, radius * 0.7, gridPaint);
    canvas.drawCircle(center, radius, gridPaint);

    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint);

    final pulsePaint = Paint()
      ..color = isLocked 
          ? const Color(0xFFFFD700).withOpacity(0.12 * (1.0 - pulseVal))
          : const Color(0xFF2ECC71).withOpacity(0.12 * (1.0 - pulseVal))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * pulseVal, pulsePaint);

    final tickPaint = Paint()
      ..color = isLocked ? const Color(0xFFFFD700).withOpacity(0.4) : Colors.white24
      ..strokeWidth = 1.0;
    double headingRad = heading * math.pi / 180;

    for (int i = 0; i < 360; i += 15) {
      double angle = (i * math.pi / 180) - headingRad - math.pi / 2;
      double startDist = i % 90 == 0 ? radius - 10 : radius - 5;
      double startX = center.dx + startDist * math.cos(angle);
      double startY = center.dy + startDist * math.sin(angle);
      double endX = center.dx + radius * math.cos(angle);
      double endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    _drawText(canvas, center, "N", -headingRad, radius - 18, isLocked ? const Color(0xFFFFD700) : const Color(0xFFFF8B8B));
    _drawText(canvas, center, "E", math.pi / 2 - headingRad, radius - 18, Colors.white54);
    _drawText(canvas, center, "S", math.pi - headingRad, radius - 18, Colors.white54);
    _drawText(canvas, center, "W", -math.pi / 2 - headingRad, radius - 18, Colors.white54);

    double qiblaAngle = (125.0 - heading) * math.pi / 180 - math.pi / 2;

    if (isLocked) {
      final kaabaGlowPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.1)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(center.dx + (radius - 20) * math.cos(qiblaAngle), center.dy + (radius - 20) * math.sin(qiblaAngle)), 20, kaabaGlowPaint);
    }

    final needlePaint = Paint()
      ..color = isLocked ? const Color(0xFFFFD700) : Colors.white60
      ..style = PaintingStyle.fill;
    
    final path = Path();
    double tipX = center.dx + (radius - 12) * math.cos(qiblaAngle);
    double tipY = center.dy + (radius - 12) * math.sin(qiblaAngle);
    
    double leftX = center.dx + 6 * math.cos(qiblaAngle - math.pi/2);
    double leftY = center.dy + 6 * math.sin(qiblaAngle - math.pi/2);
    
    double rightX = center.dx + 6 * math.cos(qiblaAngle + math.pi/2);
    double rightY = center.dy + 6 * math.sin(qiblaAngle + math.pi/2);

    path.moveTo(tipX, tipY);
    path.lineTo(leftX, leftY);
    path.lineTo(rightX, rightY);
    path.close();
    canvas.drawPath(path, needlePaint);

    canvas.drawCircle(center, 5, Paint()..color = isLocked ? const Color(0xFFFFD700) : Colors.white);
    canvas.drawCircle(center, 2, Paint()..color = Colors.black);

    double kaabaX = center.dx + radius * math.cos(qiblaAngle);
    double kaabaY = center.dy + radius * math.sin(qiblaAngle);
    
    final kaabaMarkerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(Offset(kaabaX, kaabaY), 8, kaabaMarkerPaint);
    canvas.drawCircle(Offset(kaabaX, kaabaY), 4, Paint()..color = Colors.black);
  }

  void _drawText(Canvas canvas, Offset center, String text, double angle, double distance, Color color) {
    double x = center.dx + distance * math.cos(angle - math.pi / 2);
    double y = center.dy + distance * math.sin(angle - math.pi / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant QiblaRadarPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.pulseVal != pulseVal || oldDelegate.isLocked != isLocked;
  }
}

class CosmicStarfieldPainter extends CustomPainter {
  final double rotation;

  CosmicStarfieldPainter({required this.rotation});

  static final List<Offset> _stars = List.generate(40, (index) {
    final rand = math.Random(index * 242);
    return Offset(rand.nextDouble(), rand.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    final starPaint = Paint()..color = Colors.white;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      double angle = star.dx * 2 * math.pi;
      double dist = star.dy * diagonal;
      
      double x = center.dx + dist * math.cos(angle);
      double y = center.dy + dist * math.sin(angle);

      double opacity = 0.15 + 0.65 * (0.5 + 0.5 * math.sin(rotation * 15 * math.pi + i));
      starPaint.color = Colors.white.withOpacity(opacity);

      double starSize = (i % 3 == 0) ? 1.5 : 1.0;
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CosmicStarfieldPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}