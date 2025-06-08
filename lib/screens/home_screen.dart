import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/auth_service.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';
import '../widgets/bottom_menu_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();
    final user = AuthService().currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Habits')),
      body: StreamBuilder<List<Habit>>(
        stream: habitService.getHabitsByUserIdStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data ?? [];

          if (habits.isEmpty) {
            return const Center(child: Text("You don't have any habits yet."));
          }

          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final completedToday = habit.calendar[today] ?? false;

              return Card(
                color: AppTheme.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(habit.name),
                  subtitle: Text('Streak: 🔥 ${habit.streak}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: completedToday,
                        onChanged: (checked) {
                          habitService.updateHabitCompletion(
                            habit.id,
                            DateTime.now(),
                            checked ?? false,
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushNamed(
                              context,
                              '/editHabit',
                              arguments: habit,
                            );
                          } else if (value == 'delete') {
                            habitService.deleteHabit(habit.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Habit deleted')),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/createHabit');
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit created successfully!')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomMenuBar(currentIndex: 0),
    );
  }
}