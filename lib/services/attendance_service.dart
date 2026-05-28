import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/attendance_status.dart';

class AttendanceService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Retorna o status do usuário logado para um evento
  // Retorna 'pending' se não houver registro
  Future<String> getMyStatus(int eventId) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('event_attendance')
        .select('status')
        .eq('event_id', eventId)
        .eq('user_id', currentUserId)
        .maybeSingle();

    return response?['status'] as String? ?? 'pending';
  }

  // Faz upsert do status do usuário logado para um evento
  Future<void> setStatus(int eventId, String status) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    await _supabase.from('event_attendance').upsert({
      'event_id': eventId,
      'user_id': currentUserId,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'event_id, user_id');
  }

  // Retorna lista de todos que responderam ao evento (para o dono ver)
  Future<List<AttendanceStatus>> getAttendees(int eventId) async {
    final response = await _supabase
        .from('event_attendance')
        .select(
          'id, event_id, user_id, status, updated_at, users!fk_attendance_user(username, login)',
        )
        .eq('event_id', eventId)
        .neq('status', 'pending')
        .order('updated_at', ascending: false);

    return response
        .map<AttendanceStatus>((json) => AttendanceStatus.fromJson(json))
        .toList();
  }
}
