import 'package:flutter/material.dart';
import 'home_screen.dart';

class ComfortDua {
  final String title;
  final String arabic;
  final String english;
  final String benefit;

  const ComfortDua({
    required this.title,
    required this.arabic,
    required this.english,
    required this.benefit,
  });
}

class GirlyModeScreen extends StatefulWidget {
  const GirlyModeScreen({super.key});

  @override
  State<GirlyModeScreen> createState() => _GirlyModeScreenState();
}

class _GirlyModeScreenState extends State<GirlyModeScreen>
    with SingleTickerProviderStateMixin {
  
  // Selected state for Emotion Check-in
  String _selectedEmotion = "Tired";

  // State for Q&A Accordion (which question index is expanded)
  int _expandedFaqIndex = -1;

  // Sound/Haptic states for the Sisters Dhikr
  int _sistersDhikrCount = 0;
  String _sistersDhikrType = "Ya Salam"; // Special Dhikr of Ease

  // Audio player simulation states
  bool _isPlayingAudio = false;
  late AnimationController _audioWaveController;

  @override
  void initState() {
    super.initState();
    _audioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioWaveController.dispose();
    super.dispose();
  }

  // Comfort cards data based on emotional check-in
  Map<String, Map<String, String>> _getComfortContent() {
    return {
      "Tired": {
        "verse": "لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
        "reference": "Allah does not burden a soul beyond that it can bear. (Qur'an 2:286)",
        "tip": "Your rest is your active worship right now by Allah's command. Close your eyes, take 5 slow breaths, and let your body recover. Try a warm cup of chamomile tea.",
        "dua": "Ya Allah, accept my rest and restore my energy.",
      },
      "Hurting": {
        "verse": "الَّذِي يَشْفِينِ",
        "reference": "Hadith: 'No fatigue, nor disease, nor sad anxiety befalls a believer, but that Allah expiates some of her sins.'",
        "tip": "Place a warm heating pad on your abdomen. Slow down your breathing. Let the physical discomfort cleanse and elevate your spiritual rank.",
        "dua": "اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَاسَ اشْفِ أَنْتَ الشَّافِي\n(O Allah, Lord of mankind, remove this pain. You are the Healer.)",
      },
      "Sad/Heavy": {
        "verse": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
        "reference": "For indeed, with hardship comes ease. (Qur'an 94:5)",
        "tip": "Hormonal changes are natural and temporary. Cry if you need to; your tears are beloved to Allah. Wrap yourself in a cozy blanket and listen to a soothing recitation.",
        "dua": "Ya Allah, grant my heart tranquility and replace my sadness with peace.",
      },
      "Reflective": {
        "verse": "فَاذْكُرُونِي أَذْكُرْكُمْ",
        "reference": "So remember Me; I will remember you. (Qur'an 2:152)",
        "tip": "Gaze out at the sky or look around your room. Reflect on Allah's wisdom. Your biological cycle is a beautifully designed natural rhythm aligned with creation.",
        "dua": "Subhan'Allah, how perfect and beautiful is Your design.",
      },
      "Grateful": {
        "verse": "لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
        "reference": "If you are grateful, I will surely increase you. (Qur'an 14:7)",
        "tip": "List three quiet blessings in your mind right now. Sharing silent gratitude expands the heart and invites divine abundance into your space.",
        "dua": "Alhamdulillah for the gift of health, faith, and comfort.",
      },
    };
  }

  // Sisters Comfort Duas list
  final List<ComfortDua> _comfortDuasList = const [
    ComfortDua(
      title: "Dua for Relief from Physical Pain",
      arabic: "أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ",
      english: "I seek refuge in Allah and His Power from the evil of what I feel and worry about.",
      benefit: "Recite 7 times while placing your hand on the area of physical pain/cramping.",
    ),
    ComfortDua(
      title: "Dua for Emotional Relief & Ease",
      arabic: "اللَّهُمَّ لاَ سَهْلَ إِلاَّ مَا جَعَلْتَهُ سَهْلاً وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلاً",
      english: "O Allah, there is no ease except in what You make easy, and You make difficulty easy if You will.",
      benefit: "Recite when feeling overwhelmed, anxious, or heavy-hearted.",
    ),
    ComfortDua(
      title: "Dua for Peace & Soundness of Breast",
      arabic: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
      english: "My Lord, expand for me my breast [with assurance] and ease for me my task.",
      benefit: "A beautiful Quranic prayer (20:25) to invite calm and clarity.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final comfortContent = _getComfortContent()[_selectedEmotion]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A18), // Deep Midnight Rose/Plum Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE8A0B2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "🌸 Sisters Rahma Mode",
          style: TextStyle(
            color: Color(0xFFE8A0B2),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_rounded, color: Color(0xFFE8A0B2)),
            tooltip: "Lock Sanctuary",
            onPressed: () {
              HomeScreen.isSisterVerified = false;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sisters Sanctuary locked. Re-verification required."),
                  backgroundColor: Color(0xFFB03A7B),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: -screenSize.height * 0.1,
            right: -screenSize.width * 0.3,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE754A6).withOpacity(0.08),
                    const Color(0xFF0F0A18).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.1,
            left: -screenSize.width * 0.3,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC3B1E1).withOpacity(0.06),
                    const Color(0xFF0F0A18).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Scroll
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 1. "Spiritual Streak Preserved" Dashboard Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF261233), // Deep plum
                        Color(0xFF160B21),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFE8A0B2).withOpacity(0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.25)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield, color: Color(0xFF2ECC71), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    "STREAK SECURED",
                                    style: TextStyle(
                                      color: Color(0xFF2ECC71),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Rahma Mode Active",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Your biological rest is obedience to Allah. Your spiritual streak remains fully active and rewarded during your periods.",
                              style: TextStyle(
                                color: Color(0xFFB5A7C5),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Glowing dynamic emblem
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8A0B2).withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8A0B2).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "👑",
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2. Interactive "Heart-to-Heart" Wellness Check-In
                const Text(
                  "HEART-TO-HEART CHECK-IN",
                  style: TextStyle(
                    color: Color(0xFFE8A0B2),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "How are you feeling physically and emotionally today?",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                ),
                const SizedBox(height: 12),
                
                // Horizontal Emotion Chips Selector
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildEmotionChip("Tired", "🌸"),
                      _buildEmotionChip("Hurting", "⚡"),
                      _buildEmotionChip("Sad/Heavy", "💧"),
                      _buildEmotionChip("Reflective", "💭"),
                      _buildEmotionChip("Grateful", "🙏"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Dynamic Comfort Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0F2A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFC3B1E1).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.favorite_rounded, color: Color(0xFFE754A6), size: 28),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          comfortContent["verse"]!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'QuranFont',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          comfortContent["reference"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: Colors.white10),
                      ),
                      const Text(
                        "🌸 COMFORT ADVICE",
                        style: TextStyle(
                          color: Color(0xFFE8A0B2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comfortContent["tip"]!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "🤲 DHIKR/DUA TO WHISPER",
                        style: TextStyle(
                          color: Color(0xFFC3B1E1),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          comfortContent["dua"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. Non-Ritual Worship Grid (Active alternatives)
                const Text(
                  "YOUR WORSHIP ALTERNATIVES",
                  style: TextStyle(
                    color: Color(0xFFE8A0B2),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Beautiful ways to remember Allah that require no physical purity.",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildWorshipCard("📿", "Dhikr of Ease", "Pocket Counter", _showSistersDhikrSheet),
                    _buildWorshipCard("🤲", "Comfort Duas", "Relaxing Supplications", _showComfortDuasListSheet),
                    _buildWorshipCard("🎧", "Peaceful Listening", "Audio Player Simulation", _showAudioPlayerSheet),
                    _buildWorshipCard("📖", "Daily Reflections", "Uplifting Tafsir", _showReflectionsSheet),
                  ],
                ),

                const SizedBox(height: 35),

                // 4. Period & Worship FAQ Accordion
                const Text(
                  "PERIODS & WORSHIP FAQ",
                  style: TextStyle(
                    color: Color(0xFFE8A0B2),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Scholarly, encouraging answers tailored for modern Muslim women.",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                ),
                const SizedBox(height: 16),

                _buildFaqItem(
                  index: 0,
                  question: "Can I read Quran on my phone during my period?",
                  answer: "Yes, absolutely! The prohibition is against physically holding a printed copy (Mushaf) of the Quran without purification. Reading from a digital screen, reciting from memory, or reading books of Tafsir are fully permissible and highly encouraged.",
                ),
                _buildFaqItem(
                  index: 1,
                  question: "How do I earn reward if I cannot pray Salah?",
                  answer: "Obedience to Allah is the source of all rewards. When Allah commands you to pray, you pray and earn reward. When Allah commands you to stop praying during periods, you stop and earn reward for your submission. In addition, serving family, doing dhikr, making duas, and listening to Quran are all highly rewarded.",
                ),
                _buildFaqItem(
                  index: 2,
                  question: "Can I enter a mosque or attend spiritual gatherings?",
                  answer: "While the majority of scholars recommend avoiding the primary prayer hall of a mosque, attending educational gatherings, Islamic lectures, community spaces, or outdoor religious events is fully permissible and encouraged so you don't miss out on holy atmospheres.",
                ),
                 _buildFaqItem(
                  index: 3,
                  question: "What is the best routine during these days?",
                  answer: "Exhaustion is natural. We recommend setting a 'Dhikr Alarm' at the normal Salah times. Spend 5 minutes sitting in a quiet place, facing Qibla, reciting comfortable Dhikr and making personal Duas. This maintains your spiritual rhythm easily.",
                ),
                _buildFaqItem(
                  index: 4,
                  question: "Is it permissible to perform Sajdah (prostration) of gratitude?",
                  answer: "Yes, many scholars permit performing Sajdah of gratitude (Sajdat al-Shukr) or Sajdah of Quranic recitation (Sajdat al-Tilawah) without wudu or physical purity, as it is not considered formal prayer (Salah). It is a beautiful way to express direct gratitude to Allah.",
                ),
                _buildFaqItem(
                  index: 5,
                  question: "Can I recite Duas from the Quran during my period?",
                  answer: "Yes. Reciting Quranic verses with the intention of making Dua (supplication) or seeking protection (like Ayat al-Kursi or Surah al-Falaq/al-Nas) is completely permissible according to the majority of scholars, even if reciting full Quranic chapters for recitation is restricted.",
                ),
                _buildFaqItem(
                  index: 6,
                  question: "How can I maintain my Quran memorization (Hifz) cycle?",
                  answer: "You can listen to recitations, read the text from digital devices without touching a Mushaf, recite the verses silently in your heart, or review them from memory. This will ensure your memorization stays strong and active.",
                ),
                _buildFaqItem(
                  index: 7,
                  question: "What acts of worship are recommended for Laylat al-Qadr during periods?",
                  answer: "You can make extensive Duas (especially the famous Dua: 'Allahumma innaka 'afuwwun tuhibbul-'afwa fa'fu 'anni'), perform dhikr, listen to Tafsir, give charity, and feed those who are fasting. You will not miss out on the night's immense rewards!",
                ),
                _buildFaqItem(
                  index: 8,
                  question: "Is it permissible to listen to Quran recitation?",
                  answer: "Yes, listening to the Quran is a highly rewarded form of worship. Allah says, 'When the Qur'an is recited, listen to it and be silent that you may receive mercy.' This requires no physical purity whatsoever.",
                ),
                _buildFaqItem(
                  index: 9,
                  question: "What is the best way to handle negative emotions due to hormonal changes?",
                  answer: "Hormonal shifts are biological and part of Allah's design. Be gentle with yourself. Seek relief in reciting 'Ya Salam' (O Giver of Peace), making authentic duas for anxiety, resting, and remembering that even your patience with physical discomfort is written as reward.",
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helpers to build dynamic items
  Widget _buildEmotionChip(String emotion, String emoji) {
    final isSelected = _selectedEmotion == emotion;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE754A6) : const Color(0xFF1B0F2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE754A6) : const Color(0xFFC3B1E1).withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              emotion,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB5A7C5),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorshipCard(String icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF160B21),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required int index, required String question, required String answer}) {
    final isExpanded = _expandedFaqIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF160B21),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedFaqIndex = isExpanded ? -1 : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFE8A0B2),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: Color(0xFFB5A7C5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  // worship action bottom sheets
  void _showSistersDhikrSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0A18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.15), width: 1.5),
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
                  const Text(
                    "🌸 Dhikr of Relief",
                    style: TextStyle(color: Color(0xFFE8A0B2), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Soothing remembrance specifically for biological ease.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dhikr Type selector chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ["Ya Salam", "Astaghfirullah", "SubhanAllah"].map((type) {
                      final isSel = _sistersDhikrType == type;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _sistersDhikrType = type;
                            _sistersDhikrCount = 0; // reset
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFE754A6) : const Color(0xFF1B0F2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFFB5A7C5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Tapping capsule button
                  GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        _sistersDhikrCount++;
                      });
                      setState(() {
                        // also increment global state
                      });
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF261233), Color(0xFF160B21)],
                        ),
                        border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8A0B2).withOpacity(0.1),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$_sistersDhikrCount",
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "TAP",
                            style: TextStyle(color: Color(0xFFE8A0B2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    _sistersDhikrType == "Ya Salam" 
                      ? "O Giver of Peace (Inviting physical relief & tranquility)"
                      : _sistersDhikrType == "Astaghfirullah"
                        ? "I seek Allah's forgiveness (Purifying your spiritual state)"
                        : "Glory be to Allah (Harmonizing with universal praise)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB5A7C5), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showComfortDuasListSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0A18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
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
                "🤲 Duas for Comfort & Pain Relief",
                style: TextStyle(color: Color(0xFFE8A0B2), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _comfortDuasList.length,
                  itemBuilder: (context, index) {
                    final dua = _comfortDuasList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF160B21),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.02)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dua.title,
                            style: const TextStyle(color: Color(0xFFE8A0B2), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dua.arabic,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold, height: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dua.english,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "💡 Benefit: ${dua.benefit}",
                            style: const TextStyle(color: Color(0xFFC3B1E1), fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
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

  void _showAudioPlayerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0A18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.15), width: 1.5),
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
                  const SizedBox(height: 24),
                  
                  // Album Art simulation
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0F2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.2)),
                    ),
                    child: const Center(
                      child: Text("🌸", style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Surah Ar-Rahman (Soothing Recitation)",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Beautiful non-ritual audio listing during periods",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Live pulsing waveform simulation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(10, (idx) {
                      return AnimatedBuilder(
                        animation: _audioWaveController,
                        builder: (context, child) {
                          double heightVal = 10 + (_isPlayingAudio ? (idx % 3 + 1) * 8 * _audioWaveController.value : 4.0);
                          return Container(
                            width: 6,
                            height: heightVal,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _isPlayingAudio ? const Color(0xFFE754A6) : const Color(0xFF5D6B82),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Audio Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 28),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      // Play Pause glowing button
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _isPlayingAudio = !_isPlayingAudio;
                          });
                          setState(() {
                            // Sync global
                          });
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE754A6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE754A6).withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReflectionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0A18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
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
                "📖 Inspiring Reflections",
                style: TextStyle(color: Color(0xFFE8A0B2), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildReflectionBlock(
                      title: "The Wisdom of Biological Exemptions",
                      body: "Allah's mercy encompasses all states. Removing the obligation of ritual prayer (Salah) and fasting during periods isn't a restriction—it is a divine grant of compassion. Submission to Allah means worshiping Him through activity when He commands, and worshiping Him through rest when He exempts you. Rest with full tranquility.",
                    ),
                    _buildReflectionBlock(
                      title: "The Heartbeat of Dhikr",
                      body: "Salah has specific windows, but Dhikr has no boundaries. You can remember Allah while sitting, resting, walking, or cooking. Silent whispers of glorification are highly beloved and require no ritual purity. Keep your tongue moist with 'SubhanAllah' and let your heart stay connected easily.",
                    ),
                    _buildReflectionBlock(
                      title: "Serving Others as High Worship",
                      body: "Preparing food for family, checking in on friends, raising children, and serving society are powerful active forms of worship. Every good deed done during these days is multiplied in reward. You are not empty; you are overflowing with opportunities for divine connection.",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReflectionBlock({required String title, required String body}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF160B21),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFE8A0B2), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: Color(0xFFB5A7C5), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}