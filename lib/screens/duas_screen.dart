import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DuaItem {
  final int id;
  final String category;
  final String icon;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String benefit;

  const DuaItem({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.benefit,
  });
}

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> with TickerProviderStateMixin {
  String _searchQuery = "";
  String _selectedCategory = "All";
  final Set<int> _favorites = {}; // Holds favorited Dua IDs
  
  // Audio playback simulator state
  int _activeAudioId = -1;
  bool _isPlaying = false;
  late AnimationController _waveController;

  final List<String> _categories = const [
    "All",
    "Daily",
    "Protection",
    "Worship",
    "Quranic",
    "Relief",
    "Travel",
    "Favorites"
  ];

  final List<DuaItem> _duasList = const [
    // --- DAILY ---
    DuaItem(
      id: 1,
      category: "Daily",
      icon: "🌅",
      title: "Morning Supplication",
      arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ",
      transliteration: "Asbahna wa-asbahal-mulku lillah, walhamdulillah",
      translation: "We have entered the morning and at this very time the kingdom belongs to Allah, and all praise is to Allah.",
      reference: "Muslim 4/2088",
      benefit: "Brings protection, spiritual focus, and barakah for all daily endeavors when recited upon waking.",
    ),
    DuaItem(
      id: 2,
      category: "Daily",
      icon: "😴",
      title: "Before Sleeping",
      arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
      transliteration: "Bismika Allahumma amootu wa-ahya",
      translation: "In Your name, O Allah, I die and I live.",
      reference: "Bukhari 11/113",
      benefit: "Entrusts your soul to Allah during sleep and shields against nightmare disturbances.",
    ),
    DuaItem(
      id: 3,
      category: "Daily",
      icon: "☀️",
      title: "Upon Waking Up",
      arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
      transliteration: "Alhamdu lillahil-ladhi ahyana ba'da ma amatana wa-ilayhin-nushoor",
      translation: "Praise is to Allah Who gave us life after He had caused us to die, and to Him is the final resurrection.",
      reference: "Bukhari 11/113",
      benefit: "Instills immediate gratitude to the Creator for granting another day to perform good deeds.",
    ),
    DuaItem(
      id: 4,
      category: "Daily",
      icon: "🚪",
      title: "Entering the Home",
      arabic: "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
      transliteration: "Bismillahi walajna, wa bismillahi kharajna, wa 'ala Allahi Rabbina tawakkalna",
      translation: "In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we place our trust.",
      reference: "Abu Dawud 4/325",
      benefit: "Expels negative spiritual presence (Shaytan) from entering your dwelling.",
    ),

    // --- PROTECTION ---
    DuaItem(
      id: 5,
      category: "Protection",
      icon: "🛡️",
      title: "Protection From All Harm",
      arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
      transliteration: "Bismillahil-ladhi la yadurru ma'as-mihi shay'un fil-ardi wa la fis-sama'i wa Huwas-Sami'ul-'Alim",
      translation: "In the name of Allah, with Whose name nothing is harmed on earth nor in the heaven, and He is the All-Hearing, the All-Knowing.",
      reference: "Abu Dawud 4/323",
      benefit: "Recited 3 times in morning and evening to gain total immunity from sudden calamities and harm.",
    ),
    DuaItem(
      id: 6,
      category: "Protection",
      icon: "⚡",
      title: "Relief from Sickness & Pain",
      arabic: "أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ",
      transliteration: "A'udhu billahi wa qudratihi min sharri ma ajidu wa uhadhir",
      translation: "I seek refuge in Allah and His power from the evil of what I find and dread.",
      reference: "Muslim 4/1728",
      benefit: "Place your right hand on the pain area, say Bismillah 3 times, then recite this supplication 7 times to ease bodily distress.",
    ),
    DuaItem(
      id: 7,
      category: "Protection",
      icon: "🐍",
      title: "Protection Against Evil Eye & Envy",
      arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ",
      transliteration: "A'udhu bi-kalimatil-lahit-tammati min kulli shaytanin wa hammatin, wa min kulli 'aynin lammah",
      translation: "I seek refuge in the perfect words of Allah from every devil and poisonous beast, and from every envious, blinking eye.",
      reference: "Bukhari 4/119",
      benefit: "The sunnah shield used to protect children, family, and yourself from negative energy and evil envy (Hasad).",
    ),

    // --- WORSHIP ---
    DuaItem(
      id: 8,
      category: "Worship",
      icon: "🕌",
      title: "Entering the Mosque",
      arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
      transliteration: "Allahumma-ftah lee abwaba rahmatik",
      translation: "O Allah, open for me the gates of Your mercy.",
      reference: "Muslim 1/495",
      benefit: "Supplicating for divine mercy as you enter the house of worship.",
    ),
    DuaItem(
      id: 9,
      category: "Worship",
      icon: "🚶",
      title: "Leaving the Mosque",
      arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
      transliteration: "Allahumma inni as'aluka min fadlik",
      translation: "O Allah, I ask You from Your favor.",
      reference: "Muslim 1/495",
      benefit: "Supplicating for halal provision and blessings as you step back into worldly affairs.",
    ),
    DuaItem(
      id: 10,
      category: "Worship",
      icon: "🤲",
      title: "Dua After Obligatory Salah",
      arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ",
      transliteration: "Allahumma a'inni 'ala dhikrika, wa shukrika, wa husni 'ibadatik",
      translation: "O Allah, help me remember You, express gratitude to You, and worship You in the best manner.",
      reference: "Abu Dawud 2/86",
      benefit: "Taught by Prophet Muhammad (PBUH) to Mu'adh as a vital key for spiritual consistency.",
    ),
    DuaItem(
      id: 11,
      category: "Worship",
      icon: "💦",
      title: "Upon Completing Wudu",
      arabic: "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
      transliteration: "Ashhadu an la ilaha illallahu wahdahu la sharika lahu wa ashhadu anna Muhammadan 'abduhu wa Rasuluh",
      translation: "I bear witness that none has the right to be worshipped but Allah alone, Who has no partner; and I bear witness that Muhammad is His slave and Messenger.",
      reference: "Muslim 1/209",
      benefit: "The gates of the eight Gardens of Paradise are opened for whoever recites this after performing perfect purification.",
    ),

    // --- QURANIC ---
    DuaItem(
      id: 12,
      category: "Quranic",
      icon: "📖",
      title: "Seeking Wisdom & Knowledge",
      arabic: "رَّبِّ زِدْنِي عِلْمًا",
      transliteration: "Rabbi zidnee 'ilma",
      translation: "My Lord, increase me in knowledge.",
      reference: "Qur'an 20:114",
      benefit: "Perfect Quranic supplication for students, teachers, and anyone seeking deeper Islamic wisdom.",
    ),
    DuaItem(
      id: 13,
      category: "Quranic",
      icon: "🌟",
      title: "Dua of Adam (AS) for Forgiveness",
      arabic: "رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ",
      transliteration: "Rabbana thalamna anfusana wa-in lam taghfir lana watarhamna lanakoonanna minal-khasireen",
      translation: "Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.",
      reference: "Qur'an 7:23",
      benefit: "The highly emotional first supplication of humanity, representing absolute repentance (Tawbah).",
    ),
    DuaItem(
      id: 14,
      category: "Quranic",
      icon: "🏡",
      title: "Comprehensive Good in Both Worlds",
      arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      transliteration: "Rabbana atina fid-dunya hasanatan wa-fil-akhirati hasanatan waqina 'adhaban-nar",
      translation: "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.",
      reference: "Qur'an 2:201",
      benefit: "The most frequent supplication made by Prophet Muhammad (PBUH) due to its comprehensive balance.",
    ),

    // --- RELIEF & ANXIETY ---
    DuaItem(
      id: 15,
      category: "Relief",
      icon: "⛈️",
      title: "Overcoming Grief, Debt & Anxiety",
      arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ",
      transliteration: "Allahumma inni a'udhu bika minal-hammi wal-hazan, wal-'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala'id-dayni wa ghalabatir-rijal",
      translation: "O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts and from being overpowered by men.",
      reference: "Bukhari 7/158",
      benefit: "A vital daily shield against clinical stress, laziness, economic dependency, and oppression.",
    ),
    DuaItem(
      id: 16,
      category: "Relief",
      icon: "🐋",
      title: "Dua of Yunus (AS) in Distress",
      arabic: "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
      transliteration: "La ilaha illa anta subhanaka inni kuntu minad-dhalimeen",
      translation: "There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.",
      reference: "Qur'an 21:87",
      benefit: "Recited by Prophet Yunus inside the belly of the whale. The Prophet (PBUH) stated no Muslim ever supplicates with this except that Allah answers him.",
    ),
    DuaItem(
      id: 17,
      category: "Relief",
      icon: "💎",
      title: "Dua for Decision Making (Istikhara)",
      arabic: "اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ",
      transliteration: "Allahumma inni astakhiruka bi'ilmika wa astaqdiruka bi-qudratika wa as'aluka min fadlikal-'adheem",
      translation: "O Allah, I consult You through Your knowledge, and seek strength from Your power, and ask You for Your great favor.",
      reference: "Bukhari 2/47",
      benefit: "Recite when confused or seeking divine alignment regarding marriages, careers, or major choices.",
    ),

    // --- TRAVEL & SOCIAL ---
    DuaItem(
      id: 18,
      category: "Travel",
      icon: "🚗",
      title: "Supplication for Journey & Travel",
      arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ",
      transliteration: "Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrineen, wa inna ila Rabbina lamunqaliboon",
      translation: "Glory to Him who has subjected this to us, and we could never have otherwise subdued it. And indeed, to our Lord we will surely return.",
      reference: "Muslim 2/998",
      benefit: "Grants divine protection over transport, vehicle safety, and brings peace throughout the journey.",
    ),
    DuaItem(
      id: 19,
      category: "Travel",
      icon: "👨‍👩‍👧",
      title: "Dua for Parents (Mercy & Gratitude)",
      arabic: "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
      transliteration: "Rabbi irhamhuma kama rabbayanee sagheera",
      translation: "My Lord, have mercy upon them as they brought me up when I was small.",
      reference: "Qur'an 17:24",
      benefit: "Quranic command to invoke divine compassion, long life, and spiritual honor for your mother and father.",
    ),
    DuaItem(
      id: 20,
      category: "Travel",
      icon: "🤝",
      title: "Expiaiton of Councils & Gatherings",
      arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ",
      transliteration: "Subhanaka Allahumma wa bihamdika, ashhadu an la ilaha illa Anta, astaghfiruka wa atoobu ilayk",
      translation: "Glory is to You, O Allah, and praise. I bear witness that there is no deity except You. I seek Your forgiveness and repent to You.",
      reference: "Abu Dawud 4/262",
      benefit: "Erase all minor sins, idle gossip, or errors committed during any meeting or gathering by reciting this before leaving.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  void _copyToClipboard(DuaItem item) {
    final textToCopy = "${item.title}\n\n${item.arabic}\n\n${item.transliteration}\n\n\"${item.translation}\"\n\nSource: ${item.reference}\nShared via PrayerRise Supplications Hub";
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71)),
            SizedBox(width: 10),
            Text("Supplication copied to clipboard!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF131B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _shareDua(DuaItem item) {
    // Simulated share success trigger
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.share_rounded, color: Color(0xFFFFD700)),
            SizedBox(width: 10),
            Text("Social share template ready!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF1E5B43),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _toggleAudio(int id) {
    setState(() {
      if (_activeAudioId == id && _isPlaying) {
        _isPlaying = false;
        _waveController.stop();
      } else {
        _activeAudioId = id;
        _isPlaying = true;
        _waveController.repeat(reverse: true);
      }
    });
  }

  void _showDuaDetails(DuaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isFav = _favorites.contains(item.id);
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isCurrentlyPlayingThis = _activeAudioId == item.id && _isPlaying;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              height: MediaQuery.of(context).size.height * 0.76,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1524),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
              ),
              child: Column(
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
                  
                  // Header Row with Actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                        child: Text(item.icon, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category.toUpperCase(), 
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                            Text(
                              item.title, 
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Favorite Toggle Button inside modal
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isFav ? const Color(0xFFFFD700) : Colors.white60,
                        ),
                        onPressed: () {
                          _toggleFavorite(item.id);
                          setModalState(() {});
                          setState(() {}); // sync main screen state
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  
                  // Audio player interactive visualizer bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.02)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _toggleAudio(item.id);
                            setModalState(() {});
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                            ),
                            child: Icon(
                              isCurrentlyPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(20, (idx) {
                                    final factor = isCurrentlyPlayingThis
                                        ? 0.3 + 0.7 * (1.0 + (idx % 2 == 0 ? _waveController.value : -_waveController.value)).abs() / 2.0
                                        : 0.15;
                                    return Container(
                                      width: 3.0,
                                      height: (12.0 + (idx % 3 * 8.0)) * factor,
                                      decoration: BoxDecoration(
                                        color: isCurrentlyPlayingThis ? const Color(0xFFFFD700) : Colors.white24,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable text content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          // Arabic
                          Text(
                            item.arabic,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 26,
                              fontFamily: 'QuranFont',
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Transliteration
                          const Text(
                            "TRANSLITERATION",
                            style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.transliteration,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFC3B1E1),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Translation
                          const Text(
                            "TRANSLATION",
                            style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\"${item.translation}\"",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Benefit Box
                          const Text(
                            "SPIRITUAL BENEFIT",
                            style: TextStyle(color: Color(0xFFFFD700), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E5B43).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E5B43).withOpacity(0.3)),
                            ),
                            child: Text(
                              item.benefit,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Source
                          Text(
                            "Source: ${item.reference}",
                            style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Copy & Share & Close row buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _copyToClipboard(item),
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text("Copy", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _shareDua(item),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text("Share", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter the vast list based on category and search query
    final filteredList = _duasList.where((item) {
      // Category filter
      if (_selectedCategory == "Favorites") {
        if (!_favorites.contains(item.id)) return false;
      } else if (_selectedCategory != "All" && item.category != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(query) ||
            item.transliteration.toLowerCase().contains(query) ||
            item.arabic.contains(query) ||
            item.translation.toLowerCase().contains(query) ||
            item.reference.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxury Midnight
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Vast Supplications Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Premium Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search supplication (e.g. Protection, Istikhara)...",
                hintStyle: const TextStyle(color: Color(0xFF5D6B82)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
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

          // Horizontal Categories Filter selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSel = _selectedCategory == cat;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      cat == "Favorites" ? "Saved 🌟" : cat,
                      style: TextStyle(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF131B2E).withOpacity(0.4),
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 10),

          // Dynamic Header Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                Text(
                  "${filteredList.length} Duas Found",
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Supplications Grid/List Selection
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.library_books_rounded, color: Colors.white24, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _selectedCategory == "Favorites" 
                              ? "No favorited supplications yet." 
                              : "No matching supplications found.", 
                          style: const TextStyle(color: Colors.white30),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isFav = _favorites.contains(item.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Text(item.icon, style: const TextStyle(fontSize: 22)),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Text(
                                  item.reference,
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.category,
                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  color: isFav ? const Color(0xFFFFD700) : Colors.white24,
                                  size: 20,
                                ),
                                onPressed: () => _toggleFavorite(item.id),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                            ],
                          ),
                          onTap: () => _showDuaDetails(item),
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