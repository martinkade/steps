import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.goals.dialog.dart';
import 'package:wandr/components/settings/settings.item.dart';

import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/preferences.dart';

class SettingsGoalItem extends SettingsItem {
  ///
  SettingsGoalItem({Key key, String title}) : super(key: key, title: title);

  @override
  _SettingsGoalItemState createState() => _SettingsGoalItemState();
}

class _SettingsGoalItemState extends State<SettingsGoalItem> {
  ///
  final List<int> _activityLevels = [
    DAILY_TARGET_POINTS - 20,
    DAILY_TARGET_POINTS - 10,
    DAILY_TARGET_POINTS,
    DAILY_TARGET_POINTS + 10,
  ];

  ///
  int _activityLevel;

  @override
  void initState() {
    super.initState();

    _activityLevel = DAILY_TARGET_POINTS;
    _load();
  }

  void _load() {
    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      setState(() {
        _activityLevel = value;
      });
    });
  }

  void _pickActivityLevel(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardSettingsDialogContent(
              setDailyTargetPoints: (level) {
                final int newLevel = _activityLevels[level];
                _activityLevel = newLevel;
                Preferences().setDailyGoal(newLevel).then((_) {
                  Navigator.of(context).pop();
                });
              },
              activityLevels: _activityLevels,
              selectedLevel: _activityLevel,
            ),
          );
        }).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizer.translate(
                            context, 'lblSettingsGoalDailyTitle'),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Localizer.translate(
                            context, 'lblSettingsGoalDailyInfo'),
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$_activityLevel',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              Localizer.translate(context, 'lblActionAdjust'),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
        onTap: () {
          _pickActivityLevel(context);
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleWidget,
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.grey.withAlpha(50),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: contentWidget,
          ),
        ),
      ],
    );
  }
}
