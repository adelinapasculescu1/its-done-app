import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HabitTimeFixer {
  final _habitRef = FirebaseFirestore.instance.collection('habits');

  Future<void> fixAllHabitTimes() async {
    final snapshot = await _habitRef.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rawTime = data['time'];

      if (rawTime is String) {
        try {
          final newTime = _normalizeTime(rawTime);
          await doc.reference.update({'time': newTime});
          print('Updated ${doc.id}: $rawTime → $newTime');
        } catch (e) {
          print('Failed to parse time for ${doc.id}: $rawTime');
        }
      }
    }

    print('Done fixing habit times.');
  }

  String _normalizeTime(String input) {
    // Detect AM/PM or 24h format
    try {
      DateTime parsed;
      if (input.contains('AM') || input.contains('PM')) {
        parsed = DateFormat.jm().parseStrict(input); // ex: 8:00 AM
      } else {
        parsed = DateFormat('HH:mm').parseStrict(input); // ex: 08:00
      }
      return DateFormat('HH:mm').format(parsed);
    } catch (e) {
      throw FormatException("Invalid time format: '$input'");
    }
  }
}