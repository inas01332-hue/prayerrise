import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    load();
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

  Future<void> load() async {
    final res = await http.get(
      Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani',
      ),
    );

    final data = jsonDecode(res.body);

    setState(() {
      ayahs = data['data'][0]['ayahs'];

      if (widget.surahNumber != 1 &&
          widget.surahNumber != 9 &&
          ayahs.isNotEmpty) {
        ayahs.removeAt(0);
      }

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8EE),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.surahName,
          textDirection: TextDirection.rtl,
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    widget.surahName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'QuranFont',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (widget.surahNumber != 9)
                    const Text(
                      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'QuranFont',
                        fontSize: 42,
                        color: Colors.black,
                      ),
                    ),

                  const SizedBox(height: 35),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      ayahs.map((a) {
                        return "${a['text']} ۝${toArabicNumber(a['numberInSurah'])}";
                      }).join(" "),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontFamily: 'QuranFont',
                        fontSize: 36,
                        height: 2.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}