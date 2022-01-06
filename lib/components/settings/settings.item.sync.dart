import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.dart';
import 'dart:io' show Platform;

import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';

class SettingsSyncItem extends SettingsItem {
  ///
  final String userKey;

  ///
  SettingsSyncItem({
    Key key,
    String title,
    this.userKey,
  }) : super(key: key, title: title);

  @override
  _SettingsSyncItemState createState() => _SettingsSyncItemState();
}

class _SettingsSyncItemState extends State<SettingsSyncItem> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  bool _autoSyncEnabled;

  @override
  void initState() {
    super.initState();

    _autoSyncEnabled = false;

    _load();
  }

  void _load() {
    Preferences().isAutoSyncEnabled().then((enabled) {
      if (!mounted) return;
      if (enabled) {
        _repository.hasPermissions().then((authorized) {
          if (!mounted) return;
          setState(() {
            _autoSyncEnabled = authorized;
          });
        });
      } else {
        setState(() {
          _autoSyncEnabled = false;
        });
      }
    });
  }

  void _toggleAutoSync(bool enable) {
    if (enable) {
      _repository.requestPermissions().then((authorized) {
        if (!mounted) return;
        Preferences().setAutoSyncEnabled(authorized);
        setState(() {
          _autoSyncEnabled = authorized;
        });
      });
    } else {
      Preferences().setAutoSyncEnabled(false);
      setState(() {
        _autoSyncEnabled = false;
      });
    }
  }

  void _restorePoints() {
    _repository.restorePoints(userKey: widget.userKey);
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
                      Platform.isIOS
                          ? Localizer.translate(
                              context, 'lblSettingsDataSourceApple')
                          : Localizer.translate(
                              context, 'lblSettingsDataSourceGoogle'),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Localizer.translate(context, 'lblSettingsDataSourceInfo'),
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
              ),
              Switch(
                value: _autoSyncEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (active) {
                  _toggleAutoSync(active);
                },
              )
            ],
          )
        ],
      ),
    );

    final Widget restoreWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Localizer.translate(context, 'lblSettingsDataSourceRestoreTitle'),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Localizer.translate(context, 'lblSettingsDataSourceRestoreInfo')
                  .replaceFirst(
                '%1',
                Localizer.translate(context, 'appName'),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              Localizer.translate(context, 'lblActionRestore'),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
        onTap: () {
          _restorePoints();
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleWidget,
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.grey.withAlpha(50),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: restoreWidget,
          ),
        ),
      ],
    );
  }
}
