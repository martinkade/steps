import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge9Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2023, 01, 13);
  static DateTime kEndDate = DateTime(2023, 12, 31);

  ///
  FitChallenge9Team()
      : super(
          index: 8,
          startDate: kStartDate,
          endDate: kEndDate,
          title: 'Längter Fußweg der Welt',
          description:
              'Das neue Jahr hat gerade begonnen, daher starten wir langsam mit einer einfachen Challenge. Auf mehr als 23.000 Kilometern wollen wir von L’Agulhas im Süden Südafrikas aus bis nach Magadan im Osten von Russland WANDRn. Der Routenplaner gibt eine Laufzeit von 194 Tagen an, mal gucken ob das nicht auch schneller geht 😉.',
          label: 'Kilometer',
          imageAsset: 'assets/images/challenge9.jpg',
          routeAsset: null,
        );

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 23068.0; // km
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
