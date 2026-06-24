import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseReportingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseReportingService(this._firestore, this._auth);

  /// يرسل إحصائيات الجلسة لـ Firestore — أرقام هاتف فقط، بدون نص الرسائل
  Future<void> submitSession({
    required String sessionId,
    required int total,
    required int sent,
    required int failed,
    required List<String> phonesContacted,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final batch = _firestore.batch();

      // حفظ الجلسة في Firestore
      final sessionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(sessionId);

      batch.set(sessionRef, {
        'total': total,
        'sent': sent,
        'failed': failed,
        'date': FieldValue.serverTimestamp(),
        'phones_contacted': phonesContacted, // أرقام فقط، لا رسائل
      });

      // تحديث عداد الكل في document المستخدم
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'total_sent': FieldValue.increment(sent),
        'total_failed': FieldValue.increment(failed),
        'last_session': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (_) {
      // التقرير ليس حرجاً — لا نوقف التطبيق لو فشل
    }
  }

  /// تسجيل المستخدم في Firestore عند أول تسجيل دخول
  Future<void> ensureUserDocument({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.set({
      'email': email,
      'displayName': displayName,
      'isBlocked': false,
      'total_sent': 0,
      'total_failed': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
