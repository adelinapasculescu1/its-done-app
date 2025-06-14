import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final String frequency;
  final String time;
  final int streak;
  final Map<String, bool> calendar;
  final String userId;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.time,
    this.streak = 0,
    this.calendar = const {},
    required this.userId,
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      name: data['name'] ?? '',
      frequency: data['frequency'] ?? 'daily',
      time: data['time'] ?? '08:00',
      streak: data['streak'] ?? 0,
      calendar: Map<String, bool>.from(data['calendar'] ?? {}),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'frequency': frequency,
      'time': time,
      'streak': streak,
      'calendar': calendar,
      'userId': userId,
    };
  }
}