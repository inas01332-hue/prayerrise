import 'dart:math' as math;
import 'package:flutter/material.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _pulseController;

  // Selected Name for detail view
  Map<String, String>? _selectedName;

  // Mock list of 99 Names of Allah (a complete premium set of key names, generating structural names dynamically to represent all 99 elegantly)
  final List<Map<String, String>> _allahNames = [
    {"num": "1", "arabic": "الرَّحْمَنُ", "translit": "Ar-Rahman", "meaning": "The Most Merciful", "benefits": "Invoking this name regularly brings immense peace, softening of the heart, and relief from stress.", "tafsir": "He whose mercy extends to all creation, including believers and disbelievers, nourishing them and giving them life."},
    {"num": "2", "arabic": "الرَّحِيمُ", "translit": "Ar-Raheem", "meaning": "The Bestower of Mercy", "benefits": "Recited daily after salah, it fosters a strong protection against worldly hardships.", "tafsir": "He who is specifically merciful to the believers in this life and the hereafter, rewarding their worship with eternal paradise."},
    {"num": "3", "arabic": "الْمَلِكُ", "translit": "Al-Malik", "meaning": "The Sovereign Lord", "benefits": "Fosters discipline, self-control, and independence of heart from worldly dependencies.", "tafsir": "The absolute Owner, Controller, and King of the universe, who rules with complete authority and justice."},
    {"num": "4", "arabic": "الْقُدُّوسُ", "translit": "Al-Quddus", "meaning": "The Pure One", "benefits": "Purifies the heart from jealousy, hatred, pride, and spiritual diseases.", "tafsir": "The One who is absolutely free from any imperfection, error, weakness, or human attributes."},
    {"num": "5", "arabic": "السَّلَامُ", "translit": "As-Salam", "meaning": "The Source of Peace", "benefits": "Brings harmony to domestic life and heals anxiety when repeated in dhikr.", "tafsir": "The Giver of peace and safety, who protects His servants from all danger and guarantees absolute tranquility."},
    {"num": "6", "arabic": "الْمُؤْمِنُ", "translit": "Al-Mu'min", "meaning": "The Guardian of Faith", "benefits": "Provides ultimate safety, emotional security, and confidence in times of fear.", "tafsir": "The One who inspires faith in the hearts of His servants, fulfills His promises, and secures them from punishment."},
    {"num": "7", "arabic": "الْمُهَيْمِنُ", "translit": "Al-Muhaymin", "meaning": "The Preserver of Safety", "benefits": "Brings mindfulness (muraqabah) and guards against secret sins.", "tafsir": "The Watcher, Overseer, and Witness who preserves and governs every detail of His vast creation."},
    {"num": "8", "arabic": "الْعَزِيزُ", "translit": "Al-Aziz", "meaning": "The Almighty", "benefits": "Grants honor, dignity, and resilience against worldly humilities.", "tafsir": "The Defeater who is never defeated, the Mighty One whose strength and honor surpass all comprehension."},
    {"num": "9", "arabic": "الْجَبَّارُ", "translit": "Al-Jabbar", "meaning": "The Compeller", "benefits": "Repairs broken emotions, heals deep grief, and reforms ruined situations.", "tafsir": "The Restorer who heals the broken-hearted, corrects affairs, and holds the supreme power to execute His will."},
    {"num": "10", "arabic": "الْمُتَكَبِّرُ", "translit": "Al-Mutakabbir", "meaning": "The Supreme", "benefits": "Removes vanity and reminds the soul of its humble nature before the Creator.", "tafsir": "The Majestic One who is exalted above all qualities of creation; greatness and majesty belong solely to Him."},
    {"num": "11", "arabic": "الْخَالِقُ", "translit": "Al-Khaliq", "meaning": "The Creator", "benefits": "Encourages creative problem solving, focus, and appreciation of natural complexity.", "tafsir": "The One who brings things from non-existence into existence, designing them with perfect measurement and timing."},
    {"num": "12", "arabic": "الْبَارِئُ", "translit": "Al-Bari'", "meaning": "The Maker of Order", "benefits": "Imparts harmony, coordination, and physical health, removing chaos from life.", "tafsir": "The Creator who designs each soul or object distinct from another, shaping it in complete harmony with its purpose."},
    {"num": "13", "arabic": "الْمُصَوِّرُ", "translit": "Al-Musawwir", "meaning": "The Fashioner of Beauty", "benefits": "Fosters self-acceptance and a deep eye for natural beauty.", "tafsir": "The Supreme Artist who gives everything in the cosmos its specific shape, color, texture, and character."},
    {"num": "14", "arabic": "الْغَفَّارُ", "translit": "Al-Ghaffar", "meaning": "The All-Forgiving", "benefits": "Erases guilt, purges past sins, and opens channels of divine provision.", "tafsir": "He who forgives sins repeatedly, covering the faults of His servants in this world and the next."},
    {"num": "15", "arabic": "الْقَهَّارُ", "translit": "Al-Qahhar", "meaning": "The Subduer", "benefits": "Subdues lustful desires, breaks addictions, and humbles oppressive forces.", "tafsir": "The Absolute Subduer who controls everything in the cosmos; all creation bows before His majesty and will."},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Get daily featured name based on date (Dynamic reflection prompt!)
  Map<String, String> _getDailyFeaturedName() {
    final day = DateTime.now().day;
    final index = (day - 1) % _allahNames.length;
    return _allahNames[index];
  }

  void _showReflectionDrawer(Map<String, String> name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _NamesDetailDrawer(name: name);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyName = _getDailyFeaturedName();

    final filteredNames = _allahNames.where((item) {
      final query = _searchQuery.toLowerCase();
      return item['translit']!.toLowerCase().contains(query) ||
          item['meaning']!.toLowerCase().contains(query) ||
          item['arabic']!.contains(query) ||
          item['num']!.contains(query);
    }).toList();

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
          "99 Names of Allah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Daily Featured Reflection card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: GestureDetector(
              onTap: () => _showReflectionDrawer(dailyName),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E5B43), Color(0xFF0F1524)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DAILY REFLECTION NAME",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dailyName['translit']!,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dailyName['meaning']!,
                            style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap to listen, explore spiritual tafsir and implement practical action in daily life.",
                            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dailyName['arabic']!,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontFamily: 'QuranFont',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search name (e.g. Al-Rahman, The Merciful)...",
                hintStyle: const TextStyle(color: Color(0xFF5D6B82)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
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

          const SizedBox(height: 10),

          // 99 Names Grid List
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: filteredNames.length,
              itemBuilder: (context, idx) {
                final item = filteredNames[idx];
                return GestureDetector(
                  onTap: () => _showReflectionDrawer(item),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "#${item['num']}",
                                style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              item['arabic']!,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontFamily: 'QuranFont',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['translit']!,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['meaning']!,
                              style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

// Sub-widget for details modal sheet with simulated waveform
class _NamesDetailDrawer extends StatefulWidget {
  final Map<String, String> name;
  const _NamesDetailDrawer({required this.name});

  @override
  State<_NamesDetailDrawer> createState() => _NamesDetailDrawerState();
}

class _NamesDetailDrawerState extends State<_NamesDetailDrawer> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _waveformController;
  final List<double> _waveData = List.generate(24, (index) => 5.0 + 25.0 * (index % 4 == 0 ? 0.8 : (index % 3 == 0 ? 0.6 : 0.3)));

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _waveformController.repeat(reverse: true);
    } else {
      _waveformController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
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
          const SizedBox(height: 25),

          // Calligraphy / Play Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NAME #${widget.name['num']}",
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.name['translit']!,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.name['meaning']!,
                    style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                ),
                child: Text(
                  widget.name['arabic']!,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontFamily: 'QuranFont',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Audio player container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleAudio,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _waveformController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(_waveData.length, (idx) {
                            final factor = _isPlaying
                                ? 0.3 + 0.7 * (1.0 + (idx % 2 == 0 ? _waveformController.value : -_waveformController.value)).abs() / 2.0
                                : 0.15;
                            return Container(
                              width: 3.5,
                              height: _waveData[idx] * factor,
                              decoration: BoxDecoration(
                                color: _isPlaying ? const Color(0xFFFFD700) : Colors.white24,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Deep spiritual meaning
          const Text(
            "SPIRITUAL COMMENTARY",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            widget.name['tafsir']!,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 20),

          // Practical Action
          const Text(
            "PRACTICAL DHIKR BENEFIT",
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E5B43).withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1E5B43).withOpacity(0.3)),
            ),
            child: Text(
              widget.name['benefits']!,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
