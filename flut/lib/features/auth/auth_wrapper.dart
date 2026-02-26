import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';
import '../../services/auth_service.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // While waiting for auth state, shows loading or splash if desired.
        // However, usually connection is fast.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, go to Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise go to Welcome
        return const WelcomeScreen();
      },
    );
  }
}
