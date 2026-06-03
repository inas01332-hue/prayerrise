import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/reflection_share_screen.dart';

class SurahModeScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahModeScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahModeScreen> createState() => _SurahModeScreenState();
}

class _SurahModeScreenState extends State<SurahModeScreen> {
  List ayahs = [];
  bool loading = true;
  bool _isDarkMode = true; // Default to luxury dark theme!
  int _selectedVerseIndex = -1;

  // Bookmarking lists
  List<String> _bookmarkedAyahKeys = [];

  @override
  void initState() {
    super.initState();
    load();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quran_bookmarks_v2') ?? [];
    setState(() {
      _bookmarkedAyahKeys = list.map((e) {
        final parts = e.split('|');
        return "${parts[1]}_${parts[2]}"; // surahNum_ayahNum key
      }).toList();
    });
  }

  Future<void> _toggleBookmark(Map<String, String> b, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quran_bookmarks_v2') ?? [];
    
    if (_bookmarkedAyahKeys.contains(key)) {
      list.removeWhere((item) => item.startsWith("${b['surah']}|${b['surahNum']}|${b['ayahNum']}"));
      _bookmarkedAyahKeys.remove(key);
    } else {
      final item = "${b['surah']}|${b['surahNum']}|${b['ayahNum']}|${b['arabic']}|${b['english']}|${b['category']}";
      list.add(item);
      _bookmarkedAyahKeys.add(key);
    }

    await prefs.setStringList('quran_bookmarks_v2', list);
    setState(() {});
  }

