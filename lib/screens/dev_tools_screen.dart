import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'realtime_screen.dart';

class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  Future<void> _testSupabase(BuildContext context) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('test').select().execute();
      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supabase test successful: \\${response.data}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supabase error: \\${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: \\$e')),
      );
    }
  }

  Future<void> _uploadDummyFile(BuildContext context) async {
    final supabase = Supabase.instance.client;
    try {
      // Create a simple text file in memory
      final bytes = Uint8List.fromList('Hello from Flutter'.codeUnits);
      final filePath = 'dummy/hello.txt';
      final response = await supabase.storage.from('public').uploadBinary(filePath, bytes);
      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded dummy file to $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: \\${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: \\$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _testSupabase(context),
              child: const Text('Test Supabase Connection'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
              child: const Text('Authentication Flow'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealtimeScreen())),
              child: const Text('Realtime Listener'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _uploadDummyFile(context),
              child: const Text('Upload Dummy File to Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
