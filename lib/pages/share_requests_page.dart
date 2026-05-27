import 'package:flutter/material.dart';
import 'package:sharedcalendar/services/event_service.dart';
import '../models/event.dart';
import '../models/share_request.dart';
import '../services/event_share_service.dart';
import '../themes/app_theme.dart';

class ShareRequestsPage extends StatefulWidget {
  final DateTime? focusedMonth;

  const ShareRequestsPage({super.key, this.focusedMonth});

  @override
  State<ShareRequestsPage> createState() => _ShareRequestsPageState();
}

class _ShareRequestsPageState extends State<ShareRequestsPage> {
  final EventShareService _shareService = EventShareService();
  final EventService _eventService = EventService();
  List<ShareRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final requests = await _shareService.getPendingRequests();
      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar solicitações: ${e.toString()}'),
        ),
      );
    }
  }


  Future<void> _accept(ShareRequest request) async {
    try {
      await _shareService.acceptRequest(request.id, request.senderId);

      // Recarrega eventos para o mês em foco e retorna a lista para o HomePage
      final events = await _eventService.getEventsByMonth(
        widget.focusedMonth ?? DateTime.now(),
      );
      if (!mounted) return;
      Navigator.pop(context, events);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  Future<void> _reject(ShareRequest request) async {
    try {
      await _shareService.rejectRequest(request.id);

      // Recarrega eventos para o mês em foco e retorna a lista para o HomePage
      final events = await _eventService.getEventsByMonth(
        widget.focusedMonth ?? DateTime.now(),
      );
      if (!mounted) return;
      Navigator.pop(context, events);
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
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.white),
            SizedBox(width: 8),
            Text('Solicitações pendentes'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              color: AppTheme.accentColor,
              backgroundColor: AppTheme.cardColor,
              child: _requests.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma solicitação pendente',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppTheme.dividerColor, height: 1),
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              request.senderUsername[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            request.senderUsername +
                                ' ' +
                                request.id.toString(),
                          ),
                          subtitle: Text(request.senderLogin),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green[400],
                                ),
                                tooltip: 'Aceitar',
                                onPressed: () => _accept(request),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: AppTheme.errorColor,
                                ),
                                tooltip: 'Recusar',
                                onPressed: () => _reject(request),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
