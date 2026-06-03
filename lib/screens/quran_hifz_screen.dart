import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranHifzScreen extends StatefulWidget {
  const QuranHifzScreen({super.key});

  @override
  State<QuranHifzScreen> createState() => _QuranHifzScreenState();
}

class _QuranHifzScreenState extends State<QuranHifzScreen> {
  int _streakCount = 5;
  double _overallProgress = 0.35; // 35% of target memorized
  String _activeSurah = "Al-Mulk";
  int _activeTargetStart = 1;
  int _activeTargetEnd = 10;
  List<bool> _memorizedVerses = List.filled(10, false);
  
  // Simulated contribution map data (past 28 days)
  final List<int> _contributions = [
    2, 0, 4, 1, 3, 0, 0,
    1, 2, 0, 3, 4, 1, 2,
    0, 1, 3, 2, 0, 0, 4,
    3, 1, 2, 4, 3, 2, 4,
  ];

  @override
  void initState() {
    super.initState();
    _loadHifzData();
  }

  Future<void> _loadHifzData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streakCount = prefs.getInt('hifz_streak') ?? 5;
      _activeSurah = prefs.getString('hifz_active_surah') ?? "Al-Mulk";
      _activeTargetStart = prefs.getInt('hifz_target_start') ?? 1;
      _activeTargetEnd = prefs.getInt('hifz_target_end') ?? 10;
      
