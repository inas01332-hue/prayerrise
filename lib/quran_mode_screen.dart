import 'package:flutter/material.dart';
import 'screens/quran_screen.dart';
import 'screens/quran_audio_screen.dart';
import 'screens/quran_tafsir_reader.dart';

class QuranModeScreen extends StatelessWidget {
  const QuranModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Quran Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _card(
              context,
              "Mushaf",
              Icons.menu_book,
              const QuranScreen(mode: "mushaf"),
            ),
            _card(
              context,
              "Translation",
              Icons.translate,
              const QuranScreen(mode: "translation"),
            ),
            _card(
              context,
              "Tafsir",
              Icons.auto_stories,
              const TafsirExplorerScreen(),
            ),
            _card(
              context,
              "Audio",
              Icons.play_circle_fill,
              const QuranAudioScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Widget targetScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => targetScreen,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF162033),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}