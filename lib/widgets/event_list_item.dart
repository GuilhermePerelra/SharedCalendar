import 'package:flutter/material.dart';
import '../models/event.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  // futuramente: adicionar onShare, isShared

  const EventListItem({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: event.description != null
            ? Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          '${event.targetDate.hour.toString().padLeft(2, '0')}:${event.targetDate.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
