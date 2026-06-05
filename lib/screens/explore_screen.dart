import 'package:flutter/material.dart';
import 'qibla_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: const Text("✨ Explore More"),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
        children: [
          _feature("🎓", "Tajweed"),
          _feature("📜", "99 Names"),
          _feature("🔥", "Streaks"),
          _feature("👶", "Kids Zone"),
          _featureTappable(context, "🧭", "Qibla", const QiblaScreen()),
          _feature("🕌", "Masjid Finder"),
          _feature("🥗", "Halal Places"),
          _feature("💌", "E-Cards"),
          _feature("🌐", "Language"),
          _feature("💡", "Daily Tips"),
          _feature("📝", "Islam Quiz"),
          _feature("🏆", "Achievements"),
        ],
      ),
    );
  }

  static Widget _featureTappable(
      BuildContext context, String icon, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF162033),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap to open",
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _feature(String icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF162033),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 42),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Coming Soon",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}