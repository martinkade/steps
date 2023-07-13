import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/components/settings/settings.item.display.dart';
import 'package:wandr/components/settings/settings.item.goals.dart';
import 'package:wandr/components/settings/settings.item.notifications.dart';
import 'package:wandr/components/settings/settings.item.sync.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/util/AprilJokes.dart';

class SettingsComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  const SettingsComponent({Key? key, this.userKey}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsComponent> {
  ///
  late AprilJokes _aprilJokes;

  @override
  void initState() {
    _aprilJokes = AprilJokes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = _aprilJokes.isJokeActive(Jokes.botDifficulty) ? 5 : 4;

    return DefaultPage(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          int newIndex = _aprilJokes.isJokeActive(Jokes.botDifficulty)
              ? index
              : (index + 1);
          switch (newIndex) {
            case 0:
              return SettingsDifficultyItem(
                title: Localizer.translate(context, 'lblSettingsDifficulty'),
              );
            case 1:
              return SettingsDisplayItem(
                title: Localizer.translate(context, 'lblSettingsDisplay'),
              );
            case 2:
              return SettingsGoalItem(
                title: Localizer.translate(context, 'lblSettingsGoals'),
              );
            case 3:
              return SettingsNotificationItem(
                title: Localizer.translate(context, 'lblSettingsNotifications'),
              );
            case 4:
              return SettingsSyncItem(
                userKey: widget.userKey!,
                title: Localizer.translate(context, 'lblSettingsDataSource'),
              );
            default:
              return Container();
          }
        },
      ),
      title: Localizer.translate(context, 'lblSettings'),
    );
  }
}
