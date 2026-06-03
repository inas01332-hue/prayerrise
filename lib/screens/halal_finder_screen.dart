import 'dart:async';
import 'package:flutter/material.dart';
import 'premium_plus_sheet.dart';

class HalalFinderScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUnlockPremium;
  const HalalFinderScreen({super.key, required this.isPremium, required this.onUnlockPremium});

  @override
  State<HalalFinderScreen> createState() => _HalalFinderScreenState();
}

class _HalalFinderScreenState extends State<HalalFinderScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = "All";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Scanner States
  bool _isScanning = false;
  bool _scanCompleted = false;
  Timer? _laserTimer;
  double _laserPosition = 0.0;
  bool _laserGoingDown = true;

  final List<String> _categories = ["All", "Turkish", "Middle Eastern", "Asian", "Groceries"];

  final List<Map<String, dynamic>> _outlets = [
    {
      "name": "Istanbul Grill House",
      "category": "Turkish",
      "distance": "0.8 km",
      "rating": "4.8 ⭐",
      "cuisine": "Halal Kebabs & Steaks",
      "status": "Certified Halal",
      "statusColor": const Color(0xFF2ECC71),
      "address": "45 Crescent Way, New York"
    },
    {
      "name": "Medina Grocery & Halal Meat",
      "category": "Groceries",
      "distance": "1.1 km",
      "rating": "4.9 ⭐",
      "cuisine": "Fresh Meat & Middle Eastern Imports",
      "status": "Muslim Owned",
      "statusColor": const Color(0xFF3498DB),
      "address": "88 Al-Azhar Ave, New York"
    },
    {
      "name": "Kabab Palace",
      "category": "Asian",
      "distance": "1.5 km",
      "rating": "4.5 ⭐",
      "cuisine": "Pakistani Biryani & Curries",
      "status": "Certified Halal",
      "statusColor": const Color(0xFF2ECC71),
      "address": "12 Jinnah Road, New York"
    },
    {
      "name": "Al-Basha Mandi",
      "category": "Middle Eastern",
      "distance": "2.2 km",
      "rating": "4.6 ⭐",
      "cuisine": "Yemeni Mandi & Rice",
      "status": "Muslim Owned",
      "statusColor": const Color(0xFF3498DB),
      "address": "77 Arab Street, New York"
    }
  ];

  @override
  void dispose() {
    _laserTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startScanningFlow() {
    if (!widget.isPremium) {
      PremiumPlusSheet.show(context, widget.onUnlockPremium);
      return;
    }

    setState(() {
      _isScanning = true;
      _scanCompleted = false;
      _laserPosition = 0.05;
      _laserGoingDown = true;
    });

    // Start laser sweep animation
    _laserTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_laserGoingDown) {
          _laserPosition += 0.05;
          if (_laserPosition >= 0.95) {
            _laserGoingDown = false;
          }
        } else {
          _laserPosition -= 0.05;
          if (_laserPosition <= 0.05) {
            _laserGoingDown = true;
          }
        }
      });
    });

    // Auto complete scan in 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      _laserTimer?.cancel();
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanCompleted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOutlets = _outlets.where((item) {
      final matchesCat = _selectedCategory == "All" || item['category'] == _selectedCategory;
      final matchesQuery = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['cuisine'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

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
          "Halal Finder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Premium Ingredient Scanner trigger banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E5B43), Color(0xFF0F1524)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "E-NUMBER / INGREDIENT SCANNER",
                              style: TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Doubtful Gelatin or Carmine?",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Point your camera at ingredients to scan and check chemical status instantly.",
                              style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.3),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _startScanningFlow,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.qr_code_scanner_rounded, color: Colors.black, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      "SCAN PRODUCT",
                                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.document_scanner_rounded, size: 48, color: Color(0xFFFFD700)),
                    ],
                  ),
                ),
              ),

              // Scan Completed Review drawer
              if (_scanCompleted) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "SCAN RESULT: HARAM (MUSHBOOH)",
                                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                              onPressed: () {
                                setState(() {
                                  _scanCompleted = false;
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Product Scanned: Strawberry Fruit Yogurt",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "• Found: E120 (Carmine / Cochineal) - Insect-derived red dye. Non-Halal in Hanafi Fiqh.\n• Found: Gelatin (Pork source) - Animal bones extraction. Haram.\n\nRecommendation: Avoid this product. Opt for Al-Marai organic yogurt or Danone Vegan Yogurt (Certified Halal).",
                          style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 2. Search & Category selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search Halal dining & groceries...",
                    hintStyle: const TextStyle(color: Color(0xFF5D6B82)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                    filled: true,
                    fillColor: const Color(0xFF131B2E).withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Categories row
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSel = _selectedCategory == cat;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF1E5B43) : const Color(0xFF131B2E).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.white.withOpacity(0.02),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFF8E9CB2),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 3. Outlet list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredOutlets.length,
                  itemBuilder: (context, idx) {
                    final item = filteredOutlets[idx];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.02)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['rating'],
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['cuisine'],
                            style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Color(0xFF8E9CB2), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${item['distance']} away",
                                    style: const TextStyle(color: Color(0xFF8E9CB2), fontSize: 11),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (item['statusColor'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['status'],
                                  style: TextStyle(
                                    color: item['statusColor'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Viewfinder Camera Scan Overlay Screen
          if (_isScanning) ...[
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "NURA HALAL SCANNER ACTIVE",
                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Align product ingredient text inside the viewport below.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF8E9CB2), fontSize: 12),
                      ),
                      const SizedBox(height: 30),

                      // Viewfinder frame
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              // Mock camera background text representing barcode
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "INGREDIENTS: MILK, FRUIT FLAVORS,",
                                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "CARMINE (E120), PORK GELATIN, SUGAR,",
                                      style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "PRESERVATIVES (E211, E202)...",
                                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),

                              // Scanning Green laser line
                              Positioned(
                                top: 250 * _laserPosition,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2ECC71),
                                    boxShadow: [
                                      BoxShadow(color: Color(0xFF2ECC71), blurRadius: 10, spreadRadius: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71))),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Analyzing ingredient molecular bonds...",
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
