import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/assignment_service.dart';
import 'assignment_detail_screen.dart';

// ── Shared theme constants ──────────────────────────────────────────────────
const _kGradientBg = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
);

const _kPurpleGradient = LinearGradient(
  colors: [Color(0xFF7C6CF6), Color(0xFF5A4FCF)],
);

const _kCardShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────
class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  Widget _buildAssignmentList(
    BuildContext context,
    AssignmentService assignmentService,
    List<AssignmentItem> assignments,
    Map<String, AssignmentSubmission> submissions,
  ) {
    if (assignments.isEmpty) {
      return Center(
        child: Text(
          'No assignments yet.',
          style: GoogleFonts.poppins(color: const Color(0xFF7C6CF6)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: assignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final submission = submissions[assignment.id];
        final status = assignmentService.resolveStatus(
          assignment: assignment,
          submission: submission,
        );

        return _AssignmentCard(
          assignment: assignment,
          status: status,
          delayMs: 60 * index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final assignmentService = AssignmentService();
    final assignments = assignmentService.getAssignments();

    return Scaffold(
      backgroundColor: const Color(0xFFEEE9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF5A4FCF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Assignments',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF2D1A4D),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradientBg),
        child: user == null
            ? _buildAssignmentList(
                context, assignmentService, assignments, const {},
              )
            : StreamBuilder<Map<String, AssignmentSubmission>>(
                stream: assignmentService.watchSubmissions(user.uid),
                builder: (context, snapshot) {
                  final submissions = snapshot.data ?? {};
                  return _buildAssignmentList(
                    context, assignmentService, assignments, submissions,
                  );
                },
              ),
      ),
    );
  }
}

// ── Assignment Card ──────────────────────────────────────────────────────────
class _AssignmentCard extends StatefulWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.status,
    required this.delayMs,
  });

  final AssignmentItem assignment;
  final String status;
  final int delayMs;

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: _kCardShadow,
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.assignment.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D1A4D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(status: widget.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 5),
                  Text(
                    'Due ${DateFormat('dd MMMM yyyy').format(widget.assignment.dueDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: _GradientButton(
                  label: widget.status == 'Submitted' ? 'View Details' : 'Submit / View',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AssignmentDetailScreen(assignment: widget.assignment),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (status) {
      'Submitted' => const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
        ),
      'Late' => const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFE53935)],
        ),
      _ => const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
        ),
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

// ── Gradient Button ───────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            gradient: _kPurpleGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
