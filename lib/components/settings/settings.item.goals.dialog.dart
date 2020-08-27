import 'dart:math';
import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';

class DashboardSettingsDialogContent extends StatelessWidget {
  final Function setDailyTargetPoints;
  final List<int> activityLevels;
  final int selectedLevel;

  DashboardSettingsDialogContent(
      {this.setDailyTargetPoints, this.activityLevels, this.selectedLevel});

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
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                Localizer.translate(context, 'lblDashboardSettingsText'),
                textAlign: TextAlign.start,
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
                      splashColor: Colors.blue.withAlpha(50),
                      color: selectedLevel == activityLevels[index]
                          ? Colors.blue.withAlpha(50)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey,
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
