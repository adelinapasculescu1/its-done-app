import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class FriendHabitsScreen extends StatelessWidget {
  final AppUser friend;
  const FriendHabitsScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();

    return Scaffold(
      appBar: AppBar(title: Text("${friend.displayName}'s Habits Today")),
      body: StreamBuilder<List<Habit>>(
        stream: habitService.getHabitsByUserIdStream(friend.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final habits = snapshot.data ?? [];

          if (habits.isEmpty) {
            return const Center(child: Text('No habits found.'));
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final h = habits[index];
              return ListTile(
                title: Text(h.name),
                subtitle: Text('Streak: 🔥 ${h.streak}'),
              );
            },
          );
        },
      ),
    );
  }
}