import 'package:flutter/material.dart';
import '../../screens/student_home_screen.dart';
import '../../services/auth_service.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF7C6CF6)),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const StudentHomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
