import 'package:sharedcalendar/exceptions/supa_base_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';

class UserService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  Future<User?> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      return response != null ? User.fromJson(response) : null;
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('users').update(updates).eq('id', id);
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }
}
