import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/notification_service.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _frequency = 'daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

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
      final timeFormatted =
      _selectedTime.format(context);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final habit = Habit(
        id: '',
        name: _nameController.text.trim(),
        frequency: _frequency,
        time: timeFormatted,
        userId: currentUser.uid,
      );

      await HabitService().createHabit(habit);

      try {
        await NotificationService.scheduleHabitNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: habit.name,
          time: _selectedTime,
        );
      } catch (e) {
        debugPrint('Failed to schedule notification: $e');
      }

      if (mounted) {
        Navigator.pop(context, true); // revino la HomeScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Habit')),
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
                child: const Text('Create Habit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}