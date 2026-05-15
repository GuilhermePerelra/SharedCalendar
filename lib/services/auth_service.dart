import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../env/environment.dart';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  static Future<void> initialize() async {
    await supabase.Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future<supabase.AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<supabase.AuthResponse> cadastro(
    String email,
    String password,
    String username,
  ) async {
    final existingUser = await _supabase
        .from('users')
        .select('username')
        .eq('username', username)
        .maybeSingle();

    if (existingUser != null) {
      throw Exception('Nome de usuário já está em uso');
    }

    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  supabase.User? get currentUser => _supabase.auth.currentUser;

  Stream<supabase.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
