import 'package:flutter/foundation.dart';
import 'package:wandr/model/calendar.dart';

class FitRanking {
  final Map<String, List<FitRankingEntry>> entries = Map.fromEntries([
    MapEntry('today', <FitRankingEntry>[]),
    MapEntry('yesterday', <FitRankingEntry>[]),
    MapEntry('week', <FitRankingEntry>[]),
    MapEntry('lastWeek', <FitRankingEntry>[]),
    MapEntry('total', <FitRankingEntry>[]),
  ]);
  int absolute = 0;
  List<int> challengeTotals = <int>[];
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
    dynamic data;
    Map<String, num> categoryValue;

    // iterate through user documents
    snapshot.value.forEach((userId, value) {
      teamKey = value['team'];
      timestampKey = value['meta'] == null
          ? value['timestamp']?.toInt() ?? 0
          : value['meta']['timestamp']?.toInt() ?? 0;
      timestamp = timestampKey > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestampKey)
          : null;
      data = value['stats'] == null ? value : value['stats'];
      // print('FitRanking#createFromSnapshot:\n\t$key\n\t$data');

      // collect points
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
          categoryValue.update(teamKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data[categoryKey]);
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
          categoryValue.update(teamKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data[categoryKey]);
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
          categoryValue.update(teamKey, (v) => v + data['week']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data['week']);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      }

      // collect points
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
          categoryValue.update(teamKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data[categoryKey]);
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
          categoryValue.update(teamKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data[categoryKey]);
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
          categoryValue.update(teamKey, (v) => v + data['today']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data['today']);
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      }

      // collect total points if user synced within last 14 days
      if (timestampKey > 0 &&
          !timestamp.isBefore(now.subtract(Duration(days: 14)))) {
        // print('[INFO] sync user $userId ($timestamp)\n\t - with app version ${value['client']}\n\t - on ${value['device']}');

        // total
        categoryKey = 'total';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue.update(teamKey, (v) => v + data['total']);
        } else {
          categoryValue.putIfAbsent(teamKey, () => data['total']);
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
        print('[INFO] ignore user $userId, has not synced within last 14 days');
      }

      ranking.absolute += data['total'] ?? 0;
      if (value['challenges']?.isNotEmpty == true) {
        final int challengeCount = value['challenges'].length;
        final List<int> newTotals = List.castFrom<dynamic, int>(
            value['challenges'].map((c) => c).toList());
        if (challengeCount != ranking.challengeTotals.length) {
          ranking.challengeTotals = newTotals;
        } else {
          newTotals
              .asMap()
              .forEach((i, value) => {ranking.challengeTotals[i] += value});
        }
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

  void addEntry(
    String key, {
    @required String name,
    @required num value,
    int userCount,
  }) {
    entries[key]?.add(FitRankingEntry(
      name: name,
      value: value,
      userCount: userCount,
    ));
  }
}

class FitRankingEntry {
  final String name;
  final num value;
  final int userCount;
  FitRankingEntry({
    @required this.name,
    @required this.value,
    this.userCount,
  });
}
