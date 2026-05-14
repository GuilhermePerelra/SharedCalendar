import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_list_item.dart';
import '../widgets/create_event_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

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
              // ignore: use_build_context_synchronously
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
                                // futuramente: abrir tela de detalhe/edição
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
