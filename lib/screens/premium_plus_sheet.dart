import 'dart:async';
import 'package:flutter/material.dart';

class PremiumPlusSheet extends StatefulWidget {
  final VoidCallback onPurchaseSuccess;
  const PremiumPlusSheet({super.key, required this.onPurchaseSuccess});

  static void show(BuildContext context, VoidCallback onPurchaseSuccess) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumPlusSheet(onPurchaseSuccess: onPurchaseSuccess),
    );
  }

  @override
  State<PremiumPlusSheet> createState() => _PremiumPlusSheetState();
}

class _PremiumPlusSheetState extends State<PremiumPlusSheet> with TickerProviderStateMixin {
  int _selectedPlanIndex = 0; // 0 = Yearly, 1 = Monthly
  bool _isProcessing = false;
  bool _isSuccess = false;

  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startTrial() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate safe processing
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });

        // Trigger the callback after a beautiful success frame
        Timer(const Duration(milliseconds: 1800), () {
          if (mounted) {
            widget.onPurchaseSuccess();
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF070B19), // Pitch midnight space
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFD700),
            blurRadius: 10,
            spreadRadius: -8,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient radial glowing spots
          Positioned(
            top: -screenSize.width * 0.3,
            right: -screenSize.width * 0.3,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.06),
                    const Color(0xFF070B19).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.width * 0.2,
            left: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.8,
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E5B43).withOpacity(0.05),
                    const Color(0xFF070B19).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          if (!_isProcessing && !_isSuccess) ...[
            // Main sheet contents
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Pull Handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 14),
                        SizedBox(width: 6),
                        Text(
                          "PRAYERRISE PREMIUM PLUS",
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shimmering title
                  const Text(
                    "Elevate Your Worship",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Access the ultimate tools designed for deep spiritual connection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Features grid (Scrollable lists)
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildFeatureRow(
                          "🧠",
                          "AI Spiritual Companion (Nura)",
                          "Get real-time answers, du'as & reflections curated to your emotion.",
                        ),
                        _buildFeatureRow(
                          "🎓",
                          "AI Tajweed Coach",
                          "Practice your Quran recitation with vocal analysis.",
                        ),
                        _buildFeatureRow(
                          "📿",
                          "Interactive Audio 99 Names",
                          "Explore spiritual names with beautiful HD audio & reflection guides.",
                        ),
                        _buildFeatureRow(
                          "🕌",
                          "Masjid Route & Compass GPS",
                          "Turn-by-turn routing animation directly to your nearest jamat.",
                        ),
                        _buildFeatureRow(
                          "🥗",
                          "Smart Halal barcode Scanner",
                          "Point your camera, trace ingredients & identify doubtful status instantly.",
                        ),
                        _buildFeatureRow(
                          "💌",
                          "Canvas Card Studio (Pro)",
                          "Export personalized calligraphic greeting canvases without limits.",
                        ),
                        const SizedBox(height: 20),

                        // Subscription Tiers Plan
                        const Text(
                          "SELECT PLAN",
                          style: TextStyle(
                            color: Color(0xFF5D6B82),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildPlanCard(
                          index: 0,
                          title: "Yearly Subscription",
                          priceText: "\$29.99/year",
                          periodText: "7 days free trial, then \$2.50/mo",
                          badgeText: "SAVE 50%",
                        ),
                        const SizedBox(height: 10),
                        _buildPlanCard(
                          index: 1,
                          title: "Monthly Subscription",
                          priceText: "\$4.99/month",
                          periodText: "Cancel anytime, zero commitment",
                          badgeText: null,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Call to Action
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.02),
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _startTrial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text(
                          "START 7-DAY FREE TRIAL",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Secure with standard stores. No charge during trial.",
                    style: TextStyle(color: Color(0xFF5D6B82), fontSize: 10),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ] else if (_isProcessing) ...[
            // Processing flow Screen
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      backgroundColor: const Color(0xFFFFD700).withOpacity(0.08),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Contacting App Store...",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Setting up your secure spiritual suite.",
                    style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                  ),
                ],
              ),
            )
          ] else ...[
            // Success Shimmering confettis and screen!
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E5B43).withOpacity(0.15),
                        border: Border.all(color: const Color(0xFF2ECC71), width: 2),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF2ECC71),
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      "Subscribed Successfully!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome to PrayerRise Premium Plus.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "All features are unlocked. Enjoy your premium companions.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String priceText,
    required String periodText,
    required String? badgeText,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF131B2E).withOpacity(0.8) : const Color(0xFF131B2E).withOpacity(0.3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700).withOpacity(0.6) : Colors.white.withOpacity(0.04),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Check icon pill
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 16),

            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    periodText,
                    style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                  ),
                ],
              ),
            ),

            // Plan Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (badgeText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
