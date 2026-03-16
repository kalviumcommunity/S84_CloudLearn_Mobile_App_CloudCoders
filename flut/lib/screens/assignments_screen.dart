import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/assignment_service.dart';
import 'assignment_detail_screen.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view assignments.')),
      );
    }

    final assignmentService = AssignmentService();
    final assignments = assignmentService.getAssignments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: StreamBuilder<Map<String, AssignmentSubmission>>(
        stream: assignmentService.watchSubmissions(user.uid),
        builder: (context, snapshot) {
          final submissions = snapshot.data ?? <String, AssignmentSubmission>{};

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final submission = submissions[assignment.id];
              final status = assignmentService.resolveStatus(
                assignment: assignment,
                submission: submission,
              );

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              assignment.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Due: ${DateFormat('dd MMMM').format(assignment.dueDate)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AssignmentDetailScreen(assignment: assignment),
                              ),
                            );
                          },
                          child: Text(status == 'Submitted' ? 'View Details' : 'Submit / View'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Submitted':
        color = Colors.green;
        break;
      case 'Late':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}