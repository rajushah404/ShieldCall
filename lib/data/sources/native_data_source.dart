import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NativeDataSource {
  static const _channel = MethodChannel('com.rajushah.shieldcall/call_screening');

  Future<bool> isDefaultApp() async {
    try {
      final bool status = await _channel.invokeMethod('isDefaultApp');
      return status;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> requestDefaultApp() async {
    try {
      final bool status = await _channel.invokeMethod('requestDefaultApp');
      return status;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
    ].request();
  }
}
