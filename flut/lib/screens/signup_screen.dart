import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
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

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  late final AnimationController _introController;

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  String? _learningGoal;
  String? _experienceLevel;

  static const List<String> _goalOptions = [
    'Build cloud-ready apps',
    'Prepare for certifications',
    'Improve Firebase skills',
    'Learn cloud architecture',
  ];

  static const List<String> _experienceOptions = [
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

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Route<void> _fadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _staggeredItem({required int index, required Widget child}) {
    final start = 0.08 * index;
    final end = (start + 0.38).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    final offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offset, child: child),
    );
  }

  double get _passwordStrength {
    final value = _passwordController.text;
    if (value.isEmpty) return 0;

    double score = 0;
    if (value.length >= 8) score += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.3;
    return score.clamp(0, 1);
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.4) return const Color(0xFFE11D48);
    if (_passwordStrength < 0.75) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get _strengthLabel {
    if (_passwordController.text.isEmpty) return 'Use 8+ chars, upper, number, symbol';
    if (_passwordStrength < 0.4) return 'Weak password';
    if (_passwordStrength < 0.75) return 'Medium password';
    return 'Strong password';
  }

  bool get _passwordsMatch {
    return _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please confirm password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome ${user.email}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0E9FF),
              Color(0xFF5B2E9C),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2A1E0F40),
                            blurRadius: 42,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _staggeredItem(
                              index: 0,
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2B1B4D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _staggeredItem(
                              index: 1,
                              child: CustomTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                focusNode: _nameFocus,
                                textInputAction: TextInputAction.next,
                                validator: _validateName,
                                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _staggeredItem(
                              index: 2,
                              child: CustomTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _staggeredItem(
                              index: 3,
                              child: CustomTextField(
                                controller: _passwordController,
                                label: 'Create Password',
                                focusNode: _passwordFocus,
                                obscureText: _isPasswordObscured,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscured = !_isPasswordObscured;
                                    });
                                  },
                                  icon: Icon(
                                    _isPasswordObscured
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: const Color(0xFF7B6C98),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _staggeredItem(
                              index: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOut,
                                    tween: Tween(begin: 0, end: _passwordStrength),
                                    builder: (context, value, child) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          minHeight: 8,
                                          value: value,
                                          backgroundColor: const Color(0xFFEADFFF),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _strengthColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _strengthLabel,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF2B1B4D).withValues(alpha: 0.72),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _staggeredItem(
                              index: 5,
                              child: CustomTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                focusNode: _confirmPasswordFocus,
                                obscureText: _isConfirmPasswordObscured,
                                textInputAction: TextInputAction.next,
                                validator: _validateConfirmPassword,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 220),
                                      transitionBuilder: (child, animation) => ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                      child: _passwordsMatch
                                          ? const Padding(
                                              key: ValueKey('match'),
                                              padding: EdgeInsets.only(right: 4),
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                color: Color(0xFF10B981),
                                              ),
                                            )
                                          : const SizedBox(
                                              key: ValueKey('no-match'),
                                              width: 0,
                                              height: 0,
                                            ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                                        });
                                      },
                                      icon: Icon(
                                        _isConfirmPasswordObscured
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: const Color(0xFF7B6C98),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _staggeredItem(
                              index: 6,
                              child: DropdownField(
                                label: 'Learning Goal',
                                value: _learningGoal,
                                items: _goalOptions,
                                onChanged: (value) => setState(() => _learningGoal = value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Select a learning goal';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _staggeredItem(
                              index: 7,
                              child: DropdownField(
                                label: 'Experience Level',
                                value: _experienceLevel,
                                items: _experienceOptions,
                                onChanged: (value) => setState(() => _experienceLevel = value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Select your experience level';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            _staggeredItem(
                              index: 8,
                              child: PrimaryButton(
                                text: 'Create Account',
                                isLoading: _isLoading,
                                onPressed: _signup,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _staggeredItem(
                              index: 9,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF2B1B4D).withValues(alpha: 0.72),
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
                                        _fadeRoute(const LoginScreen()),
                                        _animatedRoute(const LoginScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Log In',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6D28D9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
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
