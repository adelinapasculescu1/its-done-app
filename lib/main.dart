import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:its_done/screens/admin_screen.dart';
import 'package:its_done/screens/create_habit_screen.dart';
import 'package:its_done/screens/edit_habit_screen.dart';
import 'package:its_done/services/notification_service.dart';
import 'models/habit.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      onGenerateRoute: (settings) {
        if (settings.name == '/editHabit') {
          final habit = settings.arguments as Habit;
          return MaterialPageRoute(
            builder: (_) => EditHabitScreen(habit: habit),
          );
        }

        if (settings.name == '/createHabit') {
          return MaterialPageRoute(builder: (_) => const CreateHabitScreen());
        }

        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        if (settings.name == '/admin') {
          return MaterialPageRoute(builder: (_) => const AdminScreen());
        }

        return null;
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}