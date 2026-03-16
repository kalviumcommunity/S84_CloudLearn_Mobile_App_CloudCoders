import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.course,
    required this.avatarUrl,
    required this.coursesEnrolled,
    required this.learningStreak,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String course;
  final String avatarUrl;
  final int coursesEnrolled;
  final int learningStreak;

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      course: map['course'] as String? ?? 'Cloud Computing',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      coursesEnrolled: map['coursesEnrolled'] as int? ?? 3,
      learningStreak: map['learningStreak'] as int? ?? 7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'course': course,
      'avatarUrl': avatarUrl,
      'coursesEnrolled': coursesEnrolled,
      'learningStreak': learningStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('user_profiles').doc(uid);

  Future<StudentProfile?> getProfile(String uid) async {
    final snapshot = await _doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return StudentProfile.fromMap(snapshot.data()!);
  }

  Future<void> saveProfile(String uid, StudentProfile profile) {
    return _doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<int> getAssignmentsCompletedCount(String uid) async {
    final query = await _firestore
        .collection('assignment_submissions')
        .where('userId', isEqualTo: uid)
        .get();
    return query.docs.length;
  }
}