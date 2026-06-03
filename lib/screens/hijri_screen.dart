import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicEvent {
  final String icon;
  final String title;
  final int hijriMonth;
  final int hijriDay;
  final String description;

  const IslamicEvent({
    required this.icon,
    required this.title,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
  });
}

class HijriScreen extends StatefulWidget {
  const HijriScreen({super.key});

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  // Calendar variables calculated dynamically
  late int _currentHijriDay;
  late String _currentHijriMonth;
  late int _currentHijriYear;
  late int _currentHijriMonthIndex;
  late double _illumination;
  late String _phaseName;

  final List<String> _months = const [
    "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
    "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
    "Ramadan", "Shawwal", "Dhu al-Qa'dah", "Dhu al-Hijjah"
  ];

  final List<IslamicEvent> _eventsList = const [
    IslamicEvent(
      icon: "🕌",
      title: "Islamic New Year",
      hijriMonth: 1,
      hijriDay: 1,
      description: "Commemorating the migration (Hijrah) of Prophet Muhammad (PBUH) from Makkah to Medina.",
    ),
    IslamicEvent(
      icon: "🖤",
      title: "Day of Ashura",
      hijriMonth: 1,
      hijriDay: 10,
      description: "A blessed day of fasting, commemorating the parting of the Red Sea for Prophet Musa (AS) and the children of Israel.",
    ),
    IslamicEvent(
      icon: "🌸",
      title: "Mawlid al-Nabi",
      hijriMonth: 3,
      hijriDay: 12,
      description: "Observing the birth anniversary of our beloved Prophet Muhammad (PBUH).",
    ),
    IslamicEvent(
      icon: "🌙",
      title: "Holy Month of Ramadan",
      hijriMonth: 9,
      hijriDay: 1,
      description: "The sacred month of fasting, night prayers (Tarawih), spiritual devotion, and Quranic revelation.",
    ),
    IslamicEvent(
      icon: "🎉",
      title: "Eid al-Fitr",
      hijriMonth: 10,
      hijriDay: 1,
      description: "Festival of breaking the fast, celebrating the completion of Ramadan worship.",
    ),
    IslamicEvent(
      icon: "🐑",
      title: "Eid al-Adha",
      hijriMonth: 12,
      hijriDay: 10,
      description: "Festival of Sacrifice, honoring the ultimate obedience of Prophet Ibrahim (AS).",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _calculateHijriCalendar();
  }

  // Kuwaiti Tabular Calendar conversion algorithm (Gregorian to Julian Day to Hijri)
  void _calculateHijriCalendar() {
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
    
    // Convert Julian Day to Tabular Hijri date
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

    // Boundary corrections
    if (hMonth < 1) hMonth = 1;
    if (hMonth > 12) hMonth = 12;

    setState(() {
      _currentHijriDay = hDay;
      _currentHijriMonthIndex = hMonth;
      _currentHijriMonth = _months[hMonth - 1];
      _currentHijriYear = hYear;
      
      // Calculate moon phase parameters
      _calculateMoonPhase(hDay);
    });
  }

  // Calculate moon phase names and illumination percentage based on real Hijri day
  void _calculateMoonPhase(int day) {
    if (day <= 1) {
      _illumination = 0.01;
      _phaseName = "New Moon (Hilal)";
    } else if (day < 8) {
      _illumination = (day / 7.0) * 0.5;
      _phaseName = "Waxing Crescent";
    } else if (day == 8) {
      _illumination = 0.5;
      _phaseName = "First Quarter (Tarbiy)";
    } else if (day < 14) {
      _illumination = 0.5 + ((day - 8) / 6.0) * 0.5;
      _phaseName = "Waxing Gibbous";
    } else if (day == 14 || day == 15) {
      _illumination = 1.0;
      _phaseName = "Full Moon (Badr)";
    } else if (day < 23) {
      _illumination = 1.0 - ((day - 15) / 7.0) * 0.5;
      _phaseName = "Waning Gibbous";
    } else if (day == 23) {
      _illumination = 0.5;
      _phaseName = "Third Quarter";
    } else {
      _illumination = 0.5 - ((day - 23) / 7.0) * 0.5;
      _phaseName = "Waning Crescent";
    }
  }

  // Math helper: Hijri Date to Julian Day Number (JDN)
  int _hijriToJulianDay(int hYear, int hMonth, int hDay) {
    return ((11 * hYear + 3) / 30).floor() + 354 * hYear + 30 * hMonth - 
           ((hMonth - 1) / 2).floor() + hDay + 1948440 - 385;
  }

  // Math helper: JDN to Gregorian Date
  DateTime _julianDayToGregorian(int jd) {
    int l = jd + 68569;
    int n = ((4 * l) / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    int i = ((4000 * (l + 1)) / 1461001).floor();
    l = l - ((1461 * i) / 4).floor() + 31;
    int j = ((80 * l) / 2447).floor();
    int day = l - ((2447 * j) / 80).floor();
    l = (j / 11).floor();
    int month = j + 2 - 12 * l;
    int year = 100 * (n - 49) + i + l;
    return DateTime(year, month, day);
  }

  // Calculate event timing dynamically
  Map<String, dynamic> _calculateEventStatus(int eventMonth, int eventDay) {
    int eventYear = _currentHijriYear;
    
    int todayJd = _hijriToJulianDay(_currentHijriYear, _currentHijriMonthIndex, _currentHijriDay);
    int eventJd = _hijriToJulianDay(eventYear, eventMonth, eventDay);
    int diff = eventJd - todayJd;

    // If the event passed more than 30 days ago in this Hijri year, move to the next year
    if (diff < -30) {
      eventYear = _currentHijriYear + 1;
      eventJd = _hijriToJulianDay(eventYear, eventMonth, eventDay);
      diff = eventJd - todayJd;
    }

    final DateTime gregDate = _julianDayToGregorian(eventJd);
    
    // Format Gregorian date nicely
    final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    String gregString = "${weekdays[gregDate.weekday - 1]}, ${months[gregDate.month - 1]} ${gregDate.day}, ${gregDate.year}";

    String statusText;
    bool hasPassed = diff < 0;

    if (diff == 0) {
      statusText = "TODAY";
    } else if (diff > 0) {
      if (diff < 30) {
        statusText = "In $diff Days";
      } else {
        int monthsCount = (diff / 29.5).round();
        statusText = "In $monthsCount Month${monthsCount > 1 ? 's' : ''}";
      }
    } else {
      int ago = diff.abs();
      if (ago < 30) {
        statusText = "$ago Day${ago > 1 ? 's' : ''} Ago";
      } else {
        int monthsCount = (ago / 29.5).round();
        statusText = "$monthsCount Month${monthsCount > 1 ? 's' : ''} Ago";
      }
    }

    return {
      "status": statusText,
      "passed": hasPassed,
      "gregDate": gregString,
      "hijriDate": "$eventDay ${_months[eventMonth - 1]} $eventYear AH",
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
          "Islamic Calendar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: screenSize.height * 0.15,
            right: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.04),
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
                // 1. Dynamic Authentic Lunar dashboard Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131B2E), Color(0xFF0F1524)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Dynamic moon phase painter
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: DynamicMoonPainter(dayOfMonth: _currentHijriDay),
                        ),
                      ),
                      const SizedBox(width: 22),
                      
                      // Lunar Date Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ASTRONOMICAL LUNAR HUD",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$_currentHijriDay $_currentHijriMonth",
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Year $_currentHijriYear AH",
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Phase: $_phaseName\nIllumination: ${(_illumination * 100).toInt()}%. Calibrated via Tabular Islamic Calendar converter.",
                              style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Event list header
                const Text(
                  "PERPETUAL ISLAMIC EVENTS",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Events ListView
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _eventsList.length,
                  itemBuilder: (context, index) {
                    final event = _eventsList[index];
                    final calc = _calculateEventStatus(event.hijriMonth, event.hijriDay);
                    final isPassed = calc['passed'] as bool;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isPassed 
                              ? Colors.white.withOpacity(0.01) 
                              : const Color(0xFFFFD700).withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Text(event.icon, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPassed 
                                            ? Colors.white10 
                                            : const Color(0xFFFFD700).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        calc['status'],
                                        style: TextStyle(
                                          color: isPassed ? Colors.white38 : const Color(0xFFFFD700),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  calc['hijriDate'],
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  calc['gregDate'],
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.description,
                                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Moon Phase Custom Painter representing lunar cycles dynamically
class DynamicMoonPainter extends CustomPainter {
  final int dayOfMonth; // 1 to 30 Hijri day

  DynamicMoonPainter({required this.dayOfMonth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background shadow (Moon dark side)
    final shadowPaint = Paint()
      ..color = const Color(0xFF070B14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, shadowPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Glowing illuminated moon paint
    final litPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);

    final path = Path();
    if (dayOfMonth == 14 || dayOfMonth == 15) {
      // Full Moon
      canvas.drawCircle(center, radius, litPaint);
    } else if (dayOfMonth > 1 && dayOfMonth < 14) {
      // Waxing phases
      double percent = (dayOfMonth - 1) / 13.0;
      path.moveTo(center.dx, center.dy - radius);
      path.arcToPoint(
        Offset(center.dx, center.dy + radius),
        radius: Radius.circular(radius),
        clockwise: true,
      );
      path.arcToPoint(
        Offset(center.dx, center.dy - radius),
        radius: Radius.circular(radius * (1 - 2 * percent).abs()),
        clockwise: percent < 0.5,
      );
      canvas.drawPath(path, litPaint);
    } else if (dayOfMonth > 15 && dayOfMonth < 30) {
      // Waning phases
      double percent = (dayOfMonth - 15) / 14.0;
      path.moveTo(center.dx, center.dy - radius);
      path.arcToPoint(
        Offset(center.dx, center.dy + radius),
        radius: Radius.circular(radius),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(center.dx, center.dy - radius),
        radius: Radius.circular(radius * (1 - 2 * percent).abs()),
        clockwise: percent >= 0.5,
      );
      canvas.drawPath(path, litPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DynamicMoonPainter oldDelegate) {
    return oldDelegate.dayOfMonth != dayOfMonth;
  }
}