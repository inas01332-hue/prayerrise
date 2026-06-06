import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _auth = AuthService();
  bool _isLoading = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final res = await _auth.signUp(_emailCtrl.text, _pwdCtrl.text);
      _showMessage('Signed up! Check your email for confirmation.');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final res = await _auth.signIn(_emailCtrl.text, _pwdCtrl.text);
      _showMessage('Signed in as ${res.user?.email ?? 'unknown'}');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    await _auth.signOut();
    _showMessage('Signed out');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pwdCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Column(
                children: [
                  ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
                  ElevatedButton(onPressed: _signIn, child: const Text('Sign In')),
                  ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
