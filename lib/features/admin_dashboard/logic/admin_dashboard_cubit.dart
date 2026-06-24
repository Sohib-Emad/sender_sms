import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final FirebaseFirestore _firestore;
  StreamSubscription? _usersSub;

  AdminDashboardCubit(this._firestore) : super(AdminDashboardInitial());

  void loadUsers() {
    emit(AdminDashboardLoading());
    _usersSub?.cancel();
    _usersSub = _firestore.collection('users').snapshots().listen(
      (snapshot) {
        final users = snapshot.docs.map((doc) {
          final data = doc.data();
          return AppUser(
            uid: doc.id,
            email: data['email'] ?? '',
            displayName: data['displayName'] ?? '',
            isBlocked: data['isBlocked'] as bool? ?? false,
            isAdmin: data['isAdmin'] as bool? ?? false,
            totalSent: (data['total_sent'] as num?)?.toInt() ?? 0,
            totalFailed: (data['total_failed'] as num?)?.toInt() ?? 0,
          );
        }).toList();
        // Sort admins first, then by name
        users.sort((a, b) {
          if (a.isAdmin && !b.isAdmin) return -1;
          if (!a.isAdmin && b.isAdmin) return 1;
          return a.displayName.compareTo(b.displayName);
        });
        emit(AdminDashboardLoaded(users));
      },
      onError: (error) {
        emit(AdminDashboardError(error.toString()));
      },
    );
  }

  Future<void> toggleBlockUser(String uid, bool isBlocked) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isBlocked': isBlocked});
    } catch (e) {
      emit(AdminDashboardError('فشل تغيير حالة الحساب: ${e.toString()}'));
      loadUsers();
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool isAdmin,
  }) async {
    final currentState = state;
    emit(AdminUserCreating());
    try {
      final appName = 'TempCreator_${DateTime.now().millisecondsSinceEpoch}';
      final tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );
      try {
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final cred = await tempAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = cred.user!.uid;

        // Add to Firestore
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'displayName': displayName,
          'isBlocked': false,
          'isAdmin': isAdmin,
          'total_sent': 0,
          'total_failed': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } finally {
        await tempApp.delete();
      }
      emit(AdminUserCreated());
      if (currentState is AdminDashboardLoaded) {
        emit(currentState);
      } else {
        loadUsers();
      }
    } catch (e) {
      emit(AdminDashboardError(_mapAuthError(e.toString())));
      if (currentState is AdminDashboardLoaded) {
        emit(currentState);
      } else {
        loadUsers();
      }
    }
  }

  String _mapAuthError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
    if (error.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (error.contains('weak-password')) {
      return 'كلمة المرور ضعيفة جداً (يجب ألا تقل عن 6 أحرف)';
    }
    return 'فشل إنشاء المستخدم: $error';
  }

  @override
  Future<void> close() {
    _usersSub?.cancel();
    return super.close();
  }
}
