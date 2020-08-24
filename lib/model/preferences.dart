import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  ///
  Future<void> setAutoSyncEnabled(bool enabled) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('kAutoSync', enabled);
  }

  ///
  Future<bool> isAutoSyncEnabled() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('kAutoSync') ?? false;
  }
}
