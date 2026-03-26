import '../../domain/entities/call_entities.dart';
import '../../domain/repositories/call_repository.dart';
import '../sources/local_data_source.dart';
import '../sources/native_data_source.dart';

class CallRepositoryImpl implements CallRepository {
  final LocalDataSource localDataSource;
  final NativeDataSource nativeDataSource;

  CallRepositoryImpl({
    required this.localDataSource,
    required this.nativeDataSource,
  });

  @override
  Future<CallSettings> getSettings() async {
    final baseSettings = localDataSource.getSettings();
    final isDefault = await nativeDataSource.isDefaultApp();
    return baseSettings.copyWith(isDefaultApp: isDefault);
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await localDataSource.saveBool(key, value);
    } else if (value is int) {
      await localDataSource.saveInt(key, value);
    } else if (value is String) {
      await localDataSource.saveString(key, value);
    }
  }

  @override
  Future<bool> isDefaultApp() => nativeDataSource.isDefaultApp();

  @override
  Future<bool> requestDefaultApp() => nativeDataSource.requestDefaultApp();

  @override
  Future<List<BlockedLog>> getBlockedLogs() async {
    return localDataSource.getBlockedLogs();
  }

  @override
  Future<void> requestPermissions() => nativeDataSource.requestPermissions();
}
