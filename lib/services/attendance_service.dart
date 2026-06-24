import 'package:sharedcalendar/exceptions/supa_base_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/attendance_status.dart';

class AttendanceService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  Future<AttendanceStatus?> getMyAttendance(int eventId) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('event_attendance')
          .select(
            'id, event_id, user_id, status, visibility, updated_at, '
            'users!fk_attendance_user(username, login)',
          )
          .eq('event_id', eventId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      return response != null ? AttendanceStatus.fromJson(response) : null;
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  Future<String> getMyStatus(int eventId) async {
    final attendance = await getMyAttendance(eventId);
    return attendance?.status ?? 'pending';
  }

  Future<void> setStatus(
    int eventId,
    String status, {
    String visibility = 'public',
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      await _supabase.from('event_attendance').upsert(
        {
          'event_id': eventId,
          'user_id': currentUserId,
          'status': status,
          'visibility': visibility,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'event_id, user_id',
      );
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  Future<List<AttendanceStatus>> getAttendees(
    int eventId, {
    required String createdBy,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      final isCreator = currentUserId == createdBy;

      final response = await _supabase
          .from('event_attendance')
          .select(
            'id, event_id, user_id, status, visibility, updated_at, '
            'users!fk_attendance_user(username, login)',
          )
          .eq('event_id', eventId)
          .neq('status', 'pending')
          .order('updated_at', ascending: false);

      final all = response
          .map<AttendanceStatus>((json) => AttendanceStatus.fromJson(json))
          .toList();

      if (isCreator) return all;

      return all
          .where((a) => a.visibility == 'public' || a.userId == currentUserId)
          .toList();
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }
}
