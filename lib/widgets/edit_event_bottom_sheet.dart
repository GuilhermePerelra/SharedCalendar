import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import '../services/event_service.dart';
import '../themes/app_theme.dart';

class EditEventBottomSheet extends StatefulWidget {
  final Event event;
  final VoidCallback onEventUpdated;

  const EditEventBottomSheet({
    super.key,
    required this.event,
    required this.onEventUpdated,
  });

  @override
  State<EditEventBottomSheet> createState() => _EditEventBottomSheetState();
}

class _EditEventBottomSheetState extends State<EditEventBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDateTime;
  EventCategory? _selectedCategory;
  bool _isLoading = false;

  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );
    _selectedCategory = widget.event.category;
    _selectedDateTime = widget.event.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
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

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título do evento é obrigatório')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _eventService.updateEvent(
        id: widget.event.id,
        title: _titleController.text.trim(),
        targetDate: _selectedDateTime,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onEventUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == null || !confirm) return;

    setState(() => _isLoading = true);

    try {
      await _eventService.deleteEvent(widget.event.id);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onEventUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento excluído com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              'Editar Evento',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Divider(color: AppTheme.dividerColor, thickness: 1),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Título',
                prefixIcon: const Icon(Icons.event),
                hintText: 'Digite o título do evento',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              enabled: !_isLoading,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                prefixIcon: const Icon(Icons.description),
                hintText: 'Digite a descrição',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
           DropdownButtonFormField<EventCategory?>(
              value: _selectedCategory,
              onChanged: _isLoading
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
              onTap: _isLoading ? null : _selectDate,
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
              onTap: _isLoading ? null : _selectTime,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteEvent,
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveEvent,
                    icon: const Icon(Icons.check),
                    label: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
