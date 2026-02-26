import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/auth_choice_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7A5AF8),
      ),
    );

    return MaterialApp(
      title: 'CloudLearn',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: const CardThemeData(
          elevation: 10,
          shadowColor: Color(0x1F2F1F64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(26)),
          ),
        ),
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      initialRoute: '/',
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF4ECFF),
                Color(0xFFE9DBFF),
                Color(0xFFD8C5FF),
              ],
            ),
          ),
          child: child,
        );
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
    );
  }
}
