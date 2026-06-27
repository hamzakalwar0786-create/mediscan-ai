import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_report.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Reports ─────────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _reportsCol(String userId) =>
      _db.collection('users').doc(userId).collection('reports');

  Future<String> saveReport(MedicalReport report) async {
    final ref = await _reportsCol(report.userId).add(report.toMap());
    return ref.id;
  }

  Future<List<MedicalReport>> fetchReports(String userId) async {
    final snap = await _reportsCol(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => MedicalReport.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<MedicalReport>> reportsStream(String userId) {
    return _reportsCol(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MedicalReport.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteReport(String userId, String reportId) async {
    await _reportsCol(userId).doc(reportId).delete();
  }

  // ─── Chat Messages ─────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _chatCol(String userId) =>
      _db.collection('users').doc(userId).collection('chat');

  Future<void> saveMessage(String userId, ChatMessage message) async {
    await _chatCol(userId).add(message.toMap());
  }

  Future<List<ChatMessage>> fetchChatHistory(String userId) async {
    final snap = await _chatCol(userId)
        .orderBy('createdAt', descending: false)
        .limit(100)
        .get();
    return snap.docs
        .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> clearChatHistory(String userId) async {
    final snap = await _chatCol(userId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── User Profile ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}
