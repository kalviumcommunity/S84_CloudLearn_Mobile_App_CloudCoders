import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/assignment_service.dart';
import '../services/storage_service.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({
    required this.assignment,
    super.key,
  });

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

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _selectedFile = File(result.files.single.path!);
      _selectedFileName = result.files.single.name;
    });
  }

  Future<void> _submit(User user) async {
    final answer = _answerController.text.trim();
    if (_selectedFile == null && answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file or enter answer text.')),
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
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
      ),
      body: user == null
          ? _AssignmentDetailBody(
              assignment: widget.assignment,
              status: _assignmentService.resolveStatus(assignment: widget.assignment),
              submission: null,
              selectedFileName: _selectedFileName,
              answerController: _answerController,
              submitting: _submitting,
              onPickFile: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign in to upload files.')),
                );
              },
              onSubmit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign in to submit this assignment.')),
                );
              },
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignment.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Due: ${DateFormat('dd MMMM yyyy, hh:mm a').format(assignment.dueDate)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: status),
          const SizedBox(height: 16),
          Text(
            assignment.description,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 20),
          if (submission != null) ...[
            const Text(
              'Last Submission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted at: ${DateFormat('dd MMM yyyy, hh:mm a').format(submission!.submittedAt)}',
            ),
            if ((submission!.fileName ?? '').isNotEmpty)
              Text('File: ${submission!.fileName}'),
            if ((submission!.answerText ?? '').trim().isNotEmpty)
              const Text('Text response added'),
            const SizedBox(height: 20),
          ],
          const Text(
            'Upload File',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose File'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedFileName ?? 'No file selected',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(child: Text('OR')),
          const SizedBox(height: 20),
          TextField(
            controller: answerController,
            enabled: !submitting,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Enter your answer here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Assignment'),
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
    Color background;
    Color foreground;

    switch (status) {
      case 'Submitted':
        background = Colors.green.withValues(alpha: 0.12);
        foreground = Colors.green.shade700;
        break;
      case 'Late':
        background = Colors.red.withValues(alpha: 0.12);
        foreground = Colors.red.shade700;
        break;
      default:
        background = Colors.orange.withValues(alpha: 0.15);
        foreground = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}