import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge5Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2021, 12, 16);
  static DateTime kEndDate = DateTime(2022, 1, 31);

  ///
  FitChallenge5Team()
      : super(
          index: 4,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Ä TÄNNSCHEN, Ä TÄNNSCHEN...',
          description:
              'Nachdem wir uns rund um NRW warm gelaufen haben, besuchen wir in Tannenbaumfahrt alle Landeshauptstädte. 16 Bundesländer, keine Herausforderung für uns 😊',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge5.jpg',
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 3216.0; // km
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
