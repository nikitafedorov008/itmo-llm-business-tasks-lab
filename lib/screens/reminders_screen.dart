import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await LocalStorageService.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _addReminder() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      final reminder = {
        'title': _titleController.text,
        'date': _selectedDate!.millisecondsSinceEpoch,
        'time': _selectedTime!.hour * 60 + _selectedTime!.minute,
        'id': DateTime.now().millisecondsSinceEpoch,
      };

      setState(() {
        _reminders.add(reminder);
      });

      await LocalStorageService.saveReminders(_reminders);
      _titleController.clear();
      _selectedDate = null;
      _selectedTime = null;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Напоминание добавлено!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteReminder(int id) async {
    setState(() {
      _reminders.removeWhere((reminder) => reminder['id'] == id);
    });

    await LocalStorageService.saveReminders(_reminders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddReminderDialog(context);
            },
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Text(
                'Нет установленных напоминаний',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final date = DateTime.fromMillisecondsSinceEpoch(reminder['date']);
    final time = TimeOfDay(
      hour: reminder['time'] ~/ 60,
      minute: reminder['time'] % 60,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          reminder['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Дата: ${DateFormat('dd.MM.yyyy').format(date)}, Время: ${time.format(context)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteReminder(reminder['id']);
          },
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить напоминание'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название напоминания',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'Дата: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}'
                            : 'Выберите дату',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: const Text('Выбрать'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTime != null
                            ? 'Время: ${_selectedTime!.format(context)}'
                            : 'Выберите время',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                      child: const Text('Выбрать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: _addReminder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}