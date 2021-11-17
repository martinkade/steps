import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge2Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 9, 14);
  static DateTime kEndDate = DateTime(2020, 11, 02);

  ///
  FitChallenge2Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          endDate: kEndDate,
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
    progress = (ranking.challengeTotals[1]?.toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
