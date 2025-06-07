import 'package:flutter/material.dart';
import '../utils/fix_habit_times.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loading = false;
  String? _status;

  Future<void> _runFix() async {
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      await HabitTimeFixer().fixAllHabitTimes();
      setState(() {
        _status = 'Habit times normalized successfully.';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _runFix,
              child: const Text('Normalize Habit Times'),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_status != null) Text(_status!),
          ],
        ),
      ),
    );
  }
}