import 'package:flutter/services.dart';

class NativeUsage {
  static const MethodChannel _channel = MethodChannel("app_usage_channel");

  static Future<Map<String, int>> getLaunchCounts(
      DateTime start, DateTime end) async {
    final result = await _channel.invokeMethod("getAppLaunchCounts", {
      "start": start.millisecondsSinceEpoch,
      "end": end.millisecondsSinceEpoch
    });

    return Map<String, int>.from(result.map(
        (key, value) => MapEntry(key.toString(), value as int)));
  }
}
