import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/attendance_service.dart';
import '../themes/app_theme.dart';
import 'attendance_bottom_sheet.dart';

class EventListItem extends StatefulWidget {
  final Event event;
  final bool isOwner;
  final VoidCallback? onTap;

  const EventListItem({
    super.key,
    required this.event,
    required this.isOwner,
    this.onTap,
  });

  @override
  State<EventListItem> createState() => _EventListItemState();
}

class _EventListItemState extends State<EventListItem> {
  final AttendanceService _attendanceService = AttendanceService();
  String _myStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final eventId = int.tryParse(widget.event.id) ?? 0;
      final status = await _attendanceService.getMyStatus(eventId);
      if (mounted) setState(() => _myStatus = status);
    } catch (_) {}
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de dono
              if (widget.isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.star,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.event.description != null &&
                        widget.event.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.event.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (widget.event.createdByUsername != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Por: ${widget.event.createdByUsername}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(widget.event.targetDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentColor,
                    ),
                  ),
                  Text(
                    '${widget.event.targetDate.hour.toString().padLeft(2, '0')}:${widget.event.targetDate.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _statusIcon(_myStatus),
                  color: _statusColor(_myStatus),
                  size: 22,
                ),
                tooltip: 'Confirmar presença',
                onPressed: () async {
                  final eventId = int.tryParse(widget.event.id) ?? 0;
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (_) => AttendanceBottomSheet(
                      eventId: eventId,
                      isOwner: widget.isOwner,
                    ),
                  );
                  _loadStatus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
