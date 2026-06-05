import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SurahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahReaderScreen> createState() =>
      _SurahReaderScreenState();
}

class _SurahReaderScreenState
    extends State<SurahReaderScreen> {
  List arabicAyahs = [];
  List englishAyahs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSurah();
  }

  Future<void> loadSurah() async {
    final arabicResponse = await http.get(
      Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surahNumber}',
      ),
    );

    final englishResponse = await http.get(
      Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/en.asad',
      ),
    );

    if (arabicResponse.statusCode == 200 &&
        englishResponse.statusCode == 200) {
      setState(() {
        arabicAyahs =
            jsonDecode(arabicResponse.body)['data']['ayahs'];

        englishAyahs =
            jsonDecode(englishResponse.body)['data']['ayahs'];

        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: Text(widget.surahName),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: arabicAyahs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162033),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          englishAyahs[index]['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          arabicAyahs[index]['text'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}