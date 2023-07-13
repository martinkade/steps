import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge8Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2022, 10, 15);
  static DateTime kEndDate = DateTime(2022, 12, 31);

  ///
  FitChallenge8Team()
      : super(
          index: 7,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Jakobsweg',
          description:
              'Von Ahaus starten wir in Richtung Spanien. Dort können wir dann entspannt mit einem Esel den Jakobsweg entlangpilgern bis der Atlantik in Sicht kommt.',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge8.jpg',
          routeAsset: 'assets/routes/challenge8.gpx',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 2240.0; // km
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
