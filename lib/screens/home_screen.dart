import 'dart:async';
import 'package:flutter/material.dart';
import 'tasbih_screen.dart';
import 'prayer_times_screen.dart';
import 'quran_hub_screen.dart';
import 'duas_screen.dart';
import 'hijri_screen.dart';
import 'girly_mode_screen.dart';
import 'explore_screen.dart';
import 'nature_gallery_screen.dart';
import 'allah_names_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Timer _countdownTimer;
  Duration _timeLeft = const Duration(hours: 2, minutes: 14, seconds: 0);
  
  // States for micro-interactive buttons
  final Map<String, bool> _buttonPressStates = {};

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(hours: 5, minutes: 30, seconds: 0); // reset loop
          }
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Sabah al-Khair"; // Good Morning
    } else if (hour < 17) {
      return "Assalamu Alaikum"; // Peace be upon you
    } else {
      return "Masa' al-Khair"; // Good Evening
    }
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Rise and shine with Fajr";
    } else if (hour < 17) {
      return "Keep your heart connected";
    } else {
      return "Reflect on your day";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "PRAYERRISE",
          style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF00A86B)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Ambient Background Glows adjusted to white/green
          Positioned(
            top: -screenSize.height * 0.1,
            right: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A86B).withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.1,
            left: -screenSize.width * 0.3,
            child: Container(
              width: screenSize.width * 1.0,
              height: screenSize.width * 1.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E5B43).withOpacity(0.05),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110), // Padding bottom for floating navbar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGreetingSubtitle(),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            id: "nature",
                            icon: "🌿",
                            title: "Nature",
                            subtitle: "Gallery",
                            cardColor: const Color(0xFF131B2E),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NatureGalleryScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            id: "allah_names",
                            icon: "🕌",
                            title: "Names of Allah",
                            subtitle: "99 Beautiful Names",
                            cardColor: const Color(0xFF131B2E),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AllahNamesScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Elegant Date Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "14 Dhul-H",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "1447 AH",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Premium Glassmorphic Next Prayer Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF131B2E),
                        Color(0xFF0F1524),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mosque_outlined,
                                  color: Color(0xFFFFD700),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "NEXT PRAYER",
                                    style: TextStyle(
                                      color: Color(0xFF8E9CB2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    "Fajr",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E5B43).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1E5B43).withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.volume_up, color: Color(0xFF2ECC71), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Adhan On",
                                  style: TextStyle(
                                    color: Color(0xFF2ECC71),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Countdown timer in glowing capsule
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060914).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDuration(_timeLeft),
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "remaining until Fajr (04:18 AM)",
                        style: TextStyle(
                          color: Color(0xFF5D6B82),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2x2 Feature Grid with Micro-interactions
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        id: "quran",
                        icon: "📖",
                        title: "Quran",
                        subtitle: "Read & Listen",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuranHubScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureCard(
                        id: "tasbih",
                        icon: "📿",
                        title: "Tasbih",
                        subtitle: "Dhikr Counter",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TasbihScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                ),

                const SizedBox(height: 25),

                // Sisters Corner Redesigned (Luxurious Rose Gold Aesthetic)
                _buildSistersCard(context),

                const SizedBox(height: 25),

                // Explore More Glowing Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExploreScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 20),
                          SizedBox(width: 10),
                          Text(
                            "EXPLORE ALL FEATURES",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
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

          // 3. Floating Premium Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1524).withOpacity(0.85),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, "Home"),
                    _buildNavItem(1, Icons.schedule_rounded, "Prayer"),
                    _buildNavItem(2, Icons.radio_button_checked_rounded, "Tasbih"),
                    _buildNavItem(3, Icons.event_note_rounded, "Planner"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build micro-interactive Grid Cards
  Widget _buildFeatureCard({
    required String id,
    required String icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    final isPressed = _buttonPressStates[id] ?? false;

    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonPressStates[id] = true),
      onTapUp: (_) => setState(() => _buttonPressStates[id] = false),
      onTapCancel: () => setState(() => _buttonPressStates[id] = false),
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle Backing
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8E9CB2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sisters Corner Redesigned Card
  Widget _buildSistersCard(BuildContext context) {
    final isPressed = _buttonPressStates["sisters"] ?? false;

    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonPressStates["sisters"] = true),
      onTapUp: (_) => setState(() => _buttonPressStates["sisters"] = false),
      onTapCancel: () => setState(() => _buttonPressStates["sisters"] = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GirlyModeScreen()),
        );
      },
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE754A6), // Warm Elegant Rose
                Color(0xFFB03A7B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE754A6).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "🌸 GENTLE MODE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sisters Corner",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Worship guides, support & comfort tools",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Beautiful glowing flower graphic placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "🌸",
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Navigation Bar Item Builder
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Route according to selections
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerTimesScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}