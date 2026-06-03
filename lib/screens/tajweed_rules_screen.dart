import 'dart:async';
import 'package:flutter/material.dart';
import 'premium_plus_sheet.dart';

class TajweedRulesScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUnlockPremium;
  const TajweedRulesScreen({super.key, required this.isPremium, required this.onUnlockPremium});

  @override
  State<TajweedRulesScreen> createState() => _TajweedRulesScreenState();
}

class _TajweedRulesScreenState extends State<TajweedRulesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRecording = false;
  bool _recordingFinished = false;
  String _recordingReview = "";
  double _recordingProgress = 0.0;
  Timer? _recordingTimer;

  // Quiz States
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _answerChecked = false;
  int _score = 0;

  final List<Map<String, dynamic>> _tajweedRules = const [
    {
      "title": "Noon Sakinah & Tanween",
      "description": "Rules governing the quiet Noon (نْ) and double vowel tanween (ً ٍ ٌ).",
      "types": [
        {"name": "Izhar (إظهار)", "explanation": "Pronouncing the Noon clearly without nasalization when followed by throat letters: ء هـ ع ح غ خ.", "example": "مِنْ حَيْثُ", "highlight": "نْ ح"},
        {"name": "Idgham (إدغام)", "explanation": "Merging the Noon into the next letter with nasalization (Ghannah) for ي ن م و, and without for ل ر.", "example": "مَنْ يَقُولُ", "highlight": "نْ يَ"},
        {"name": "Ikhfa (إخفاء)", "explanation": "Hiding the sound of Noon, making a nasal sound in the nose, for the remaining 15 letters.", "example": "مِنْ قَبْلِ", "highlight": "نْ قَ"},
        {"name": "Iqlab (إقلاب)", "explanation": "Converting the Noon sound into a Meem (م) when followed by Ba (ب).", "example": "مِنْ بَعْدِ", "highlight": "نْ بَ"}
      ]
    },
    {
      "title": "Meem Sakinah",
      "description": "Rules governing the silent Meem (مْ) followed by any Arabic letter.",
      "types": [
        {"name": "Ikhfa Shafawi", "explanation": "Hiding the Meem with nasalization when followed by Ba (ب).", "example": "تَرْمِيهِمْ بِحِجَارَةٍ", "highlight": "هْمْ بِ"},
        {"name": "Idgham Shafawi", "explanation": "Merging the Meem into another Meem (م) that follows it.", "example": "لَهُمْ مَا يَشَاؤُونَ", "highlight": "هُمْ مَّ"},
        {"name": "Izhar Shafawi", "explanation": "Pronouncing the Meem clearly without nasalization for all other letters.", "example": "أَمْ لَمْ تُنْذِرْهُمْ", "highlight": "أَمْ لَ"}
      ]
    },
    {
      "title": "Al-Mudood (Prolongation)",
      "description": "Elongating the sound of vowels using Alif (ا), Waw (و), or Ya (ي).",
      "types": [
        {"name": "Madd Tabee'ee (Natural)", "explanation": "Standard 2-beat prolongation of vowel letters.", "example": "قَالَ • يَقُولُ • قِيلَ", "highlight": "قَا"},
        {"name": "Madd Wajib Muttasil", "explanation": "Elongation of 4-5 beats when Madd letter and Hamzah are in the same word.", "example": "جَاءَ • السَّمَاءِ", "highlight": "جَاءَ"},
        {"name": "Madd Ja'iz Munfasil", "explanation": "Elongation of 2-5 beats when Madd letter and Hamzah are in separate words.", "example": "إِنَّا أَنْزَلْنَاهُ", "highlight": "إِنَّا أَنْ"}
      ]
    },
    {
      "title": "Al-Qalqalah (Echoing)",
      "description": "Creating a vibrant echoing or bouncing sound on specific quiet letters: ق ط ب ج د.",
      "types": [
        {"name": "Qalqalah Kubra (Strong)", "explanation": "Strong echoing sound on Qalqalah letters situated at the end of an ayah.", "example": "الْفَلَقِ ۝", "highlight": "قِ"},
        {"name": "Qalqalah Sughra (Light)", "explanation": "Light bounce sound on Qalqalah letters situated in the middle of a word.", "example": "يَقْتُلُونَ", "highlight": "قْ"}
      ]
    }
  ];

  final List<Map<String, dynamic>> _quizQuestions = const [
    {
      "verse": "مِنْ بَعْدِ أَنْ رَأَوُا الْآيَاتِ",
      "question": "What is the Tajweed rule for the highlighted words 'مِنْ بَعْدِ'?",
      "options": ["Izhar", "Iqlab", "Idgham", "Ikhfa"],
      "answerIndex": 1,
      "explanation": "When a Noon Sakinah (نْ) is followed by Ba (ب), it changes into a Meem (م) sound with Ghunnah (nasalization). This is Iqlab."
    },
    {
      "verse": "تَرْمِيهِمْ بِحِجَارَةٍ مِنْ سِجِّيلٍ",
      "question": "What rule applies to the transition in 'تَرْمِيهِمْ بِحِجَارَةٍ'?",
      "options": ["Izhar Shafawi", "Idgham Shafawi", "Ikhfa Shafawi", "Qalqalah"],
      "answerIndex": 2,
      "explanation": "A silent Meem (مْ) followed by a Ba (ب) requires hiding the Meem with a nasal sound, known as Ikhfa Shafawi."
    },
    {
      "verse": "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ",
      "question": "Which rule applies to the final letter of 'الْفَلَقِ' when stopping?",
      "options": ["Madd Wajib", "Qalqalah Kubra", "Iqlab", "Qalqalah Sughra"],
      "answerIndex": 1,
      "explanation": "The letter Qaf (ق) is a Qalqalah letter. When it occurs at the end of the ayah (when stopping), it undergoes a strong echo sound (Qalqalah Kubra)."
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
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _handleRecordTap() {
    if (!widget.isPremium) {
      PremiumPlusSheet.show(context, widget.onUnlockPremium);
      return;
    }

    if (_isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingFinished = true;
        _recordingReview = "Nura AI Coach Review:\n• Pronunciation Score: 96%\n• Echo (Qalqalah) strength is correct.\n• Avoid shortening Madd Ja'iz in 'إِنَّا أَنْزَلْنَاهُ'. Keep it strictly 4 counts.";
      });
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordingFinished = false;
        _recordingProgress = 0.0;
      });

      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          if (_recordingProgress < 1.0) {
            _recordingProgress += 0.02;
          } else {
            _handleRecordTap(); // auto stop at 5 seconds
          }
        });
      });
    }
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
          "Tajweed Rules",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: const Color(0xFF8E9CB2),
          tabs: const [
            Tab(text: "Library"),
            Tab(text: "Practice AI"),
            Tab(text: "Quiz Quest"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Library of rules
          _buildLibraryTab(screenSize),

          // Tab 2: Practice AI
          _buildPracticeTab(screenSize),

          // Tab 3: Quiz Quest
          _buildQuizTab(screenSize),
        ],
      ),
    );
  }

  Widget _buildLibraryTab(Size screenSize) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _tajweedRules.length,
      itemBuilder: (context, idx) {
        final category = _tajweedRules[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: ExpansionTile(
            shape: const Border(), // Removes bottom line
            title: Text(
              category['title'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                category['description'],
                style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
              ),
            ),
            iconColor: const Color(0xFFFFD700),
            collapsedIconColor: Colors.white60,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: (category['types'] as List).map<Widget>((type) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1524),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type['name'],
                          style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            type['example'],
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontFamily: 'QuranFont',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      type['explanation'],
                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
                    ),
                    if (type['highlight'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Highlight letters: ${type['highlight']}",
                        style: const TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ]
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPracticeTab(Size screenSize) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NURA AI RECITATION COACH",
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          const Text(
            "Practice reciting Quran verses and get detailed voice feedback analysis from Nura AI.",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 25),

          // Core Practice verse card
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
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                const Text(
                  "PRACTICE VERSE",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 18),
                const Text(
                  "إِنَّا أَنْزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'QuranFont',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "\"Indeed, We sent it down in the Night of Decree.\"",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Surah Al-Qadr 97:1",
                  style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                const Text(
                  "Watch rules: Madd Ja'iz (إِنَّا أَنْ) • Qalqalah Sughra (الْقَدْ)",
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Recording widget
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E).withOpacity(0.4),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Column(
              children: [
                if (_isRecording) ...[
                  // Recording soundwave micro-animation (Visualizer)
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (idx) {
                        // Create animated bars
                        final height = 15.0 + 35.0 * (DateTime.now().millisecondsSinceEpoch % (200 * (idx + 1)) / (200 * (idx + 1)));
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 3.5,
                          height: height,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Listening... Recording (${(_recordingProgress * 5).toStringAsFixed(1)}s)",
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ] else if (_recordingFinished) ...[
                  // Recording analysis details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5B43).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.2)),
                    ),
                    child: Text(
                      _recordingReview,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  const Icon(Icons.mic_none_rounded, color: Color(0xFF8E9CB2), size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap button to record pronunciation",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Button
                GestureDetector(
                  onTap: _handleRecordTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.redAccent.withOpacity(0.15) : const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRecording ? Colors.redAccent : const Color(0xFFFFD700),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: _isRecording ? Colors.redAccent : const Color(0xFFFFD700),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? "STOP RECORDING" : "START PRACTICE COACH",
                          style: TextStyle(
                            color: _isRecording ? Colors.redAccent : const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!widget.isPremium) ...[
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 12),
                      SizedBox(width: 4),
                      Text(
                        "Premium Plus Feature",
                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab(Size screenSize) {
    if (_currentQuestionIndex >= _quizQuestions.length) {
      // Show Score / Result screen
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.08),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: const Text("🏆", style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 25),
              const Text(
                "Quiz Completed!",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "You scored $_score out of ${_quizQuestions.length}",
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Keep practicing rule definitions to sharpen your tajweed instincts.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _selectedAnswerIndex = null;
                    _answerChecked = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text("RETRY QUIZ QUEST", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      );
    }

    final quiz = _quizQuestions[_currentQuestionIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TAJWEED INTERACTIVE QUIZ",
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              Text(
                "Q: ${_currentQuestionIndex + 1}/${_quizQuestions.length}",
                style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E).withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Column(
              children: [
                // Highlighted Arabic Verse
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060914),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    quiz['verse'],
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontFamily: 'QuranFont',
                      fontSize: 24,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  quiz['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Options Checklist
          ...List.generate((quiz['options'] as List).length, (index) {
            final option = quiz['options'][index];
            final isSelected = _selectedAnswerIndex == index;
            final isCorrect = quiz['answerIndex'] == index;

            Color tileColor = const Color(0xFF131B2E).withOpacity(0.4);
            Color borderColor = Colors.white.withOpacity(0.03);
            Widget? trailing;

            if (_answerChecked) {
              if (isCorrect) {
                tileColor = const Color(0xFF1E5B43).withOpacity(0.2);
                borderColor = const Color(0xFF2ECC71).withOpacity(0.4);
                trailing = const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71));
              } else if (isSelected) {
                tileColor = Colors.redAccent.withOpacity(0.12);
                borderColor = Colors.redAccent.withOpacity(0.4);
                trailing = const Icon(Icons.cancel_rounded, color: Colors.redAccent);
              }
            } else if (isSelected) {
              tileColor = const Color(0xFFFFD700).withOpacity(0.08);
              borderColor = const Color(0xFFFFD700).withOpacity(0.4);
            }

            return GestureDetector(
              onTap: _answerChecked
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswerIndex = index;
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

          // Action Button (Check Answer / Next Question)
          if (!_answerChecked) ...[
            ElevatedButton(
              onPressed: _selectedAnswerIndex == null
                  ? null
                  : () {
                      setState(() {
                        _answerChecked = true;
                        if (_selectedAnswerIndex == quiz['answerIndex']) {
                          _score++;
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
              child: const Text("CHECK ANSWER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ] else ...[
            // Explanation box
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rule Explanation:",
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quiz['explanation'],
                    style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex++;
                  _selectedAnswerIndex = null;
                  _answerChecked = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5B43),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text("NEXT QUESTION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ],
        ],
      ),
    );
  }
}
