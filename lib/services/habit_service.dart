import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';

class HabitService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _habitRef =>
      _db.collection('users').doc(_uid).collection('habits');

  Future<void> createHabit(Habit habit) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final habitData = habit.toMap();
    habitData['userId'] = currentUser.uid;

    final docRef = await _habitRef.add(habitData);
    await docRef.update({'id': docRef.id});
  }

  Stream<List<Habit>> getHabitsByUserIdStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Habit.fromFirestore(doc))
        .toList());
  }

  Future<void> updateHabitCompletion(String habitId, DateTime date, bool completed) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    final doc = _habitRef.doc(habitId);
    final snapshot = await doc.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final calendar = Map<String, bool>.from(data['calendar'] ?? {});

    calendar[dateKey] = completed;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(currentDate);
      if (calendar[key] == true) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
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

  Future<List<Habit>> getHabitsByUserId(String userId) async {
    final querySnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .get();

    return querySnapshot.docs
        .map((doc) => Habit.fromFirestore(doc))
        .toList();
  }
}