import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge11Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2024, 04, 01);
  static DateTime kEndDate = DateTime(2024, 07, 01);

  ///
  FitChallenge11Team()
      : super(
    index: 10,
    startDate: kStartDate,
    endDate: kEndDate,
    title: 'EM-Stadien Tour',
    description:
    'Die EM 2024 findet wieder in Deutschland statt. In dieser Challenge wollen wir die Stadien ablaufen in denen gespielt wird. Von Ahaus startend zuerst in den Süden bis München um dann über Berlin nach Hamburg in den Norden zu gelangen. Am Ende gehts wieder zurück nach Ahaus.',
    label: 'Kilometer',
    imageAsset: 'assets/images/challenge11.jpg',
    routeAsset: null,
  );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 2098.0; // km
  }

  @override
  void evaluate({FitSnapshot? snapshot, FitRanking? ranking}) {
    progress = (ranking?.challengeTotals[index].toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
