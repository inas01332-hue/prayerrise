import 'dart:async';
import 'package:flutter/material.dart';

class ReflectionShareScreen extends StatefulWidget {
  final String arabicText;
  final String englishText;
  final String source;

  const ReflectionShareScreen({
    super.key,
    required this.arabicText,
    required this.englishText,
    required this.source,
  });

  @override
  State<ReflectionShareScreen> createState() => _ReflectionShareScreenState();
}

class _ReflectionShareScreenState extends State<ReflectionShareScreen> {
  // Gradients list
  final List<List<Color>> _gradients = const [
    [Color(0xFF0F1524), Color(0xFF060914)], // Midnight Space
    [Color(0xFF1E5B43), Color(0xFF0B2017)], // Golden Emerald
    [Color(0xFF3F192E), Color(0xFF1F0B17)], // Royal Plum
    [Color(0xFF231A3C), Color(0xFF0E0A1A)], // Celestial Twilight
  ];

  int _selectedGradientIndex = 0;
  bool _showArabic = true;
  double _fontSizeMultiplier = 1.0;

  void _exportCard() {
    // Simulated rendering & sharing animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double prog = 0.0;
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
              if (prog >= 1.0) {
                timer.cancel();
                Navigator.pop(context); // close progress dialog
                _showSuccessSheet();
              } else {
                setDialogState(() {
                  prog += 0.1;
                });
              }
            });

            return Dialog(
              backgroundColor: const Color(0xFF131B2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))),
                    const SizedBox(height: 20),
                    const Text(
                      "Generating High-Res Canvas...",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${(prog * 100).toInt()}% Rendered",
                      style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 64),
              const SizedBox(height: 16),
              const Text(
                "Canvas Exported Successfully!",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "The image has been rendered and copied to your clipboard. You can now paste it directly into your Instagram/TikTok/WhatsApp stories!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Alhamdulillah (Done)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGradient = _gradients[_selectedGradientIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Midnight Navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Viral Quote Creator", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const Text(
                "Customize the canvas below and share to social media to spread the viral barakah! 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Canvas Preview Frame
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: activeGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Moon Logo watermark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("🌙", style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                              ).createShader(bounds),
                              child: const Text(
                                "PRAYERRISE",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 4),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        if (_showArabic && widget.arabicText.isNotEmpty) ...[
                          Text(
                            widget.arabicText,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: const Color(0xFFFFD700),
                              fontSize: 24 * _fontSizeMultiplier,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'QuranFont',
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Text(
                          "\"${widget.englishText}\"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * _fontSizeMultiplier,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "— ${widget.source}",
                          style: const TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "Join the journey on @PrayerRise",
                          style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Customizer Controls Panel
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    // 1. Gradients Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Canvas Theme:", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(_gradients.length, (idx) {
                            final isSel = _selectedGradientIndex == idx;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGradientIndex = idx;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSel ? const Color(0xFFFFD700) : Colors.transparent, width: 2),
                                  gradient: LinearGradient(
                                    colors: _gradients[idx],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),

                    // 2. Settings row (Size multiplier, Arabic Toggle)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Arabic Text", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Switch(
                              value: _showArabic,
                              activeColor: const Color(0xFFFFD700),
                              onChanged: (val) {
                                setState(() {
                                  _showArabic = val;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Font Size:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                              onPressed: _fontSizeMultiplier > 0.8
                                  ? () => setState(() => _fontSizeMultiplier -= 0.1)
                                  : null,
                            ),
                            Text(
                              "${(_fontSizeMultiplier * 100).toInt()}%",
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white70, size: 18),
                              onPressed: _fontSizeMultiplier < 1.3
                                  ? () => setState(() => _fontSizeMultiplier += 0.1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Export/Share Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    shadowColor: const Color(0xFFFFD700).withOpacity(0.3),
                    elevation: 8,
                  ),
                  onPressed: _exportCard,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    "Export to Instagram Story",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
