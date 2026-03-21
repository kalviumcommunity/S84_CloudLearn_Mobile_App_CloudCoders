import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

// ── Theme constants ──────────────────────────────────────────────────────────
const _kPurpleGradient = LinearGradient(
  colors: [Color(0xFF7C6CF6), Color(0xFF5A4FCF)],
);

const _kCardShadow = [
  BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 16,
    spreadRadius: 0,
    offset: Offset(0, 6),
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = AuthService().currentUser;
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;
  bool _isEditing = false;
  String? _localImagePath;

  int _coursesEnrolled = 3;
  int _learningStreak = 7;
  int _assignmentsCompleted = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool get _isGuestMode => _user == null;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_user == null) {
      _nameController.text = 'Student';
      _emailController.text = 'student@email.com';
      _phoneController.text = '';
      _courseController.text = 'Cloud Computing';
      setState(() => _loading = false);
      _fadeCtrl.forward();
      return;
    }
    try {
      final profile = await _profileService.getProfile(_user!.uid);
      final completed =
          await _profileService.getAssignmentsCompletedCount(_user!.uid);
      _nameController.text = profile?.name.isNotEmpty == true
          ? profile!.name
          : (_user?.displayName ?? '');
      _emailController.text = profile?.email.isNotEmpty == true
          ? profile!.email
          : (_user?.email ?? '');
      _phoneController.text = profile?.phoneNumber ?? '';
      _courseController.text = profile?.course ?? 'Cloud Computing';
      _coursesEnrolled = profile?.coursesEnrolled ?? 3;
      _learningStreak = profile?.learningStreak ?? 7;
      _assignmentsCompleted = completed;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile details.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _fadeCtrl.forward();
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploading) return;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to upload a profile photo.')),
      );
      return;
    }
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile == null) return;
    setState(() {
      _uploading = true;
      _localImagePath = pickedFile.path;
    });
    try {
      final file = File(pickedFile.path);
      final downloadUrl =
          await StorageService().uploadProfileImage(_user!.uid, file);
      await _user!.updatePhotoURL(downloadUrl);
      await _profileService.saveProfile(
        _user!.uid,
        StudentProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          course: _courseController.text.trim().isEmpty
              ? 'Cloud Computing'
              : _courseController.text.trim(),
          avatarUrl: downloadUrl,
          coursesEnrolled: _coursesEnrolled,
          learningStreak: _learningStreak,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image upload failed: $error')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Profile updated in guest mode. Sign in to sync changes.')));
      return;
    }
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final course = _courseController.text.trim().isEmpty
        ? 'Cloud Computing'
        : _courseController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name and email are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _profileService.saveProfile(
        _user!.uid,
        StudentProfile(
          name: name,
          email: email,
          phoneNumber: phone,
          course: course,
          avatarUrl: _user?.photoURL ?? '',
          coursesEnrolled: _coursesEnrolled,
          learningStreak: _learningStreak,
        ),
      );
      if ((_user?.displayName ?? '') != name) await _user!.updateDisplayName(name);
      if ((_user?.email ?? '') != email) {
        try {
          await _user!.verifyBeforeUpdateEmail(email);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save profile: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final profile = await _profileService.getProfile(_user!.uid);
      final completed = await _profileService.getAssignmentsCompletedCount(_user!.uid);

      _nameController.text = profile?.name.isNotEmpty == true
          ? profile!.name
          : (_user?.displayName ?? '');
      _emailController.text = profile?.email.isNotEmpty == true
          ? profile!.email
          : (_user?.email ?? '');
      _phoneController.text = profile?.phoneNumber ?? '';
      _courseController.text = profile?.course ?? 'Cloud Computing';
      _coursesEnrolled = profile?.coursesEnrolled ?? 3;
      _learningStreak = profile?.learningStreak ?? 7;
      _assignmentsCompleted = completed;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile details.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_user == null || _uploading) return;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    setState(() {
      _uploading = true;
      _localImagePath = pickedFile.path;
    });

    try {
      final file = File(pickedFile.path);
      final downloadUrl = await StorageService().uploadProfileImage(_user!.uid, file);

      await _user!.updatePhotoURL(downloadUrl);
      await _profileService.saveProfile(
        _user!.uid,
        StudentProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          course: _courseController.text.trim().isEmpty
              ? 'Cloud Computing'
              : _courseController.text.trim(),
          avatarUrl: downloadUrl,
          coursesEnrolled: _coursesEnrolled,
          learningStreak: _learningStreak,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final course = _courseController.text.trim().isEmpty
        ? 'Cloud Computing'
        : _courseController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _profileService.saveProfile(
        _user!.uid,
        StudentProfile(
          name: name,
          email: email,
          phoneNumber: phone,
          course: course,
          avatarUrl: _user?.photoURL ?? '',
          coursesEnrolled: _coursesEnrolled,
          learningStreak: _learningStreak,
        ),
      );

      if ((_user?.displayName ?? '') != name) {
        await _user!.updateDisplayName(name);
      }

      if ((_user?.email ?? '') != email) {
        try {
          await _user!.verifyBeforeUpdateEmail(email);
        } catch (_) {
          // Email update may require recent login; profile data is still saved.
        }
      }

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  ImageProvider? _profileImage() {
    if (_localImagePath != null) return FileImage(File(_localImagePath!));
    if ((_user?.photoURL ?? '').isNotEmpty) return NetworkImage(_user!.photoURL!);
    if (_localImagePath != null) {
      return FileImage(File(_localImagePath!));
    }
    if ((_user?.photoURL ?? '').isNotEmpty) {
      return NetworkImage(_user!.photoURL!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
    if (_user == null) {
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

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // No backgroundColor — let the gradient show through everywhere
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5A4FCF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF2D1A4D),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _saving ? null : () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7C6CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Avatar section ─────────────────────────────────────
                  const SizedBox(height: 8),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Gradient ring
                        Container(
                          width: 116,
                          height: 116,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _kPurpleGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x447C6CF6),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: const Color(0xFFF3F0FF),
                            backgroundImage: _profileImage(),
                            child: _uploading
                                ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF7C6CF6)),
                                  )
                                : (_profileImage() == null
                                    ? const Icon(Icons.person_rounded,
                                        size: 48, color: Color(0xFF7C6CF6))
                                    : null),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: _kPurpleGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x337C6CF6),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Student',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1A4D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _courseController.text.isNotEmpty
                        ? _courseController.text
                        : 'Cloud Computing',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF7C6CF6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Stats row ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Courses',
                          value: '$_coursesEnrolled',
                          icon: Icons.school_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Completed',
                          value: '$_assignmentsCompleted',
                          icon: Icons.task_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Streak',
                          value: '${_learningStreak}d',
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── Info section card ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _kCardShadow,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Info',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D1A4D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileField(
                          label: 'Full Name',
                          controller: _nameController,
                          enabled: _isEditing,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _ProfileField(
                          label: 'Email',
                          controller: _emailController,
                          enabled: _isEditing && !_isGuestMode,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _ProfileField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          enabled: _isEditing,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _ProfileField(
                          label: 'Course',
                          controller: _courseController,
                          enabled: _isEditing,
                          icon: Icons.menu_book_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Save button ────────────────────────────────────────
                  if (_isEditing) ...[
                    _GradientButton(
                      label: _saving ? 'Saving…' : 'Save Changes',
                      onTap: _saving ? null : _saveChanges,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Logout ─────────────────────────────────────────────
                  _LogoutButton(
                    isGuestMode: _isGuestMode,
                    onTap: _isGuestMode
                        ? null
                        : () async => await AuthService().signOut(),
                  ),
                ],
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
            child: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: _profileImage(),
                    child: _uploading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ((_profileImage() == null)
                            ? const Icon(Icons.person, size: 44)
                            : null),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ProfileField(
              label: 'Name',
              controller: _nameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Email',
              controller: _emailController,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Phone Number',
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Course',
              controller: _courseController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 24),
            Text(
              'Account Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Courses Enrolled', value: '$_coursesEnrolled')),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(label: 'Assignments Completed', value: '$_assignmentsCompleted'),
                ),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Learning Streak', value: '${_learningStreak}d')),
              ],
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveChanges,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await AuthService().signOut();
                },
                child: const Text('Log Out'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF7C6CF6), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: const Color(0xFF2D1A4D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Field ─────────────────────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF7C6CF6).withValues(alpha: 0.4)
                  : const Color(0xFFE8E4FF),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF2D1A4D),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFBDBDBD),
                fontSize: 14,
              ),
              prefixIcon:
                  Icon(icon, color: const Color(0xFF7C6CF6), size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.reverse() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.forward();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.onTap != null
                ? _kPurpleGradient
                : const LinearGradient(
                    colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.onTap != null
                ? const [
                    BoxShadow(
                      color: Color(0x447C6CF6),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.isGuestMode, required this.onTap});
  final bool isGuestMode;
  final VoidCallback? onTap;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _ctrl.reverse(),
      onTapUp: disabled
          ? null
          : (_) {
              _ctrl.forward();
              widget.onTap!();
            },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: disabled
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFFE53935),
              width: 1.8,
            ),
            boxShadow: disabled
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x1AE53935),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: disabled
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isGuestMode ? 'Log Out (Sign in required)' : 'Log Out',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: disabled
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
