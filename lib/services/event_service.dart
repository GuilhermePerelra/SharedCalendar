import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/event.dart';

class EventService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

Future<List<Event>> getEventsByMonth(DateTime month) async {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final currentUserId = _supabase.auth.currentUser!.id;

  final response = await _supabase.rpc('get_events_by_month', params: {
    'p_user_id': currentUserId,
    'p_start': start.toIso8601String(),
    'p_end': end.toIso8601String(),
  });

  return (response as List).map<Event>((json) => Event.fromJson(json)).toList();
}

  Future<Event> createEvent({
    required String title,
    required DateTime targetDate,
    String? description,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null || session.isExpired) {
      await _supabase.auth.refreshSession();
    }
     final currentSession = _supabase.auth.currentSession!;

    final response = await _supabase
        .rest
        .setAuth(currentSession.accessToken)
        .from('events')
        .insert({
          'title': title,
          'target_date': targetDate.toIso8601String(),
          'description': description,
          'created_by': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

  return Event.fromJson(response);
}

  Future<Event> updateEvent({
    required String id,
    required String title,
    required DateTime targetDate,
    String? description,
  }) async {
    final response = await _supabase
        .from('events')
        .update({
          'title': title,
          'target_date': targetDate.toIso8601String(),
          'description': description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return Event.fromJson(response);
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
  }
}
