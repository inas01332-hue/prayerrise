import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/prayer_time_service.dart';
import '../models/city.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  // Sunnah Alarms State (must match SunnahPrayer enum keys)
  final Map<String, bool> _sunnahAlarms = {
    "beforeFajr": true,
    "duha": false,
    "beforeDhuhr": false,
    "tahajjud": true,
    "witr": true,
  };

  // 15-minute warning toggles
  final Map<String, bool> _warningAlarms = {
    "Fajr": true,
    "Dhuhr": true,
    "Asr": true,
    "Maghrib": true,
    "Isha": true,
  };

  bool _fridayReminder = true;

  // Fard Alarms State
  final Map<String, bool> _fardAlarms = {
    "Fajr": true,
    "Dhuhr": false,
    "Asr": true,
    "Maghrib": true,
    "Isha": true,
  };

  AudioPlayer? _previewPlayer;
  AdhanStyle? _playingAdhanStyle;

  void _toggleTonePreview(AdhanStyle style) async {
    if (_playingAdhanStyle == style) {
      await _previewPlayer?.stop();
      if (mounted) {
        setState(() {
          _playingAdhanStyle = null;
        });
      }
    } else {
      await _previewPlayer?.stop();
      _previewPlayer ??= AudioPlayer();
      if (mounted) {
        setState(() {
          _playingAdhanStyle = style;
        });
      }
      // Try URL source first (online)
      final url = _prayerTimeService.adhanUrls[style] ??
          'https://www.islamcan.com/audio/adhan/azan2.mp3';
      debugPrint("[Adhan Preview] Loading tone: $url");
      try {
        await _previewPlayer!.play(UrlSource(url));
        _previewPlayer!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playingAdhanStyle = null;
            });
          }
        });
      } catch (e) {
        debugPrint("[Adhan Preview] URL stream failed: $e. Trying local asset.");
        // Fallback to local asset
        try {
          await _previewPlayer!.play(AssetSource('audio/adhan.mp3'));
          _previewPlayer!.onPlayerComplete.listen((_) {
            if (mounted) {
              setState(() {
                _playingAdhanStyle = null;
              });
            }
          });
        } catch (assetError) {
          debugPrint("[Adhan Preview] Local asset also failed: $assetError");
          if (mounted) {
            setState(() {
              _playingAdhanStyle = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tone playback unavailable. Check internet connection."),
                backgroundColor: Color(0xFFC0392B),
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
    _prayerTimeService.addListener(_onCityChanged);
    _loadAlarmToggles();
  }

  @override
  void dispose() {
    _prayerTimeService.removeListener(_onCityChanged);
    _previewPlayer?.stop();
    _previewPlayer?.dispose();
    super.dispose();
  }

  void _onCityChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAlarmToggles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String key in _fardAlarms.keys) {
        _fardAlarms[key] = prefs.getBool('alarm_$key') ?? (key != "Dhuhr");
      }
      for (String key in _sunnahAlarms.keys) {
        _sunnahAlarms[key] = prefs.getBool('sunnah_alarm_$key') ?? 
            (key == "tahajjud" || key == "witr" || key == "beforeFajr");
      }
      for (String key in _warningAlarms.keys) {
        _warningAlarms[key] = prefs.getBool('warning_15_mins_$key') ?? true;
      }
      _fridayReminder = prefs.getBool('friday_jumuah_reminder') ?? true;
    });
  }

  Future<void> _toggleAlarm(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final current = _fardAlarms[name] ?? false;
      _fardAlarms[name] = !current;
      prefs.setBool('alarm_$name', !current);
    });
  }

  Future<void> _toggleSunnahAlarm(String key) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final current = _sunnahAlarms[key] ?? false;
      _sunnahAlarms[key] = !current;
      prefs.setBool('sunnah_alarm_$key', !current);
    });
  }

  Future<void> _toggleWarningAlarm(String key) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final current = _warningAlarms[key] ?? false;
      _warningAlarms[key] = !current;
      prefs.setBool('warning_15_mins_$key', !current);
    });
  }

  Future<void> _toggleFridayReminder() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fridayReminder = !_fridayReminder;
      prefs.setBool('friday_jumuah_reminder', _fridayReminder);
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "$displayHour:$min $period";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxury Deep Midnight
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Salah Schedule",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<City>(
              dropdownColor: const Color(0xFF0F1524),
              icon: const Icon(Icons.location_on, color: Color(0xFFFFD700)),
              value: _prayerTimeService.selectedCity,
              onChanged: (City? newCity) {
                if (newCity != null) {
                  _prayerTimeService.setSelectedCity(newCity);
                }
              },
              items: _prayerTimeService.availableCities.map((City city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(
                    city.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -screenSize.height * 0.1,
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

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Celestial Prayer Clock / Timeline Custom Paint
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Dynamic custom paint timeline
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: CelestialTimelinePainter(
                                  progress: (DateTime.now().hour * 60 + DateTime.now().minute) / (24 * 60.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Details text
                              FutureBuilder<Map<String, DateTime>>(
                                future: _prayerTimeService.getPrayerTimes(_prayerTimeService.selectedCity, DateTime.now()),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final todayTimes = snapshot.data!;
                                  final activeCity = _prayerTimeService.selectedCity;
                                  final nextPrayerInfo = _prayerTimeService.getNextPrayerInfo(activeCity);
                                  final nextName = nextPrayerInfo["name"];
                                  final nextTimeText = _formatTime(todayTimes[nextName]!);
                                  var duration = nextPrayerInfo["duration"] as Duration;
                                  if (duration.isNegative) {
                                    duration = Duration.zero;
                                  }
                                  final hoursLeft = duration.inHours;
                                  final minsLeft = duration.inMinutes.remainder(60);

                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "NEXT PRAYER",
                                          style: TextStyle(
                                            color: Color(0xFF8E9CB2),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$nextName ($nextTimeText)",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_filled_rounded, color: Color(0xFFFFD700), size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${hoursLeft}h ${minsLeft}m remaining",
                                              style: TextStyle(
                                                color: const Color(0xFFFFD700).withOpacity(0.85),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Sabah al-Khair! The angels of the night are transitioning to the angels of the day.",
                          style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildCalculationMethodSelector(),

                const SizedBox(height: 30),

                _buildAdhanSelector(),

                const SizedBox(height: 30),

                // 2. Fard (Obligatory) Prayer Tiles
                const Text(
                  "OBLIGATORY (FARD) PRAYERS",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<Map<String, DateTime>>(
                  future: _prayerTimeService.getPrayerTimes(_prayerTimeService.selectedCity, DateTime.now()),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final todayTimes = snapshot.data!;
                    final activeCity = _prayerTimeService.selectedCity;
                    final nextPrayerInfo = _prayerTimeService.getNextPrayerInfo(activeCity);
                    final nextName = nextPrayerInfo["name"];

                    return Column(
                      children: [
                        _buildFardTile("🌅", "Fajr", _formatTime(todayTimes["Fajr"]!), nextName == "Fajr"),
                        _buildFardTile("☀️", "Dhuhr", _formatTime(todayTimes["Dhuhr"]!), nextName == "Dhuhr"),
                        _buildFardTile("🌤", "Asr", _formatTime(todayTimes["Asr"]!), nextName == "Asr"),
                        _buildFardTile("🌇", "Maghrib", _formatTime(todayTimes["Maghrib"]!), nextName == "Maghrib"),
                        _buildFardTile("🌙", "Isha", _formatTime(todayTimes["Isha"]!), nextName == "Isha"),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 3. Sunnah Prayers Section
                const Text(
                  "SUNNAH & VOLUNTARY PRAYERS",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Invaluable daily routines to increase your scales and lock consistency.",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: PrayerTimeService.sunnahPrayers.length,
                  itemBuilder: (context, index) {
                    final prayer = PrayerTimeService.sunnahPrayers[index];
                    final alarmOn = _sunnahAlarms[prayer.key] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Text(prayer.icon, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prayer.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  prayer.timeRange,
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayer.description,
                                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Switch(
                            value: alarmOn,
                            activeColor: const Color(0xFFFFD700),
                            inactiveTrackColor: Colors.white10,
                            onChanged: (val) {
                              _toggleSunnahAlarm(prayer.key);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 4. 15-Minute Warning Reminders Section
                const Text(
                  "15-MINUTE REMINDERS",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Silent reminders 15 minutes before each Salah to prepare.",
                  style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                ),
                const SizedBox(height: 12),
                ..._warningAlarms.keys.map((name) {
                  final isOn = _warningAlarms[name] ?? true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Color(0xFF8E9CB2), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "15 mins before $name",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Switch(
                          value: isOn,
                          activeColor: const Color(0xFFFFD700),
                          inactiveTrackColor: Colors.white10,
                          onChanged: (val) => _toggleWarningAlarm(name),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 30),

                // 5. Weekly Friday / Jumu'ah Reminder
                const Text(
                  "WEEKLY REMINDERS",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                        child: const Text("🕌", style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jumu'ah Reminder",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Surah Al-Kahf & Salawat every Friday at 11:30 AM",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _fridayReminder,
                        activeColor: const Color(0xFFFFD700),
                        inactiveTrackColor: Colors.white10,
                        onChanged: (val) => _toggleFridayReminder(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFardTile(String icon, String name, String time, bool isActive) {
    final alarmOn = _fardAlarms[name] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF131B2E) : const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? const Color(0xFFFFD700).withOpacity(0.4) : Colors.white.withOpacity(0.03),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFD700).withOpacity(0.12) : Colors.white.withOpacity(0.02),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFFFD700) : const Color(0xFF8E9CB2),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              alarmOn ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: alarmOn ? const Color(0xFFFFD700) : const Color(0xFF5D6B82),
              size: 22,
            ),
            onPressed: () => _toggleAlarm(name),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                "CALCULATION METHOD",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Select the calculation rule to adjust prayer time accuracy for your region.",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1524),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CalculationMethodOption>(
                dropdownColor: const Color(0xFF0F1524),
                isExpanded: true,
                value: _prayerTimeService.selectedMethod,
                onChanged: (CalculationMethodOption? newMethod) {
                  if (newMethod != null) {
                    setState(() {
                      _prayerTimeService.setSelectedMethod(newMethod);
                    });
                  }
                },
                items: CalculationMethodOption.values.map((CalculationMethodOption option) {
                  return DropdownMenuItem<CalculationMethodOption>(
                    value: option,
                    child: Text(
                      option.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.audiotrack_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                "PREMIUM ADHAN TONE",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Select your preferred Adhan sound to play for notifications and alarms.",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
          ),
          const SizedBox(height: 16),
          ..._prayerTimeService.adhanUrls.keys.map((style) {
            final isSelected = _prayerTimeService.selectedAdhanStyle == style;
            final isPlaying = _playingAdhanStyle == style;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF131B2E) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.white.withOpacity(0.03),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _prayerTimeService.setSelectedAdhanStyle(style);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white30,
                              width: 2,
                            ),
                            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 12, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          style.displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_fill_rounded,
                      color: isPlaying ? const Color(0xFFFFD700) : const Color(0xFF2ECC71),
                      size: 26,
                    ),
                    onPressed: () => _toggleTonePreview(style),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Custom Painter to draw a circular prayer timeline (looks super premium!)
class CelestialTimelinePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 representing active day cycle

  CelestialTimelinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw outer circle
    final outerCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // 2. Draw elapsed timeline arc
    final arcPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );

    // 3. Draw dots representing the 5 daily prayers on the circle
    final dotPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final inactiveDotPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;

    // 5 prayer angles (simulated Fajr, Dhuhr, Asr, Maghrib, Isha)
    final angles = [
      -math.pi / 2 + 0.5,  // Fajr
      -math.pi / 2 + 2.2,  // Dhuhr
      -math.pi / 2 + 3.8,  // Asr
      -math.pi / 2 + 5.0,  // Maghrib
      -math.pi / 2 + 5.8,  // Isha
    ];

    for (int i = 0; i < angles.length; i++) {
      double angle = angles[i];
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      
      bool elapsed = (i / angles.length) <= progress;
      canvas.drawCircle(Offset(x, y), elapsed ? 5.5 : 4.0, elapsed ? dotPaint : inactiveDotPaint);
    }

    // 4. Center Moon graphic
    final centerMoonPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.45, centerMoonPaint);

    // Draw little crescent inside
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "🌙",
        style: TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 16, center.dy - 20));
  }

  @override
  bool shouldRepaint(covariant CelestialTimelinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}