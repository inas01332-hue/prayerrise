import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../surah_mode_screen.dart';
import '../surah_reader_screen.dart';

class QuranScreen extends StatefulWidget {
  final String mode; // "mushaf" or "translation"
  const QuranScreen({super.key, required this.mode});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List surahs = [];
  List filteredSurahs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahs();
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

  Future<void> fetchSurahs() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            surahs = data['data'];
            filteredSurahs = surahs;
            loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load Quran data. Please check internet.")),
        );
      }
    }
  }

  void searchSurah(String value) {
    setState(() {
      filteredSurahs = surahs.where((surah) {
        return surah['englishName']
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            surah['name']
                .toString()
                .contains(value);
      }).toList();
    });
  }

  void _showReadingModeSelector(Map s) {
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
              Text(
                s['englishName'],
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                s['name'],
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 26, fontFamily: 'QuranFont', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your reading style",
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Option 1: Mushaf Arabic Mode
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                tileColor: const Color(0xFF131B2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.chrome_reader_mode_rounded, color: Color(0xFFFFD700)),
                title: const Text("Uthmani Mushaf Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Traditional Arabic paragraph text reading.", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahModeScreen(
                        surahNumber: s['number'],
                        surahName: s['name'],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Option 2: Side-by-Side English Translation Mode
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                tileColor: const Color(0xFF131B2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.translate_rounded, color: Color(0xFFFFD700)),
                title: const Text("Translation Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Arabic & English verses side-by-side.", style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahReaderScreen(
                        surahNumber: s['number'],
                        surahName: s['name'],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Midnight Navy

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("The Mushaf", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
            )
          : Column(
              children: [
                // Custom Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: searchSurah,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search Surah (e.g. Al-Fatiha, البقرة)...",
                      hintStyle: const TextStyle(color: Color(0xFF5D6B82)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                      filled: true,
                      fillColor: const Color(0xFF131B2E).withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, i) {
                      final s = filteredSurahs[i];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.02)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                toArabicNumber(s['number']),
                                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),

                          title: Text(
                            s['name'],
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'QuranFont',
                            ),
                          ),

                          subtitle: Text(
                            s['englishName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${toArabicNumber(s['numberOfAyahs'])} آية",
                                style: const TextStyle(
                                  color: Color(0xFF8E9CB2),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s['revelationType'].toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          onTap: () {
                            if (widget.mode == "mushaf") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SurahModeScreen(
                                    surahNumber: s['number'],
                                    surahName: s['name'],
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SurahReaderScreen(
                                    surahNumber: s['number'],
                                    surahName: s['name'],
                                  ),
                                ),
                              );
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
  }
}