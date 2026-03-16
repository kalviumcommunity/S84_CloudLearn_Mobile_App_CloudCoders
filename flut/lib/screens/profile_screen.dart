import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

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
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view profile.')),
      );
    }

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
