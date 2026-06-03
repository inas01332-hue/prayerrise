import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reflection_share_screen.dart';

class QuranBookmarksScreen extends StatefulWidget {
  const QuranBookmarksScreen({super.key});

  @override
  State<QuranBookmarksScreen> createState() => _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends State<QuranBookmarksScreen> {
  List<Map<String, String>> _bookmarks = [];
  bool _loading = true;

  // Mock list of recent reading histories
  final List<Map<String, dynamic>> _readingHistory = [
    {
      "surah": "Al-Fatiha",
      "number": 1,
      "progress": 1.0,
      "verse": 7,
      "date": "Today"
    },
    {
      "surah": "Al-Kahf",
      "number": 18,
      "progress": 0.45,
      "verse": 50,
      "date": "2 days ago"
    },
    {
      "surah": "Al-Mulk",
      "number": 67,
      "progress": 0.2,
      "verse": 6,
      "date": "Last week"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('quran_bookmarks_v2') ?? [];
    
    // Default mock bookmarks if none exists yet, so that it looks gorgeous immediately!
    if (saved.isEmpty) {
      _bookmarks = [
        {
          "surah": "Al-Baqarah",
          "surahNum": "2",
          "ayahNum": "286",
          "arabic": "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
          "english": "Allah does not burden a soul beyond that it can bear...",
          "category": "Comforting"
        },
        {
          "surah": "Ash-Sharh",
          "surahNum": "94",
          "ayahNum": "5",
          "arabic": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
          "english": "For indeed, with hardship comes ease.",
          "category": "Strength"
        }
      ];
      _saveBookmarks();
    } else {
      _bookmarks = saved.map((e) {
        final parts = e.split('|');
        return {
          "surah": parts[0],
          "surahNum": parts.length > 1 ? parts[1] : "1",
          "ayahNum": parts.length > 2 ? parts[2] : "1",
          "arabic": parts.length > 3 ? parts[3] : "",
          "english": parts.length > 4 ? parts[4] : "",
          "category": parts.length > 5 ? parts[5] : "General",
        };
      }).toList();
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _bookmarks.map((e) {
      return "${e['surah']}|${e['surahNum']}|${e['ayahNum']}|${e['arabic']}|${e['english']}|${e['category']}";
    }).toList();
    await prefs.setStringList('quran_bookmarks_v2', data);
  }

  void _deleteBookmark(int index) {
    final removed = _bookmarks[index];
    setState(() {
      _bookmarks.removeAt(index);
      _saveBookmarks();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC0392B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text("Removed Bookmark: ${removed['surah']} Ayah ${removed['ayahNum']}"),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _bookmarks.insert(index, removed);
              _saveBookmarks();
            });
          },
        ),
      ),
    );
  }

  void _shareBookmark(Map<String, String> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReflectionShareScreen(
          arabicText: b['arabic'] ?? "",
          englishText: b['english'] ?? "",
          source: "Quran ${b['surahNum']}:${b['ayahNum']} (${b['surah']})",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Premium Midnight
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bookmarks & Stats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            bottom: -screenSize.height * 0.1,
            left: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E5B43).withOpacity(0.04),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),

                // 1. Core Reading Statistics Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ring progress indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 76,
                            height: 76,
                            child: CircularProgressIndicator(
                              value: 0.14, // 14% of Quran read
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                              backgroundColor: Color(0xFF060914),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF131B2E),
                            ),
                            child: const Center(
                              child: Text(
                                "14%",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quran Journey Progress",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "You have finished 16 Surahs, 3 Juz, and memorized 25 verses. Keep building your legacy!",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2. Recent Reading Logs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "RECENT LOGS",
                      style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    Text(
                      "${_readingHistory.length} Sessions",
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _readingHistory.length,
                  itemBuilder: (context, idx) {
                    final hist = _readingHistory[idx];
                    final progVal = hist['progress'] as double;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.02)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.chrome_reader_mode_rounded, color: Color(0xFFFFD700), size: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      hist['surah'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      hist['date'],
                                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progVal,
                                        minHeight: 4,
                                        backgroundColor: Colors.white.withOpacity(0.05),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${(progVal * 100).toInt()}% Done (Ayah ${hist['verse']})",
                                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // 3. Saved Bookmarks list
                const Text(
                  "SAVED AYAH BOOKMARKS",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),

                _loading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
                    : _bookmarks.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            alignment: Alignment.center,
                            child: const Column(
                              children: [
                                Icon(Icons.bookmark_outline, color: Colors.white24, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  "No Bookmarks Saved Yet",
                                  style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Bookmarks will appear here when saved from the reader.",
                                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _bookmarks.length,
                            itemBuilder: (context, i) {
                              final b = _bookmarks[i];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131B2E).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row with Tag, Surah context, and actions
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Category Tag
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD700).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            (b['category'] ?? "General").toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        // Actions: Share & Delete
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.palette_rounded, color: Colors.white60, size: 18),
                                              onPressed: () => _shareBookmark(b),
                                              tooltip: "Share quote creator",
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE74C3C), size: 18),
                                              onPressed: () => _deleteBookmark(i),
                                              tooltip: "Remove Bookmark",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Arabic Text snippet
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        b['arabic'] ?? "",
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 22,
                                          fontFamily: 'QuranFont',
                                          height: 1.4,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // English translation
                                    Text(
                                      b['english'] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Surah label reference
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Surah ${b['surah']} • Ayah ${b['ayahNum']}",
                                          style: const TextStyle(
                                            color: Color(0xFF8E9CB2),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "QURAN ${b['surahNum']}:${b['ayahNum']}",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.15),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