      final savedVerses = prefs.getStringList('hifz_verses_status');
      if (savedVerses != null && savedVerses.length == (_activeTargetEnd - _activeTargetStart + 1)) {
        _memorizedVerses = savedVerses.map((e) => e == 'true').toList();
      } else {
        _memorizedVerses = List.filled(_activeTargetEnd - _activeTargetStart + 1, false);
      }
      _calculateProgress();
    });
  }

  Future<void> _saveHifzData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hifz_streak', _streakCount);
    await prefs.setString('hifz_active_surah', _activeSurah);
    await prefs.setInt('hifz_target_start', _activeTargetStart);
    await prefs.setInt('hifz_target_end', _activeTargetEnd);
    await prefs.setStringList('hifz_verses_status', _memorizedVerses.map((e) => e.toString()).toList());
  }

  void _calculateProgress() {
    int total = _memorizedVerses.length;
    int done = _memorizedVerses.where((element) => element).length;
    setState(() {
      _overallProgress = total > 0 ? done / total : 0;
    });
  }

  void _toggleVerse(int index) {
    setState(() {
      _memorizedVerses[index] = !_memorizedVerses[index];
      _calculateProgress();
      _saveHifzData();
    });

    if (_memorizedVerses[index]) {
      // Trigger a beautiful SnackBar or particles on milestone
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E5B43),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(milliseconds: 1500),
          content: Row(
            children: [
              const Text("✨", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Masha'Allah! Ayah ${_activeTargetStart + index} marked as Memorized!",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Color _getContributionColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF131B2E);
      case 1:
        return const Color(0xFF1E5B43).withOpacity(0.3);
      case 2:
        return const Color(0xFF1E5B43).withOpacity(0.6);
      case 3:
        return const Color(0xFF1E5B43).withOpacity(0.85);
      case 4:
      default:
        return const Color(0xFF2ECC71);
    }
  }

  void _showNewGoalModal() {
    String tempSurah = _activeSurah;
    int tempStart = _activeTargetStart;
    int tempEnd = _activeTargetEnd;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                  const Text(
                    "Set New Memorization Target",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Define your target surah and verse block to commit.",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  
                  // Surah dropdown simulator
                  const Text("SURAH NAME", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempSurah,
                        dropdownColor: const Color(0xFF0F1524),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        items: <String>['Al-Fatiha', 'Al-Kahf', 'Al-Mulk', 'Al-Waqi\'ah', 'An-Naba', 'Yaseen']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => tempSurah = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verse ranges
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("START AYAH", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131B2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.04)),
                              ),
                              child: TextField(
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, hintText: "1", hintStyle: TextStyle(color: Colors.white24)),
                                onChanged: (val) {
                                  tempStart = int.tryParse(val) ?? 1;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("END AYAH", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131B2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.04)),
                              ),
                              child: TextField(
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, hintText: "10", hintStyle: TextStyle(color: Colors.white24)),
                                onChanged: (val) {
                                  tempEnd = int.tryParse(val) ?? 10;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 6,
                        shadowColor: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                      onPressed: () {
                        if (tempEnd >= tempStart) {
                          setState(() {
                            _activeSurah = tempSurah;
                            _activeTargetStart = tempStart;
                            _activeTargetEnd = tempEnd;
                            _memorizedVerses = List.filled(tempEnd - tempStart + 1, false);
                            _overallProgress = 0.0;
                            _saveHifzData();
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("End Ayah must be greater or equal to Start Ayah")),
                          );
                        }
                      },
                      child: const Text("Initialize Target Plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxury Midnight
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Hifz Memorizer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                    const Color(0xFF1E5B43).withOpacity(0.06),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),

                // Streak Banner Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 34)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_streakCount Day Commit Streak",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "Keep reviewing daily to cement the verses.",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "+30 XP",
                          style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Circular Gauge & Current Surah Info
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
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
                                "CURRENT TARGET",
                                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Surah $_activeSurah",
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Verses $_activeTargetStart to $_activeTargetEnd",
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.mode_edit_outline_outlined, color: Color(0xFFFFD700)),
                            onPressed: _showNewGoalModal,
                            tooltip: "Change Target Goal",
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Gorgeous Glass Circular Gauge
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: _overallProgress,
                                strokeWidth: 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                                backgroundColor: const Color(0xFF0F1524),
                              ),
                            ),
                            // Inner Glow Ring
                            Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF131B2E),
                                border: Border.all(color: Colors.white.withOpacity(0.02)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71).withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(_overallProgress * 100).toInt()}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Text(
                                    "MEMORIZED",
                                    style: TextStyle(
                                      color: Color(0xFF8E9CB2),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem("Total Ayahs", "${_memorizedVerses.length}"),
                          Container(width: 1, height: 24, color: Colors.white10),
                          _statItem("Completed", "${_memorizedVerses.where((e) => e).length}"),
                          Container(width: 1, height: 24, color: Colors.white10),
                          _statItem("Remaining", "${_memorizedVerses.where((e) => !e).length}"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Grid Contribution map (GitHub-style calendar for memorization)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MEMORIZATION COMMITMENT GRID",
                        style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Activity (Past 4 Weeks)", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            "${_contributions.where((x) => x > 0).length} active days",
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Grid build
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _contributions.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemBuilder: (context, idx) {
                          return Container(
                            decoration: BoxDecoration(
                              color: _getContributionColor(_contributions[idx]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Less  ", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9)),
                          ...List.generate(5, (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getContributionColor(index),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          )),
                          const Text("  More", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. List of Verses inside Active Target
                const Text(
                  "ACTIVE TARGET CHECKLIST",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _memorizedVerses.length,
                  itemBuilder: (context, i) {
                    final verseNum = _activeTargetStart + i;
                    final isMemorized = _memorizedVerses[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isMemorized 
                            ? const Color(0xFF1E5B43).withOpacity(0.12)
                            : const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isMemorized 
                              ? const Color(0xFF2ECC71).withOpacity(0.3)
                              : Colors.white.withOpacity(0.02),
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: isMemorized ? const Color(0xFF2ECC71) : const Color(0xFF1E5B43).withOpacity(0.15),
                          child: Text(
                            "$verseNum",
                            style: TextStyle(
                              color: isMemorized ? Colors.black : const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          "Ayah $verseNum of $_activeSurah",
                          style: TextStyle(
                            color: isMemorized ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: isMemorized ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          isMemorized ? "Committed & Certified" : "Wip • Tap to finalize",
                          style: TextStyle(
                            color: isMemorized ? const Color(0xFF2ECC71) : const Color(0xFF8E9CB2),
                            fontSize: 11,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isMemorized,
                          activeColor: const Color(0xFF2ECC71),
                          checkColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: (_) => _toggleVerse(i),
                        ),
                        onTap: () => _toggleVerse(i),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
