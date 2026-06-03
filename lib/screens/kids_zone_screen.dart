import 'dart:async';
import 'package:flutter/material.dart';

class KidsZoneScreen extends StatefulWidget {
  const KidsZoneScreen({super.key});

  @override
  State<KidsZoneScreen> createState() => _KidsZoneScreenState();
}

class _KidsZoneScreenState extends State<KidsZoneScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Good Deeds Tracker states
  final List<Map<String, dynamic>> _deeds = [
    {"icon": "🤝", "text": "Helped my parents", "checked": false},
    {"icon": "😊", "text": "Smiled at someone", "checked": false},
    {"icon": "🕌", "text": "Prayed my salah", "checked": false},
    {"icon": "📖", "text": "Read a short Surah", "checked": false},
    {"icon": "🍇", "text": "Shared food or toys", "checked": false},
  ];

  // Kids Quiz states
  int _quizIndex = 0;
  int? _selectedAns;
  bool _checkedAns = false;
  int _kidsScore = 0;

  final List<Map<String, dynamic>> _kidsQuestions = const [
    {
      "question": "Who was the very first Prophet created by Allah?",
      "options": ["Prophet Musa", "Prophet Ibrahim", "Prophet Adam", "Prophet Nuh"],
      "ansIdx": 2,
      "funFact": "Allah made Prophet Adam from clay and taught him the names of everything!"
    },
    {
      "question": "Which Prophet built the massive Ark (Ship) to save animals?",
      "options": ["Prophet Yusuf", "Prophet Nuh", "Prophet Isa", "Prophet Muhammad (PBUH)"],
      "ansIdx": 1,
      "funFact": "Prophet Nuh took a pair of every animal—lions, birds, sheep, and more—onto the big Ark!"
    },
    {
      "question": "How many times a day do Muslims pray (Salah)?",
      "options": ["3 times", "4 times", "5 times", "10 times"],
      "ansIdx": 2,
      "funFact": "Praying 5 times a day keeps our hearts clean and keeps us close to Allah!"
    }
  ];

  // Stories
  final List<Map<String, dynamic>> _stories = const [
    {
      "emoji": "🌱",
      "title": "Prophet Adam & Clay",
      "subtitle": "The First Creation",
      "details": "Allah created Prophet Adam from different colored clays of the earth. He taught him the names of all the plants, animals, and stars, making him the father of all humanity."
    },
    {
      "emoji": "🚢",
      "title": "Prophet Nuh & the Ark",
      "subtitle": "The Giant Rescue Ship",
      "details": "Prophet Nuh spent hundreds of years telling people to be good. When a big flood came, Allah told him to build a giant ship. He loaded his family and two of every animal safely onto the Ark."
    },
    {
      "emoji": "👑",
      "title": "Prophet Yusuf & Dreams",
      "subtitle": "The Well to the Palace",
      "details": "Prophet Yusuf was blessed with beauty and the power to explain dreams. Though his brothers threw him in a well out of jealousy, Allah saved him and made him a mighty ruler of Egypt."
    },
    {
      "emoji": "🌊",
      "title": "Prophet Musa & the Sea",
      "subtitle": "The Parted Waves",
      "details": "To save the believers from Pharaoh, Allah told Prophet Musa to strike the Red Sea with his wooden staff. Instantly, the water parted into twelve dry paths, creating walls of water on each side!"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _allDeedsChecked => _deeds.every((element) => element['checked'] == true);

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
          "Kids Zone",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: const Color(0xFF8E9CB2),
          tabs: const [
            Tab(text: "Prophet Stories"),
            Tab(text: "Quiz Quest"),
            Tab(text: "Good Deeds"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Story Tab
          _buildStoriesTab(screenSize),

          // Quiz Tab
          _buildQuizTab(screenSize),

          // Deeds Tab
          _buildDeedsTab(screenSize),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(Size screenSize) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _stories.length,
      itemBuilder: (context, idx) {
        final story = _stories[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.04),
              child: Text(story['emoji'], style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              story['title'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              story['subtitle'],
              style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
            ),
            iconColor: const Color(0xFFFFD700),
            collapsedIconColor: Colors.white60,
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1524),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  story['details'],
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(Size screenSize) {
    if (_quizIndex >= _kidsQuestions.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: const Center(child: Text("⭐", style: TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 25),
              const Text(
                "Super Champ!",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "You scored $_kidsScore out of ${_kidsQuestions.length}",
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "You've earned the Golden Star Badge. Tell your parents to get a reward!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _quizIndex = 0;
                    _kidsScore = 0;
                    _selectedAns = null;
                    _checkedAns = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text("PLAY AGAIN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      );
    }

    final quiz = _kidsQuestions[_quizIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "KIDS QUIZ QUEST",
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              Text(
                "Level: ${_quizIndex + 1}/${_kidsQuestions.length}",
                style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Frame
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E).withOpacity(0.4),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Text(
              quiz['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
          const SizedBox(height: 25),

          // Options cards
          ...List.generate((quiz['options'] as List).length, (index) {
            final option = quiz['options'][index];
            final isSelected = _selectedAns == index;
            final isCorrect = quiz['ansIdx'] == index;

            Color tileColor = const Color(0xFF131B2E).withOpacity(0.4);
            Color borderColor = Colors.white.withOpacity(0.03);
            Widget? trailing;

            if (_checkedAns) {
              if (isCorrect) {
                tileColor = const Color(0xFF1E5B43).withOpacity(0.2);
                borderColor = const Color(0xFF2ECC71).withOpacity(0.4);
                trailing = const Icon(Icons.check, color: Color(0xFF2ECC71));
              } else if (isSelected) {
                tileColor = Colors.redAccent.withOpacity(0.12);
                borderColor = Colors.redAccent.withOpacity(0.4);
                trailing = const Icon(Icons.close, color: Colors.redAccent);
              }
            } else if (isSelected) {
              tileColor = const Color(0xFFFFD700).withOpacity(0.08);
              borderColor = const Color(0xFFFFD700).withOpacity(0.4);
            }

            return GestureDetector(
              onTap: _checkedAns
                  ? null
                  : () {
                      setState(() {
                        _selectedAns = index;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF8E9CB2),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Actions Buttons
          if (!_checkedAns) ...[
            ElevatedButton(
              onPressed: _selectedAns == null
                  ? null
                  : () {
                      setState(() {
                        _checkedAns = true;
                        if (_selectedAns == quiz['ansIdx']) {
                          _kidsScore++;
                        }
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                disabledBackgroundColor: Colors.white10,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text("SUBMIT ANSWER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ] else ...[
            // Fact Bubble
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E5B43).withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "💡 FUN FACT:",
                    style: TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz['funFact'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _quizIndex++;
                  _selectedAns = null;
                  _checkedAns = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5B43),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text("NEXT LEVEL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeedsTab(Size screenSize) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "DAILY GOOD DEED TRACKER",
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          const Text(
            "Complete all five deeds today to unlock the Special Deed Champion Badge!",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 25),

          if (_allDeedsChecked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5B43), Color(0xFF0F1524)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text("🏆", style: TextStyle(fontSize: 32)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deed Champion Unlocked!",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "You've completed all deeds. Allah loves your kindness!",
                          style: TextStyle(color: Color(0xFF2ECC71), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          ...List.generate(_deeds.length, (idx) {
            final deed = _deeds[idx];
            final checked = deed['checked'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: checked ? const Color(0xFF1E5B43).withOpacity(0.12) : const Color(0xFF131B2E).withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: checked ? const Color(0xFF2ECC71).withOpacity(0.3) : Colors.white.withOpacity(0.02),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Text(deed['icon'], style: const TextStyle(fontSize: 22)),
                title: Text(
                  deed['text'],
                  style: TextStyle(
                    color: checked ? Colors.white : const Color(0xFF8E9CB2),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: Checkbox(
                  value: checked,
                  activeColor: const Color(0xFF2ECC71),
                  checkColor: Colors.black,
                  onChanged: (val) {
                    setState(() {
                      _deeds[idx]['checked'] = val;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _deeds[idx]['checked'] = !checked;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
