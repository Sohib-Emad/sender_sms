import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final bool isBlocked;
  final bool isAdmin;
  final int totalSent;
  final int totalFailed;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName, 
    this.isBlocked = false,
    this.isAdmin = false,
    this.totalSent = 0,
    this.totalFailed = 0,
  });

  @override
  List<Object?> get props => [uid, email, displayName, isBlocked, isAdmin];
}
