import 'dart:async';
import 'package:flutter/material.dart';

class IslamicCardsScreen extends StatefulWidget {
  const IslamicCardsScreen({super.key});

  @override
  State<IslamicCardsScreen> createState() => _IslamicCardsScreenState();
}

class _IslamicCardsScreenState extends State<IslamicCardsScreen> {
  // Card customization states
  int _selectedGradientIdx = 0;
  int _selectedCalligraphyIdx = 0;
  int _selectedDuaIdx = 0;
  bool _isExporting = false;

  final List<Map<String, dynamic>> _gradients = [
    {
      "name": "Midnight Navy",
      "colors": [const Color(0xFF0F1524), const Color(0xFF060914)],
      "accent": const Color(0xFFFFD700)
    },
    {
      "name": "Emerald Gold",
      "colors": [const Color(0xFF1E5B43), const Color(0xFF0B2017)],
      "accent": const Color(0xFFFFDF7A)
    },
    {
      "name": "Rose Gold",
      "colors": [const Color(0xFFE754A6), const Color(0xFF5A1E3C)],
      "accent": Colors.white
    },
    {
      "name": "Sunset Amber",
      "colors": [const Color(0xFFE67E22), const Color(0xFF2C3E50)],
      "accent": const Color(0xFFFFD700)
    }
  ];

  final List<Map<String, String>> _calligraphies = const [
    {"arabic": "عِيد مُبَارَك", "translit": "Eid Mubarak", "translation": "Blessed Celebration"},
    {"arabic": "جُمُعَة مُبَارَكَة", "translit": "Jumuah Mubarak", "translation": "Blessed Friday"},
    {"arabic": "رَمَضَان كَرِيم", "translit": "Ramadan Kareem", "translation": "Noble Month"},
    {"arabic": "بِسْمِ اللَّهِ", "translit": "Bismillah", "translation": "In the Name of Allah"}
  ];

  final List<String> _duas = const [
    "May Allah shower His blessings upon you and your family.",
    "Wishing you a day filled with peace, prayer, and divine protection.",
    "May your prayers be answered and your heart be filled with tranquility.",
    "May Allah guide us all to the straight path of righteousness."
  ];

  void _exportGreetingCard() {
    setState(() {
      _isExporting = true;
    });

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        // Show satisfying success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F1524),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71)),
                  SizedBox(width: 10),
                  Text("Canvas Saved!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                "Your customized greeting card has been rendered in 4K resolution and saved to your gallery. Share it now!",
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5B43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SHARE NOW"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final activeGrad = _gradients[_selectedGradientIdx];
    final activeCallig = _calligraphies[_selectedCalligraphyIdx];
    final activeDua = _duas[_selectedDuaIdx];

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
          "Islamic Cards",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CANVAS CREATOR",
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Design custom greeting cards with noble calligraphy and share them with friends.",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 25),

                // 1. Live Render Card Preview
                Container(
                  width: double.infinity,
                  height: screenSize.height * 0.28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: activeGrad['colors'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: (activeGrad['accent'] as Color).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Ambient golden stars vector overlay
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Icon(Icons.star_purple500_rounded, color: (activeGrad['accent'] as Color).withOpacity(0.15), size: 36),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Icon(Icons.stars_rounded, color: (activeGrad['accent'] as Color).withOpacity(0.1), size: 48),
                      ),

                      // Calligraphy & Text details center
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            // Calligraphy
                            Text(
                              activeCallig['arabic']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: activeGrad['accent'] as Color,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'QuranFont',
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Translit/Sub
                            Text(
                              activeCallig['translit']!,
                              style: TextStyle(color: (activeGrad['accent'] as Color).withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 14),
                            // Dua text block
                            Text(
                              "\"$activeDua\"",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4, fontStyle: FontStyle.italic),
                            ),
                            const Spacer(),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mosque, color: Colors.white30, size: 12),
                                SizedBox(width: 6),
                                Text(
                                  "PRAYERRISE CANVAS",
                                  style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Customizers Panel
                // Background Gradients Row
                const Text(
                  "CHOOSE CANVAS BACKGROUND",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _gradients.length,
                    itemBuilder: (context, idx) {
                      final grad = _gradients[idx];
                      final isSelected = _selectedGradientIdx == idx;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGradientIdx = idx;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: grad['colors'] as List<Color>,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              grad['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Calligraphies List
                const Text(
                  "CHOOSE NOBLE CALLIGRAPHY",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                ...List.generate(_calligraphies.length, (idx) {
                  final callig = _calligraphies[idx];
                  final isSelected = _selectedCalligraphyIdx == idx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF131B2E).withOpacity(0.8) : const Color(0xFF131B2E).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD700).withOpacity(0.5) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(callig['translit']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(callig['translation']!, style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11)),
                      trailing: Text(
                        callig['arabic']!,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontFamily: 'QuranFont',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCalligraphyIdx = idx;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Duas List
                const Text(
                  "CHOOSE GREETING MESSAGE",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                ...List.generate(_duas.length, (idx) {
                  final dua = _duas[idx];
                  final isSelected = _selectedDuaIdx == idx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF131B2E).withOpacity(0.8) : const Color(0xFF131B2E).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD700).withOpacity(0.5) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        dua,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF8E9CB2),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDuaIdx = idx;
                        });
                      },
                    ),
                  );
                }),

                const SizedBox(height: 30),

                // Action Export button
                ElevatedButton(
                  onPressed: _exportGreetingCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5B43),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    shadowColor: const Color(0xFF1E5B43).withOpacity(0.3),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_for_offline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text("EXPORT 4K CANVAS CARD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Export loader view
          if (_isExporting) ...[
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
                    const SizedBox(height: 24),
                    Text(
                      "COMPILING ELEMENTS...",
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rendering greeting card canvas in 4K resolution.",
                      style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
