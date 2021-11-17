import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge3Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 11, 03);
  static DateTime kEndDate = DateTime(2020, 12, 24);

  ///
  FitChallenge3Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          endDate: kEndDate,
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
    progress = (ranking.challengeTotals[2]?.toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
