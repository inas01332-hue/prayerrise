import 'package:flutter/material.dart';
import 'quran_screen.dart';
import 'duas_screen.dart';
import 'quran_bookmarks_screen.dart';
import 'quran_hifz_screen.dart';
import 'quran_audio_screen.dart';
import 'quran_tafsir_reader.dart'; // import the new Tafsir reader!

class QuranHubScreen extends StatelessWidget {
  const QuranHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Premium Midnight Space
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quran Center",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -screenSize.height * 0.15,
            right: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E5B43).withOpacity(0.04),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Main body fully wrapped in scroll view to prevent cutoffs on all devices!
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Noble Quran Card Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF131B2E),
                        Color(0xFF0F1524),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFFFD700),
                        size: 56,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "The Noble Quran",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Read • Listen • Learn • Reflect",
                        style: TextStyle(
                          color: Color(0xFF8E9CB2),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2 PRIMARY HERO BUTTONS (Mushaf & Translation)
                const Text(
                  "READ & RECITE STYLE",
                  style: TextStyle(
                    color: Color(0xFF8E9CB2),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // Hero 1: Classic Mushaf
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuranScreen(mode: "mushaf"),
                            ),
                          );
                        },
                        child: Container(
                          height: 130,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E5B43), Color(0xFF0B2017)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1.2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF1E5B43).withOpacity(0.15), blurRadius: 10),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("📜", style: TextStyle(fontSize: 28)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Read Mushaf",
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Traditional Arabic",
                                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Hero 2: Translations
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuranScreen(mode: "translation"),
                            ),
                          );
                        },
                        child: Container(
                          height: 130,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("🌍", style: TextStyle(fontSize: 28)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Translations",
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Multi-Language",
                                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // COMPANION UTILITIES (Tafsir, Audio, Hifz, Bookmarks)
                const Text(
                  "COMPANION CORE FEATURES",
                  style: TextStyle(
                    color: Color(0xFF8E9CB2),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Premium Card grids or scrolling lanes
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.35,
                  children: [
                    _card(
                      context,
                      "📚",
                      "Inline Tafsir",
                      "Arabic & Tafsir Inline",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TafsirExplorerScreen(),
                          ),
                        );
                      },
                    ),
                    _card(
                      context,
                      "🎧",
                      "Audio Deck",
                      "Visualizer Reciters",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuranAudioScreen(),
                          ),
                        );
                      },
                    ),
                    _card(
                      context,
                      "📈",
                      "Hifz Tracker",
                      "Memorization Goal",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuranHifzScreen(),
                          ),
                        );
                      },
                    ),
                    _card(
                      context,
                      "🔖",
                      "Saved Verses",
                      "Personal Bookmarks",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuranBookmarksScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _card(
    BuildContext context,
    String icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E9CB2),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}