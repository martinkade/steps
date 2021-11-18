import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge4Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2021, 11, 22);
  static DateTime kEndDate = DateTime(2021, 12, 19);

  ///
  FitChallenge4Team(BuildContext context)
      : super(
          context,
          startDate: kStartDate,
          endDate: kEndDate,
          title: Localizer.translate(context, 'lblTeamChallenge4Title'),
          description:
              Localizer.translate(context, 'lblTeamChallenge4Description'),
          label: Localizer.translate(context, 'lblUnitKilometer'),
          imageAsset: 'assets/images/challenge4.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1662.0; // km
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = (ranking.challenge4?.toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}