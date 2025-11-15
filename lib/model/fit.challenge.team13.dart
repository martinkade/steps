import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge13Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2025, 10, 22, 13, 30);
  static DateTime kEndDate = DateTime(2025, 10, 26, 21, 30);

  ///
  FitChallenge13Team()
      : super(
          index: 12,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'PMI - PMI around Mallorca entlang der Küstenlinie',
          description:
              'Wir starten Mittwoch am Flughafen Palma und haben bis Sonntag Zeit 554,7 km gemeinsam zu erlaufen, so dass wir rechtzeitig in unsere Nach-Hause-Flieger steigen können.\n\nWie immer: jeder Schritt zählt - Vamos, CAMINANDO',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge13.jpg',
          routeAsset: null,
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 554.7; // km
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
