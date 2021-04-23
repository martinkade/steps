import 'package:flutter/material.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

const int DAILY_TARGET_POINTS = 75;

abstract class FitChallenge {
  final DateTime startDate;
  final String title;
  final String description;
  final String label;
  final String imageAsset;

  double target = 1.0;
  double progress = 0.0;
  double get percent => progress / target;

  FitChallenge(
    BuildContext context, {
    @required this.startDate,
    @required this.title,
    @required this.description,
    @required this.label,
    @required this.imageAsset,
  }) {
    initTargets();
  }

  bool get requiresSnapshotData => true;
  bool get requiresRankingData => true;
  bool get isCompleted => percent >= 1.0;

  void initTargets();

  void load({FitSnapshot snapshot, FitRanking ranking}) {
    if ((requiresRankingData && ranking == null) ||
        (requiresSnapshotData && snapshot == null)) return;
    evaluate(snapshot: snapshot, ranking: ranking);
  }

  void evaluate({FitSnapshot snapshot, FitRanking ranking});

  Duration getStartDateDelta(
      {@required Calendar calendar, @required DateTime date}) {
    return calendar.delta(startDate, date);
  }
}
