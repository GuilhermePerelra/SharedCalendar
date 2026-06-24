import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AttendanceVisibilityToggle extends StatelessWidget {
  final String visibility;
  final ValueChanged<String> onChanged;

  const AttendanceVisibilityToggle({
    super.key,
    required this.visibility,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivate = visibility == 'private';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPrivate ? Icons.lock : Icons.lock_open,
          size: 16,
          color: isPrivate ? AppTheme.errorColor : AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          isPrivate ? 'Apenas criador vê' : 'Visível a todos',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Switch(
          value: isPrivate,
          onChanged: (val) => onChanged(val ? 'private' : 'public'),
          activeColor: AppTheme.errorColor,
        ),
      ],
    );
  }
}
