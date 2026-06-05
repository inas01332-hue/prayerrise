import 'package:flutter/material.dart';

class AllahNamesScreen extends StatelessWidget {
  const AllahNamesScreen({super.key});

  // A shortened sample list; can be expanded to all 99 names.
  static const List<String> _names = [
    "Ar-Rahman", "Ar-Rahim", "Al-Malik", "Al-Quddus", "As-Salam",
    "Al-Mu'min", "Al-Muhaymin", "Al-Aziz", "Al-Jabbar", "Al-Mutakabbir",
    // ... add remaining names as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _names.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF2ECC71)),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _names[index],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}
