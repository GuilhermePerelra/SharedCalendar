import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../services/event_share_service.dart';
import '../widgets/event_list_item.dart';
import '../widgets/create_event_bottom_sheet.dart';
import '../widgets/edit_event_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  final EventShareService _shareService = EventShareService();

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _eventsOfMonth = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    final events = await _eventService.getEventsByMonth(_focusedMonth);
    setState(() {
      _eventsOfMonth = events;
      _loading = false;
    });
  }

  // Retorna eventos de um dia específico para o TableCalendar
  List<Event> _getEventsForDay(DateTime day) {
    return _eventsOfMonth.where((event) {
      return isSameDay(event.targetDate, day);
    }).toList();
  }

  // Retorna eventos do dia selecionado para a listagem abaixo do calendário
  List<Event> get _selectedDayEvents {
    if (_selectedDay == null) return _eventsOfMonth;
    return _getEventsForDay(_selectedDay!);
  }

  Future<void> _showShareDialog() async {
    final loginController = TextEditingController();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar calendário'),
        content: TextField(
          controller: loginController,
          decoration: const InputDecoration(
            labelText: 'Login do usuário',
            hintText: 'usuario',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final login = loginController.text.trim();
              if (login.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login obrigatório')),
                );
                return;
              }

              try {
                await _shareService.shareWith(login);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calendário compartilhado com sucesso'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: ${e.toString()}')),
                );
              }
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveShareDialog() async {
    try {
      final sharedUsers = await _shareService.getSharedUsers();

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remover compartilhamento'),
          content: sharedUsers.isEmpty
              ? const Text('Nenhum compartilhamento ativo')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sharedUsers.length,
                    itemBuilder: (context, index) {
                      final user = sharedUsers[index];
                      return ListTile(
                        title: Text(user.username),
                        subtitle: Text(user.login),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () async {
                            try {
                              await _shareService.removeShareByUser(
                                user.userId,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Compartilhamento removido com sucesso',
                                  ),
                                ),
                              );
                              _showRemoveShareDialog();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro: ${e.toString()}'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Calendário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Event>(
                  locale: 'pt_BR',
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedMonth,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      // Clicou no mesmo dia selecionado → desmarca e mostra todos do mês
                      if (isSameDay(_selectedDay, selectedDay)) {
                        _selectedDay = null;
                      } else {
                        _selectedDay = selectedDay;
                      }
                      _focusedMonth = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedMonth = focusedDay;
                    _loadEvents();
                  },
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _selectedDayEvents.isEmpty
                      ? const Center(child: Text('Nenhum evento neste período'))
                      : ListView.builder(
                          itemCount: _selectedDayEvents.length,
                          itemBuilder: (context, index) {
                            final event = _selectedDayEvents[index];
                            return EventListItem(
                              event: event,
                              onTap: () {
                                final currentUserId =
                                    _authService.currentUser?.id;
                                if (currentUserId != null &&
                                    event.createdBy == currentUserId) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => EditEventBottomSheet(
                                      event: event,
                                      onEventUpdated: _loadEvents,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'remove_share',
            onPressed: _showRemoveShareDialog,
            child: const Icon(Icons.group_remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            heroTag: 'share',
            onPressed: _showShareDialog,
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              final date = _selectedDay ?? DateTime.now();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CreateEventBottomSheet(
                  selectedDate: date,
                  onEventCreated: _loadEvents,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
