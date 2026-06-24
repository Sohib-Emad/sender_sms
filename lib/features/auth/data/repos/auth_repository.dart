import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  AppUser _fromFirebase(User u, Map<String, dynamic>? data) => AppUser(
        uid: u.uid,
        email: u.email ?? '',
        displayName: u.displayName ?? data?['displayName'] ?? '',
        isBlocked: data?['isBlocked'] as bool? ?? false,
        isAdmin: data?['isAdmin'] as bool? ?? false,
        totalSent: (data?['total_sent'] as num?)?.toInt() ?? 0,
        totalFailed: (data?['total_failed'] as num?)?.toInt() ?? 0,
      );

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppUser(uid: u.uid, email: u.email ?? '', displayName: u.displayName ?? '');
  }

  @override
  Stream<AppUser?> get authStateChanges {
    late StreamController<AppUser?> controller;
    StreamSubscription? authSub;
    StreamSubscription? docSub;

    controller = StreamController<AppUser?>.broadcast(
      onListen: () {
        authSub = _auth.authStateChanges().listen((u) {
          docSub?.cancel();
          if (u == null) {
            controller.add(null);
          } else {
            docSub = _firestore
                .collection('users')
                .doc(u.uid)
                .snapshots()
                .listen((doc) async {
              if (!controller.isClosed) {
                if (!doc.exists) {
                  try {
                    final usersSnapshot = await _firestore.collection('users').limit(1).get();
                    final isFirstUser = usersSnapshot.docs.isEmpty;
                    await _firestore.collection('users').doc(u.uid).set({
                      'email': u.email ?? '',
                      'displayName': u.displayName ?? u.email?.split('@').first ?? 'مسؤول',
                      'isBlocked': false,
                      'isAdmin': isFirstUser,
                      'total_sent': 0,
                      'total_failed': 0,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } catch (_) {
                    controller.add(_fromFirebase(u, null));
                  }
                } else {
                  controller.add(_fromFirebase(u, doc.data()));
                }
              }
            });
          }
        });
      },
      onCancel: () {
        authSub?.cancel();
        docSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final u = cred.user!;
    final doc = await _firestore.collection('users').doc(u.uid).get();
    final data = doc.data();
    final isBlocked = data?['isBlocked'] as bool? ?? false;
    if (isBlocked) {
      await _auth.signOut();
      throw Exception('تم تعليق حسابك. تواصل مع الإدارة.');
    }
    // تأكد من وجود document في Firestore
    if (!doc.exists) {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      final isFirstUser = usersSnapshot.docs.isEmpty;

      final newData = {
        'email': u.email ?? '',
        'displayName': u.displayName ?? u.email?.split('@').first ?? 'مسؤول',
        'isBlocked': false,
        'isAdmin': isFirstUser, // أول مستخدم يسجل دخوله يكون هو المسؤول تلقائياً
        'total_sent': 0,
        'total_failed': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(u.uid).set(newData);
      return _fromFirebase(u, newData);
    }
    return _fromFirebase(u, data);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
