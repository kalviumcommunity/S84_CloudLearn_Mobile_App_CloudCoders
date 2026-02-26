import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../../services/auth_service.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  bool _visible = false;

  String? _learningGoal;
  String? _experienceLevel;

  final List<String> _learningGoals = const [
    'Cloud Fundamentals',
    'Firebase App Development',
    'Cloud Security',
    'DevOps on Cloud',
  ];

  final List<String> _experienceLevels = const [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }

    final email = value.trim();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create a password.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  double get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) {
      return 0;
    }

    var score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score / 4;
  }

  String get _strengthText {
    final strength = _passwordStrength;
    if (strength >= 0.75) {
      return 'Strong';
    }
    if (strength >= 0.5) {
      return 'Medium';
    }
    if (strength > 0) {
      return 'Weak';
    }
    return 'No password';
  }

  Color get _strengthColor {
    final strength = _passwordStrength;
    if (strength >= 0.75) {
      return const Color(0xFF12B76A);
    }
    if (strength >= 0.5) {
      return const Color(0xFFF79009);
    }
    return const Color(0xFFD92D20);
  }

  Future<void> _submit() async {
    final validForm = _formKey.currentState!.validate();
    // Validate dropdowns too
    if (_learningGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a learning goal.')),
      );
      return;
    }
    if (_experienceLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your experience level.')),
      );
      return;
    }

    if (!validForm) {
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    width: maxWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2F1F64),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                validator: _validateName,
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                label: 'Create Password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: _validatePassword,
                                onChanged: (_) => setState(() {}),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: strength == 0 ? 0.02 : strength,
                                  minHeight: 7,
                                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                  backgroundColor: const Color(0xFFECEAF2),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Password strength: $_strengthText',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _strengthColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: _validateConfirmPassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: _learningGoal,
                                decoration: _dropdownDecoration('Learning Goal'),
                                items: _learningGoals
                                    .map(
                                      (goal) => DropdownMenuItem<String>(
                                        value: goal,
                                        child: Text(goal),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _learningGoal = value);
                                },
                                validator: (value) =>
                                    value == null ? 'Please select a learning goal.' : null,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: _experienceLevel,
                                decoration: _dropdownDecoration('Experience Level'),
                                items: _experienceLevels
                                    .map(
                                      (level) => DropdownMenuItem<String>(
                                        value: level,
                                        child: Text(level),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _experienceLevel = value);
                                },
                                validator: (value) => value == null
                                    ? 'Please select your experience level.'
                                    : null,
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: 'Create Account',
                                loading: _loading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    _fadeRoute(const LoginScreen()),
                                  );
                                },
                                child: const Text('Already have an account? Log In'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7A5AF8), width: 1.4),
      ),
    );
  }
}

PageRouteBuilder<void> _fadeRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: animation,
      child: page,
    ),
    transitionDuration: const Duration(milliseconds: 320),
  );
}
