import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final List<AppUser> users;
  const AdminDashboardLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminUserCreating extends AdminDashboardState {}

class AdminUserCreated extends AdminDashboardState {}
