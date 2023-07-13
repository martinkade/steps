import 'dart:math';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';

class FitChallenge2Team extends FitChallenge {
  ///
  static DateTime kStartDate = DateTime(2020, 9, 14);
  static DateTime kEndDate = DateTime(2020, 11, 02);

  ///
  FitChallenge2Team()
      : super(
            index: 1,
            startDate: kStartDate,
            endDate: kEndDate,
            title: 'Einmal rund um Deutschland',
            description:
                'Von Nizza aus fliegen wir Non-Stop zum Flughafen in Stadtlohn, packen unsere Rucksäcke und schon geht\'s weiter: Wir umrunden Deutschland - im Uhrzeigersinn, für die, die es ganz genau wissen wollen 😉. Lasst euch unterwegs beeindrucken und überraschen, da liegt einiges auf unserem Weg. Und bei 4800 km kommt keine Langeweile auf.\n\n♫ Das WANDRn ist des WANDRers Lust ♫',
            label: 'Kilometer',
            imageAsset: 'assets/images/challenge2.jpg',
            routeAsset: null);

  @override
  bool get requiresSnapshotData => false;

  @override
  bool get requiresRankingData => true;

  @override
  void initTargets() {
    target = 4800.0; // km
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
