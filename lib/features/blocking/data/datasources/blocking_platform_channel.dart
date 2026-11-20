import 'package:flutter/services.dart';

/// Dart platform channel wrapper communicating with Android Kotlin UsageStats
/// and Windows C# Focus Monitor.
class BlockingPlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.letsflytgr.app/focus_blocker');

  static Future<bool> hasUsagePermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('hasUsagePermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (_) {}
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  static Future<void> startBlockingService(List<String> blocklist) async {
    try {
      await _channel.invokeMethod('startBlockingService', {'blocklist': blocklist});
    } catch (_) {}
  }

  static Future<void> stopBlockingService() async {
    try {
      await _channel.invokeMethod('stopBlockingService');
    } catch (_) {}
  }
}
