import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../services/event_share_service.dart';
import '../widgets/event_list_item.dart';
import '../widgets/create_event_bottom_sheet.dart';
import '../widgets/edit_event_bottom_sheet.dart';
import '../themes/app_theme.dart';
import 'share_requests_page.dart';

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
  bool _fabOpen = false;
  int _pendingRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadPendingRequestsCount();
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final count = await _shareService.getPendingRequestsCount();
      if (mounted) {
        setState(() => _pendingRequestsCount = count);
      }
    } catch (e) {
      // Silenciosamente falha ao carregar contagem
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    final events = await _eventService.getEventsByMonth(_focusedMonth);
    setState(() {
      _eventsOfMonth = events;
      _loading = false;
    });
    await _loadPendingRequestsCount();
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
        title: Row(
          children: [
            Icon(Icons.share, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            const Text('Compartilhar calendário'),
          ],
        ),
        content: TextField(
          controller: loginController,
          decoration: InputDecoration(
            labelText: 'Login do usuário',
            hintText: 'usuario',
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
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
            icon: const Icon(Icons.send),
            label: const Text('Compartilhar'),
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
          title: Row(
            children: [
              Icon(Icons.group_remove, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              const Text('Remover compartilhamento'),
            ],
          ),
          content: sharedUsers.isEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum compartilhamento ativo',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sharedUsers.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppTheme.dividerColor),
                    itemBuilder: (context, index) {
                      final user = sharedUsers[index];
                      return ListTile(
                        title: Text(user.username),
                        subtitle: Text(user.login),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: AppTheme.errorColor,
                          ),
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

  Future<void> _showLogoutConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirm != null && confirm) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Meu Calendário'),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Solicitações',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShareRequestsPage(),
                    ),
                  );
                  // Recarrega a contagem ao voltar
                  await _loadPendingRequestsCount();
                },
              ),
              if (_pendingRequestsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_pendingRequestsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Tooltip(
            message: 'Sair',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutConfirmation,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando eventos...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEvents,
              color: AppTheme.accentColor,
              backgroundColor: AppTheme.cardColor,
              child: Column(
                children: [
                  // Calendário
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: TableCalendar<Event>(
                        locale: 'pt_BR',
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        focusedDay: _focusedMonth,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        eventLoader: _getEventsForDay,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
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
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: AppTheme.accentColor,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Color(0xFFE57373),
                          ),
                          defaultTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          outsideTextStyle: const TextStyle(color: Colors.grey),
                          markerDecoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 6,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.grey),
                          weekendStyle: TextStyle(color: Color(0xFFE57373)),
                        ),
                      ),
                    ),
                  ),
                  Divider(color: AppTheme.dividerColor, height: 1),
                  // Cabeçalho da lista
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eventos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDay != null
                              ? DateFormat(
                                  'd \'de\' MMMM \'de\' yyyy',
                                  'pt_BR',
                                ).format(_selectedDay!)
                              : 'Todos os eventos do mês',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.accentColor),
                        ),
                      ],
                    ),
                  ),
                  // Lista de eventos
                  Expanded(
                    child: _selectedDayEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum evento neste período',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _selectedDayEvents.length,
                            separatorBuilder: (_, __) => Divider(
                              color: AppTheme.dividerColor,
                              height: 1,
                            ),
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
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
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
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mini-FABs que aparecem quando _fabOpen = true
          AnimatedOpacity(
            opacity: _fabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'add_event',
                  backgroundColor: AppTheme.cardColor,
                  onPressed: () {
                    setState(() => _fabOpen = false);
                    final date = _selectedDay ?? DateTime.now();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => CreateEventBottomSheet(
                        selectedDate: date,
                        onEventCreated: _loadEvents,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.edit_calendar,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'share',
                  backgroundColor: AppTheme.cardColor,
                  onPressed: () {
                    setState(() => _fabOpen = false);
                    _showShareDialog();
                  },
                  child: const Icon(
                    Icons.group_add,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'remove_share',
                  backgroundColor: AppTheme.cardColor,
                  onPressed: () {
                    setState(() => _fabOpen = false);
                    _showRemoveShareDialog();
                  },
                  child: const Icon(
                    Icons.group_remove,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Botão toggle (único sempre visível)
          FloatingActionButton(
            heroTag: 'toggle',
            backgroundColor: AppTheme.primaryColor,
            onPressed: () => setState(() => _fabOpen = !_fabOpen),
            child: AnimatedRotation(
              turns: _fabOpen ? 0.240 : 0.0,  // 45° para parecer um "X"
              duration: const Duration(milliseconds: 250),
              child: Icon(_fabOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
