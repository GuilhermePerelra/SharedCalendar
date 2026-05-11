import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';

class UserService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Buscar usuário por ID
  Future<User?> getUserById(String id) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', id)
        .single();

    return User.fromJson(response);
  }

  // Buscar usuário por username
  Future<User?> getUserByUsername(String username) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    return response != null ? User.fromJson(response) : null;
  }

  // Atualizar usuário
  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from('users')
        .update(updates)
        .eq('id', id);
  }

  // Deletar usuário
  Future<void> deleteUser(String id) async {
    await _supabase
        .from('users')
        .delete()
        .eq('id', id);
  }
}