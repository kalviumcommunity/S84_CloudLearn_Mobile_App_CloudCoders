import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'storage_service.dart';

class AssignmentItem {
  const AssignmentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;

  factory AssignmentItem.fromMap(String id, Map<String, dynamic> map) {
    final dueDateValue = map['dueDate'];
    DateTime dueDate;
    if (dueDateValue is Timestamp) {
      dueDate = dueDateValue.toDate();
    } else if (dueDateValue is DateTime) {
      dueDate = dueDateValue;
    } else {
      dueDate = DateTime.now().add(const Duration(days: 7));
    }

    return AssignmentItem(
      id: id,
      title: map['title'] as String? ?? 'Untitled Assignment',
      description: map['description'] as String? ?? '',
      dueDate: dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AssignmentSubmission {
  const AssignmentSubmission({
    required this.assignmentId,
    required this.userId,
    required this.status,
    required this.submittedAt,
    this.answerText,
    this.fileUrl,
    this.fileName,
  });

  final String assignmentId;
  final String userId;
  final String status;
  final DateTime submittedAt;
  final String? answerText;
  final String? fileUrl;
  final String? fileName;

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmission(
      assignmentId: map['assignmentId'] as String,
      userId: map['userId'] as String,
      status: map['status'] as String? ?? 'Submitted',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      answerText: map['answerText'] as String?,
      fileUrl: map['fileUrl'] as String?,
      fileName: map['fileName'] as String?,
    );
  }
}

class AssignmentService {
  AssignmentService({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService ?? StorageService();

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  static final List<AssignmentItem> _assignments = [
    AssignmentItem(
      id: 'cloud-computing-assignment-1',
      title: 'Cloud Computing Assignment 1',
      description:
          'Design a cloud deployment plan for a 3-tier web application. Include scalability, security, and cost considerations.',
      dueDate: DateTime(2026, 3, 25, 23, 59),
    ),
    AssignmentItem(
      id: 'cloud-security-quiz',
      title: 'Cloud Security Quiz',
      description:
          'Answer the cloud security quiz questions covering IAM, encryption, compliance, and incident response basics.',
      dueDate: DateTime(2026, 3, 30, 23, 59),
    ),
  ];

  List<AssignmentItem> getAssignments() => List.unmodifiable(_assignments);

  AssignmentItem? getAssignmentById(String id) {
    for (final assignment in _assignments) {
      if (assignment.id == id) {
        return assignment;
      }
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>> get _submissions =>
      _firestore.collection('assignment_submissions');

  CollectionReference<Map<String, dynamic>> get _assignmentsCollection =>
      _firestore.collection('assignments');

  Stream<List<AssignmentItem>> watchAssignments() {
    return _assignmentsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return getAssignments();
      }

      return snapshot.docs
          .map((doc) => AssignmentItem.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<Map<String, AssignmentSubmission>> watchSubmissions(String userId) {
    return _submissions.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final map = <String, AssignmentSubmission>{};
      for (final doc in snapshot.docs) {
        final submission = AssignmentSubmission.fromMap(doc.data());
        map[submission.assignmentId] = submission;
      }
      return map;
    });
  }

  Future<AssignmentSubmission?> getSubmission({
    required String userId,
    required String assignmentId,
  }) async {
    final query = await _submissions
        .where('userId', isEqualTo: userId)
        .where('assignmentId', isEqualTo: assignmentId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }
    return AssignmentSubmission.fromMap(query.docs.first.data());
  }

  String resolveStatus({
    required AssignmentItem assignment,
    AssignmentSubmission? submission,
    DateTime? now,
  }) {
    if (submission != null) {
      return submission.submittedAt.isAfter(assignment.dueDate) ? 'Late' : 'Submitted';
    }

    final compareNow = now ?? DateTime.now();
    if (compareNow.isAfter(assignment.dueDate)) {
      return 'Late';
    }
    return 'Pending';
  }

  Future<void> submitAssignment({
    required String userId,
    required AssignmentItem assignment,
    String? answerText,
    File? file,
    String? originalFileName,
  }) async {
    String? fileUrl;
    String? fileName;

    if (file != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sourceName = originalFileName ?? file.path.split(RegExp(r'[\\/]')).last;
      final safeName = sourceName
          .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final storagePath = 'assignments/${assignment.id}/$userId-$timestamp-$safeName';
      fileUrl = await _storageService.uploadFile(file, storagePath);
      fileName = safeName;
    }

    final submittedAt = DateTime.now();
    final status = submittedAt.isAfter(assignment.dueDate) ? 'Late' : 'Submitted';
    final submissionDocId = '${assignment.id}_$userId';

    await _submissions.doc(submissionDocId).set({
      'assignmentId': assignment.id,
      'userId': userId,
      'answerText': (answerText ?? '').trim(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<int> getCompletedAssignmentCount(String userId) async {
    final query = await _submissions.where('userId', isEqualTo: userId).get();
    return query.docs.length;
  }
}