import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.display.dart';
import 'package:wandr/components/settings/settings.item.goals.dart';
import 'package:wandr/components/settings/settings.item.notifications.dart';
import 'package:wandr/components/settings/settings.item.sync.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';

class SettingsComponent extends StatefulWidget {
  ///
  final String userKey;

  ///
  const SettingsComponent({Key key, this.userKey}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return SettingsDisplayItem(
                title: Localizer.translate(context, 'lblSettingsDisplay'),
              );
            case 1:
              return SettingsGoalItem(
                title: Localizer.translate(context, 'lblSettingsGoals'),
              );
            case 2:
              return SettingsNotificationItem(
                title: Localizer.translate(context, 'lblSettingsNotifications'),
              );
            case 3:
              return SettingsSyncItem(
                userKey: widget.userKey,
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
