import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/call_entities.dart';

class LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSource(this._prefs);

  CallSettings getSettings() {
    return CallSettings(
      blockEnabled: _prefs.getBool('blockEnabled') ?? false,
      blockAll: _prefs.getBool('blockAll') ?? false,
      whitelistMode: _prefs.getBool('whitelistMode') ?? false,
      focusMode: _prefs.getBool('focusMode') ?? false,
      maxCalls: _prefs.getInt('maxCalls') ?? 3,
      timeWindow: _prefs.getInt('timeWindow') ?? 5,
      isDefaultApp: false, // Updated by native call
    );
  }

  Future<void> saveBool(String key, bool value) => _prefs.setBool(key, value);
  Future<void> saveInt(String key, int value) => _prefs.setInt(key, value);
  Future<void> saveString(String key, String value) => _prefs.setString(key, value);

  List<BlockedLog> getBlockedLogs() {
    final rawLogs = _prefs.getString('blockedLogs') ?? '';
    return rawLogs
        .split('\n')
        .where((s) => s.isNotEmpty)
        .map((line) {
          final parts = line.split('|');
          if (parts.length < 3) return null;
          return BlockedLog(
            timestamp: DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[0]) ?? 0),
            phoneNumber: parts[1],
            reason: parts[2],
          );
        })
        .whereType<BlockedLog>()
        .toList();
  }
}
