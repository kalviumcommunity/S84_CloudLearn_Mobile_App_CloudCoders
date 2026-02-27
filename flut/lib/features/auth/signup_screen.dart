import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'widgets/auth_shell.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  bool _visible = false;
  late final AnimationController _entranceController;

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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _passwordController.addListener(_onPasswordInputsChanged);
    _confirmPasswordController.addListener(_onPasswordInputsChanged);

    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() => _visible = true);
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordInputsChanged);
    _confirmPasswordController.removeListener(_onPasswordInputsChanged);
    _entranceController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordInputsChanged() {
    if (mounted) {
      setState(() {});
    }
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

  bool get _passwordsMatch {
    final confirm = _confirmPasswordController.text;
    return confirm.isNotEmpty && confirm == _passwordController.text;
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
    final hasGoal = _learningGoal != null;
    final hasLevel = _experienceLevel != null;

    if (!validForm || !hasGoal || !hasLevel) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;

    return AuthShell(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 460),
          curve: Curves.easeOutCubic,
          offset: _visible ? Offset.zero : const Offset(0, 0.03),
          child: GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF291451),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Build your personalized cloud learning path.',
                    style: TextStyle(
                      color: const Color(0xFF291451).withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _staggered(
                    index: 0,
                    child: CustomTextField(
                      label: 'Full Name',
                      controller: _fullNameController,
                      validator: _validateName,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    index: 1,
                    child: CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    index: 2,
                    child: CustomTextField(
                      label: 'Create Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
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
                  ),
                  const SizedBox(height: 10),
                  _staggered(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: strength == 0 ? 0.03 : strength,
                          ),
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                backgroundColor: const Color(0xFFECEAF2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Password strength: $_strengthText',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _strengthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    index: 4,
                    child: CustomTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutBack,
                            scale: _passwordsMatch ? 1 : 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: _passwordsMatch ? 1 : 0,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: Color(0xFF12B76A),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    index: 5,
                    child: DropdownButtonFormField<String>(
                      initialValue: _learningGoal,
                      decoration: _dropdownDecoration('Learning Goal'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5F38CC)),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    index: 6,
                    child: DropdownButtonFormField<String>(
                      initialValue: _experienceLevel,
                      decoration: _dropdownDecoration('Experience Level'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5F38CC)),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      validator: (value) =>
                          value == null ? 'Please select your experience level.' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _staggered(
                    index: 7,
                    child: PrimaryButton(
                      label: 'Create Account',
                      loading: _loading,
                      elevated: true,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        buildAuthRoute(const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Already have an account? Log In',
                      style: TextStyle(
                        color: const Color(0xFF3D2082).withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _staggered({required int index, required Widget child}) {
    final start = 0.06 + (index * 0.08);
    final end = (start + 0.24).clamp(0, 1);
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end.toDouble(), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.84),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFF8D57FF), width: 1.4),
      ),
    );
  }
}
