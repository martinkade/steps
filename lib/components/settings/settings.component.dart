import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.settings.dialog.dart';
import 'package:steps/components/settings/settings.item.goals.dart';
import 'package:steps/components/settings/settings.item.sync.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/model/preferences.dart';

class Settings extends StatefulWidget {
  ///
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> implements SettingsGoalDelegate {
  ///
  final List<int> _activity_levels = [55, 65, 75, 85];

  @override
  void initState() {
    super.initState();
  }

  @override
  void onDailyGoalRequested() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardSettingsDialogContent(
              setDailyTargetPoints: (int level) {
                final int newGoal = _activity_levels[level];
                Preferences().setDailyGoal(newGoal).then((_) {
                  Navigator.of(context).pop();
                  setState(() {
                    print('set new goal $newGoal');
                  });
                });
              },
              activityLevels: _activity_levels,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return SettingsGoalItem(
                title: Localizer.translate(context, 'lblSettingsGoals'),
                delegate: this,
              );
            case 1:
              return SettingsSyncItem(
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
