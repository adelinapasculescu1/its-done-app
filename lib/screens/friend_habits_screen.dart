import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class FriendHabitsScreen extends StatelessWidget {
  final AppUser friend;
  const FriendHabitsScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text("${friend.displayName}'s Habits Today")),
      body: FutureBuilder<List<Habit>>(
        future: habitService.getHabitsByUserId(friend.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data ?? [];

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final h = habits[index];
              return ListTile(
                title: Text(h.name),
                subtitle: Text("userId: ${h.userId}"),
              );
            },
          );
        },
      ),
    );
  }
}
