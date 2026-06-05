import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../services/adhan_player.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  DateTime? _nextPrayerTime;
  bool _adhanNotificationsEnabled = true;
  bool _isLoading = true;
  String _locationStatus = "Detecting location...";
  String _city = "Makkah";

  final List<Map<String, String>> _prayerSchedule = [
    {"name": "Fajr", "time": "04:48"},
    {"name": "Dhuhr", "time": "12:25"},
    {"name": "Asr", "time": "15:48"},
    {"name": "Maghrib", "time": "18:41"},
    {"name": "Isha", "time": "19:55"},
  ];

  String _playerStatus = AdhanPlayer.instance.statusMessage;

  @override
  void initState() {
    super.initState();
    _loadLocationAndPrayerTimes();
    _startTimer();
    AdhanPlayer.instance.onStatusChanged = (status) {
      if (mounted) {
        setState(() {
          _playerStatus = status;
        });
      }
    };
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadLocationAndPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _locationStatus = "Detecting GPS location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw "Location services disabled.";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw "Location permissions denied.";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw "Location permissions permanently denied.";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      _city = "Your Location";
      await _fetchPrayerTimes(position.latitude, position.longitude);
    } catch (e) {
      print("Location error: $e. Falling back to Makkah.");
      _city = "Makkah (Fallback)";
      _locationStatus = "GPS Denied. Makkah time.";
      await _fetchPrayerTimes(21.3891, 39.8579);
    }
  }

  Future<void> _fetchPrayerTimes(double lat, double lon) async {
    try {
      final url = Uri.parse("https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lon&method=2");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data["data"]["timings"];

        setState(() {
          _prayerSchedule[0]["time"] = _formatApiTime(timings["Fajr"]);
          _prayerSchedule[1]["time"] = _formatApiTime(timings["Dhuhr"]);
          _prayerSchedule[2]["time"] = _formatApiTime(timings["Asr"]);
          _prayerSchedule[3]["time"] = _formatApiTime(timings["Maghrib"]);
          _prayerSchedule[4]["time"] = _formatApiTime(timings["Isha"]);
          
          _isLoading = false;
          _locationStatus = "Synced with $_city";
          _determineNextPrayer();
        });
      } else {
        throw "Failed to load prayer times from API";
      }
    } catch (e) {
      print("Fetch error: $e. Using local default times.");
      setState(() {
        _isLoading = false;
        _determineNextPrayer();
      });
    }
  }

  String _formatApiTime(String time) {
    return time.split(" ")[0];
  }

  void _determineNextPrayer() {
    final now = DateTime.now();
    _nextPrayerTime = null;
    for (var entry in _prayerSchedule) {
      final parts = entry["time"]!.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isBefore(now)) {
        continue;
      }
      _nextPrayerTime = candidate;
      break;
    }
    _nextPrayerTime ??= _nextDayPrayer(_prayerSchedule.first);
    _updateRemaining();
  }

  DateTime _nextDayPrayer(Map<String, String> prayer) {
    final parts = prayer["time"]!.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);
  }

  String? _lastPlayedPrayer;
  DateTime? _lastPlayedDate;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {
          _updateRemaining();
          _checkAndPlayAdhan();
        }));
  }

  void _checkAndPlayAdhan() {
    if (!_adhanNotificationsEnabled) return;

    final now = DateTime.now();
    final hourStr = now.hour.toString().padLeft(2, '0');
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final nowTimeStr = "$hourStr:$minuteStr";

    for (var entry in _prayerSchedule) {
      if (entry["time"] == nowTimeStr) {
        final name = entry["name"]!;
        if (_lastPlayedPrayer != name ||
            _lastPlayedDate == null ||
            _lastPlayedDate!.day != now.day ||
            _lastPlayedDate!.month != now.month ||
            _lastPlayedDate!.year != now.year) {
          AdhanPlayer.instance.play();
          _lastPlayedPrayer = name;
          _lastPlayedDate = now;
          _determineNextPrayer();
        }
        break;
      }
    }
  }

  void _updateRemaining() {
    if (_nextPrayerTime == null) return;
    final now = DateTime.now();
    _remaining = _nextPrayerTime!.difference(now);
    if (_remaining.isNegative) {
      _determineNextPrayer();
    }
  }

  String _formatDuration(Duration d) {
    if (d.isNegative || d.inSeconds <= 0) {
      return "0m remaining";
    }
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return "${hours}h ${minutes}m remaining";
    } else if (minutes > 0) {
      return "${minutes}m remaining";
    } else {
      return "${seconds}s remaining";
    }
  }

  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? "PM" : "AM";
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return "$hour12:$minuteStr $period";
    } catch (e) {
      return time24;
    }
  }

  bool _isPlaying = false;

  void _togglePlayAdhan() async {
    if (_isPlaying) {
      await AdhanPlayer.instance.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      await AdhanPlayer.instance.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String? nextPrayerName;
    for (var p in _prayerSchedule) {
      final parts = p["time"]!.split(":");
      final prayerTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      if (prayerTime.isAfter(now)) {
        nextPrayerName = p["name"];
        break;
      }
    }
    nextPrayerName ??= _prayerSchedule.first["name"];

    String nextPrayerTime12 = "";
    if (nextPrayerName != null) {
      final entry = _prayerSchedule.firstWhere((p) => p["name"] == nextPrayerName);
      nextPrayerTime12 = _formatTo12Hour(entry["time"]!);
    }

    final Map<String, String> icons = {
      "Fajr": "🌅",
      "Dhuhr": "☀️",
      "Asr": "🌤",
      "Maghrib": "🌇",
      "Isha": "🌙",
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Prayer Times", style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF00A86B)),
            onPressed: _loadLocationAndPrayerTimes,
            tooltip: "Recalculate location",
          )
        ],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
                  SizedBox(height: 16),
                  Text(
                    "Syncing prayer times...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Premium Next Prayer Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE0F2E9),
                          Color(0xFFC8E6C9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF00A86B).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "NEXT PRAYER",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nextPrayerName ?? "",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextPrayerTime12,
                          style: const TextStyle(
                            color: Color(0xFF00A86B),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDuration(_remaining),
                          style: TextStyle(
                            color: Colors.black87.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Prayer times list
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: _prayerSchedule.map((p) {
                        final name = p["name"]!;
                        final time24 = p["time"]!;
                        final icon = icons[name] ?? "🕌";
                        final time12 = _formatTo12Hour(time24);
                        final isNext = name == nextPrayerName;
                        return PrayerTile(
                          icon,
                          name,
                          time12,
                          isHighlighted: isNext,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Adhan Notifications Switch
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF00A86B).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  color: Color(0xFF00A86B),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Adhan Notifications",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _adhanNotificationsEnabled,
                              activeColor: const Color(0xFF00A86B),
                              onChanged: (val) {
                                setState(() {
                                  _adhanNotificationsEnabled = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.black12, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _locationStatus,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _playerStatus,
                                  style: const TextStyle(
                                    color: Color(0xFF00A86B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _togglePlayAdhan,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A86B).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isPlaying ? Icons.stop : Icons.play_arrow,
                                      color: const Color(0xFF00A86B),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class PrayerTile extends StatelessWidget {
  final String icon;
  final String prayer;
  final String time;
  final bool isHighlighted;

  const PrayerTile(
    this.icon,
    this.prayer,
    this.time, {
    this.isHighlighted = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFE0F2E9) : const Color(0xFFF5F9F5),
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF00A86B), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}