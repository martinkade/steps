import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge1Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 8, 31);

  ///
  FitChallenge1Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          title: Localizer.translate(context, 'lblTeamChallenge1Title'),
          description:
              Localizer.translate(context, 'lblTeamChallenge1Description'),
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
    progress = (ranking.challenge1?.toDouble() ?? 0.0) / 12.0;
  }
}
