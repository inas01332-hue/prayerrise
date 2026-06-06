import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Sign up with email & password
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _client.auth.signUp(email: email, password: password);
    return response;
  }

  // Sign in with email & password
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;
}
