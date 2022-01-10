import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge1Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 8, 31);
  static DateTime kEndDate = DateTime(2020, 9, 13);

  ///
  FitChallenge1Team()
      : super(
          index: 0,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Auf nach Nizza',
          description:
              'Bei allen Team-Challenges geht es darum, gemeinsam einen virtuellen Trail zu absolvieren. Gesammelte Schritte oder aktive Minuten werden dabei in Kilometer umgerechnet.\n\nErstes Ziel ist Kreuztal (165 km), hier spendiert uns Markus ein Eis. Weiter gehts nach Nizza (1044 km), Thomas besuchen. 👋\n\nNur du siehst deine täglichen aktiven Minuten bzw. Schritte, aber jeder kann sehen wie viel der Strecke das Team schon geschafft hat. Anfeuern erwünscht. Los gehts!',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge1.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 1044.0; // km
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
