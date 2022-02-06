import 'package:flutter/foundation.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/calendar.dart';
import 'package:intl/intl.dart';

class FitRanking {
  static int fitRankingTypeSingle = 0;
  static int fitRankingTypeTeam = 1;

  final Map<String, List<FitRankingEntry>> entries = Map.fromEntries([
    MapEntry('today', <FitRankingEntry>[]),
    MapEntry('yesterday', <FitRankingEntry>[]),
    MapEntry('week', <FitRankingEntry>[]),
    MapEntry('lastWeek', <FitRankingEntry>[]),
    MapEntry('total', <FitRankingEntry>[]),
  ]);
  int totalPoints = 0, totalUsers = 0;
  List<int> challengeTotals = <int>[];
  FitRanking._internal();

  static FitRanking createFromSnapshot(dynamic snapshot) {
    final FitRanking ranking = FitRanking._internal();

    final Map<String, Map<String, Map<String, dynamic>>> summary = Map();
    final Map<String, num> participation = Map();
    final Calendar calendar = Calendar();
    final DateTime now = DateTime.now();

    DateTime timestamp;
    String itemKey, itemName, categoryKey, teamKey;
    int timestampKey;
    dynamic data;
    Map<String, Map<String, dynamic>> categoryValue;

    // iterate through user documents
    snapshot.value.forEach((userId, value) {
      itemKey = userId;
      teamKey = value['team'];
      itemName = value['meta'] == null
          ? 'Anonym'
          : value['meta']['displayName'] ?? 'Anonym';
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data['week']);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data[categoryKey]);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data['today']);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
        }

        if (summary.containsKey(categoryKey)) {
          summary.update(categoryKey, (v) => categoryValue);
        } else {
          summary.putIfAbsent(categoryKey, () => categoryValue);
        }
      }

      if (timestampKey > 0 && calendar.isThisYear(timestamp, now)) {
        // year
        categoryKey = 'year';
        if (summary.containsKey(categoryKey)) {
          categoryValue = summary[categoryKey];
        } else {
          categoryValue = Map();
        }

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data['year']);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
                  MapEntry('name', teamKey),
                  MapEntry('value', data[categoryKey]),
                  MapEntry('sync', timestamp),
                  MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        if (categoryValue.containsKey(itemKey)) {
          // categoryValue.update(itemKey, (v) => v + data['total']);
        } else {
          categoryValue.putIfAbsent(
            itemKey,
            () => Map.fromEntries([
              MapEntry('name', itemName),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeSingle)
            ]),
          );
        }

        if (categoryValue.containsKey(teamKey)) {
          categoryValue[teamKey]["value"] += data[categoryKey];
        } else {
          categoryValue.putIfAbsent(
            teamKey,
                () => Map.fromEntries([
              MapEntry('name', teamKey),
              MapEntry('value', data[categoryKey]),
              MapEntry('sync', timestamp),
              MapEntry('type', fitRankingTypeTeam)
            ]),
          );
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

        ranking.totalUsers += 1;
      } else {
        // print('[INFO] ignore user $userId, has not synced within last 14 days');
      }

      ranking.totalPoints += data['total'] ?? 0;
      if (value['challenges']?.isNotEmpty == true) {
        final int challengeCount = value['challenges'].length;
        final List<int> newTotals = List.castFrom<dynamic, int>(
            value['challenges'].map((c) => c).toList());
        if (challengeCount > ranking.challengeTotals.length) {
          for (int i = ranking.challengeTotals.length;
              i < newTotals.length;
              i++) {
            ranking.challengeTotals.add(0);
          }
        }
        newTotals
            .asMap()
            .forEach((i, value) => {ranking.challengeTotals[i] += value});
      }
    });

    List<String> itemKeys;
    summary.forEach((categoryKey, categoryValue) {
      itemKeys = categoryValue.keys.toList(growable: false);
      // print('$itemKeys \n\t$categoryValue');
      itemKeys.sort((k1, k2) => (categoryValue[k2]['value']?.toInt() ?? 0)
          .compareTo((categoryValue[k1]['value']?.toInt() ?? 0)));
      itemKeys.forEach((itemKey) {
        ranking.addEntry(categoryKey,
            userKey: itemKey,
            name: categoryValue[itemKey]['name'],
            value: categoryValue[itemKey]['value'],
            sync: categoryValue[itemKey]['sync'],
            type: categoryValue[itemKey]['type'],
            userCount: participation[itemKey] ?? 0);
      });
    });

    return ranking;
  }

  void addEntry(
    String key, {
    @required String userKey,
    @required String name,
    @required num value,
    @required DateTime sync,
    @required int type,
    int userCount = 0,
  }) {
    entries[key]?.add(FitRankingEntry(
      key: userKey,
      name: name,
      value: value,
      sync: sync,
      type: type,
      userCount: userCount,
    ));
  }
}

class FitRankingEntry {
  final String key, name;
  final num value;
  final int userCount;
  final int type;
  final DateTime sync;
  FitRankingEntry({
    @required this.key,
    @required this.name,
    @required this.value,
    @required this.sync,
    @required this.type,
    this.userCount = 0,
  });

  String get timestamp {
    final DateTime now = DateTime.now();
    final Calendar calendar = Calendar();
    if (calendar.isToday(sync, now))
      return DateFormat('HH:mm', LOCALE ?? 'de_DE').format(sync);
    return DateFormat('dd.MM.yyyy, HH:mm', LOCALE ?? 'de_DE').format(sync);
  }
}