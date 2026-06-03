import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/prayer_time_service.dart';

class AlarmScreen extends StatefulWidget {
  final String prayerName;
  final String timeText;

  const AlarmScreen({
    super.key,
    required this.prayerName,
    required this.timeText,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  // Typing Challenge States
  final List<String> _islamicPhrases = const [
    "SubhanAllah wa bihamdihi",
    "Astaghfirullah al-Azeem",
    "La ilaha illallah",
    "Alhamdulillah",
    "Allahu Akbar"
  ];
  late String _targetPhrase;
  final TextEditingController _typingController = TextEditingController();
  bool _phraseMatched = false;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _targetPhrase = _islamicPhrases[math.Random().nextInt(_islamicPhrases.length)];

    // Animation setups
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start playing Adhan audio on loop
    _playAdhan();
  }

  Future<void> _playAdhan() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      final service = PrayerTimeService();
      final adhanUrl = service.adhanUrls[service.selectedAdhanStyle] ??
          "https://www.islamcan.com/audio/adhan/azan2.mp3";
      debugPrint("[AlarmScreen] Playing Adhan URL: $adhanUrl");
      await _player.play(UrlSource(adhanUrl));
      debugPrint("[AlarmScreen] Adhan URL playback started.");
    } catch (e) {
      debugPrint("[AlarmScreen] URL stream failed: $e. Falling back to local asset.");
      // Fallback 1: local bundled asset
      try {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource('audio/adhan.mp3'));
        debugPrint("[AlarmScreen] Local asset adhan playback started.");
      } catch (assetError) {
        // Both online and offline failed
        debugPrint("[AlarmScreen] Local asset also failed: $assetError. Both sources unavailable.");
      }
    }
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _checkPhrase(String value) {
    if (value.trim().toLowerCase() == _targetPhrase.toLowerCase()) {
      setState(() {
        _phraseMatched = true;
      });
    } else {
      setState(() {
        _phraseMatched = false;
      });
    }
  }

  void _stopAlarmAndDismiss() {
    _player.stop();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF04060E), // Deep space navy black
      body: Stack(
        children: [
          // 1. Ambient Golden background glow
          Positioned(
            top: screenSize.height * 0.1,
            left: screenSize.width * 0.1,
            right: screenSize.width * 0.1,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.08 * _glowAnimation.value),
                        const Color(0xFF04060E).withOpacity(0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header Status
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        // Mosque active pulsating icon
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFD700).withOpacity(0.1),
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.mosque_outlined,
                                  color: Color(0xFFFFD700),
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${widget.prayerName.toUpperCase()} PRAYER TIME",
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Rise and Worship",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Adhan Time: ${widget.timeText}",
                          style: const TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Islamic Phrase Typing Challenge
                    _buildTypingChallenge(),

                    // Confirm Unlock button
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _phraseMatched
                                  ? const Color(0xFF2ECC71)
                                  : Colors.white.withOpacity(0.03),
                              foregroundColor: _phraseMatched
                                  ? Colors.black
                                  : Colors.white30,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                              elevation: _phraseMatched ? 8 : 0,
                            ),
                            onPressed: _phraseMatched
                                ? _stopAlarmAndDismiss
                                : null,
                            child: const Text(
                              "DISMISS ADHAN ALARM",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quick dismiss option (swipe up hint)
                        TextButton(
                          onPressed: _stopAlarmAndDismiss,
                          child: const Text(
                            "Quick Dismiss",
                            style: TextStyle(
                              color: Color(0xFF5D6B82),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingChallenge() {
    return Container(
      key: const ValueKey("typing_challenge"),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          const Text(
            "TYPE THE PHRASE BELOW TO SILENCE ALARM",
            style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF04060E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15)),
            ),
            child: Text(
              _targetPhrase,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _typingController,
            onChanged: _checkPhrase,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Type phrase exactly here...",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF04060E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _phraseMatched ? const Color(0xFF2ECC71) : const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          if (_phraseMatched)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    "MashaAllah! Phrase matched.",
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
