import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/event_share.dart';

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
      userId: json['user_id'].toString(),
      username: json['users']?['username'] as String? ?? 'Desconhecido',
      login: json['users']?['login'] as String? ?? '',
    );
  }
}

class EventShareService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  Future<List<EventShare>> getSharesByEvent(int eventId) async {
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

  Future<EventShare> shareEvent(int eventId, String userId) async {
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

  Future<void> removeShare(int eventId, String userId) async {
    await _supabase
        .from('event_share')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  Future<bool> isEventSharedWithUser(int eventId, String userId) async {
    final response = await _supabase
        .from('event_share')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .limit(1);

    return response.isNotEmpty;
  }

  // Compartilha todos os eventos do usuário logado com um novo usuário
  Future<void> shareWith(String login) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    // 1. Busca id do usuário pelo login
    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('login', login)
        .single();

    final userId = userResponse['id'] as String;

    // 2. Busca todos os event_id do usuário logado
    final eventsResponse = await _supabase
        .from('events')
        .select('id')
        .eq('created_by', currentUserId);

    final eventIds = List<int>.from(
      eventsResponse.map((e) => e['id'] as int),
    );

    // 3. Insere um registro em event_share para cada evento
    for (final eventId in eventIds) {
      await _supabase.from('event_share').insert({
        'event_id': eventId,
        'user_id': userId,
      });
    }
  }

  // Retorna lista de usuários com quem o calendário está compartilhado
  Future<List<SharedUser>> getSharedUsers() async {
    final currentUserId = _supabase.auth.currentUser!.id;

    // 1. Busca todos os event_id do usuário logado
    final eventsResponse = await _supabase
        .from('events')
        .select('id')
        .eq('created_by', currentUserId);

    final eventIds = List<int>.from(
      eventsResponse.map((e) => e['id'] as int),
    );

    if (eventIds.isEmpty) return [];

    // 2. Busca registros de event_share com join para trazer username
    final sharesResponse = await _supabase
        .from('event_share')
        .select('user_id, users!inner(username, login)')
        .inFilter('event_id', eventIds);

    // 3. Deduplicar por user_id
    final seenUserIds = <String>{};
    final sharedUsers = <SharedUser>[];

    for (final share in sharesResponse) {
      final userId = share['user_id'] as String;
      if (!seenUserIds.contains(userId)) {
        seenUserIds.add(userId);
        sharedUsers.add(SharedUser.fromJson(share));
      }
    }

    return sharedUsers;
  }

  // Remove todos os compartilhamentos de um usuário específico
  Future<void> removeShareByUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    // 1. Busca todos os event_id do usuário logado
    final eventsResponse = await _supabase
        .from('events')
        .select('id')
        .eq('created_by', currentUserId);

    final eventIds = List<int>.from(
      eventsResponse.map((e) => e['id'] as int),
    );

    // 2. Deleta registros onde user_id = userId e event_id pertence ao usuário logado
    await _supabase
        .from('event_share')
        .delete()
        .eq('user_id', userId)
        .inFilter('event_id', eventIds);
  }
}