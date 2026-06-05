import 'package:flutter/material.dart';

class DhikrItem {
  final String arabic;
  final String english;
  final String translation;

  const DhikrItem({
    required this.arabic,
    required this.english,
    required this.translation,
  });
}

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _totalCount = 0;
  int _targetIndex = 0; // 0: 33, 1: 99, 2: 100, 3: Infinite
  final List<int> _targets = [33, 99, 100, 0]; // 0 represents infinite

  int _selectedDhikrIndex = 0;
  final List<DhikrItem> _dhikrs = const [
    DhikrItem(
      arabic: "سُبْحَانَ ٱللَّٰهِ",
      english: "Subhan'Allah",
      translation: "Glory be to Allah",
    ),
    DhikrItem(
      arabic: "ٱلْحَمْدُ لِلَّٰهِ",
      english: "Alhamdulillah",
      translation: "Praise be to Allah",
    ),
    DhikrItem(
      arabic: "ٱللَّٰهُ أَكْبَرُ",
      english: "Allahu Akbar",
      translation: "Allah is the Greatest",
    ),
    DhikrItem(
      arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
      english: "La ilaha illallah",
      translation: "There is no deity but Allah",
    ),
    DhikrItem(
      arabic: "أَسْتَغْفِرُ ٱللَّٰهَ",
      english: "Astaghfirullah",
      translation: "I seek forgiveness from Allah",
    ),
  ];

  // Feedback Toggles
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  // Animation controller for tapping halo pulse
  late AnimationController _haloController;
  late Animation<double> _haloScale;
  late Animation<double> _haloOpacity;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _haloScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeOut),
    );
    _haloOpacity = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  void _increment() {
    _haloController.forward().then((_) => _haloController.reverse());
    setState(() {
      _count++;
      _totalCount++;

      final target = _targets[_targetIndex];
      if (target > 0 && _count >= target) {
        _triggerGoalCompletion();
      }
    });
  }

  void _triggerGoalCompletion() {
    // Elegant bottom sheet or dialog to congratulate
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "✨ Masha'Allah ✨",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You have completed your goal of ${_targets[_targetIndex]} Dhikr of",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _dhikrs[_selectedDhikrIndex].english,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _count = 0; // reset this session's count
                    });
                  },
                  child: const Text(
                    "Alhamdulillah (Reset Counter)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  double _getProgress() {
    final target = _targets[_targetIndex];
    if (target == 0) return 0.0;
    return (_count / target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final activeDhikr = _dhikrs[_selectedDhikrIndex];
    final currentTarget = _targets[_targetIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxury Dark Navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tasbih Counter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFFFFD700)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: screenSize.height * 0.1,
            left: screenSize.width * 0.1,
            right: screenSize.width * 0.1,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.04),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  // 1. Selector sheet clicker for Dhikr
                  GestureDetector(
                    onTap: _showDhikrSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book, color: Color(0xFFFFD700), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ACTIVE DHIKR",
                                  style: TextStyle(
                                    color: Color(0xFF8E9CB2),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeDhikr.english,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 2. Main Calligraphy Display
                  Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          activeDhikr.arabic,
                          key: ValueKey(activeDhikr.arabic),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'QuranFont',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          activeDhikr.translation,
                          key: ValueKey(activeDhikr.translation),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // 3. Tactile Pulse Circular Tapper
                  GestureDetector(
                    onTap: _increment,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated pulsing background halo
                        AnimatedBuilder(
                          animation: _haloScale,
                          builder: (context, child) {
                            return Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD700).withOpacity(_haloOpacity.value),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.08),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Outer circular progress path
                        SizedBox(
                          width: 216,
                          height: 216,
                          child: CircularProgressIndicator(
                            value: _getProgress(),
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.03),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        ),

                        // Main inner button capsule
                        Container(
                          width: 194,
                          height: 194,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1B2742),
                                Color(0xFF0F1524),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$_count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              if (currentTarget > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "/ $currentTarget",
                                  style: const TextStyle(
                                    color: Color(0xFF8E9CB2),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Text(
                                "TAP",
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 4. Target Goals Chip Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_targets.length, (index) {
                      final target = _targets[index];
                      final isSelected = _targetIndex == index;
                      final label = target == 0 ? "∞" : "$target";

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _targetIndex = index;
                            _count = 0; // reset session count for new goal
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF131B2E).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF060914) : Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const Spacer(flex: 1),

                  // 5. Sound/Haptic feedback toggles & Reset
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Toggle sound simulation
                        IconButton(
                          icon: Icon(
                            _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            color: _soundEnabled ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
                          ),
                          onPressed: () {
                            setState(() {
                              _soundEnabled = !_soundEnabled;
                            });
                          },
                        ),
                        // Reset button
                        GestureDetector(
                          onLongPress: () {
                            _reset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Counter reset to 0"),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFF8B8B),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Hold Reset to clear"),
                                  duration: Duration(milliseconds: 800),
                                ),
                              );
                            },
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text(
                              "RESET",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                        // Toggle haptic simulation
                        IconButton(
                          icon: Icon(
                            _hapticEnabled ? Icons.vibration_rounded : Icons.phone_android_rounded,
                            color: _hapticEnabled ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
                          ),
                          onPressed: () {
                            setState(() {
                              _hapticEnabled = !_hapticEnabled;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Totals Footer indicator
                  Text(
                    "Total Sessions: $_totalCount Dhikrs",
                    style: const TextStyle(
                      color: Color(0xFF5D6B82),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDhikrSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Select Dhikr",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dhikrs.length,
                  itemBuilder: (context, index) {
                    final item = _dhikrs[index];
                    final isSelected = _selectedDhikrIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDhikrIndex = index;
                          _count = 0; // reset session count for new dhikr
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD700).withOpacity(0.1)
                              : const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFD700).withOpacity(0.3)
                                : Colors.white.withOpacity(0.03),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.english,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.translation,
                                    style: const TextStyle(
                                      color: Color(0xFF8E9CB2),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.arabic,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}