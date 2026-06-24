import 'package:sharedcalendar/exceptions/supa_base_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/share_request.dart';

class SharedUser {
  final String userId;
  final String username;
  final String login;

  SharedUser({
    required this.userId,
    required this.username,
    required this.login,
  });

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    return SharedUser(
      userId: json['viewer_id'] as String,
      username: json['users']?['username'] as String? ?? 'Desconhecido',
      login: json['users']?['login'] as String? ?? '',
    );
  }
}

class EventShareService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Envia solicitação de compartilhamento
  Future<void> shareWith(String login) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;

      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('login', login)
          .single();

      final receiverId = userResponse['id'] as String;

      await _supabase.from('share_requests').insert({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
      });
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Retorna lista de viewers com quem o calendário está compartilhado
  Future<List<SharedUser>> getSharedUsers() async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('user_share')
          .select('viewer_id, users!fk_viewer(username, login)')
          .eq('owner_id', currentUserId);

      return response
          .map<SharedUser>((json) => SharedUser.fromJson(json))
          .toList();
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Remove compartilhamento com um usuário específico
  Future<void> removeShareByUser(String viewerId) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;

      await _supabase
          .from('user_share')
          .delete()
          .eq('owner_id', currentUserId)
          .eq('viewer_id', viewerId);
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Retorna solicitações pendentes para o usuário atual
  Future<List<ShareRequest>> getPendingRequests() async {
    try { 
      final currentUserId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('share_requests')
          .select(
            'id, sender_id, receiver_id, status, created_at, users!fk_sender(username, login)',
          )
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response
          .map<ShareRequest>((json) => ShareRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Aceita solicitação: insere em user_share e atualiza status
  Future<void> acceptRequest(int requestId, String senderId) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      await _supabase.from('user_share').insert({
        'owner_id': senderId,
        'viewer_id': currentUserId,
      });

      await _supabase.from('share_requests').delete().eq('id', requestId);
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Rejeita solicitação: apenas deleta o registro
  Future<void> rejectRequest(int requestId) async {
    try {
      await _supabase.from('share_requests').delete().eq('id', requestId);
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }

  // Contagem de solicitações pendentes para o badge
  Future<int> getPendingRequestsCount() async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('share_requests')
          .select('id')
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending');

      return response.length;
     } catch (e) {
      throw SupabaseErrorHandler.parse(e);
    }
  }
}
