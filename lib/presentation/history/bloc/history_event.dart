
import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoad extends HistoryEvent {}

class HistoryLoadDetails extends HistoryEvent {
  final String sessionId;
  const HistoryLoadDetails(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}
