import 'package:steps/model/calendar.dart';

class FitRanking {
  final List<FitRankingEntry> entries = List();
  int absolute = 0;
  FitRanking._internal();

  static FitRanking createFromSnapshot(dynamic snapshot) {
    final FitRanking ranking = FitRanking._internal();

    final Map<String, num> summary = Map();
    final Calendar calendar = Calendar();
    final DateTime now = DateTime.now();

    String teamKey;
    int timestampKey;
    snapshot.value.forEach((key, value) {
      // key is user
      teamKey = value['team'];
      timestampKey = value['timestamp']?.toInt() ?? 0;
      // sum user's weekly points if sync timestamp is within current week
      if (timestampKey == 0 ||
          calendar.isThisWeek(
              DateTime.fromMillisecondsSinceEpoch(timestampKey), now)) {
        if (summary.containsKey(teamKey)) {
          summary.update(teamKey, (v) => v + value['week']);
        } else {
          summary.putIfAbsent(teamKey, () => value['week']);
        }
      }
      ranking.absolute += value['total'];
    });

    final List<String> keys = summary.keys.toList(growable: false);
    keys.sort((k1, k2) => summary[k2].compareTo(summary[k1]));
    keys.forEach((k) {
      ranking.addEntry(name: k, value: summary[k].toString());
    });

    return ranking;
  }

  void addEntry({String name, String value}) {
    entries.add(FitRankingEntry(name: name, value: value));
  }
}

class FitRankingEntry {
  final String name;
  final String value;
  FitRankingEntry({this.name, this.value});
}
