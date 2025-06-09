import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _frequency = 'daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  late Habit _habit;

  @override
  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _nameController.text = _habit.name;
    _frequency = _habit.frequency;

    try {
      final time = _habit.time;

      if (time.contains('AM') || time.contains('PM')) {
        final parsed = DateFormat.jm().parseStrict(time);
        _selectedTime = TimeOfDay.fromDateTime(parsed);
      } else {
        final parts = time.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      debugPrint("Failed to parse time '${_habit.time}': $e");
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedHabit = Habit(
        id: _habit.id,
        name: _nameController.text.trim(),
        frequency: _frequency,
        time: "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
        calendar: _habit.calendar,
        streak: _habit.streak,
        userId: _habit.userId,
      );

      await HabitService().updateHabit(updatedHabit);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit updated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Habit name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _frequency = val);
                },
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("Reminder time: ${_selectedTime.format(context)}"),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Pick Time'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}