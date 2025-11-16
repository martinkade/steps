import 'package:firebase_database/firebase_database.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/calendar.dart';
import 'package:intl/intl.dart';
import 'package:wandr/util/AprilJokes.dart';

class FitRanking {
  static int fitRankingTypeSingle = 0;
  static int fitRankingTypeTeam = 1;
  static int fitRankingTypeOrganization = 2;

  final Map<String, List<FitRankingEntry>> entries = Map.fromEntries([
    MapEntry('today', <FitRankingEntry>[]),
    MapEntry('yesterday', <FitRankingEntry>[]),
    MapEntry('week', <FitRankingEntry>[]),
    MapEntry('lastWeek', <FitRankingEntry>[]),
    MapEntry('total', <FitRankingEntry>[]),
  ]);
  num totalPoints = 0, totalUsers = 0;
  List<num> challengeTotals = <num>[];
  List<String> obsoleteUserIdList = <String>[];
  FitRanking._internal();

  static Future<FitRanking> createFromFirebaseSnapshot(
    DatabaseEvent databaseEvent,
  ) async {
    final FitRanking ranking = FitRanking._internal();

    final Map<String, Map<String, Map<String, dynamic>>> summary = Map();
    final Map<String, Map<String, num>> participation = Map();
    final Calendar calendar = Calendar();
    final DateTime now = DateTime.now();

    DateTime? timestamp;
    String itemKey, itemName;
    String? teamKey, organizationKey;
    int timestampKey;
    dynamic data;
    Map<String, Map<String, dynamic>> categoryValue = Map();

    DataSnapshot dataSnapshot;
    String userId;
    dynamic value;
    final Iterator iterator = databaseEvent.snapshot.children.iterator;
    // iterate through user documents
    while (iterator.moveNext()) {
      dataSnapshot = iterator.current;
      if (dataSnapshot.key == null) continue;
      if (dataSnapshot.value == null) continue;
      userId = dataSnapshot.key!;
      value = dataSnapshot.value!;
      itemKey = userId;

      if (value['meta'] == null) {
        ranking.obsoleteUserIdList.add(userId);
        continue;
      }

      timestampKey = value['meta']['timestamp']?.toInt() ?? 0;
      timestamp = timestampKey > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestampKey)
          : null;
      if (timestamp == null ||
          timestamp.isBefore(now.subtract(Duration(days: 365)))) {
        ranking.obsoleteUserIdList.add(userId);
        continue;
      }

      data = value['stats'] == null ? value : value['stats'];
      // print('FitRanking#createFromSnapshot:\n\t$key\n\t$data');

      itemName = value['meta']['displayName'] ?? 'Anonym';
      if (value['organization'] == null) {
        teamKey = null;
        organizationKey = value['team'];
      } else {
        teamKey = value['team'];
        organizationKey = value['organization'];
      }

      if (userId == AprilJokes.botID) {
        AprilJokes.botName = itemName;
      }

      // collect points
      // - sum user's weekly points if sync timestamp is within current week
      // - sum user's last weeks points if sync timestamp is within current week
      if (calendar.isThisWeek(timestamp, now)) {
        // this week, last week
        readCategoriesData(
          ['week', 'lastWeek'],
          ['week', 'lastWeek'],
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation,
        );
      } else if (calendar.isLastWeek(timestamp, now)) {
        // last week
        readCategoryData(
          'week',
          'lastWeek',
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation,
        );
      }

      // collect points
      // - sum user's today points if sync timestamp is today
      // - sum user's yesterday points if sync timestamp is today
      if (calendar.isToday(timestamp, now)) {
        // today, yesterday
        readCategoriesData(
          ['today', 'yesterday'],
          ['today', 'yesterday'],
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation,
        );
      } else if (calendar.isYesterday(timestamp, now)) {
        // yesterday
        readCategoryData(
          'today',
          'yesterday',
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation,
        );
      }

      if (calendar.isThisYear(timestamp, now)) {
        // year
        readCategoryData(
          'year',
          'year',
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation,
        );
      }

      // total
      readCategoryData(
        'total',
        'total',
        itemKey,
        itemName,
        teamKey,
        organizationKey,
        timestamp,
        data,
        categoryValue,
        summary,
        participation,
      );

      ranking.totalPoints += data['total'] as num;

      // count active users (active: if synced within last 14 days)
      if (!timestamp.isBefore(now.subtract(Duration(days: 14)))) {
        ranking.totalUsers += 1;
      }

      if (value['challenges']?.isNotEmpty == true) {
        final dynamic challengeList = value['challenges'];
        final int challengeCount = challengeList.length;
        final List<num> newTotals =
            List.castFrom<dynamic, num>(challengeList.map((c) => c).toList());
        if (challengeCount > ranking.challengeTotals.length) {
          for (int i = ranking.challengeTotals.length;
              i < newTotals.length;
              i++) {
            ranking.challengeTotals.insert(i, 0);
          }
        }
        newTotals
            .asMap()
            .forEach((i, value) => ranking.challengeTotals[i] += value);
      }
    }

