import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

class FitChallengeWeek extends FitChallenge {
  FitChallengeWeek(BuildContext context)
      : super(
          context,
          title: Localizer.translate(context, 'lblWeekChallengeTitle'),
          description:
              Localizer.translate(context, 'lblWeekChallengeDescription'),
          imageAsset: 'assets/images/challenge1.jpg',
        );

  @override
  bool get requiresSnapshotData => true;

  @override
  bool get requiresRankingData => false;

  @override
  void initTargets() {
    target = 30.0;
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = snapshot.week().toDouble();
    print('week=${snapshot.week()}, progress=$percent');
  }
}
