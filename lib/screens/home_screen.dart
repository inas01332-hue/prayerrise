import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tasbih_screen.dart';
import 'prayer_times_screen.dart';
import 'quran_hub_screen.dart';
import 'duas_screen.dart';
import 'hijri_screen.dart';
import 'girly_mode_screen.dart';
import 'explore_screen.dart';
import 'sister_verification_screen.dart';
import 'achievements_screen.dart';
import 'reflection_share_screen.dart';
import 'alarm_screen.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../surah_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  static bool isSisterVerified = false;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Timer _countdownTimer;
  Duration _timeLeft = Duration.zero;
  
  // States for micro-interactive buttons
  final Map<String, bool> _buttonPressStates = {};

  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  String _nextPrayerName = "Fajr";
  String _nextPrayerTimeText = "04:18 AM";
  String _lastTriggeredAlarm = "";
  String _lastTriggeredSunnahKey = "";
  int _lastTriggeredSunnahDay = 0;

  AudioPlayer? _previewPlayer;
  bool _isPlayingPreview = false;

  int _lastReadSurahNum = 0;
  String _lastReadSurahName = "";
  int _lastReadAyahNum = 0;

  // Notification sync state values
  int _lastSyncDay = 0;
  dynamic _lastSyncCity;
  CalculationMethodOption? _lastSyncMethod;

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastReadSurahNum = prefs.getInt('last_read_surah_num') ?? 0;
        _lastReadSurahName = prefs.getString('last_read_surah_name') ?? "";
        _lastReadAyahNum = prefs.getInt('last_read_ayah_num') ?? 0;
      });
    }
  }

  void _toggleAdhanPreview() async {
    if (_isPlayingPreview) {
      await _previewPlayer?.stop();
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
        });
      }
    } else {
      _previewPlayer ??= AudioPlayer();
      setState(() {
        _isPlayingPreview = true;
      });
      try {
        final adhanUrl = _prayerTimeService.adhanUrls[_prayerTimeService.selectedAdhanStyle] ??
            "https://www.islamcan.com/audio/adhan/azan2.mp3";
        debugPrint("[Adhan Playback] Tapping preview. Streaming: $adhanUrl");
        await _previewPlayer!.play(UrlSource(adhanUrl));
        _previewPlayer!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlayingPreview = false;
            });
          }
        });
      } catch (e) {
        debugPrint("[Adhan Playback] Direct stream failed: $e. Using local fallback.");
        try {
          await _previewPlayer!.play(AssetSource('audio/adhan.mp3'));
          _previewPlayer!.onPlayerComplete.listen((_) {
            if (mounted) {
              setState(() {
                _isPlayingPreview = false;
              });
            }
          });
        } catch (assetError) {
          debugPrint("[Adhan Playback] Fallback asset play failed: $assetError");
          if (mounted) {
            setState(() {
              _isPlayingPreview = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Tone playback failed: $assetError. Check connection & asset status."),
                backgroundColor: const Color(0xFFC0392B),
              ),
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVerificationState();
    _prayerTimeService.addListener(_onPrayerCityChanged);
    _updateCountdown();
    _startCountdown();
    _loadLastRead();
    _initialSync();
  }

  Future<void> _loadVerificationState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        HomeScreen.isSisterVerified = prefs.getBool('is_sister_verified') ?? false;
      });
    }
  }

  Future<void> _initialSync() async {
    // Perform check-in daily
    await _prayerTimeService.checkInToday(HomeScreen.isSisterVerified);
    // Sync notifications for today
    final todayTimes = await _prayerTimeService.getPrayerTimes(_prayerTimeService.selectedCity, DateTime.now());
    await _syncNotificationsIfNeeded(
  _prayerTimeService.selectedCity,
  todayTimes,
);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _prayerTimeService.removeListener(_onPrayerCityChanged);
    _countdownTimer.cancel();
    _previewPlayer?.stop();
    _previewPlayer?.dispose();
    super.dispose();
  }

  void _onPrayerCityChanged() {
    if (mounted) {
      setState(() {
        _updateCountdown();
      });
    }
  }

  Future<void> _syncNotificationsIfNeeded(
    dynamic city,
    Map<String, DateTime> todayTimes,
) async {
  final now = DateTime.now();

  if (_lastSyncDay != now.day ||
      _lastSyncCity != city ||
      _lastSyncMethod != _prayerTimeService.selectedMethod) {
    _lastSyncDay = now.day;
    _lastSyncCity = city;
    _lastSyncMethod = _prayerTimeService.selectedMethod;

    await NotificationService().syncPrayerNotifications(
      city,
      todayTimes,
    );

    debugPrint(
      "[Notification Diagnostics] Synchronized prayer notifications for day ${now.day}",
    );
  }
}

  Future<void> _updateCountdown() async {
    final info = _prayerTimeService.getNextPrayerInfo(_prayerTimeService.selectedCity);
    _nextPrayerName = info["name"];
    _timeLeft = info["duration"];

    // Find the next prayer time to display it
    final todayTimes = await _prayerTimeService.getPrayerTimes(
      _prayerTimeService.selectedCity,
      DateTime.now(),
    );
    debugPrint("FAJR: ${todayTimes['Fajr']}");
debugPrint("SUNRISE: ${todayTimes['Sunrise']}");
debugPrint("DHUHR: ${todayTimes['Dhuhr']}");
debugPrint("ASR: ${todayTimes['Asr']}");
debugPrint("MAGHRIB: ${todayTimes['Maghrib']}");
debugPrint("ISHA: ${todayTimes['Isha']}");

    // Synchronize notifications when day or configuration parameters shift
    await _syncNotificationsIfNeeded(_prayerTimeService.selectedCity, todayTimes);

    DateTime nextTime = todayTimes[_nextPrayerName]!;
    if (nextTime.isBefore(DateTime.now()) && _nextPrayerName == "Fajr") {
      // Tomorrow's Fajr
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowTimes = await _prayerTimeService.getPrayerTimes(
        _prayerTimeService.selectedCity,
        tomorrow,
      );
      nextTime = tomorrowTimes["Fajr"]!;
    }

    // Format nextTime (e.g. 04:18 AM)
    final hour = nextTime.hour;
    final min = nextTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    _nextPrayerTimeText = "$displayHour:$min $period";
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        await _updateCountdown();
        await _checkPrayerAlarms();
        await _checkSunnahAlarms();
        setState(() {});
      }
    });
  }

  Future<void> _checkSunnahAlarms() async {
    final now = DateTime.now();
    final todayTimes = await _prayerTimeService.getPrayerTimes(_prayerTimeService.selectedCity, now);

    final currentHour = now.hour;
    final currentMin = now.minute;

    final prefs = await SharedPreferences.getInstance();

    final fajr = todayTimes['Fajr'];
    final sunrise = todayTimes['Sunrise'];
    final dhuhr = todayTimes['Dhuhr'];
    final isha = todayTimes['Isha'];

    for (var prayer in PrayerTimeService.sunnahPrayers) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_${prayer.key}') ?? 
          (prayer.key == 'tahajjud' || prayer.key == 'witr' || prayer.key == 'beforeFajr');
      if (!alarmEnabled) continue;

      bool isTime = false;
      String subKey = prayer.key;

      if (prayer.key == "beforeFajr" && fajr != null) {
        final time = fajr.subtract(const Duration(minutes: 20));
        isTime = (currentHour == time.hour && currentMin == time.minute);
      } else if (prayer.key == "duha" && sunrise != null) {
        final time = sunrise.add(const Duration(hours: 1, minutes: 30));
        isTime = (currentHour == time.hour && currentMin == time.minute);
      } else if (prayer.key == "beforeDhuhr" && dhuhr != null) {
        final time = dhuhr.subtract(const Duration(minutes: 20));
        isTime = (currentHour == time.hour && currentMin == time.minute);
      } else if (prayer.key == "tahajjud" && fajr != null) {
        final time = fajr.subtract(const Duration(hours: 1));
        isTime = (currentHour == time.hour && currentMin == time.minute);
      } else if (prayer.key == "witr" && isha != null) {
        final time = isha.add(const Duration(hours: 1));
        isTime = (currentHour == time.hour && currentMin == time.minute);
      }

      if (isTime) {
        final lastTriggerDay = prefs.getInt('last_triggered_sunnah_day_$subKey') ?? 0;
        if (lastTriggerDay != now.day) {
          await prefs.setInt('last_triggered_sunnah_day_$subKey', now.day);
          _triggerSunnahAlert(prayer);
        }
      }
    }
  }

  void _triggerSunnahAlert(SunnahPrayer prayer) async {
    try {
      final chimePlayer = AudioPlayer();
      await chimePlayer.play(UrlSource("https://www.islamcan.com/audio/adhan/azan2.mp3")); 
      Timer(const Duration(seconds: 4), () {
        chimePlayer.stop();
        chimePlayer.dispose();
      });
    } catch (e) {
      debugPrint("Error playing chime: $e");
    }

    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "SunnahAlert",
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(anim1);

        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: const Color(0xFF0F1524),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        prayer.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "BLESSED SUNNAH TIME",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prayer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.timeRange,
                    style: const TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prayer.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8E9CB2),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 14),
                            SizedBox(width: 6),
                            Text(
                              "SPIRITUAL REWARD",
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prayer.benefit,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF2ECC71).withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Alhamdulillah",
                            style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
                              );
                            },
                            child: const Text(
                              "View Schedule",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkPrayerAlarms() async {
    final now = DateTime.now();
    final todayTimes = await _prayerTimeService.getPrayerTimes(_prayerTimeService.selectedCity, now);

    for (var entry in todayTimes.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      final diffSeconds = now.difference(prayerTime).inSeconds;

      if (diffSeconds >= 0 && diffSeconds < 5) {
        final prefs = await SharedPreferences.getInstance();
        final lastTriggeredDate = prefs.getString('last_triggered_date_$prayerName');
        final todayStr = "${now.year}-${now.month}-${now.day}";

        if (lastTriggeredDate != todayStr) {
          await prefs.setString('last_triggered_date_$prayerName', todayStr);
          _triggerAlarmFor(prayerName, prayerTime);
        }
      }
    }
  }

  Future<void> _triggerAlarmFor(String prayerName, DateTime prayerTime) async {
    final prefs = await SharedPreferences.getInstance();
    final bool alarmEnabled = prefs.getBool('alarm_$prayerName') ?? (prayerName != "Dhuhr");

    if (alarmEnabled) {
      if (mounted) {
        final hour = prayerTime.hour;
        final min = prayerTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? "PM" : "AM";
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeText = "$displayHour:$min $period";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmScreen(
              prayerName: prayerName,
              timeText: timeText,
            ),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) {
      d = Duration.zero;
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _getDynamicHijriDateText() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = (a / 4).floor();
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();
    double jd = c + day + e + f - 1524.5;
    int jdRound = jd.round();
    
    int l = jdRound - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor()) + 
            (((l) / 5670).floor() * ((43 * l) / 15238).floor());
    l = l - (((30 - j).floor() * (17719 * j).floor() / 50).floor()) - 
        (((j).floor() * (15238 * j).floor() / 43).floor()) + 29;
    
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    if (hMonth < 1) hMonth = 1;
    if (hMonth > 12) hMonth = 12;

    final shortMonths = const [
      "Muharram", "Safar", "Rabi I", "Rabi II",
      "Jumada I", "Jumada II", "Rajab", "Sha'ban",
      "Ramadan", "Shawwal", "Dhul-Q", "Dhul-H"
    ];

    return "$hDay ${shortMonths[hMonth - 1]} • $hYear AH";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Sabah al-Khair"; // Good Morning
    } else if (hour < 17) {
      return "Assalamu Alaikum"; // Peace be upon you
    } else {
      return "Masa' al-Khair"; // Good Evening
    }
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Rise and shine with Fajr";
    } else if (hour < 17) {
      return "Keep your heart connected";
    } else {
      return "Reflect on your day";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Premium Midnight Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: const Text(
            "PRAYERRISE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFFFFD700)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Ambient Background Glows
          Positioned(
            top: -screenSize.height * 0.1,
            right: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.06),
                    const Color(0xFF060914).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.1,
            left: -screenSize.width * 0.3,
            child: Container(
              width: screenSize.width * 1.0,
              height: screenSize.width * 1.0,
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

          // 2. Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110), // Padding bottom for floating navbar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGreetingSubtitle(),
                          style: const TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Elegant Date Badge
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchievementsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "🔥 ${_prayerTimeService.currentStreak} Day Streak",
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _getDynamicHijriDateText(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Premium Glassmorphic Next Prayer Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF131B2E),
                        Color(0xFF0F1524),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mosque_outlined,
                                  color: Color(0xFFFFD700),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "NEXT PRAYER",
                                    style: TextStyle(
                                      color: Color(0xFF8E9CB2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    _nextPrayerName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _toggleAdhanPreview,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isPlayingPreview
                                    ? const Color(0xFFFFD700).withOpacity(0.15)
                                    : const Color(0xFF1E5B43).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isPlayingPreview
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF1E5B43).withOpacity(0.3),
                                  width: _isPlayingPreview ? 1.5 : 1.0,
                                ),
                                boxShadow: _isPlayingPreview
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isPlayingPreview ? Icons.stop_circle_outlined : Icons.volume_up,
                                    color: _isPlayingPreview ? const Color(0xFFFFD700) : const Color(0xFF2ECC71),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isPlayingPreview ? "Stop Adhan" : "Adhan On",
                                    style: TextStyle(
                                      color: _isPlayingPreview ? const Color(0xFFFFD700) : const Color(0xFF2ECC71),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Countdown timer in glowing capsule
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060914).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDuration(_timeLeft),
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "remaining until $_nextPrayerName ($_nextPrayerTimeText)",
                        style: const TextStyle(
                          color: Color(0xFF5D6B82),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _buildResumeReadingCard(),

                // Daily Reflection & Hadith Card (Premium Design)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "💡 DAILY REFLECTION",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReflectionShareScreen(
                                    arabicText: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
                                    englishText: "For indeed, with hardship comes ease.",
                                    source: "Qur'an 94:5",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.share_rounded, color: Color(0xFFFFD700), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    "Share Canvas",
                                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'QuranFont',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "\"For indeed, with hardship comes ease.\"",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "— Qur'an 94:5",
                        style: TextStyle(
                          color: Color(0xFF8E9CB2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2x2 Feature Grid with Micro-interactions
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        id: "quran",
                        icon: "📖",
                        title: "Quran",
                        subtitle: "Read & Listen",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuranHubScreen()),
                          ).then((_) => _loadLastRead());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureCard(
                        id: "tasbih",
                        icon: "📿",
                        title: "Tasbih",
                        subtitle: "Dhikr Counter",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TasbihScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        id: "duas",
                        icon: "🤲",
                        title: "Duas",
                        subtitle: "Daily Prayers",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DuasScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureCard(
                        id: "hijri",
                        icon: "📅",
                        title: "Hijri",
                        subtitle: "Islamic Dates",
                        cardColor: const Color(0xFF131B2E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HijriScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Sisters Corner Redesigned (Luxurious Rose Gold Aesthetic)
                _buildSistersCard(context),

                const SizedBox(height: 25),

                // Explore More Glowing Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExploreScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 20),
                          SizedBox(width: 10),
                          Text(
                            "EXPLORE ALL FEATURES",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Premium Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1524).withOpacity(0.85),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, "Home"),
                    _buildNavItem(1, Icons.schedule_rounded, "Prayer"),
                    _buildNavItem(2, Icons.radio_button_checked_rounded, "Tasbih"),
                    _buildNavItem(3, Icons.event_note_rounded, "Planner"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeReadingCard() {
    if (_lastReadSurahNum == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF131B2E),
            Color(0xFF0F1524),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "RESUME READING",
                  style: TextStyle(
                    color: Color(0xFF8E9CB2),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastReadSurahName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Ayah $_lastReadAyahNum",
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahReaderScreen(
                    surahNumber: _lastReadSurahNum,
                    surahName: _lastReadSurahName,
                  ),
                ),
              ).then((_) => _loadLastRead());
            },
            child: const Text(
              "Continue",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build micro-interactive Grid Cards
  Widget _buildFeatureCard({
    required String id,
    required String icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    final isPressed = _buttonPressStates[id] ?? false;

    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonPressStates[id] = true),
      onTapUp: (_) => setState(() => _buttonPressStates[id] = false),
      onTapCancel: () => setState(() => _buttonPressStates[id] = false),
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle Backing
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8E9CB2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sisters Corner Redesigned Card
  Widget _buildSistersCard(BuildContext context) {
    final isPressed = _buttonPressStates["sisters"] ?? false;

    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonPressStates["sisters"] = true),
      onTapUp: (_) => setState(() => _buttonPressStates["sisters"] = false),
      onTapCancel: () => setState(() => _buttonPressStates["sisters"] = false),
      onTap: () {
        if (HomeScreen.isSisterVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GirlyModeScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SisterVerificationScreen(
                onVerificationSuccess: () {
                  setState(() {
                    HomeScreen.isSisterVerified = true;
                  });
                },
              ),
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE754A6), // Warm Elegant Rose
                Color(0xFFB03A7B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE754A6).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "🌸 GENTLE MODE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sisters Corner",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Worship guides, support & comfort tools",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Beautiful glowing flower graphic placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "🌸",
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Navigation Bar Item Builder
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Route according to selections
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerTimesScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}