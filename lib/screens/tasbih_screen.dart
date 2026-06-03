import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class DhikrPreset {
  final String arabic;
  final String english;
  final String translation;
  final String benefit;

  const DhikrPreset({
    required this.arabic,
    required this.english,
    required this.translation,
    required this.benefit,
  });
}

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  int count = 0;
  int totalCount = 0;
  int streak = 1;

  final List<int> goals = [33, 99, 100, 0];
  int selectedGoal = 0;

  // Dhikr Presets List
  static const List<DhikrPreset> dhikrPresets = [
    DhikrPreset(
      arabic: "سُبْحَانَ ٱللَّهِ",
      english: "SubhanAllah",
      translation: "Glory be to Allah",
      benefit: "Fills half the scale of good deeds with spiritual rewards.",
    ),
    DhikrPreset(
      arabic: "ٱلْحَمْدُ لِلَّهِ",
      english: "Alhamdulillah",
      translation: "Praise be to Allah",
      benefit: "Fills the entire scale of good deeds with blessings.",
    ),
    DhikrPreset(
      arabic: "ٱللَّهُ أَكْبَرُ",
      english: "Allahu Akbar",
      translation: "Allah is the Greatest",
      benefit: "Exalts the soul and keeps one humbled in the presence of the Creator.",
    ),
    DhikrPreset(
      arabic: "أَسْتَغْفِرُ ٱللَّهَ",
      english: "Astaghfirullah",
      translation: "I seek forgiveness from Allah",
      benefit: "Opens doors of abundance, relief from anxieties, and mercy.",
    ),
    DhikrPreset(
      arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
      english: "La ilaha illallah",
      translation: "There is no deity but Allah",
      benefit: "The absolute best declaration of faith and heaviest on the scale.",
    ),
  ];

  int selectedDhikr = 0;

  // Settings
  int soundSetting = 1; // 0: Silent, 1: Soft Click, 2: Chime
  bool visualPulseEnabled = true;

  final AudioPlayer _player = AudioPlayer();
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    loadData();

    // Scale animation setup for spring haptic tactile tap feedback
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        count = prefs.getInt("tasbih_count") ?? 0;
        totalCount = prefs.getInt("tasbih_total") ?? 0;
        streak = prefs.getInt("tasbih_streak") ?? 1;
        selectedDhikr = prefs.getInt("tasbih_dhikr") ?? 0;
        selectedGoal = prefs.getInt("tasbih_goal") ?? 0;
        soundSetting = prefs.getInt("tasbih_sound") ?? 1;
        visualPulseEnabled = prefs.getBool("tasbih_visual") ?? true;
      });
    } catch (e) {
      debugPrint("Error loading Tasbih data: $e");
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("tasbih_count", count);
      await prefs.setInt("tasbih_total", totalCount);
      await prefs.setInt("tasbih_streak", streak);
      await prefs.setInt("tasbih_dhikr", selectedDhikr);
      await prefs.setInt("tasbih_goal", selectedGoal);
      await prefs.setInt("tasbih_sound", soundSetting);
      await prefs.setBool("tasbih_visual", visualPulseEnabled);
    } catch (e) {
      debugPrint("Error saving Tasbih data: $e");
    }
  }

  void _playClick() async {
    if (soundSetting == 0) return;
    try {
      final url = soundSetting == 1
          ? "https://assets.mixkit.co/active_storage/sfx/2568/2568-84.wav" // Soft click
          : "https://assets.mixkit.co/active_storage/sfx/2019/2019-84.wav"; // Chime/Bell
      await _player.play(UrlSource(url), volume: 0.3);
    } catch (e) {
      debugPrint("Error playing click sound: $e");
    }
  }

  void _playSuccessChime() async {
    try {
      await _player.play(
        UrlSource("https://assets.mixkit.co/active_storage/sfx/2019/2019-84.wav"),
        volume: 0.5,
      );
    } catch (e) {
      debugPrint("Error playing success chime: $e");
    }
  }

  void increment() {
    if (visualPulseEnabled) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }

    _playClick();

    setState(() {
      count++;
      totalCount++;
    });

    saveData();

    final goal = goals[selectedGoal];

    if (goal > 0 && count >= goal) {
      _playSuccessChime();
      _showCompletionDialog(goal);
    }
  }

  void _showCompletionDialog(int goal) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(anim1);

        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: const Color(0xFF0F1524),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(28),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "✨ MASHA ALLAH ✨",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.08),
                    ),
                    child: const Center(
                      child: Text(
                        "🏆",
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Goal Achieved!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You completed $goal rounds of glorification with ${dhikrPresets[selectedDhikr].english}.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8E9CB2),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          count = 0;
                          streak++;
                        });
                        saveData();
                      },
                      child: const Text(
                        "Alhamdulillah",
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void resetCounter() {
    setState(() {
      count = 0;
    });
    saveData();
  }

  double progress() {
    final goal = goals[selectedGoal];
    if (goal == 0) return 0;
    return (count / goal).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final goal = goals[selectedGoal];
    final activePreset = dhikrPresets[selectedDhikr];
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: const Text(
            "TASBIH SANCTUARY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background ambient glows
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
                    const Color(0xFFFFD700).withOpacity(0.04),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Column(
              children: [
                // 1. Horizontal Stats Overview Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "CURRENT STREAK",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "🔥 $streak Days",
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "TOTAL DHIKR",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "📿 $totalCount",
                              style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Dhikr Preset Horizontal Carousel Selector
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: dhikrPresets.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedDhikr == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDhikr = index;
                          });
                          saveData();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                                : null,
                            color: isSelected ? null : const Color(0xFF131B2E).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.03),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              dhikrPresets[index].english,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Gorgeous Glassmorphic Active Presets Display Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Column(
                    children: [
                      // Arabic
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: Text(
                          activePreset.arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: 'QuranFont',
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // English Meaning
                      Text(
                        "\"${activePreset.translation}\"",
                        style: const TextStyle(
                          color: Color(0xFF8E9CB2),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Benefit Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060914).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.02)),
                        ),
                        child: Text(
                          "💡 ${activePreset.benefit}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // 4. Concentric Glowing Tap Ring
                GestureDetector(
                  onTap: increment,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Ambient Glow Shadows
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.04),
                                  blurRadius: 40,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Custom gradient progress ring painter
                          CustomPaint(
                            size: const Size(244, 244),
                            painter: GradientCircularProgressPainter(progress: progress()),
                          ),

                          // Concentric Tap bead surface
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B2742), Color(0xFF0F1524)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$count",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  if (goal > 0)
                                    Text(
                                      "/ $goal",
                                      style: const TextStyle(
                                        color: Color(0xFF8E9CB2),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "TAP",
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
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
                ),

                const SizedBox(height: 35),

                // 5. Goals row selection
                Wrap(
                  spacing: 12,
                  children: List.generate(goals.length, (index) {
                    final isSelected = selectedGoal == index;
                    final g = goals[index];
                    return ChoiceChip(
                      selected: isSelected,
                      selectedColor: const Color(0xFFFFD700),
                      backgroundColor: const Color(0xFF131B2E).withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.02),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      label: Text(
                        g == 0 ? "∞" : g.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedGoal = index;
                        });
                        saveData();
                      },
                    );
                  }),
                ),

                const SizedBox(height: 25),

                // 6. Settings Panel card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Column(
                    children: [
                      // Sound Setting switcher row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 18),
                              SizedBox(width: 8),
                              Text("Click Sound", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() => soundSetting = 0);
                                  saveData();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: soundSetting == 0 ? const Color(0xFFFFD700) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("Mute", style: TextStyle(color: soundSetting == 0 ? Colors.black : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => soundSetting = 1);
                                  saveData();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: soundSetting == 1 ? const Color(0xFFFFD700) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("Click", style: TextStyle(color: soundSetting == 1 ? Colors.black : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => soundSetting = 2);
                                  saveData();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: soundSetting == 2 ? const Color(0xFFFFD700) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("Bell", style: TextStyle(color: soundSetting == 2 ? Colors.black : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 7. Reset Counter button
                OutlinedButton.icon(
                  onPressed: resetCounter,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8B8B),
                    side: BorderSide(color: const Color(0xFFFF8B8B).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text("Reset Count", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  GradientCircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw active progress arc with gold radial-like gradient shader
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final activePaint = Paint()
        ..shader = const SweepGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
          stops: [0.0, 0.5, 1.0],
          transform: GradientRotation(-pi / 2),
        ).createShader(rect)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}