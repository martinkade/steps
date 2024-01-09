import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge10Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2024, 01, 09);
  static DateTime kEndDate = DateTime(2024, 2, 29);

  ///
  FitChallenge10Team()
      : super(
    index: 9,
    startDate: kStartDate,
    endDate: kEndDate,
    title: 'Der Ostseeküsten-Radweg',
    description:
    'In diesem Jahr starte wir mit einer einfachen Challenge. Auf dem Ostseeküsten-Radweg geht es von Kupfermühle an der dänischen Grenze entlang der Ostseeküste bis nach Ahlbeck an der polnischen Grenze.',
    label: 'Kilometer',
    imageAsset: 'assets/images/challenge10.jpg',
    routeAsset: null,
  );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1140.0; // km
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
