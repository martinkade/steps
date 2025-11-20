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
    Key? key,
    required String title,
    required this.userKey,
  }) : super(key: key, title: title);

  @override
  _SettingsSyncItemState createState() => _SettingsSyncItemState();
}

class _SettingsSyncItemState extends State<SettingsSyncItem> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  bool _autoSyncEnabled = false;

  @override
  void initState() {
    super.initState();

    _autoSyncEnabled = false;

    _load();
  }

  void _load() async {
    final bool isAutoSyncEnabled = await Preferences().isAutoSyncEnabled();
    if (isAutoSyncEnabled && await _repository.hasPermissions()) {
      setState(() {
        _autoSyncEnabled = true;
      });
    } else {
      setState(() {
        _autoSyncEnabled = false;
      });
    }
  }

  void _toggleAutoSync(bool enable) async {
    if (enable) {
      if (Platform.isAndroid && !(await _repository.isInstalled())) {
        await _repository.requestInstallation();
      }
      final bool hasAutoSyncPermissions =
          await _repository.requestPermissions();
      await Preferences().setAutoSyncEnabled(hasAutoSyncPermissions);
      setState(() {
        _autoSyncEnabled = hasAutoSyncPermissions;
      });
    } else {
      await Preferences().setAutoSyncEnabled(false);
      setState(() {
        _autoSyncEnabled = false;
      });
    }
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
                  child:  GestureDetector(
                onTap: () {
                  if (Platform.isAndroid) {
                  _repository.requestExternalSettings();
                  }
                },
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
                        Localizer.translate(
                            context, 'lblSettingsDataSourceInfo'),
                        style: TextStyle(fontSize: 16.0),
                      )
                    ],
                  ),
                ),
              ),
              Switch(
                value: _autoSyncEnabled,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: (active) {
                  _toggleAutoSync(active);
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
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: contentWidget,
          ),
        ),
      ],
    );
  }
}
