import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/util/AprilJokes.dart';

class DashboardSettingsDifficultyLevelDialog extends StatelessWidget {
  final Function setDifficultyLevel;
  final List<int> difficultyLevels;
  final int selectedLevel;

  DashboardSettingsDifficultyLevelDialog({
    this.setDifficultyLevel,
    this.difficultyLevels,
    this.selectedLevel,
  });

  String _getLocalizedDifficultyLevel(BuildContext context, int index) {
    Difficulties difficulty = Difficulties.values[index];
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
    return Localizer.translate(context, 'lblDashboardSettingsDifficulty2');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(312.0, MediaQuery.of(context).size.height * 0.33),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          children: [
            Text(
              Localizer.translate(context, 'lblSettingsDifficultyTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                Localizer.translate(context, 'lblSettingsDifficultyDialogInfo')
                    .replaceFirst(
                  '%1',
                  AprilJokes().getBotName(),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: difficultyLevels.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      child: Text(
                        _getLocalizedDifficultyLevel(context, index),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: selectedLevel == difficultyLevels[index]
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        setDifficultyLevel(index);
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
