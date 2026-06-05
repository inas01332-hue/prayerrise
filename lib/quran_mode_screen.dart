import 'package:flutter/material.dart';
import 'screens/quran_screen.dart';

class QuranModeScreen extends StatelessWidget {
  const QuranModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: const Text("Quran"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          children: [
            _card(context, "Mushaf", Icons.menu_book),
            _card(context, "Translation", Icons.translate),
            _card(context, "Tafsir", Icons.auto_stories),
            _card(context, "Audio", Icons.play_circle_fill),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const QuranScreen(),
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