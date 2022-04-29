import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge7Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2022, 5, 1);
  static DateTime kEndDate = DateTime(2022, 7, 31);

  ///
  FitChallenge7Team()
      : super(
          index: 6,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'WANDR "Rhein"kultur Challenge',
          description: '1357 km am Rhein entlang – 3 Länder, etliche Flußbiegungen, hunderte Brücken und noch viel mehr Schiffe. Da gibt es immer etwas zu sehen. Schuhe zubinden, Rucksack schultern und los geht’s 😊',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge7.jpg',
          routeAsset: 'assets/routes/challenge7.gpx',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1357.0; // km
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
