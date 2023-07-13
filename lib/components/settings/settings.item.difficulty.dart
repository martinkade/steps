import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dialog.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/util/AprilJokes.dart';

class SettingsDifficultyItem extends SettingsItem {
  ///
  SettingsDifficultyItem({Key? key, required String title})
      : super(key: key, title: title);

  @override
  _SettingsDifficultyItemState createState() => _SettingsDifficultyItemState();
}

class _SettingsDifficultyItemState extends State<SettingsDifficultyItem> {
  ///
  final List<int> _difficultyLevels = [
    Difficulties.easy.index,
    Difficulties.normal.index,
    Difficulties.hard.index,
    Difficulties.veryHard.index,
  ];

  ///
  int _difficultyLevel = Difficulties.hard.index;

  ///
  late AprilJokes _aprilJokes;

  @override
  void initState() {
    super.initState();

    _aprilJokes = AprilJokes();
    _difficultyLevel = Difficulties.hard.index;
    _load();
  }

  void _load() {
    Preferences().getDifficultyLevel().then((value) {
      if (!mounted) return;
      setState(() {
        _difficultyLevel = value;
      });
    });
  }

  String _getLocalizedDifficultyLevel() {
    Difficulties difficulty = Difficulties.values[_difficultyLevel];
    switch (difficulty) {
      case Difficulties.easy:
        return Localizer.translate(context, 'lblDashboardSettingsDifficulty0');
      case Difficulties.normal:
        return Localizer.translate(context, 'lblDashboardSettingsDifficulty1');
      case Difficulties.hard:
        return Localizer.translate(context, 'lblDashboardSettingsDifficulty2');
      case Difficulties.veryHard:
        return Localizer.translate(context, 'lblDashboardSettingsDifficulty3');
    }
  }

  void _pickDifficultyLevel(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardSettingsDifficultyLevelDialog(
              setDifficultyLevel: (level) {
                final int newLevel = _difficultyLevels[level];
                _difficultyLevel = newLevel;
                Preferences().setDifficultyLevel(newLevel).then((_) {
                  Navigator.of(context).pop();
                });
              },
              difficultyLevels: _difficultyLevels,
              selectedLevel: _difficultyLevel,
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
                            context, 'lblSettingsDifficultyTitle'),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Localizer.translate(
                                context, 'lblSettingsDifficultyInfo')
                            .replaceFirst(
                          '%1',
                          _aprilJokes.getBotName(),
                        ),
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _getLocalizedDifficultyLevel(),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
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
          ],
        ),
        onTap: () {
          _pickDifficultyLevel(context);
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

enum Difficulties { easy, normal, hard, veryHard }
