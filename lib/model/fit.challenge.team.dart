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
          label: Localizer.translate(context, 'lblUnitKilometer'),
          imageAsset: 'assets/images/challenge1.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1044.0; // km
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = ranking.absolute.toDouble() / 12.0;
  }
}
