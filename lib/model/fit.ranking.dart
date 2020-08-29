import 'package:steps/model/calendar.dart';

class FitRanking {
  final Map<String, List<FitRankingEntry>> entries = Map.fromEntries([
    MapEntry('today', List<FitRankingEntry>()),
    MapEntry('yesterday', List<FitRankingEntry>()),
    MapEntry('week', List<FitRankingEntry>()),
    MapEntry('lastWeek', List<FitRankingEntry>()),
  ]);
  int absolute = 0;
  FitRanking._internal();

  static FitRanking createFromSnapshot(dynamic snapshot) {
    final FitRanking ranking = FitRanking._internal();

    final Map<String, Map<String, num>> summary = Map();
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

      if (timestamp == null) {
        print('!!! user $key is deprecated, missing timestamp');
      } else if (timestamp.isBefore(now.subtract(Duration(days: 7)))) {
        print('!!! user $key is outdated, not synced within last 7 days');
      }

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
      ranking.absolute += value['total'];
    });

    List<String> teamKeys;
    summary.forEach((categoryKey, categoryValue) {
      teamKeys = categoryValue.keys.toList(growable: false);
      teamKeys.sort((k1, k2) => categoryValue[k2].compareTo(categoryValue[k1]));
      teamKeys.forEach((teamKey) {
        ranking.addEntry(categoryKey,
            name: teamKey, value: categoryValue[teamKey].toString());
      });
    });

    return ranking;
  }

  void addEntry(String key, {String name, String value}) {
    entries[key]?.add(FitRankingEntry(name: name, value: value));
  }
}

class FitRankingEntry {
  final String name;
  final String value;
  FitRankingEntry({this.name, this.value});
}
