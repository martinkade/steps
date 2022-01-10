import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge3Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 11, 03);
  static DateTime kEndDate = DateTime(2020, 12, 24);

  ///
  FitChallenge3Team()
      : super(
          index: 2,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Polarlichter angucken am Nordkap',
          description:
              'An festes Schuhwerk sind wir schon gewöhnt, aber jetzt brauchen wir auch noch Mütze und Schal - es wird kalt 🥶 Diese WANDR Challenge bringt uns in den Norden, mit einem kleinen Abstecher zum Weihnachtsmann. Wenn wir schnell genug sind, können wir unsere Wunschzettel persönlich abgeben, ist ja immer besser 😉\n\nUnd dann ist unser Ziel auch nicht mehr weit - Polarlichter angucken am Nordkap."',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge3.jpg',
        );
  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 3421.0; // km
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
