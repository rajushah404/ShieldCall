import 'package:equatable/equatable.dart';

class CallSettings extends Equatable {
  final bool blockEnabled;
  final bool whitelistMode;
  final bool focusMode;
  final int maxCalls;
  final int timeWindow;
  final bool blockAll;
  final bool isDefaultApp;

  const CallSettings({
    required this.blockEnabled,
    required this.blockAll,
    required this.whitelistMode,
    required this.focusMode,
    required this.maxCalls,
    required this.timeWindow,
    required this.isDefaultApp,
  });

  CallSettings copyWith({
    bool? blockEnabled,
    bool? blockAll,
    bool? whitelistMode,
    bool? focusMode,
    int? maxCalls,
    int? timeWindow,
    bool? isDefaultApp,
  }) {
    return CallSettings(
      blockEnabled: blockEnabled ?? this.blockEnabled,
      blockAll: blockAll ?? this.blockAll,
      whitelistMode: whitelistMode ?? this.whitelistMode,
      focusMode: focusMode ?? this.focusMode,
      maxCalls: maxCalls ?? this.maxCalls,
      timeWindow: timeWindow ?? this.timeWindow,
      isDefaultApp: isDefaultApp ?? this.isDefaultApp,
    );
  }

  @override
  List<Object?> get props => [
        blockEnabled,
        blockAll,
        whitelistMode,
        focusMode,
        maxCalls,
        timeWindow,
        isDefaultApp,
      ];
}

class BlockedLog extends Equatable {
  final DateTime timestamp;
  final String phoneNumber;
  final String reason;

  const BlockedLog({
    required this.timestamp,
    required this.phoneNumber,
    required this.reason,
  });

  @override
  List<Object?> get props => [timestamp, phoneNumber, reason];
}
