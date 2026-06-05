import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../surah_mode_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

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
    final res = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/surah'),
    );

    final data = jsonDecode(res.body);

    setState(() {
      surahs = data['data'];
      filteredSurahs = surahs;
      loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: const Text("📖 Mushaf"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    onChanged: searchSurah,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search Surah...",
                      hintStyle:
                          const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF162033),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, i) {
                      final s = filteredSurahs[i];

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            toArabicNumber(s['number']),
                          ),
                        ),

                        title: Text(
                          s['name'],
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'QuranFont',
                          ),
                        ),

                        subtitle: Text(
                          s['englishName'],
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        trailing: Text(
                          "${toArabicNumber(s['numberOfAyahs'])} آية",
                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),

                        onTap: () {
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}