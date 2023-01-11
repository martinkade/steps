import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/model/fit.challenge.dart';

const kFlagInitialNotifications = 'kFlagInitialNotifications';
const kFlagUnitKilometers = 'kFlagUnitKilometers';

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  ///
  static Future<String> getUserKey() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String value = preferences.getString('kUser');
    return value;
  }

  ///
  Future<void> setHasRestoredData(bool enabled) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('kDidRestoreData', enabled);
  }

  ///
  Future<bool> hasRestoredData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('kDidRestoreData') ?? false;
  }

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
  Future<void> setDisplayName(String value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('kDisplayName', value);
  }

  ///
  Future<String> getDisplayName() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('kDisplayName') ?? 'Anonym';
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

  ///
  Future<void> setDifficultyLevel(int value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('kChallengeDifficulty', value);
  }

  ///
  Future<int> getDifficultyLevel() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt('kChallengeDifficulty') ?? Difficulties.hard.index;
  }
  ///
  Future<void> setFlag(String key, bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, value);
  }

  ///
  Future<bool> isFlagSet(String key) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key) ?? false;
  }
}
