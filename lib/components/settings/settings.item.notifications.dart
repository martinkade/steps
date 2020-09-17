import 'package:flutter/material.dart';
import 'package:steps/components/settings/settings.item.dart';
import 'dart:io' show Platform;

import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/preferences.dart';
import 'package:steps/model/repositories/fitness.repository.dart';

abstract class SettingsNotificationDelegate {
  void onSettingsRequested();
}

class SettingsNotificationItem extends SettingsItem {
  ///
  SettingsNotificationItem({Key key, String title})
      : super(key: key, title: title);

  @override
  _SettingsNotificationItemState createState() =>
      _SettingsNotificationItemState();
}

class _SettingsNotificationItemState extends State<SettingsNotificationItem> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();

    _notificationsEnabled = false;

    _load();
  }

  void _load() {
    _repository.isNotificationsEnabled().then((enabled) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
      });
    });
  }

  void _toggleNotifications(bool enable) {
    _repository.enableNotifications(enable).then((enabled) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localizer.translate(
                              context, 'lblSettingsNotificationsTitle')
                          .replaceFirst(
                        '%1',
                        Localizer.translate(context, 'appName'),
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Localizer.translate(
                              context, 'lblSettingsNotificationsInfo')
                          .replaceFirst(
                        '%1',
                        Localizer.translate(context, 'appName'),
                      ),
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (active) {
                  _toggleNotifications(active);
                },
              )
            ],
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
