import 'package:flutter/foundation.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.plugin.dart';
import 'package:wandr/model/fit.record.dart';
import 'dart:io' show Platform;

import 'package:wandr/model/preferences.dart';

class FitSnapshot {
  ///
  Map<dynamic, dynamic> data = Map();

  ///
  FitSnapshot();

  ///
  void _reset() {
    data.clear();
  }

  ///
  void fillWithLocalData(
    List<FitRecord> records, {
    List<FitChallenge> challenges,
    @required DateTime anchor,
  }) {
    _reset();

    final Map<String, dynamic> history = Map();
    final List<int> challengePoints = List.filled(challenges.length, 0);

    int today = 0;
    int yesterday = 0;
    int week = 0;
    int lastWeek = 0;
    int year = 0;
    int total = 0;

    int points;
    DateTime date;
    final DateTime now = DateTime.now();
    final Calendar calendar = Calendar();
    records.forEach((record) {
      date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
      if (date.isAfter(anchor) || date.isAtSameMomentAs(anchor)) {
        points = record.type == FitRecord.TYPE_ACTIVE_MINUTES
            ? record.value
            : record.value ~/ 80;
        total += points;
        if (points > 0)
          history.putIfAbsent(
            record.dateTimeString,
            () => Map.fromEntries([
              MapEntry('source', record.source),
              MapEntry('type', record.type),
              MapEntry('value', record.value),
              MapEntry('name', record.name),
            ]),
          );
        if (calendar.isThisYear(date, now)) {
          year += points;
        }
        if (calendar.isThisWeek(date, now)) {
          week += points;
          if (calendar.isToday(date, now)) {
            today += points;
          } else if (calendar.isYesterday(date, now)) {
            yesterday += points;
          }
        } else if (calendar.isLastWeek(date, now)) {
          lastWeek += points;
          if (calendar.isYesterday(date, now)) {
            yesterday += points;
          }
        }

        challenges.forEach((challenge) {
          if (date.isAfter(challenge.startDate) ||
              date.isAtSameMomentAs(challenge.startDate)) {
            if (date.isBefore(challenge.endDate) ||
                date.isAtSameMomentAs(challenge.endDate)) {
              challengePoints[challenge.index] += points;
            }
          }
        });
      }
    });

    data['stats'] = Map<String, dynamic>();
    data['stats']['today'] = today;
    data['stats']['yesterday'] = yesterday;
    data['stats']['week'] = week;
    data['stats']['lastWeek'] = lastWeek;
    data['stats']['year'] = year;
    data['stats']['total'] = total;
    data['history'] = history;
    data['challenges'] = challengePoints;
  }

  ///
  Future<void> fillWithExternalData(
      FitRecordDao dao, Map<dynamic, dynamic> data) async {
    final int source = Platform.isIOS
        ? FitRecord.SOURCE_APPLE_HEALTH
        : FitRecord.SOURCE_GOOGLE_FIT;
    print('Import external data: $data');
    DateTime id;
    FitRecord record;
    final List<FitRecord> records = <FitRecord>[];
    if (source == FitRecord.SOURCE_GOOGLE_FIT) {
      data['activeMinutes']?.forEach((key, value) {
        id = DateTime.parse(key);
        record = FitRecord(dateTime: id);
        record.fill(
          source: source,
          value: value.toInt(),
          type: FitRecord.TYPE_ACTIVE_MINUTES,
        );
        records.add(record);
      });
    } else {
      data['activeMinutes']?.forEach((key, value) {
        id = DateTime.parse(key);
        record = FitRecord(dateTime: id);
        record.fill(
          source: source,
          value: value.toInt(),
          type: FitRecord.TYPE_ACTIVE_MINUTES,
        );
        records.add(record);
      });
      data['steps']?.forEach((key, value) {
        id = DateTime.parse(key).add(Duration(seconds: 1));
        record = FitRecord(dateTime: id);
        record.fill(
          source: source,
          value: value.toInt(),
          type: FitRecord.TYPE_STEPS,
        );
        records.add(record);
      });
    }

    await dao.insertOrReplace(records: records);
  }

  ///
  Future<Map<String, dynamic>> persist() async {
    final Map<String, dynamic> meta = Map.fromEntries([
      MapEntry('timestamp', DateTime.now().millisecondsSinceEpoch),
      MapEntry('device', await FitPlugin.getDeviceInfo()),
      MapEntry('client', await FitPlugin.getAppInfo()),
      MapEntry('displayName', await Preferences().getDisplayName()),
    ]);
    final Map<String, dynamic> stats = Map.fromEntries([
      MapEntry('today', today),
      MapEntry('yesterday', yesterday),
      MapEntry('week', week),
      MapEntry('lastWeek', lastWeek),
      MapEntry('year', year),
      MapEntry('total', total),
    ]);
    return Map.fromEntries([
      MapEntry('meta', meta),
      MapEntry('stats', stats),
      MapEntry('history', history),
      MapEntry('challenges', challenges),
      // temporary, compatibility reasons: section 1
      MapEntry('today', today),
      MapEntry('yesterday', yesterday),
      MapEntry('week', week),
      MapEntry('lastWeek', lastWeek),
      MapEntry('year', year),
      MapEntry('total', total),
      // temporary, compatibility reasons: section 2
      MapEntry('timestamp', DateTime.now().millisecondsSinceEpoch),
      MapEntry('device', await FitPlugin.getDeviceInfo()),
      MapEntry('client', await FitPlugin.getAppInfo()),
    ]);
  }

  ///
  num get today =>
      data['stats'] == null ? data['today'] ?? 0 : data['stats']['today'] ?? 0;

  ///
  num get yesterday => data['stats'] == null
      ? data['yesterday'] ?? 0
      : data['stats']['yesterday'] ?? 0;

  ///
  num get week =>
      data['stats'] == null ? data['week'] ?? 0 : data['stats']['week'] ?? 0;

  ///
  num get lastWeek => data['stats'] == null
      ? data['lastWeek'] ?? 0
      : data['stats']['lastWeek'] ?? 0;

  ///
  num get year =>
      data['stats'] == null ? data['year'] ?? 0 : data['stats']['year'] ?? 0;

  ///
  num get total =>
      data['stats'] == null ? data['total'] ?? 0 : data['stats']['total'] ?? 0;

  ///
  Map<String, dynamic> get history => data['history'] ?? Map();

  ///
  List<num> get challenges =>
      List.castFrom<dynamic, int>(data['challenges'].map((c) => c).toList()) ??
      [0, 0, 0, 0];
}
