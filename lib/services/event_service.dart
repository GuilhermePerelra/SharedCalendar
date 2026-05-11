import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/event.dart';

class EventService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Buscar todos os eventos
  Future<List<Event>> getAllEvents() async {
    final response = await _supabase
        .from('events')
        .select();

    return response.map<Event>((json) => Event.fromJson(json)).toList();
  }

  // Buscar eventos por usuário criador
  Future<List<Event>> getEventsByCreator(String userId) async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('created_by', userId);

    return response.map<Event>((json) => Event.fromJson(json)).toList();
  }

  // Buscar evento por ID
  Future<Event?> getEventById(String id) async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('id', id)
        .single();

    return Event.fromJson(response);
  }

  // Criar evento
  Future<Event> createEvent(Event event) async {
    final response = await _supabase
        .from('events')
        .insert(event.toJson())
        .select()
        .single();

    return Event.fromJson(response);
  }

  // Atualizar evento
  Future<void> updateEvent(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from('events')
        .update(updates)
        .eq('id', id);
  }

  // Deletar evento
  Future<void> deleteEvent(String id) async {
    await _supabase
        .from('events')
        .delete()
        .eq('id', id);
  }
}