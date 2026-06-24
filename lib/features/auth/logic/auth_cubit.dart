import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/auth/data/repos/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSub;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSub = _authRepository.authStateChanges.listen((user) {
      if (isClosed) return;
      if (user == null) {
        emit(AuthUnauthenticated());
      } else if (user.isBlocked) {
        emit(const AuthBlocked('تم تعليق حسابك. تواصل مع الإدارة.'));
      } else {
        emit(AuthAuthenticated(user));
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('تم تعليق')) {
        emit(AuthBlocked(msg));
      } else {
        emit(AuthError(_mapFirebaseError(msg)));
      }
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  String _mapFirebaseError(String code) {
    if (code.contains('user-not-found') || code.contains('wrong-password') || code.contains('invalid-credential')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (code.contains('too-many-requests')) return 'محاولات كثيرة. انتظر قليلاً.';
    if (code.contains('network')) return 'مشكلة في الاتصال بالإنترنت';
    return 'حدث خطأ. حاول مرة أخرى.';
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
