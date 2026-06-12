import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../models/attendance_status.dart';
import '../themes/app_theme.dart';

class AttendanceBottomSheet extends StatefulWidget {
  final int eventId;
  final bool isOwner;

  const AttendanceBottomSheet({
    super.key,
    required this.eventId,
    required this.isOwner,
  });

  @override
  State<AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  final AttendanceService _attendanceService = AttendanceService();

  String _myStatus = 'pending';
  List<AttendanceStatus> _attendees = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final myStatus = await _attendanceService.getMyStatus(widget.eventId);
      final attendees = await _attendanceService.getAttendees(widget.eventId);

      setState(() {
        _myStatus = myStatus;
        _attendees = attendees;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar presença: ${e.toString()}')),
      );
    }
  }

  Future<void> _setStatus(String status) async {
    setState(() => _saving = true);
    try {
      await _attendanceService.setStatus(widget.eventId, status);
      setState(() {
        _myStatus = status;
        _saving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusLabel(status) + ' com sucesso')),
      );
      final attendees = await _attendanceService.getAttendees(widget.eventId);
      setState(() => _attendees = attendees);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Presença confirmada';
      case 'declined':
        return 'Presença recusada';
      default:
        return 'Pendente';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'declined':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_vote, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Text(
                'Confirmação de presença',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Botões de status
            Text('Sua presença', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _saving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    children: [
                      _StatusButton(
                        label: 'Confirmar',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        selected: _myStatus == 'confirmed',
                        onTap: () => _setStatus('confirmed'),
                      ),
                      const SizedBox(width: 8),
                      _StatusButton(
                        label: 'Recusar',
                        icon: Icons.cancel,
                        color: AppTheme.errorColor,
                        selected: _myStatus == 'declined',
                        onTap: () => _setStatus('declined'),
                      ),
                      const SizedBox(width: 8),
                      _StatusButton(
                        label: 'Pendente',
                        icon: Icons.help_outline,
                        color: Colors.grey,
                        selected: _myStatus == 'pending',
                        onTap: () => _setStatus('pending'),
                      ),
                    ],
                  ),
            // --Lista de convidados (apenas para o dono)--
            // regra removida, mas pode ser reimplementada para mostrar somente ao dono
            if (true) ...[
              const SizedBox(height: 24),
              Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 8),
              Text(
                'Respostas dos convidados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (_attendees.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Nenhuma resposta ainda',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attendees.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppTheme.dividerColor, height: 1),
                  itemBuilder: (context, index) {
                    final attendee = _attendees[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          attendee.username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(attendee.username),
                      subtitle: Text(attendee.login),
                      trailing: Icon(
                        _statusIcon(attendee.status),
                        color: _statusColor(attendee.status),
                      ),
                    );
                  },
                ),
            ],
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
              color: selected ? color : Colors.grey.withOpacity(0.3),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? color : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
