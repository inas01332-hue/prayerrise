import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060914), // Luxurious Deep Space Navy
      body: Stack(
        children: [
          // 1. Ambient Glow Layers
          Positioned(
            top: -screenSize.height * 0.15,
            left: -screenSize.width * 0.2,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: screenSize.width * 0.9,
                  height: screenSize.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.08 * _glowAnimation.value),
                        const Color(0xFF060914).withOpacity(0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.2,
            right: -screenSize.width * 0.2,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: screenSize.width * 1.1,
                  height: screenSize.width * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1E5B43).withOpacity(0.06 * _glowAnimation.value),
                        const Color(0xFF060914).withOpacity(0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Animated glowing center logo
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Backing glow
                                  Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withOpacity(0.12 * _glowAnimation.value),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Drawing the crescent & star
                                  Container(
                                    width: 140,
                                    height: 140,
                                    padding: const EdgeInsets.all(10),
                                    child: CustomPaint(
                                      painter: LogoPainter(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Brand Text with subtle gold gradient shader
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFDF7A),
                              Color(0xFFD4AF37),
                              Color(0xFFFFDF7A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            "PRAYERRISE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Modern Tagline
                        const Text(
                          "Rise with prayer.\nWalk with spiritual purpose.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8E9CB2),
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const Spacer(),

                        // Micro-animated Interactive Button
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isButtonPressed = true),
                          onTapUp: (_) => setState(() => _isButtonPressed = false),
                          onTapCancel: () => setState(() => _isButtonPressed = false),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: AnimatedScale(
                            scale: _isButtonPressed ? 0.96 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                            child: Container(
                              width: double.infinity,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFDF7A),
                                    Color(0xFFD4AF37),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Begin Journey",
                                  style: TextStyle(
                                    color: Color(0xFF060914),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Beautiful Custom Vector Painter for Crescent and Star
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Crescent Moon
    final moonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final moonPath1 = Path();
    moonPath1.addOval(Rect.fromLTWH(0, 0, size.width * 0.9, size.height * 0.9));

    final moonPath2 = Path();
    moonPath2.addOval(Rect.fromLTWH(
      size.width * 0.22,
      -size.height * 0.02,
      size.width * 0.85,
      size.height * 0.85,
    ));

    final crescentPath = Path.combine(PathOperation.difference, moonPath1, moonPath2);
    canvas.drawPath(crescentPath, moonPaint);

    // 2. Draw Elegant Star
    final starPaint = Paint()
      ..color = const Color(0xFFFFDF7A)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1);

    final starPath = Path();
    double cx = size.width * 0.72;
    double cy = size.height * 0.35;
    double spikes = 4;
    double outerRadius = size.width * 0.15;
    double innerRadius = size.width * 0.05;
    double rot = math.pi / 2 * 3;
    double step = math.pi / spikes;

    starPath.moveTo(cx, cy - outerRadius);
    for (int i = 0; i < spikes; i++) {
      double x = cx + math.cos(rot) * outerRadius;
      double y = cy + math.sin(rot) * outerRadius;
      starPath.lineTo(x, y);
      rot += step;

      x = cx + math.cos(rot) * innerRadius;
      y = cy + math.sin(rot) * innerRadius;
      starPath.lineTo(x, y);
      rot += step;
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}