import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_menu_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: const Center(child: Text("You're logged in!")),
      bottomNavigationBar: const BottomMenuBar(currentIndex: 0),
    );
  }
}