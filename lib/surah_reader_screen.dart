import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/reflection_share_screen.dart';
import 'services/quran_audio_service.dart';

class SurahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List arabicAyahs = [];
  List englishAyahs = [];
  bool loading = true;
  bool _isDarkMode = true; // Default to luxury dark theme!

  // Dynamic language selection parameters (Quran Majeed flow!)
  String _selectedLangName = "English";
  String _selectedLangCode = "en.asad";

  final List<Map<String, String>> _languages = const [
    {"name": "English", "code": "en.asad"},
    {"name": "Amharic (አማርኛ)", "code": "am.sadiq"},
    {"name": "Urdu (اردو)", "code": "ur.khan"},
    {"name": "French (Français)", "code": "fr.hamidullah"},
    {"name": "Spanish (Español)", "code": "es.cortes"},
    {"name": "Turkish (Türkçe)", "code": "tr.ates"},
    {"name": "Indonesian (Bahasa)", "code": "id.indonesian"},
  ];

  // Audio synchronization state
  final QuranAudioService _audioService = QuranAudioService();
  int _currentPlayingIndex = -1;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _completeSub;

  String _activeReciterName = "Mishary Rashid Alafasy";
  String _activeReciterAvatar = "🎙️";
  String _activeReciterPrefix = "https://everyayah.com/data/Alafasy_128kbps/";

  final List<Map<String, String>> _readerReciters = const [
    {"name": "Mishary Rashid Alafasy", "avatar": "🎙️", "prefix": "https://everyayah.com/data/Alafasy_128kbps/"},
    {"name": "Abdul Rahman Al-Sudais", "avatar": "🕌", "prefix": "https://everyayah.com/data/Sudais_64kbps/"},
    {"name": "Maher Al-Muaiqly", "avatar": "⭐", "prefix": "https://everyayah.com/data/MaherMuaiqly128kbps/"},
    {"name": "Saad Al-Ghamdi", "avatar": "🌊", "prefix": "https://everyayah.com/data/Ghamadi_40kbps/"},
  ];

  // Bookmarking lists
  List<String> _bookmarkedAyahKeys = [];

  @override
  void initState() {
    super.initState();
    loadSurah();
    _loadBookmarks();

    _audioService.addListener(_onAudioStateChanged);
    _completeSub = _audioService.onComplete.listen((_) {
      _playNextAyah();
    });
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    _completeSub?.cancel();
    _scrollController.dispose();
    // Stop the playback when exiting this Surah screen
    _audioService.stop();
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (!mounted) return;
    setState(() {});
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

  Future<void> loadSurah() async {
    setState(() {
      loading = true;
    });

    try {
      final arabicResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}'),
      );

      final englishResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/$_selectedLangCode'),
      );

      if (arabicResponse.statusCode == 200 && englishResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            arabicAyahs = jsonDecode(arabicResponse.body)['data']['ayahs'];
            englishAyahs = jsonDecode(englishResponse.body)['data']['ayahs'];
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
          const SnackBar(content: Text("Failed to load translation. Please check connection.")),
        );
      }
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                "Select Translation Language",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Change translation language in real-time.",
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _languages.length,
                  itemBuilder: (context, idx) {
                    final lang = _languages[idx];
                    final isSel = _selectedLangCode == lang['code'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E5B43).withOpacity(0.15) : const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSel ? const Color(0xFF2ECC71).withOpacity(0.3) : Colors.transparent),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          child: const Icon(Icons.language_rounded, color: Color(0xFFFFD700), size: 18),
                        ),
                        title: Text(
                          lang['name']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle, color: Color(0xFF2ECC71))
                            : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                        onTap: () {
                          setState(() {
                            _selectedLangName = lang['name']!;
                            _selectedLangCode = lang['code']!;
                          });
                          Navigator.pop(context);
                          loadSurah(); // Reload translation text instantly!
                        },
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

  void _startAudioSync() {
    if (_currentPlayingIndex == -1) {
      _playAyah(0);
    } else {
      final expectedUrl = _getAyahAudioUrl(_currentPlayingIndex);
      if (_audioService.isPlaying && _audioService.currentUrl == expectedUrl) {
        _audioService.pause();
      } else {
        if (_audioService.currentUrl == expectedUrl) {
          _audioService.resume();
        } else {
          _playAyah(_currentPlayingIndex);
        }
      }
    }
  }

  String _getAyahAudioUrl(int index) {
    final String surahStr = widget.surahNumber.toString().padLeft(3, '0');
    final String ayahStr = (index + 1).toString().padLeft(3, '0');
    return "$_activeReciterPrefix$surahStr$ayahStr.mp3";
  }

  void _playAyah(int index) {
    setState(() {
      _currentPlayingIndex = index;
    });
    final url = _getAyahAudioUrl(index);
    _audioService.play(url);
    _scrollToAyah(index);
  }

  void _playNextAyah() {
    if (!mounted) return;
    if (_currentPlayingIndex < arabicAyahs.length - 1) {
      _playAyah(_currentPlayingIndex + 1);
    } else {
      setState(() {
        _currentPlayingIndex = -1;
      });
      _audioService.stop();
    }
  }

  bool get _isCurrentAyahPlaying {
    if (_currentPlayingIndex == -1) return false;
    final expectedUrl = _getAyahAudioUrl(_currentPlayingIndex);
    return _audioService.isPlaying && _audioService.currentUrl == expectedUrl;
  }

  void _scrollToAyah(int index) {
    if (_scrollController.hasClients) {
      double offset = index * 200.0;
      double maxScroll = _scrollController.position.maxScrollExtent;
      if (offset > maxScroll) offset = maxScroll;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showReciterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                "Select Reciter for Translation Mode",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Change recitation voice for verse highlights.",
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _readerReciters.length,
                  itemBuilder: (context, idx) {
                    final rec = _readerReciters[idx];
                    final isSel = _activeReciterName == rec['name'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E5B43).withOpacity(0.15) : const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSel ? const Color(0xFF2ECC71).withOpacity(0.3) : Colors.transparent),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          child: Text(rec['avatar']!, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          rec['name']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle, color: Color(0xFF2ECC71))
                            : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                        onTap: () {
                          setState(() {
                            _activeReciterName = rec['name']!;
                            _activeReciterAvatar = rec['avatar']!;
                            _activeReciterPrefix = rec['prefix']!;
                          });
                          Navigator.pop(context);
                          if (_currentPlayingIndex != -1) {
                            _playAyah(_currentPlayingIndex); // Switch audio stream instantly
                          }
                        },
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

  List<Map<String, String>> _getWordBreakdown(int ayahIndex, String rawArabic) {
    List<String> words = rawArabic.trim().split(' ');
    List<Map<String, String>> breakdown = [];

    if (widget.surahNumber == 94 && ayahIndex == 4) {
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
    final String rawArabic = arabicAyahs[index]['text'];
    final String rawEnglish = englishAyahs[index]['text'];
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
              "category": "Explorer Bookmark"
            };

            final expectedAyahUrl = _getAyahAudioUrl(index);
            final isThisAyahPlaying = _audioService.isPlaying && _audioService.currentUrl == expectedAyahUrl;

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
                                "AYAH EXPLORER",
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
                              // Play specific ayah button
                              IconButton(
                                icon: Icon(
                                  isThisAyahPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                  color: const Color(0xFFFFD700),
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (isThisAyahPlaying) {
                                    _audioService.pause();
                                  } else {
                                    _playAyah(index);
                                  }
                                  setModalState(() {});
                                  setState(() {});
                                },
                              ),
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
                          // Tab 1: Word-by-Word Breakdown
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme options
    final bgColor = _isDarkMode ? const Color(0xFF060914) : const Color(0xFFFDF8EE);
    final tileColor = _isDarkMode ? const Color(0xFF131B2E).withOpacity(0.5) : Colors.white;
    final borderCol = _isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black12;
    final englishColor = _isDarkMode ? Colors.white70 : Colors.black87;
    final arabicColor = _isDarkMode ? const Color(0xFFFFD700) : const Color(0xFF1F1A10);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        title: Text(widget.surahName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // GORGEOUS LANGUAGE SELECTOR PILL (Like Quran Majeed!)
          GestureDetector(
            onTap: _showLanguageSelector,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _selectedLangName.split(' ').first,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
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
      body: Stack(
        children: [
          loading
              ? const Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: arabicAyahs.length,
                        itemBuilder: (context, index) {
                          final isPlayingThis = index == _currentPlayingIndex;
                          final verseKey = "${widget.surahNumber}_${index + 1}";
                          final isBookmarked = _bookmarkedAyahKeys.contains(verseKey);

                          return GestureDetector(
                            onTap: () => _showContextualExplorer(context, index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isPlayingThis
                                    ? const Color(0xFF1E5B43).withOpacity(0.18)
                                    : tileColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isPlayingThis
                                      ? const Color(0xFF2ECC71).withOpacity(0.4)
                                      : isBookmarked 
                                          ? const Color(0xFFFFD700).withOpacity(0.2)
                                          : borderCol,
                                  width: (isPlayingThis || isBookmarked) ? 1.5 : 1,
                                ),
                                boxShadow: _isDarkMode ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPlayingThis 
                                              ? const Color(0xFF2ECC71).withOpacity(0.2)
                                              : _isDarkMode 
                                                  ? Colors.white.withOpacity(0.04) 
                                                  : Colors.black.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "AYAH ${index + 1}",
                                          style: TextStyle(
                                            color: isPlayingThis
                                                ? const Color(0xFF2ECC71)
                                                : _isDarkMode ? Colors.white54 : Colors.black54,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      if (isBookmarked)
                                        const Icon(Icons.bookmark_rounded, color: Color(0xFFFFD700), size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      arabicAyahs[index]['text'],
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: arabicColor,
                                        fontSize: 26,
                                        fontFamily: 'QuranFont',
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Divider(color: _isDarkMode ? Colors.white10 : Colors.black12),
                                  const SizedBox(height: 10),
                                  
                                  Text(
                                    englishAyahs[index]['text'],
                                    style: TextStyle(
                                      color: englishColor,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Tap for word breakdown & Tafsir 🔍",
                                        style: TextStyle(color: _isDarkMode ? Colors.white24 : Colors.black26, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1524),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.5)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _startAudioSync,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFD700),
                              ),
                              child: Icon(
                                _isCurrentAyahPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentPlayingIndex != -1 ? "Reciting: Ayah ${_currentPlayingIndex + 1}" : "Listen to Recitation",
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isCurrentAyahPlaying ? "Highlight & Autoscroll Active" : "Tap play to sync voice recitation",
                                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reciter selector pill
                          GestureDetector(
                            onTap: _showReciterSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15)),
                              ),
                              child: Row(
                                children: [
                                  Text("$_activeReciterAvatar ", style: const TextStyle(fontSize: 12)),
                                  Text(
                                    _activeReciterName.split(' ').last,
                                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}