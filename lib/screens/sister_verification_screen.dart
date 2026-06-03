import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'girly_mode_screen.dart';

class SisterVerificationScreen extends StatefulWidget {
  final VoidCallback onVerificationSuccess;

  const SisterVerificationScreen({
    super.key,
    required this.onVerificationSuccess,
  });

  @override
  State<SisterVerificationScreen> createState() => _SisterVerificationScreenState();
}

class _SisterVerificationScreenState extends State<SisterVerificationScreen> {
  int _currentStep = 0; // 0: Intro/Oath, 1: PIN Setup/Entry, 2: Success
  bool _pledgeAccepted = false;
  bool _hasSavedPin = false;
  String _savedPin = "";
  bool _pinError = false;
  bool _obscurePin = true;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('sisters_sanctuary_pin') ?? "";
    if (mounted) {
      setState(() {
        _savedPin = pin;
        _hasSavedPin = pin.isNotEmpty;
      });
    }
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sisters_sanctuary_pin', pin);
    await prefs.setBool('is_sister_verified', true);
  }

  void _resetVerification() {
    setState(() {
      _currentStep = 0;
      _pledgeAccepted = false;
      _pinController.clear();
      _pinConfirmController.clear();
      _pinError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A18), // Deep Midnight Plum
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFFE8A0B2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sanctuary Verification",
          style: TextStyle(
            color: Color(0xFFE8A0B2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient radial glows
          Positioned(
            top: -screenSize.height * 0.15,
            left: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE754A6).withOpacity(0.06),
                    const Color(0xFF0F0A18).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.15,
            right: -screenSize.width * 0.2,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB03A7B).withOpacity(0.06),
                    const Color(0xFF0F0A18).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepOath();
      case 1:
        return _hasSavedPin ? _buildStepPinEntry() : _buildStepPinSetup();
      case 2:
        return _buildStepSuccess();
      default:
        return _buildStepOath();
    }
  }

  // STEP 0: Sisterhood Oath / Pledge
  Widget _buildStepOath() {
    return SingleChildScrollView(
      key: const ValueKey("step_oath"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE754A6).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.2)),
            ),
            child: const Center(
              child: Icon(Icons.lock_person_rounded, color: Color(0xFFE754A6), size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Sisters' Sanctuary Access",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Girly Mode contains specific private utilities for sisters. To preserve the security, comfort, and sanctity of this space, please accept the pledge below.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB5A7C5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0F2A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.12)),
            ),
            child: Column(
              children: [
                const Text(
                  "📜 THE AMANA COVENANT",
                  style: TextStyle(
                    color: Color(0xFFE8A0B2),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "\"I solemnly pledge before Allah, who knows what is hidden and manifest, that I am indeed a sister entering this private sanctuary. I will preserve the sanctity, privacy, and integrity of this sisters-only space.\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _pledgeAccepted = !_pledgeAccepted),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _pledgeAccepted,
                        activeColor: const Color(0xFFE754A6),
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _pledgeAccepted = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          "I accept this covenant and confirm I am a sister.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _pledgeAccepted ? const Color(0xFFE754A6) : Colors.grey.withOpacity(0.05),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: _pledgeAccepted ? 8 : 0,
              ),
              onPressed: _pledgeAccepted
                  ? () => setState(() => _currentStep = 1)
                  : null,
              child: Text(
                _hasSavedPin ? "Continue to PIN Entry" : "Set Up PIN Protection",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // STEP 1a: PIN Setup (first time)
  Widget _buildStepPinSetup() {
    return SingleChildScrollView(
      key: const ValueKey("step_pin_setup"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE754A6).withOpacity(0.1),
            ),
            child: const Center(
              child: Icon(Icons.pin_rounded, color: Color(0xFFE754A6), size: 32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Create Your PIN",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Set a 4-8 digit PIN to protect your Sisters' Sanctuary. You will use this PIN to re-enter in the future.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB5A7C5), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 30),

          _buildPinTextField(_pinController, "Enter PIN (4-8 digits)"),
          const SizedBox(height: 16),
          _buildPinTextField(_pinConfirmController, "Confirm PIN"),

          if (_pinError) ...[
            const SizedBox(height: 12),
            const Text(
              "PINs don't match or are too short (minimum 4 digits).",
              style: TextStyle(color: Color(0xFFFF8B8B), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE754A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
              onPressed: () async {
                final pin = _pinController.text.trim();
                final confirm = _pinConfirmController.text.trim();
                if (pin.length < 4 || pin != confirm) {
                  setState(() => _pinError = true);
                  return;
                }
                await _savePin(pin);
                setState(() {
                  _pinError = false;
                  _currentStep = 2;
                });
              },
              child: const Text(
                "Create PIN & Enter Sanctuary",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1b: PIN Entry (returning user)
  Widget _buildStepPinEntry() {
    return SingleChildScrollView(
      key: const ValueKey("step_pin_entry"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE754A6).withOpacity(0.1),
            ),
            child: const Center(
              child: Icon(Icons.lock_open_rounded, color: Color(0xFFE754A6), size: 32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Enter Your PIN",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter the PIN you set previously to access the Sisters' Sanctuary.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB5A7C5), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 30),

          _buildPinTextField(_pinController, "Enter your PIN"),

          if (_pinError) ...[
            const SizedBox(height: 12),
            const Text(
              "Incorrect PIN. Please try again.",
              style: TextStyle(color: Color(0xFFFF8B8B), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE754A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
              onPressed: () async {
                final entered = _pinController.text.trim();
                if (entered == _savedPin) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_sister_verified', true);
                  setState(() {
                    _pinError = false;
                    _currentStep = 2;
                  });
                } else {
                  setState(() => _pinError = true);
                }
              },
              child: const Text(
                "Unlock Sanctuary",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              // Reset PIN flow
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('sisters_sanctuary_pin');
              setState(() {
                _hasSavedPin = false;
                _savedPin = "";
                _pinController.clear();
                _pinError = false;
              });
            },
            child: const Text(
              "Forgot PIN? Reset",
              style: TextStyle(color: Color(0xFFB5A7C5), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B0F2A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8A0B2).withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        obscureText: _obscurePin,
        keyboardType: TextInputType.number,
        maxLength: 8,
        style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 8),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14, letterSpacing: 0),
          counterText: "",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: const Color(0xFFE8A0B2).withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePin = !_obscurePin),
          ),
        ),
      ),
    );
  }

  // STEP 2: Success
  Widget _buildStepSuccess() {
    return Column(
      key: const ValueKey("step_success"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2ECC71).withOpacity(0.12),
            border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withOpacity(0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.verified_user_rounded, color: Color(0xFF2ECC71), size: 56),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Access Approved",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Welcome, Sister! Your oath and PIN verification have been validated.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFB5A7C5),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "The sanctuary is now unlocked for you.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE8A0B2),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            onPressed: () {
              widget.onVerificationSuccess();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GirlyModeScreen(),
                ),
              );
            },
            child: const Text(
              "Enter Sisters Sanctuary 🌸",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
