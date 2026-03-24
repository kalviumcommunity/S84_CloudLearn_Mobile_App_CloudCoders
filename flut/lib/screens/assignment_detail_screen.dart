import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/assignment_service.dart';
import '../services/storage_service.dart';

const _kPurple = Color(0xFF7C6CF6);
const _kDeep = Color(0xFF2D1A4D);
const _kCardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
];

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({required this.assignment, super.key});
  final AssignmentItem assignment;

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final AssignmentService _assignmentService = AssignmentService();
  final TextEditingController _answerController = TextEditingController();

  File? _selectedFile;
  String? _selectedFileName;
  bool _submitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (!StorageService.isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StorageService.unavailableMessage)),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      withData: false,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _selectedFile = File(result.files.single.path!);
      _selectedFileName = result.files.single.name;
    });
  }

  Future<void> _submit(User user) async {
    final answer = _answerController.text.trim();
    if (_selectedFile == null && answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload a file or enter answer text.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _assignmentService.submitAssignment(
        userId: user.uid,
        assignment: widget.assignment,
        answerText: answer,
        file: _selectedFile,
        originalFileName: _selectedFileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
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
          'Assignment Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _kDeep,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
          ),
        ),
        child: SafeArea(
          child: user == null
              ? _AssignmentDetailBody(
                  assignment: widget.assignment,
                  status: _assignmentService.resolveStatus(
                      assignment: widget.assignment),
                  submission: null,
                  selectedFileName: _selectedFileName,
                  answerController: _answerController,
                  submitting: _submitting,
                  onPickFile: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sign in to upload files.')),
                  ),
                  onSubmit: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Sign in to submit this assignment.')),
                  ),
                )
              : FutureBuilder<AssignmentSubmission?>(
                  future: _assignmentService.getSubmission(
                    userId: user.uid,
                    assignmentId: widget.assignment.id,
                  ),
                  builder: (context, snapshot) {
                    final submission = snapshot.data;
                    final status = _assignmentService.resolveStatus(
                      assignment: widget.assignment,
                      submission: submission,
                    );
                    return _AssignmentDetailBody(
                      assignment: widget.assignment,
                      status: status,
                      submission: submission,
                      selectedFileName: _selectedFileName,
                      answerController: _answerController,
                      submitting: _submitting,
                      onPickFile: _submitting ? null : _pickFile,
                      onSubmit: _submitting ? null : () => _submit(user),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AssignmentDetailBody extends StatelessWidget {
  const _AssignmentDetailBody({
    required this.assignment,
    required this.status,
    required this.submission,
    required this.selectedFileName,
    required this.answerController,
    required this.submitting,
    required this.onPickFile,
    required this.onSubmit,
  });

  final AssignmentItem assignment;
  final String status;
  final AssignmentSubmission? submission;
  final String? selectedFileName;
  final TextEditingController answerController;
  final bool submitting;
  final VoidCallback? onPickFile;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info card ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: _kCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    Text(
                      'Due ${DateFormat('dd MMMM yyyy, hh:mm a').format(assignment.dueDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  assignment.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.6,
                    color: _kDeep.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // ── Last submission ────────────────────────────────────────────
          if (submission != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: _kCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: _kPurple, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Last Submission',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kDeep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Submitted: ${DateFormat('dd MMM yyyy, hh:mm a').format(submission!.submittedAt)}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: const Color(0xFF9E9E9E)),
                  ),
                  if ((submission!.fileName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'File: ${submission!.fileName}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF9E9E9E)),
                    ),
                  ],
                  if ((submission!.answerText ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Text response included',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF9E9E9E)),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Upload section ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: _kCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload File',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kDeep,
                  ),
                ),
                if (!StorageService.isEnabled) ...[
                  const SizedBox(height: 6),
                  Text(
                    'File upload disabled on free plan. Use text answer below.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: const Color(0xFF9E9E9E)),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onPickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: onPickFile != null
                              ? const LinearGradient(colors: [
                                  Color(0xFF7C6CF6),
                                  Color(0xFF5A4FCF)
                                ])
                              : const LinearGradient(colors: [
                                  Color(0xFFBDBDBD),
                                  Color(0xFF9E9E9E)
                                ]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Choose File',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFileName ?? 'No file selected',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: selectedFileName != null
                              ? _kDeep
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Text Answer',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kDeep,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E4FF), width: 1.2),
                  ),
                  child: TextField(
                    controller: answerController,
                    enabled: !submitting,
                    minLines: 5,
                    maxLines: 10,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: _kDeep),
                    decoration: InputDecoration(
                      hintText: 'Enter your answer here...',
                      hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFFBDBDBD), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Submit button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onSubmit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: onSubmit != null
                      ? const LinearGradient(
                          colors: [Color(0xFF7C6CF6), Color(0xFF5A4FCF)])
                      : const LinearGradient(
                          colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: onSubmit != null
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
                child: submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Submit Assignment',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (status) {
      'Submitted' => const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)]),
      'Late' => const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFE53935)]),
      _ => const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFB8C00)]),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
