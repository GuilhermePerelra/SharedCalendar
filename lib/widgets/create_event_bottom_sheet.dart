import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_category.dart';
import '../services/event_service.dart';
import '../themes/app_theme.dart';

class CreateEventBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onEventCreated;

  const CreateEventBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onEventCreated,
  });

  @override
  State<CreateEventBottomSheet> createState() => _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState extends State<CreateEventBottomSheet> {
  final EventService _eventService = EventService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDateTime;
  EventCategory? _selectedCategory;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: AppTheme.cardColor,
          ),
          dialogBackgroundColor: AppTheme.cardColor,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: AppTheme.cardColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Título obrigatório')));
      return;
    }

    setState(() => _loading = true);

    try {
      await _eventService.createEvent(
        title: _titleController.text.trim(),
        targetDate: _selectedDateTime,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onEventCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar evento: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo Evento',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Divider(color: AppTheme.dividerColor, thickness: 1),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Título *',
                prefixIcon: const Icon(Icons.event),
                hintText: 'Digite o título do evento',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Descrição',
                prefixIcon: const Icon(Icons.description),
                hintText: 'Digite a descrição (opcional)',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventCategory?>(
              value: _selectedCategory,
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _selectedCategory = value);
                    },
              decoration: InputDecoration(
                labelText: 'Categoria (opcional)',
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem<EventCategory?>(
                  value: null,
                  child: Text('Sem categoria'),
                ),

                ...EventCategory.values.map(
                  (category) => DropdownMenuItem<EventCategory?>(
                    value: category,
                    child: Text(category.displayName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loading ? null : _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDateTime),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loading ? null : _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppTheme.accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hora',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: const Icon(Icons.check),
              label: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Salvar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}
