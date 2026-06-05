import 'package:flutter/material.dart';
import 'quran_screen.dart';

class QuranHubScreen extends StatelessWidget {
  const QuranHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: const Text("📖 Quran Center"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B2742),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFFFFD700),
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "The Noble Quran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Read • Listen • Learn • Memorize",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [

                  _card(
                    context,
                    "📜",
                    "Mushaf",
                    "114 Surahs",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuranScreen(),
                        ),
                      );
                    },
                  ),

                  _card(
                    context,
                    "🌍",
                    "Translation",
                    "All Languages",
                    () {},
                  ),

                  _card(
                    context,
                    "📚",
                    "Tafsir",
                    "Understand Quran",
                    () {},
                  ),

                  _card(
                    context,
                    "🎧",
                    "Audio",
                    "Listen Quran",
                    () {},
                  ),

                  _card(
                    context,
                    "🔖",
                    "Bookmarks",
                    "Saved Ayahs",
                    () {},
                  ),

                  _card(
                    context,
                    "📈",
                    "Hifz",
                    "Memorization",
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF162033),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}