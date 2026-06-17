import 'package:equatable/equatable.dart';

abstract class ImportEvent extends Equatable {
  const ImportEvent();
  @override
  List<Object?> get props => [];
}

class ImportPickFile extends ImportEvent {}

class ImportReset extends ImportEvent {}