    List<String> itemKeys;
    summary.forEach((categoryKey, categoryValue) {
      itemKeys = categoryValue.keys.toList(growable: false);
      // print('$itemKeys \n\t$categoryValue');
      itemKeys.sort((k1, k2) => (categoryValue[k2]!['value']?.toInt() ?? 0)
          .compareTo((categoryValue[k1]!['value']?.toInt() ?? 0)));
      itemKeys.forEach((itemKey) {
        ranking.addEntry(categoryKey,
            userKey: itemKey,
            name: categoryValue[itemKey]!['name'],
            value: categoryValue[itemKey]!['value'],
            sync: categoryValue[itemKey]!['sync'],
            type: categoryValue[itemKey]!['type'],
            userCount: (participation[categoryKey]![itemKey] ?? 0).toInt());
      });
    });

    return ranking;
  }

  static void readCategoriesData(
      List<String> categories,
      List<String> destinations,
      String itemKey,
      String itemName,
      String? teamKey,
      String? organizationKey,
      DateTime timestamp,
      dynamic data,
      Map<String, Map<String, dynamic>> categoryValue,
      Map<String, Map<String, Map<String, dynamic>>> summary,
      Map<String, Map<String, num>> participation) {
    for (var i = 0; i < categories.length; i++) {
      readCategoryData(
          categories[i],
          destinations[i],
          itemKey,
          itemName,
          teamKey,
          organizationKey,
          timestamp,
          data,
          categoryValue,
          summary,
          participation);
    }
  }

  static void readCategoryData(
      String categoryKey,
      String destinationKey,
      String itemKey,
      String itemName,
      String? teamKey,
      String? organizationKey,
      DateTime timestamp,
      dynamic data,
      Map<String, Map<String, dynamic>> categoryValue,
      Map<String, Map<String, Map<String, dynamic>>> summary,
      Map<String, Map<String, num>> participation) {
    if (summary.containsKey(destinationKey)) {
      categoryValue = summary[destinationKey]!;
    } else {
      categoryValue = Map();
    }

    if (!categoryValue.containsKey(itemKey)) {
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

    if (teamKey?.isNotEmpty == true &&
        categoryValue.containsKey(teamKey) &&
        categoryValue[teamKey]!['type'] == fitRankingTypeTeam) {
      categoryValue[teamKey]!['value'] += data[categoryKey];
    } else if (teamKey?.isNotEmpty == true) {
      categoryValue.putIfAbsent(
        teamKey!,
        () => Map.fromEntries([
          MapEntry('name', teamKey),
          MapEntry('value', data[categoryKey]),
          MapEntry('sync', timestamp),
          MapEntry('type', fitRankingTypeTeam)
        ]),
      );
    }

    if (organizationKey?.isNotEmpty == true &&
        categoryValue.containsKey(organizationKey) &&
        categoryValue[organizationKey]!['type'] == fitRankingTypeOrganization) {
      categoryValue[organizationKey]!['value'] += data[categoryKey];
    } else if (organizationKey?.isNotEmpty == true) {
      categoryValue.putIfAbsent(
        organizationKey!,
        () => Map.fromEntries([
          MapEntry('name', organizationKey),
          MapEntry('value', data[categoryKey]),
          MapEntry('sync', timestamp),
          MapEntry('type', fitRankingTypeOrganization)
        ]),
      );
    }

    if (summary.containsKey(destinationKey)) {
      summary.update(destinationKey, (v) => categoryValue);
    } else {
      summary.putIfAbsent(destinationKey, () => categoryValue);
    }

    if (participation.containsKey(destinationKey)) {
      if (teamKey?.isNotEmpty == true &&
          participation[destinationKey]?.containsKey(teamKey) == true) {
        final int value = participation[destinationKey]![teamKey]!.toInt();
        participation[destinationKey]![teamKey!] = value + 1;
      } else if (teamKey?.isNotEmpty == true) {
        participation[destinationKey]!.putIfAbsent(teamKey!, () => 1);
      }

      if (organizationKey?.isNotEmpty == true &&
          participation[destinationKey]?.containsKey(organizationKey) == true) {
        final int value =
            participation[destinationKey]![organizationKey]!.toInt();
        participation[destinationKey]![organizationKey!] = value + 1;
      } else if (organizationKey?.isNotEmpty == true) {
        participation[destinationKey]!.putIfAbsent(organizationKey!, () => 1);
      }
    } else {
      if (teamKey?.isNotEmpty == true) {
        participation.putIfAbsent(
            destinationKey, () => Map.fromEntries([MapEntry(teamKey!, 1)]));
      }

      if (organizationKey?.isNotEmpty == true) {
        participation.putIfAbsent(destinationKey,
            () => Map.fromEntries([MapEntry(organizationKey!, 1)]));
      }
    }
  }

  void addEntry(
    String key, {
    required String userKey,
    required String name,
    required num value,
    required DateTime sync,
    required int type,
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
  num value;
  final int userCount;
  final int type;
  final DateTime sync;
  FitRankingEntry({
    required this.key,
    required this.name,
    required this.value,
    required this.sync,
    required this.type,
    this.userCount = 0,
  });

  String get timestamp {
    final DateTime now = DateTime.now();
    final Calendar calendar = Calendar();
    if (calendar.isToday(sync, now))
      return DateFormat('HH:mm', LOCALE).format(sync);
    return DateFormat('dd.MM.yyyy, HH:mm', LOCALE).format(sync);
  }
}