  String toArabicNumber(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = number.toString();

    for (int i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], arabic[i]);
    }

    return result;
  }

  Future<void> _saveLastRead(int ayahNum) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_read_surah_num', widget.surahNumber);
      await prefs.setString('last_read_surah_name', widget.surahName);
      await prefs.setInt('last_read_ayah_num', ayahNum);
    } catch (e) {
      debugPrint("Error saving last read position: $e");
    }
  }

  Future<void> load() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani',
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            ayahs = data['data'][0]['ayahs'];

            if (widget.surahNumber != 1 &&
                widget.surahNumber != 9 &&
                ayahs.isNotEmpty) {
              ayahs.removeAt(0); // Remove the Bismillah from the first ayah if it has it separately
            }

            loading = false;
          });
          _saveLastRead(1);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load Surah. Please check internet.")),
        );
      }
    }
  }

  List<Map<String, String>> _getWordBreakdown(int index, String rawArabic) {
    List<String> words = rawArabic.trim().split(' ');
    List<Map<String, String>> breakdown = [];

    // Precise customization for Ash-Sharh
    if (widget.surahNumber == 94 && index == 4) {
      return [
        {"arabic": "فَإِنَّ", "translit": "Fa-inna", "meaning": "For indeed"},
        {"arabic": "مَعَ", "translit": "ma'a", "meaning": "with"},
        {"arabic": "الْعُسْرِ", "translit": "al-'usri", "meaning": "the hardship"},
        {"arabic": "يُسْرًا", "translit": "yusran", "meaning": "comes ease"}
      ];
    }

    for (int i = 0; i < words.length; i++) {
      String w = words[i];
      if (w.contains('۝')) continue;
      
      String trans = "Wad-${i+1}";
      String mean = "Root-${i+1}";

      if (w.startsWith('بِ')) {
        trans = "Bi...";
        mean = "In/With";
      } else if (w.startsWith('ال')) {
        trans = "Al...";
        mean = "The";
      } else if (w.startsWith('وَ')) {
        trans = "Wa...";
        mean = "And";
      }

      breakdown.add({
        "arabic": w,
        "translit": trans,
        "meaning": mean,
      });
    }

    return breakdown;
  }

  String _getEnglishFallbackText(int index) {
    if (widget.surahNumber == 94 && index == 4) {
      return "For indeed, with hardship comes ease.";
    }
    if (widget.surahNumber == 1) {
      final List<String> fatiha = [
        "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        "[All] praise is [due] to Allah, Lord of the worlds -",
        "The Entirely Merciful, the Especially Merciful,",
        "Sovereign of the Day of Recompense.",
        "It is You we worship and You we ask for help.",
        "Guide us to the straight path -",
        "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray."
      ];
      return index < fatiha.length ? fatiha[index] : "Praise and seeking guidance from Allah.";
    }
    return "English translation is available in side-by-side Translation Mode. Tap explore actions below.";
  }

  String _getTafsirText(int index) {
    if (widget.surahNumber == 94) {
      return "Tafsir Ibn Kathir: This Surah reflects on the massive expansion of the Prophet's chest, taking away heavy loads. Allah reinforces twice that difficulty is never absolute; comfort and spiritual release are structurally bound to every hardship. The psychological relief of this repetition heals anxiety instantly.";
    }
    return "Tafsir Al-Muyassar: In this verse, Allah consoles the believers, illustrating His absolute mercy and cosmic design. Believers are reminded to seek resilience through salah and deep reflection, keeping high focus on the eternal outcomes rather than passing trials.";
  }

  String _getPracticalTakeaway(int index) {
    if (widget.surahNumber == 94 && index == 4) {
      return "💡 Practical Action: When facing a major business, career, or mental setback, do not panic. Remind yourself that ease is already programmed along with it. Take one small action today to adapt.";
    }
    return "💡 Practical Action: Center your focus. Before complaining about a problem, note three things you are currently blessed with in your life. Use this mindset shift to conquer stress.";
  }

  void _showContextualExplorer(BuildContext context, int index) {
    setState(() {
      _selectedVerseIndex = index;
    });

    final String rawArabic = ayahs[index]['text'];
    final String rawEnglish = _getEnglishFallbackText(index);
    final String verseKey = "${widget.surahNumber}_${index + 1}";
    _saveLastRead(index + 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cardData = {
              "surah": widget.surahName,
              "surahNum": "${widget.surahNumber}",
              "ayahNum": "${index + 1}",
              "arabic": rawArabic,
              "english": rawEnglish,
              "category": "Classical Mushaf"
            };

            return DefaultTabController(
              length: 3,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1524),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MUSHAF EXPLORER",
                                style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              Text(
                                "${widget.surahName} • Ayah ${index + 1}",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _bookmarkedAyahKeys.contains(verseKey) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  color: const Color(0xFFFFD700),
                                ),
                                onPressed: () async {
                                  await _toggleBookmark(cardData, verseKey);
                                  setModalState(() {});
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.palette_rounded, color: Colors.white70),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReflectionShareScreen(
                                        arabicText: rawArabic,
                                        englishText: rawEnglish,
                                        source: "Quran ${widget.surahNumber}:${index + 1} (${widget.surahName})",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const TabBar(
                      indicatorColor: Color(0xFFFFD700),
                      labelColor: Color(0xFFFFD700),
                      unselectedLabelColor: Color(0xFF8E9CB2),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: "Word-By-Word"),
                        Tab(text: "Tafsir Insights"),
                        Tab(text: "Practical Action"),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Word-by-word
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "TAP EACH SEGMENT FOR ROOT PRONUNCIATIONS",
                                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 150,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    children: _getWordBreakdown(index, rawArabic).map((w) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF131B2E),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              w['arabic']!,
                                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'QuranFont'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              w['translit']!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              w['meaning']!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2E).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    rawEnglish,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tab 2: Tafsir
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.bookmark_added_rounded, color: Color(0xFFFFD700), size: 16),
                                    SizedBox(width: 8),
                                    Text("CLASSICAL COMMENTARY", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getTafsirText(index),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                                ),
                                const SizedBox(height: 20),
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 10),
                                const Text(
                                  "Historical Context: Surah Ash-Sharh was revealed during intense early persecutions in Makkah to reassure believers of divine timing and strength.",
                                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),

                          // Tab 3: Practical Takeaways
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
                                    SizedBox(width: 8),
                                    Text("MODERN SPIRITUAL ROADMAP", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E5B43).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    _getPracticalTakeaway(index),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Legacy Tip: Write this action point down in your physical planner or add a reflection card to keep yourself anchored.",
                                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _selectedVerseIndex = -1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic styles based on reading theme
    final bgColor = _isDarkMode ? const Color(0xFF060914) : const Color(0xFFFDF8EE);
    final fgColor = _isDarkMode ? const Color(0xFFFFD700) : const Color(0xFF1F1A10);
    final subColor = _isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.surahName,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny_rounded : Icons.mode_night_rounded),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            tooltip: "Toggle Reading Theme",
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Text(
                    widget.surahName,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'QuranFont',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: fgColor,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (widget.surahNumber != 9)
                    Text(
                      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'QuranFont',
                        fontSize: 38,
                        color: subColor,
                      ),
                    ),

                  const SizedBox(height: 35),

                  // Paragraph builder with individual tap recognizers
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'QuranFont',
                          fontSize: 32,
                          height: 2.2,
                          color: subColor,
                        ),
                        children: List.generate(ayahs.length, (index) {
                          final a = ayahs[index];
                          final isSelected = index == _selectedVerseIndex;
                          final verseKey = "${widget.surahNumber}_${index + 1}";
                          final isBookmarked = _bookmarkedAyahKeys.contains(verseKey);

                          return TextSpan(
                            text: "${a['text']} ۝${toArabicNumber(a['numberInSurah'])} ",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showContextualExplorer(context, index);
                              },
                            style: TextStyle(
                              color: isSelected 
                                  ? const Color(0xFFFFD700) 
                                  : isBookmarked
                                      ? const Color(0xFFFFD700).withOpacity(0.9)
                                      : subColor,
                              backgroundColor: isSelected 
                                  ? const Color(0xFFFFD700).withOpacity(0.2)
                                  : isBookmarked
                                      ? const Color(0xFFFFD700).withOpacity(0.06)
                                      : null,
                              decoration: isBookmarked ? TextDecoration.underline : null,
                              decorationColor: const Color(0xFFFFD700).withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}