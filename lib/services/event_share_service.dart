import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/event_share.dart';

class EventShareService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  Future<List<EventShare>> getSharesByEvent(String eventId) async {
    final response = await _supabase
        .from('event_share')
        .select()
        .eq('event_id', eventId);

    return response
        .map<EventShare>((json) => EventShare.fromJson(json))
        .toList();
  }

  Future<List<EventShare>> getSharesByUser(String userId) async {
    final response = await _supabase
        .from('event_share')
        .select()
        .eq('user_id', userId);

    return response
        .map<EventShare>((json) => EventShare.fromJson(json))
        .toList();
  }

  Future<EventShare> shareEvent(String eventId, String userId) async {
    final response = await _supabase
        .from('event_share')
        .insert({
          'event_id': eventId,
          'user_id': userId,
        })
        .select()
        .single();

    return EventShare.fromJson(response);
  }

  Future<void> removeShare(String eventId, String userId) async {
    await _supabase
        .from('event_share')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  Future<bool> isEventSharedWithUser(String eventId, String userId) async {
    final response = await _supabase
        .from('event_share')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .limit(1);

    return response.isNotEmpty;
  }
}