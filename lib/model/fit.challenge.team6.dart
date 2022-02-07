import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge6Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2022, 2, 1);
  static DateTime kEndDate = DateTime(2022, 5, 31);

  ///
  FitChallenge6Team()
      : super(
          index: 5,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Finale wir kommen',
          description: 'Der Ball ist rund und das Spiel dauert 90 Minuten. Bis November ist es noch ein bisschen länger, somit Zeit genug für uns uns auf den Weg nach Katar zu machen und den Weltmeistertitel abzuholen.',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge6.jpg',
          routeAsset: 'assets/routes/challenge6.gpx',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 6780.0; // km
  }

  @override
  void evaluate({FitSnapshot snapshot, FitRanking ranking}) {
    progress = (ranking.challengeTotals[index]?.toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
