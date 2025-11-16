import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.plugin.dart';
import 'package:wandr/model/fit.record.dart';
import 'dart:io' show Platform;

import 'package:wandr/model/preferences.dart';

class FitSnapshot {
  num _today = 0;
  num _yesterday = 0;
  num _week = 0;
  num _lastWeek = 0;
  num _year = 0;
  num _total = 0;

  final Calendar calendar = Calendar();
  Map<String, num> _challengeResults = Map();
  Map<String, dynamic> _history = Map();

  ///
  FitSnapshot();

  ///
  void _reset() {
    _today = 0;
    _yesterday = 0;
    _week = 0;
    _lastWeek = 0;
    _year = 0;
    _total = 0;
    _challengeResults.clear();
    _history.clear();
  }

  /// Fill snapshot with data that is present in on-device SQLite database.
  Future<void> fillWithCachedData(
    List<FitRecord> recordList, {
    required List<FitChallenge> challengeList,
    required DateTime anchor,
  }) async {
    _reset();

    int points;
    DateTime date;
    bool isAfterStart, isBeforeEnd;
    challengeList
        .forEach((challenge) => _challengeResults[challenge.uniqueId] = 0);

    final DateTime now = DateTime.now();
    recordList.forEach((record) {
      date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
      if (date.isAfter(anchor) || date.isAtSameMomentAs(anchor)) {
        points = record.type == FitRecord.TYPE_ACTIVE_MINUTES
            ? record.value
            : record.value ~/ 80;
        _total += points;
        if (points > 0) {
          _history.putIfAbsent(
            record.dateTimeString,
            () => Map.fromEntries([
              MapEntry('source', record.source),
              MapEntry('type', record.type),
              MapEntry('value', record.value),
              MapEntry('name', record.name),
            ]),
          );
        }
        if (calendar.isThisYear(date, now)) {
          _year += points;
        }
        if (calendar.isThisWeek(date, now)) {
          _week += points;
          if (calendar.isToday(date, now)) {
            _today += points;
          } else if (calendar.isYesterday(date, now)) {
            _yesterday += points;
          }
        } else if (calendar.isLastWeek(date, now)) {
          _lastWeek += points;
          if (calendar.isYesterday(date, now)) {
            _yesterday += points;
          }
        }

        challengeList.forEach((challenge) {
          isAfterStart = date.isAfter(challenge.startDate) ||
              date.isAtSameMomentAs(challenge.startDate);
          isBeforeEnd = date.isBefore(challenge.endDate) ||
              date.isAtSameMomentAs(challenge.endDate);
          if (isAfterStart && isBeforeEnd) {
            _challengeResults.update(challenge.uniqueId, (old) => old + points,
                ifAbsent: () => points);
          }
        });
      }
    });
  }

  /// Write provider data (either Apple Health or Health Connect) to on-device SQLite database.
  Future<void> writeFitProviderDataToCache(
    FitRecordDao dao,
    Map<dynamic, dynamic> data,
  ) async {
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
  Future<Map<String, dynamic>> createDataSnapshot() async {
    final Map<String, dynamic> meta = Map.fromEntries([
      MapEntry('timestamp', DateTime.now().millisecondsSinceEpoch),
      MapEntry('device', await FitPlugin.getDeviceInfo()),
      MapEntry('client', await FitPlugin.getAppInfo()),
      MapEntry('displayName', await Preferences().getDisplayName()),
    ]);
    final Map<String, dynamic> stats = Map.fromEntries([
      MapEntry('today', todaysPoints),
      MapEntry('yesterday', yesterdaysPoints),
      MapEntry('week', weeksPoints),
      MapEntry('lastWeek', lastWeeksPoints),
      MapEntry('year', yearsPoints),
      MapEntry('total', totalPoints),
    ]);
    return Map.fromEntries([
      MapEntry('meta', meta),
      MapEntry('stats', stats),
      MapEntry('history', history),
      MapEntry('challenges', challengePoints),
    ]);
  }

  ///
  num get todaysPoints => _today;

  ///
  num get yesterdaysPoints => _yesterday;

  ///
  num get weeksPoints => _week;

  ///
  num get lastWeeksPoints => _lastWeek;

  ///
  num get yearsPoints => _year;

  ///
  num get totalPoints => _total;

  ///
  List<num> get challengePoints =>
      _challengeResults.entries.map((entry) => entry.value).toList();

  ///
  Map<String, dynamic> get history => _history;
}
