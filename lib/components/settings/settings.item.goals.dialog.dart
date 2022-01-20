import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';

class DashboardSettingsActivityLevelDialog extends StatelessWidget {
  final Function setDailyTargetPoints;
  final List<int> activityLevels;
  final int selectedLevel;

  DashboardSettingsActivityLevelDialog({
    this.setDailyTargetPoints,
    this.activityLevels,
    this.selectedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(312.0, MediaQuery.of(context).size.height * 0.33),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          children: [
            Text(
              Localizer.translate(context, 'lblDashboardSettingsTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                Localizer.translate(context, 'lblDashboardSettingsText'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: activityLevels.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      child: Text(
                        Localizer.translate(context,
                            'lblDashboardSettingsOption' + index.toString()),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: selectedLevel == activityLevels[index]
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      splashColor:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                      color: selectedLevel == activityLevels[index]
                          ? Theme.of(context).colorScheme.primary.withAlpha(50)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () {
                        setDailyTargetPoints(index);
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
