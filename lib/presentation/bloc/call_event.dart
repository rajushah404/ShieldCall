import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsAndLogs extends CallEvent {}

class UpdateSetting extends CallEvent {
  final String key;
  final dynamic value;

  const UpdateSetting(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class RequestDefaultAppAction extends CallEvent {}

class RequestPermissionsAction extends CallEvent {}

class RefreshStatusAction extends CallEvent {}
