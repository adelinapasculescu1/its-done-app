import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/bottom_menu_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Habit> _habits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habitStream = HabitService().getHabits();
    habitStream.listen((data) {
      if (mounted) {
        setState(() {
          _habits = data;
          _loading = false;
        });
      }
    });
  }

  List<Habit> _getScheduledHabitsForDay(DateTime day) {
    return _habits.where((habit) {
      if (habit.frequency == 'daily') return true;
      if (habit.frequency == 'weekly') {
        final startDate = habit.calendar.keys
            .map((d) => DateTime.tryParse(d))
            .whereType<DateTime>()
            .toList()
            .cast<DateTime>()
            .fold<DateTime?>(null, (a, b) => a == null || a.isAfter(b) ? b : a);

        return startDate != null &&
            startDate.weekday == day.weekday; // simplificare pentru demo
      }
      return false;
    }).toList();
  }

  Set<DateTime> _getMarkedDates() {
    final marked = <DateTime>{};
    for (final habit in _habits) {
      for (final dateStr in habit.calendar.keys) {
        if (habit.calendar[dateStr] == true) {
          final parts = dateStr.split('-').map(int.parse).toList();
          if (parts.length == 3) {
            marked.add(DateTime(parts[0], parts[1], parts[2]));
          }
        }
      }
    }
    return marked;
  }

  @override
  Widget build(BuildContext context) {
    final scheduledHabits = _getScheduledHabitsForDay(_selectedDay!);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final markedDates = _getMarkedDates();

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Calendar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade300,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (markedDates.any((d) => isSameDay(d, day))) {
                  return const Positioned(
                    bottom: 1,
                    child: Icon(Icons.check_circle, size: 14, color: Colors.green),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Completed Habits:'),
          Expanded(
            child: scheduledHabits.isEmpty
                ? const Center(child: Text("No habits scheduled for this day."))
                : ListView.builder(
              itemCount: scheduledHabits.length,
              itemBuilder: (context, index) {
                final habit = scheduledHabits[index];
                final isDone = habit.calendar[dateKey] == true;

                return ListTile(
                  leading: Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? Colors.green : Colors.grey,
                  ),
                  title: Text(habit.name),
                  subtitle: Text("Streak: 🔥 ${habit.streak}"),
                  trailing: isDone
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      HabitService().updateHabitCompletion(
                        habit.id,
                        _selectedDay!,
                        true,
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(currentIndex: 1),
    );
  }
}