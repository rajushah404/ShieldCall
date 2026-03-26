import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/call_repository.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository repository;

  CallBloc({required this.repository}) : super(CallInitial()) {
    on<LoadSettingsAndLogs>(_onLoadSettings);
    on<UpdateSetting>(_onUpdateSetting);
    on<RequestDefaultAppAction>(_onRequestDefaultApp);
    on<RequestPermissionsAction>(_onRequestPermissions);
    on<RefreshStatusAction>(_onRefreshStatus);
  }

  Future<void> _onLoadSettings(LoadSettingsAndLogs event, Emitter<CallState> emit) async {
    emit(CallLoading());
    try {
      await repository.requestPermissions();
      final settings = await repository.getSettings();
      final logs = await repository.getBlockedLogs();
      emit(CallLoaded(settings, logs));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onUpdateSetting(UpdateSetting event, Emitter<CallState> emit) async {
    if (state is CallLoaded) {
      final currentState = state as CallLoaded;
      await repository.saveSetting(event.key, event.value);
      
      // Local update for responsiveness
      final newSettings = await repository.getSettings();
      emit(CallLoaded(newSettings, currentState.logs));
    }
  }

  Future<void> _onRequestDefaultApp(RequestDefaultAppAction event, Emitter<CallState> emit) async {
    await repository.requestPermissions();
    final bool isDefault = await repository.requestDefaultApp();
    if (state is CallLoaded) {
      final currentState = state as CallLoaded;
      final settings = currentState.settings.copyWith(isDefaultApp: isDefault);
      emit(CallLoaded(settings, currentState.logs));
    } else {
      add(RefreshStatusAction());
    }
  }

  Future<void> _onRefreshStatus(RefreshStatusAction event, Emitter<CallState> emit) async {
    if (state is CallLoaded) {
      final settings = await repository.getSettings();
      final logs = await repository.getBlockedLogs();
      emit(CallLoaded(settings, logs));
    }
  }

  Future<void> _onRequestPermissions(RequestPermissionsAction event, Emitter<CallState> emit) async {
    await repository.requestPermissions();
  }
}
