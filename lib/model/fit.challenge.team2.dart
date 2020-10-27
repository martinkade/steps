import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

class FitChallenge2Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 9, 14);

  ///
  FitChallenge2Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          title: Localizer.translate(context, 'lblTeamChallenge2Title'),
          description:
              Localizer.translate(context, 'lblTeamChallenge2Description'),
          label: Localizer.translate(context, 'lblUnitKilometer'),
          imageAsset: 'assets/images/challenge2.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 4800.0; // km
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = (ranking.challenge2?.toDouble() ?? 0.0) / 12.0;
  }
}
