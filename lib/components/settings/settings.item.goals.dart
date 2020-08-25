import 'package:flutter/material.dart';
import 'package:steps/components/settings/settings.item.dart';

import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/preferences.dart';

abstract class SettingsGoalDelegate {
  void onDailyGoalRequested();
}

class SettingsGoalItem extends SettingsItem {
  ///
  final SettingsGoalDelegate delegate;

  ///
  SettingsGoalItem({Key key, String title, this.delegate})
      : super(key: key, title: title);

  @override
  _SettingsGoalItemState createState() => _SettingsGoalItemState();
}

class _SettingsGoalItemState extends State<SettingsGoalItem> {
  ///
  int _goalDaily = DAILY_TARGET_POINTS;

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void didUpdateWidget(SettingsGoalItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    _load();
  }

  void _load() {
    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      setState(() {
        _goalDaily = value;
      });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            child: Row(
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
                      )
                    ],
                  ),
                ),
                Text(
                  '$_goalDaily',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              widget.delegate?.onDailyGoalRequested();
            },
          )
        ],
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
