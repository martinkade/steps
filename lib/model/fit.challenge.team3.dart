import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

class FitChallenge3Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 11, 03);

  ///
  FitChallenge3Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          title: Localizer.translate(context, 'lblTeamChallenge3Title'),
          description:
              Localizer.translate(context, 'lblTeamChallenge3Description'),
          label: Localizer.translate(context, 'lblUnitKilometer'),
          imageAsset: 'assets/images/challenge3.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 3421.0; // km
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = (ranking.challenge3?.toDouble() ?? 0.0) / 12.0;
  }
}
