import 'package:flutter/services.dart';

class FitPlugin {
  ///
  static const platform = const MethodChannel('com.mediabeam/fitness');

  ///
  static Future<String> getDeviceInfo() async {
    try {
      final String info = await platform.invokeMethod('getDeviceInfo');
      return info;
    } on PlatformException catch (ex) {
      print(ex.toString());
    }
    return "unknown";
  }

  ///
  static Future<String> getAppInfo() async {
    try {
      final String info = await platform.invokeMethod('getAppInfo');
      return info;
    } on PlatformException catch (ex) {
      print(ex.toString());
    }
    return "unknown";
  }
}
