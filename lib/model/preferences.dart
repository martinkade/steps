import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps/model/fit.challenge.dart';

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

  ///
  Future<void> setDailyGoal(int value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('kChallengeGoalDaily', value);
  }

  ///
  Future<int> getDailyGoal() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt('kChallengeGoalDaily') ?? DAILY_TARGET_POINTS;
  }
}
