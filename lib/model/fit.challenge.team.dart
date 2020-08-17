import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

class FitChallengeTeam extends FitChallenge {
  FitChallengeTeam(BuildContext context)
      : super(
          context,
          title: Localizer.translate(context, 'lblTeamChallengeTitle'),
          description:
              Localizer.translate(context, 'lblTeamChallengeDescription'),
          imageAsset: 'assets/images/challenge2.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1000.0;
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = 10.0;
  }
}
