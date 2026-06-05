import 'package:flutter/material.dart';

class NatureGalleryScreen extends StatelessWidget {
  const NatureGalleryScreen({super.key});

  // List of image asset paths. Add more images as needed.
  static const List<String> _imagePaths = [
    'assets/images/nature/nature_01_1780541742160.png',
    // Additional images can be added here.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nature Gallery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _imagePaths.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _imagePaths[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
