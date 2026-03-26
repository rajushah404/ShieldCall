import '../entities/call_entities.dart';

abstract class CallRepository {
  Future<CallSettings> getSettings();
  Future<void> saveSetting(String key, dynamic value);
  Future<bool> isDefaultApp();
  Future<bool> requestDefaultApp();
  Future<List<BlockedLog>> getBlockedLogs();
  Future<void> requestPermissions();
}
