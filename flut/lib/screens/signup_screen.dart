import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/fade_in_page.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<String> _learningGoals = const [
    'Cloud Basics',
    'AWS',
    'Azure',
    'DevOps',
    'Kubernetes',
  ];
  final List<String> _experienceLevels = const [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  String? _selectedLearningGoal;
  String? _selectedExperience;
  bool _isSubmitting = false;
  bool _autoValidate = false;

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _autoValidate = true;
    });

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (_selectedExperience == null) {
      setState(() {
        _autoValidate = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  double get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return score / 4;
  }

  String get _passwordStrengthLabel {
    final strength = _passwordStrength;
    if (strength >= 0.75) return 'Strong password';
    if (strength >= 0.5) return 'Medium password';
    if (strength > 0) return 'Weak password';
    return 'Use at least 8 characters';
  }

  PageRouteBuilder _animatedRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildDropdownCard({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF1ECFF),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6D5DF6), width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F1FF), Color(0xFFEDE7FF), Color(0xFFE7DDFF)],
          ),
        ),
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FadeInPage(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autoValidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CircleAvatar(
                                  radius: 21,
                                  backgroundColor: Colors.white.withValues(alpha: 0.76),
                                  child: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                    iconSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Create Account',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2F254E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign up and start learning cloud concepts with Firebase.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF5F587C).withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.46),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6D5DF6).withValues(alpha: 0.12),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomTextField(
                                      controller: _nameController,
                                      labelText: 'Full Name',
                                      hintText: 'How should we address you?',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _emailController,
                                      labelText: 'Email Address',
                                      hintText: 'Your learning account email',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        final email = value?.trim() ?? '';
                                        if (email.isEmpty) {
                                          return 'Please enter your email address';
                                        }
                                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(email)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _passwordController,
                                      labelText: 'Create Password',
                                      hintText: 'Minimum 8 characters',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        final password = value ?? '';
                                        if (password.isEmpty) {
                                          return 'Please create a password';
                                        }
                                        if (password.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        minHeight: 8,
                                        value: _passwordStrength,
                                        backgroundColor:
                                            const Color(0xFFD7D0F5).withValues(alpha: 0.5),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _passwordStrength >= 0.75
                                              ? Colors.green
                                              : _passwordStrength >= 0.5
                                                  ? Colors.orange
                                                  : Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _passwordStrengthLabel,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF5F587C),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _confirmPasswordController,
                                      labelText: 'Confirm Password',
                                      hintText: 'Re-enter your password',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (value) {
                                        final confirmPassword = value ?? '';
                                        if (confirmPassword.isEmpty) {
                                          return 'Please re-enter your password';
                                        }
                                        if (confirmPassword != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDropdownCard(
                                      label: 'Learning Goal',
                                      hint: 'What do you want to learn?',
                                      icon: Icons.track_changes_outlined,
                                      value: _selectedLearningGoal,
                                      options: _learningGoals,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedLearningGoal = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDropdownCard(
                                      label: 'Experience Level',
                                      hint: 'Select your experience level',
                                      icon: Icons.school_outlined,
                                      value: _selectedExperience,
                                      options: _experienceLevels,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select your experience level';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedExperience = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    PrimaryButton(
                                      label: 'Create Account',
                                      isLoading: _isSubmitting,
                                      onPressed: _signup,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5F587C),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        _animatedRoute(const LoginScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Log In',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF6D5DF6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                                ],
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
          ),
        ),
      ),
    );
  }
}
