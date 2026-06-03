import 'package:flutter/material.dart';
import '../services/prayer_time_service.dart';

class AchievementItem {
  final String id;
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final String progressText;
  final String rarity; // Common, Rare, Legendary

  const AchievementItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.progress,
    required this.progressText,
    required this.rarity,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  late int _currentStreak;
  late int _bestStreak;
  final int _totalDhikr = 450;
  final int _surahsRead = 1;

  late List<AchievementItem> _achievements;

  @override
  void initState() {
    super.initState();
    _currentStreak = _prayerTimeService.currentStreak;
    _bestStreak = _prayerTimeService.bestStreak;
    _loadAchievements();
  }

  void _loadAchievements() {
    _achievements = [
      AchievementItem(
        id: "fajr_warrior",
        icon: "🌅",
        title: "Fajr Warrior",
        description: "Pray Fajr on time 5 days in a row.",
        isUnlocked: _currentStreak >= 5,
        progress: (_currentStreak / 5).clamp(0.0, 1.0),
        progressText: "$_currentStreak/5 days",
        rarity: "Common",
      ),
      AchievementItem(
        id: "sisters_sanctuary",
        icon: "🌸",
        title: "Sanctuary Guardian",
        description: "Successfully verify and enter Gentle Mode.",
        isUnlocked: true,
        progress: 1.0,
        progressText: "Completed",
        rarity: "Rare",
      ),
      AchievementItem(
        id: "dhikr_master",
        icon: "📿",
        title: "Dhikr Master",
        description: "Perform 1,000 total dhikrs in Tasbih counter.",
        isUnlocked: _totalDhikr >= 1000,
        progress: (_totalDhikr / 1000).clamp(0.0, 1.0),
        progressText: "$_totalDhikr/1,000 dhikrs",
        rarity: "Rare",
      ),
      AchievementItem(
        id: "quran_devotee",
        icon: "📖",
        title: "Quran Devotee",
        description: "Read 3 full Surahs in Mushaf mode.",
        isUnlocked: _surahsRead >= 3,
        progress: (_surahsRead / 3).clamp(0.0, 1.0),
        progressText: "$_surahsRead/3 Surahs",
        rarity: "Legendary",
      ),
      AchievementItem(
        id: "tahajjud_seeker",
        icon: "🌌",
        title: "Tahajjud Seeker",
        description: "Awake for Tahajjud and log Salah details.",
        isUnlocked: false,
        progress: 0.0,
        progressText: "0/1 times",
        rarity: "Legendary",
      ),
      AchievementItem(
        id: "consistency_star",
        icon: "⭐",
        title: "Consistency Star",
        description: "Maintain a spiritual streak of 7 days.",
        isUnlocked: _currentStreak >= 7,
        progress: (_currentStreak / 7).clamp(0.0, 1.0),
        progressText: "$_currentStreak/7 days",
        rarity: "Common",
      ),
    ];
  }

  void _showAchievementDetail(AchievementItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final rarityColor = item.rarity == "Legendary"
            ? const Color(0xFFFFD700)
            : item.rarity == "Rare"
                ? const Color(0xFFC3B1E1)
                : const Color(0xFF8E9CB2);

        return Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 20),
              // Large Badge Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isUnlocked
                      ? const Color(0xFFFFD700).withOpacity(0.1)
                      : Colors.white.withOpacity(0.02),
                  border: Border.all(
                    color: item.isUnlocked ? const Color(0xFFFFD700) : Colors.white12,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: TextStyle(fontSize: 48, color: item.isUnlocked ? null : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title & Rarity
              Text(
                item.title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rarityColor.withOpacity(0.3)),
                ),
                child: Text(
                  item.rarity.toUpperCase(),
                  style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isUnlocked ? const Color(0xFF2ECC71) : const Color(0xFFFFD700),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item.progressText,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Share button if unlocked
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isUnlocked ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.04),
                    foregroundColor: item.isUnlocked ? Colors.black : Colors.white30,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: item.isUnlocked
                      ? () {
                          Navigator.pop(context);
                          _shareCertificate(item);
                        }
                      : null,
                  icon: const Icon(Icons.share_rounded),
                  label: const Text(
                    "Share Accomplishment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  void _shareCertificate(AchievementItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Certificate Frame Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131B2E), Color(0xFF060914)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Brand Badge
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                      ).createShader(bounds),
                      child: const Text(
                        "PRAYERRISE",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "CERTIFICATE OF DILIGENCE",
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "This is awarded for unlocking",
                      style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    // Moon graphic or stamp
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
                      ),
                      child: const Center(
                        child: Text("🌙", style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Verified Spiritual Growth",
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Dialog actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text("Close"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Certificate saved to gallery & copied!"),
                          backgroundColor: Color(0xFF2ECC71),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_done_rounded),
                    label: const Text("Export Card"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
          "Achievements & Streak",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    const Color(0xFFFFD700).withOpacity(0.05),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Streak Status Widget
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text("🔥", style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 6),
                              Text(
                                "$_currentStreak Days",
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text("Current Streak", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12)),
                            ],
                          ),
                          Container(width: 1, height: 70, color: Colors.white10),
                          Column(
                            children: [
                              const Text("👑", style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 6),
                              Text(
                                "$_bestStreak Days",
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text("Best Record", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      // Weekly streak calendar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ["M", "T", "W", "T", "F", "S", "S"].asMap().entries.map((entry) {
                          final idx = entry.key;
                          final day = entry.value;
                          final isToday = idx == 6; // Sunday mock
                          final isDone = idx < 6; // mock active previous days

                          return Column(
                            children: [
                              Text(day, style: TextStyle(color: isToday ? const Color(0xFFFFD700) : const Color(0xFF8E9CB2), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone 
                                      ? const Color(0xFF2ECC71).withOpacity(0.15)
                                      : isToday 
                                          ? const Color(0xFFFFD700).withOpacity(0.15)
                                          : Colors.white.withOpacity(0.02),
                                  border: Border.all(
                                    color: isDone 
                                        ? const Color(0xFF2ECC71) 
                                        : isToday 
                                            ? const Color(0xFFFFD700) 
                                            : Colors.white10,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isDone 
                                        ? Icons.check 
                                        : isToday 
                                            ? Icons.star_rounded 
                                            : Icons.radio_button_unchecked,
                                    color: isDone 
                                        ? const Color(0xFF2ECC71) 
                                        : isToday 
                                            ? const Color(0xFFFFD700) 
                                            : Colors.white24,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Achievements Grid Header
                const Text(
                  "UNLOCKED SPIRITUAL BADGES",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Grid of Achievements
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _achievements.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final item = _achievements[index];

                    return GestureDetector(
                      onTap: () => _showAchievementDetail(item),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: item.isUnlocked ? const Color(0xFFFFD700).withOpacity(0.2) : Colors.white.withOpacity(0.03),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.icon,
                                  style: TextStyle(fontSize: 28, color: item.isUnlocked ? null : Colors.grey),
                                ),
                                if (item.isUnlocked)
                                  const Icon(Icons.verified_rounded, color: Color(0xFF2ECC71), size: 18)
                                else
                                  const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 18),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: item.isUnlocked ? Colors.white : Colors.white30,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Tiny progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: item.progress,
                                backgroundColor: Colors.white.withOpacity(0.03),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item.isUnlocked ? const Color(0xFF2ECC71) : const Color(0xFFFFD700).withOpacity(0.5),
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
