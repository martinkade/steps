import 'package:flutter/foundation.dart';
import 'package:wandr/model/calendar.dart';

class FitRanking {
  final Map<String, List<FitRankingEntry>> entries = Map.fromEntries([
    MapEntry('today', List<FitRankingEntry>()),
    MapEntry('yesterday', List<FitRankingEntry>()),
    MapEntry('week', List<FitRankingEntry>()),
    MapEntry('lastWeek', List<FitRankingEntry>()),
    MapEntry('total', List<FitRankingEntry>()),
  ]);
  int absolute = 0;
  int challenge1 = 0;
  int challenge2 = 0;
  int challenge3 = 0;
  FitRanking._internal();

  static FitRanking createFromSnapshot(dynamic snapshot) {
    final FitRanking ranking = FitRanking._internal();

    final Map<String, Map<String, num>> summary = Map();
    final Map<String, num> participation = Map();
    final Calendar calendar = Calendar();
    final DateTime now = DateTime.now();

    DateTime timestamp;
    String teamKey, categoryKey;
    int timestampKey;
    Map<String, num> categoryValue;
    snapshot.value.forEach((key, value) {
      // key is user
      teamKey = value['team'];
      timestampKey = value['timestamp']?.toInt() ?? 0;
      timestamp = timestampKey > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestampKey)
          : null;

      // - sum user's weekly points if sync timestamp is within current week
      // - sum user's last weeks points if sync timestamp is within current week
      if (timestampKey != 0 && calendar.isThisWeek(timestamp, now)) {
        // this week
        categoryKey = 'week';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value[categoryKey]);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }

        // last week
        categoryKey = 'lastWeek';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value[categoryKey]);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      } else if (timestampKey != 0 && calendar.isLastWeek(timestamp, now)) {
        // last week
        categoryKey = 'lastWeek';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value['week']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value['week']);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      }
      // - sum user's today points if sync timestamp is today
      // - sum user's yesterday points if sync timestamp is today
      if (timestampKey > 0 && calendar.isToday(timestamp, now)) {
        // today
        categoryKey = 'today';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value[categoryKey]);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }

        // yesterday
        categoryKey = 'yesterday';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value[categoryKey]);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      } else if (timestampKey > 0 && calendar.isYesterday(timestamp, now)) {
        // yesterday
        categoryKey = 'yesterday';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value['today']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value['today']);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      }

      if (timestampKey > 0 &&
          !timestamp.isBefore(now.subtract(Duration(days: 14)))) {
        print(
            '[INFO] sync user $key ($timestamp) with app version ${value['client']} on ${value['device']}');
        // total
        categoryKey = 'total';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + value['total']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => value['total']);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }

        if (participation.containsKey(teamKey)) {
          participation.update(teamKey, (v) => v + 1);
        } else {
          participation.putIfAbsent(teamKey, () => 1);
        }
      } else {
        print('!!! user $key is outdated, not synced within last 14 days');
      }

      ranking.absolute += value['total'] ?? 0;
      if (value['challenges'] != null) {
        ranking.challenge1 += ((value['challenges']?.length ?? 0) > 0)
            ? (value['challenges'][0] ?? 0)
            : 0;
        ranking.challenge2 += ((value['challenges']?.length ?? 0) > 1)
            ? (value['challenges'][1] ?? 0)
            : 0;
        ranking.challenge3 += ((value['challenges']?.length ?? 0) > 2)
            ? (value['challenges'][2] ?? 0)
            : 0;
      } else {
        ranking.challenge1 += value['total'] ?? 0;
      }
    });

    List<String> teamKeys;
    summary.forEach((categoryKey, categoryValue) {
      teamKeys = categoryValue.keys.toList(growable: false);
      teamKeys.sort((k1, k2) => categoryValue[k2].compareTo(categoryValue[k1]));
      teamKeys.forEach((teamKey) {
        ranking.addEntry(categoryKey,
            name: teamKey,
            value: categoryValue[teamKey],
            userCount: participation[teamKey] ?? 0);
      });
    });

    return ranking;
  }

  void addEntry(String key,
      {@required String name, @required num value, int userCount}) {
    entries[key]
        ?.add(FitRankingEntry(name: name, value: value, userCount: userCount));
  }
}

class FitRankingEntry {
  final String name;
  final num value;
  final int userCount;
  FitRankingEntry({@required this.name, @required this.value, this.userCount});
}
