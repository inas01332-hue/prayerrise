import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/quran_audio_service.dart';

class QuranAudioScreen extends StatefulWidget {
  const QuranAudioScreen({super.key});

  @override
  State<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends State<QuranAudioScreen> with SingleTickerProviderStateMixin {
  final QuranAudioService _audioService = QuranAudioService();
  late AnimationController _waveController;

  // Active playing metadata
  String _activeSurah = "Al-Mulk";
  int _activeSurahNum = 67;
  int _activeSurahVerses = 30;
  String _activeReciter = "Mishary Rashid Alafasy";
  String _activeReciterAvatar = "🎙️";
  String _activeReciterPrefix = "https://server8.mp3quran.net/afs/";

  // Audio track lists
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _isLoadingTracks = true;
  String _searchQuery = "";

  StreamSubscription? _completeSub;

  final List<double> _baseWaveHeights = [12, 28, 44, 18, 36, 52, 22, 48, 64, 30, 16, 42, 58, 20, 38, 50, 14, 26, 46, 32];

  final List<Map<String, dynamic>> _reciters = const [
    {"name": "Mishary Rashid Alafasy", "title": "Emotional & Clear", "avatar": "🎙️", "urlPrefix": "https://server8.mp3quran.net/afs/"},
    {"name": "Abdul Rahman Al-Sudais", "title": "Grand Mosque Reciter", "avatar": "🕌", "urlPrefix": "https://server11.mp3quran.net/shs/"},
    {"name": "Maher Al-Muaiqly", "title": "Calming & Deep", "avatar": "⭐", "urlPrefix": "https://server12.mp3quran.net/maher/"},
    {"name": "Saad Al-Ghamdi", "title": "Melodic Rhythms", "avatar": "🌊", "urlPrefix": "https://server7.mp3quran.net/s_gmd/"},
  ];

  final List<Map<String, dynamic>> _offlineSurahs = const [
    {"englishName": "Al-Fatiha", "number": 1, "numberOfAyahs": 7, "name": "الفاتحة"},
    {"englishName": "Al-Baqarah", "number": 2, "numberOfAyahs": 286, "name": "البقرة"},
    {"englishName": "Al-Kahf", "number": 18, "numberOfAyahs": 110, "name": "الكهف"},
    {"englishName": "Ya-Sin", "number": 36, "numberOfAyahs": 83, "name": "يس"},
    {"englishName": "Ar-Rahman", "number": 55, "numberOfAyahs": 78, "name": "الرحمن"},
    {"englishName": "Al-Waqi'ah", "number": 56, "numberOfAyahs": 96, "name": "الواقعة"},
    {"englishName": "Al-Mulk", "number": 67, "numberOfAyahs": 30, "name": "الملك"},
    {"englishName": "An-Naba", "number": 78, "numberOfAyahs": 40, "name": "النبأ"},
    {"englishName": "Al-Ikhlas", "number": 112, "numberOfAyahs": 4, "name": "الإخلاص"},
    {"englishName": "Al-Falaq", "number": 113, "numberOfAyahs": 5, "name": "الفلق"},
    {"englishName": "An-Nas", "number": 114, "numberOfAyahs": 6, "name": "الناس"},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _audioService.addListener(_onAudioStateChanged);

    _completeSub = _audioService.onComplete.listen((_) {
      _playNext();
    });

    _fetchSurahs();
  }

  @override
  void dispose() {
    _audioService.stop();
    _audioService.removeListener(_onAudioStateChanged);
    _completeSub?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (!mounted) return;
    setState(() {
      if (_audioService.isPlaying) {
        if (!_waveController.isAnimating) {
          _waveController.repeat(reverse: true);
        }
      } else {
        _waveController.stop();
      }
    });
  }

  Future<void> _fetchSurahs() async {
    try {
      final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _allSurahs = data['data'];
            _filteredSurahs = _allSurahs;
            _isLoadingTracks = false;
          });
        }
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allSurahs = _offlineSurahs;
          _filteredSurahs = _allSurahs;
          _isLoadingTracks = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Using offline/popular tracks mode.")),
        );
      }
    }
  }

  void _searchSurahs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSurahs = _allSurahs.where((surah) {
        final name = surah['englishName'].toString().toLowerCase();
        final arabicName = surah['name'].toString();
        final num = surah['number'].toString();
        return name.contains(query.toLowerCase()) ||
            arabicName.contains(query) ||
            num.contains(query);
      }).toList();
    });
  }

  void _playCurrentSurah() {
    final String surahStr = _activeSurahNum.toString().padLeft(3, '0');
    final String audioUrl = "$_activeReciterPrefix$surahStr.mp3";
    _audioService.play(audioUrl);
  }

  void _togglePlayback() {
    if (_audioService.isPlaying) {
      _audioService.pause();
    } else {
      if (_audioService.currentUrl != null && _audioService.currentUrl == _getExpectedUrl()) {
        _audioService.resume();
      } else {
        _playCurrentSurah();
      }
    }
  }

  String _getExpectedUrl() {
    final String surahStr = _activeSurahNum.toString().padLeft(3, '0');
    return "$_activeReciterPrefix$surahStr.mp3";
  }

  void _selectSurah(Map<String, dynamic> surah) {
    setState(() {
      _activeSurah = surah['englishName'];
      _activeSurahNum = surah['number'];
      _activeSurahVerses = surah['numberOfAyahs'] ?? surah['numberOfAyahs'];
    });
    _playCurrentSurah();
  }

  void _playNext() {
    if (_filteredSurahs.isEmpty) return;
    int currentIndex = _filteredSurahs.indexWhere((s) => s['number'] == _activeSurahNum);
    if (currentIndex != -1 && currentIndex < _filteredSurahs.length - 1) {
      _selectSurah(_filteredSurahs[currentIndex + 1]);
    } else {
      _selectSurah(_filteredSurahs.first);
    }
  }

  void _playPrevious() {
    if (_filteredSurahs.isEmpty) return;
    int currentIndex = _filteredSurahs.indexWhere((s) => s['number'] == _activeSurahNum);
    if (currentIndex > 0) {
      _selectSurah(_filteredSurahs[currentIndex - 1]);
    } else {
      _selectSurah(_filteredSurahs.last);
    }
  }

  void _showReciterSheet() {
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
                "Choose Reciter Edition",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select a voice that connects deepest with your soul.",
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _reciters.length,
                  itemBuilder: (context, idx) {
                    final rec = _reciters[idx];
                    final isSel = _activeReciter == rec['name'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E5B43).withOpacity(0.15) : const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSel ? const Color(0xFF2ECC71).withOpacity(0.3) : Colors.transparent),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          child: Text(rec['avatar'], style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          rec['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          rec['title'],
                          style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle, color: Color(0xFF2ECC71))
                            : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                        onTap: () {
                          setState(() {
                            _activeReciter = rec['name'];
                            _activeReciterAvatar = rec['avatar'];
                            _activeReciterPrefix = rec['urlPrefix'];
                          });
                          Navigator.pop(context);
                          if (_audioService.currentUrl != null) {
                            _playCurrentSurah(); // Switch audio stream instantly
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCurrentTrackExpected = _audioService.currentUrl == _getExpectedUrl();

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxury Midnight
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Audio Suite", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -screenSize.height * 0.15,
            left: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E5B43).withOpacity(0.05),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // 1. Glowing Player Deck Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Active Title & Reciter Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _showReciterSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Text("$_activeReciterAvatar  ", style: const TextStyle(fontSize: 14)),
                                Text(
                                  _activeReciter.split(' ').last,
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFFD700), size: 14),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _audioService.isPlaying && isCurrentTrackExpected ? "PLAYING LIVE" : "LIVE STREAM",
                            style: TextStyle(
                              color: _audioService.isPlaying && isCurrentTrackExpected
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFFFD700),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Animated Waveform Sound Visualizer
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return SizedBox(
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(_baseWaveHeights.length, (idx) {
                              final isPlayingNow = _audioService.isPlaying && isCurrentTrackExpected;
                              final factor = isPlayingNow
                                  ? 0.3 + 0.7 * (1.0 + (idx % 2 == 0 ? _waveController.value : -_waveController.value)).abs() / 2.0
                                  : 0.15;
                              final currentHeight = _baseWaveHeights[idx] * factor;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                width: 4,
                                height: currentHeight,
                                decoration: BoxDecoration(
                                  color: isPlayingNow
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFFFFD700).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // Surah metadata details
                    Text(
                      _activeSurah,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Reciter: $_activeReciter • $_activeSurahVerses Verses",
                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                    ),

                    const SizedBox(height: 25),

                    // Seek progress bar slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFFFFD700),
                        inactiveTrackColor: Colors.white.withOpacity(0.05),
                        thumbColor: const Color(0xFFFFD700),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayColor: const Color(0xFFFFD700).withOpacity(0.12),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: isCurrentTrackExpected && _audioService.duration.inSeconds > 0
                            ? _audioService.position.inSeconds.toDouble() / _audioService.duration.inSeconds.toDouble()
                            : 0.0,
                        onChanged: (val) {
                          if (isCurrentTrackExpected) {
                            final targetSeconds = (val * _audioService.duration.inSeconds).toInt();
                            _audioService.seek(Duration(seconds: targetSeconds));
                          }
                        },
                      ),
                    ),

                    // Timer displays
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCurrentTrackExpected ? _formatDuration(_audioService.position) : "00:00",
                            style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isCurrentTrackExpected ? _formatDuration(_audioService.duration) : "--:--",
                            style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Media controls console deck
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Playback Speed control
                        GestureDetector(
                          onTap: () {
                            double newSpeed = 1.0;
                            if (_audioService.playbackSpeed == 1.0) {
                              newSpeed = 1.25;
                            } else if (_audioService.playbackSpeed == 1.25) {
                              newSpeed = 1.5;
                            } else if (_audioService.playbackSpeed == 1.5) {
                              newSpeed = 2.0;
                            } else {
                              newSpeed = 1.0;
                            }
                            _audioService.setSpeed(newSpeed);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.03),
                            ),
                            child: Center(
                              child: Text(
                                "${_audioService.playbackSpeed}x",
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                        // Skip back
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                          onPressed: _playPrevious,
                        ),

                        // Play / Pause Circle trigger
                        GestureDetector(
                          onTap: _togglePlayback,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                            ),
                            child: Icon(
                              _audioService.isPlaying && isCurrentTrackExpected
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        ),

                        // Skip next
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                          onPressed: _playNext,
                        ),

                        // Loop switcher toggle
                        IconButton(
                          icon: Icon(
                            _audioService.isLooping ? Icons.loop_rounded : Icons.repeat_one_rounded,
                            color: _audioService.isLooping ? const Color(0xFF2ECC71) : Colors.white60,
                            size: 22,
                          ),
                          onPressed: () {
                            _audioService.setLoop(!_audioService.isLooping);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. Custom Search bar for tracklist
              TextField(
                onChanged: _searchSurahs,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Surah in tracklist...",
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

              const SizedBox(height: 20),

              // 3. Playlists / Track selections lists
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SURAH TRACKLISTS",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  Text(
                    "${_filteredSurahs.length} Chapters",
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _isLoadingTracks
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
                      ),
                    )
                  : _filteredSurahs.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          alignment: Alignment.center,
                          child: const Text("No matching Surahs found.", style: TextStyle(color: Colors.white30)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredSurahs.length,
                          itemBuilder: (context, idx) {
                            final surah = _filteredSurahs[idx];
                            final isCurrent = _activeSurahNum == surah['number'];
                            final isCurrentlyPlayingThis = isCurrent && _audioService.isPlaying;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrent ? const Color(0xFF1E5B43).withOpacity(0.12) : const Color(0xFF131B2E).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isCurrent ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.white.withOpacity(0.01),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCurrent ? const Color(0xFF2ECC71).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                                  ),
                                  child: Center(
                                    child: isCurrentlyPlayingThis
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71))),
                                          )
                                        : Text(
                                            "${surah['number']}",
                                            style: TextStyle(
                                              color: isCurrent ? const Color(0xFF2ECC71) : Colors.white60,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  surah['englishName'] ?? "",
                                  style: TextStyle(
                                    color: isCurrent ? const Color(0xFF2ECC71) : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  isCurrent ? "Now Reciting • $_activeReciter" : "Edition English Translation Sync Available",
                                  style: TextStyle(
                                    color: isCurrent ? const Color(0xFF2ECC71).withOpacity(0.8) : const Color(0xFF8E9CB2),
                                    fontSize: 11,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${surah['numberOfAyahs']} Verses",
                                      style: const TextStyle(color: Colors.white30, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isCurrentlyPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      color: isCurrent ? const Color(0xFF2ECC71) : const Color(0xFFFFD700),
                                      size: 28,
                                    ),
                                  ],
                                ),
                                onTap: () => _selectSurah(surah),
                              ),
                            );
                          },
                        ),

              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
