import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge4Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2021, 11, 22);
  static DateTime kEndDate = DateTime(2021, 12, 19);

  ///
  FitChallenge4Team()
      : super(
          index: 3,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Walk Around NRW',
          description:
              'Nach unserer kurzen Verschnaufpause starten wir in die nächste Runde. Uns erwarten Berge, Flüsse, Schlösser und Sauerbraten 😊',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge4.jpg',
          routeAsset: null
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
    progress = (ranking.challengeTotals[index]?.toDouble() ?? 0.0) / 12.0;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
