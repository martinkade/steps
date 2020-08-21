import 'package:flutter/material.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

const int DAILY_TARGET_POINTS = 75;

abstract class FitChallenge {
  final String title;
  String description;
  String label;
  final String imageAsset;

  double target = 1.0;
  double progress = 0.0;
  double get percent => progress / target;

  FitChallenge(BuildContext context, {this.title, this.description, this.label, this.imageAsset}) {
    initTargets();
  }

  bool get requiresSnapshotData => true;
  bool get requiresRankingData => true;

  void initTargets();

  void load({FitSnapshot snapshot, FitRanking ranking}) {
    if ((requiresRankingData && ranking == null) ||
        (requiresSnapshotData && snapshot == null)) return;
    print('load challenge data from snapshot=$snapshot and ranking=$ranking');
    evaluate(snapshot: snapshot, ranking: ranking);
  }

  void evaluate({FitSnapshot snapshot, FitRanking ranking});
}
