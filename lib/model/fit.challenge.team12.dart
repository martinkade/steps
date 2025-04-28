import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge12Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2025, 05, 05);
  static DateTime kEndDate = DateTime(2025, 05, 11);

  ///
  FitChallenge12Team()
      : super(
          index: 11,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'WANDR goes HELLWEEK',
          description:
              'Mit ACDC im Ohr nehmen wir die Herausforderung an und erWANDRn ab dem 5. Mai in 7 Tagen 500 000 Schritte. Unsere täglichen Schritte geben wir als Team an die HELLWEEK. Die HELLWEEK will in diesen 7 Tagen 500 Millionen Schritte virtuell sammeln und wir sind dabei, mit 1 Promille 🤣. Challenge accepted 🚶‍♀️🚶🚶‍♂️',
          label: 'Schritte',
          imageAsset: 'assets/images/challenge12.jpg',
          routeAsset: null,
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 500000; // Schritte
  }

  @override
  void evaluate({FitSnapshot? snapshot, FitRanking? ranking}) {
    progress = (ranking?.challengeTotals[index].toDouble() ?? 0.0) * 80;
    final int totalHours = kEndDate.difference(kStartDate).inHours;
    final int hours = max(0, DateTime.now().difference(kStartDate).inHours);
    final double estimatedPercent = min(1.0, hours / totalHours.toDouble());
    estimated = target * estimatedPercent;
  }
}
