import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/util/AprilJokes.dart';

class DashboardDebugDialog extends StatelessWidget {
  final AprilJokes aprilJokes = AprilJokes();

  final Function setJokeActive;

  DashboardDebugDialog({required this.setJokeActive});

  String _getLocalizedJoke(BuildContext context, int index) {
    Jokes joke = Jokes.values[index];
    switch (joke) {
      case Jokes.rankingLast:
        return Localizer.translate(context, 'lblDashboardDebugJokeRanking');
      case Jokes.botDifficulty:
        return Localizer.translate(context, 'lblDashboardDebugJokeBot');
      case Jokes.purchases:
        return Localizer.translate(context, 'lblDashboardDebugJokePurchases');
      case Jokes.none:
        return Localizer.translate(context, 'lblDashboardDebugJokeNone');
    }
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
              Localizer.translate(context, 'lblDashboardDebugTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                Localizer.translate(context, 'lblDashboardDebugInfo'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Jokes.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      child: Text(
                        _getLocalizedJoke(context, index),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        AprilJokes.activeJoke = Jokes.values[index];
                        setJokeActive(index);
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
