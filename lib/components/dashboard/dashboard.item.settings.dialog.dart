import 'dart:math';
import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';

class DashboardSettingsDialogContent extends StatelessWidget {
  final Function setDailyTargetPoints;
  final List<int> activityLevels;

  DashboardSettingsDialogContent({this.setDailyTargetPoints, this.activityLevels});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(312.0, MediaQuery.of(context).size.height * 0.33),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      Localizer.translate(context, 'lblDashboardSettingsTitle'),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                      child: Text(
                        Localizer.translate(
                            context, 'lblDashboardSettingsText'),
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: activityLevels.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FlatButton(
                            child: Text(
                              Localizer.translate(
                                  context,
                                  'lblDashboardSettingsOption' +
                                      index.toString()),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            splashColor: Colors.blue.withAlpha(50),
                            color: DAILY_TARGET_POINTS ==
                                activityLevels[index]
                                ? Colors.blue.withAlpha(50)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: DAILY_TARGET_POINTS ==
                                            activityLevels[index]
                                        ? Colors.blue.withAlpha(50)
                                        : Colors.grey,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(5)),
                            onPressed: () {
                              setDailyTargetPoints(index);
                            },
                          );
                        })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
