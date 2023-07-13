import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.dart';
import 'package:wandr/components/settings/settings.item.display.dialog.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/preferences.dart';

class SettingsDisplayItem extends SettingsItem {
  ///
  SettingsDisplayItem({Key? key, required String title})
      : super(key: key, title: title);

  @override
  _SettingsDisplayItemState createState() => _SettingsDisplayItemState();
}

class _SettingsDisplayItemState extends State<SettingsDisplayItem> {
  ///
  bool _unitKilometersEnabled = false;

  ///
  String? _displayName;

  @override
  void initState() {
    super.initState();

    _unitKilometersEnabled = false;

    _load();
  }

  void _load() async {
    _unitKilometersEnabled = await Preferences().isFlagSet(kFlagUnitKilometers);
    _displayName = await Preferences().getDisplayName();
    setState(() {});
  }

  void _toggleUnits(bool enable) {
    Preferences().setFlag(kFlagUnitKilometers, enable).then((_) {
      if (!mounted) return;
      setState(() {
        _unitKilometersEnabled = enable;
      });
    });
  }

  void _changeDisplayName(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardSettingsDisplayNameDialog(
              setDisplayName: (newDisplayName) {
                _displayName = newDisplayName;
                Preferences().setDisplayName(newDisplayName).then((_) {
                  Navigator.of(context).pop();
                });
              },
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
                        context,
                        'lblSettingsDisplayUnitMainTitle',
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Localizer.translate(
                        context,
                        'lblSettingsDisplayUnitMainInfo',
                      ),
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
              ),
              Switch(
                value: _unitKilometersEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (active) {
                  _toggleUnits(active);
                },
              )
            ],
          ),
          Divider(),
          GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  Localizer.translate(
                    context,
                    'lblSettingsDisplayNameMainTitle',
                  ),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Localizer.translate(
                    context,
                    'lblSettingsDisplayNameMainInfo',
                  ).replaceFirst('%1', _displayName ?? ''),
                  style: TextStyle(fontSize: 16.0),
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
            onTap: () => _changeDisplayName(context),
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
