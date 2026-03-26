import 'package:equatable/equatable.dart';
import '../../../domain/entities/call_entities.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final CallSettings settings;
  final List<BlockedLog> logs;

  const CallLoaded(this.settings, this.logs);

  @override
  List<Object?> get props => [settings, logs];
}

class CallError extends CallState {
  final String message;
  const CallError(this.message);
  @override
  List<Object?> get props => [message];
}
