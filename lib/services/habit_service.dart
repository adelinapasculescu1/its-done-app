import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _habitRef =>
      _db.collection('users').doc(_uid).collection('habits');

  Future<void> createHabit(Habit habit) async {
    final docRef = await _habitRef.add(habit.toMap());
    await docRef.update({'id': docRef.id});
  }

  Stream<List<Habit>> getHabits() {
    return _habitRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> updateHabitCompletion(String habitId, DateTime date, bool completed) async {
    final dateKey = date.toIso8601String().split("T").first;

    final doc = _habitRef.doc(habitId);
    final snapshot = await doc.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final calendar = Map<String, bool>.from(data['calendar'] ?? {});
    final lastStreak = data['streak'] ?? 0;

    calendar[dateKey] = completed;

    int streak = 0;
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split("T").first;

    if (completed && calendar[yesterday] == true) {
      streak = lastStreak + 1;
    } else if (completed) {
      streak = 1;
    }

    await doc.update({
      'calendar': calendar,
      'streak': streak,
    });
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitRef.doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitRef.doc(habitId).delete();
  }
}