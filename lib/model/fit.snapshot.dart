import 'package:flutter/foundation.dart';
import 'package:steps/model/cache/fit.record.dao.dart';
import 'package:steps/model/calendar.dart';
import 'package:steps/model/fit.challenge.team1.dart';
import 'package:steps/model/fit.challenge.team2.dart';
import 'package:steps/model/fit.challenge.team3.dart';
import 'package:steps/model/fit.plugin.dart';
import 'package:steps/model/fit.record.dart';
import 'dart:io' show Platform;

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
  void fillWithLocalData(List<FitRecord> records, {@required DateTime anchor}) {
    _reset();

    int today = 0;
    int yesterday = 0;
    int week = 0;
    int lastWeek = 0;
    int total = 0;

    int challenge1 = 0;
    int challenge2 = 0;
    int challenge3 = 0;

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

        if (date.isAfter(FitChallenge3Team.kStartDate) ||
            date.isAtSameMomentAs(FitChallenge3Team.kStartDate)) {
          challenge3 += points;
        } else if (date.isAfter(FitChallenge2Team.kStartDate) ||
            date.isAtSameMomentAs(FitChallenge2Team.kStartDate)) {
          challenge2 += points;
        } else if (date.isAfter(FitChallenge1Team.kStartDate) ||
            date.isAtSameMomentAs(FitChallenge1Team.kStartDate)) {
          challenge1 += points;
        }
      }
    });

    data['today'] = today;
    data['yesterday'] = yesterday;
    data['week'] = week;
    data['lastWeek'] = lastWeek;
    data['challenges'] = [challenge1, challenge2, challenge3];
    data['total'] = total;
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
    final List<FitRecord> records = List();
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
    return Map.fromEntries(
      [
        MapEntry('today', today()),
        MapEntry('yesterday', yesterday()),
        MapEntry('week', week()),
        MapEntry('lastWeek', lastWeek()),
        MapEntry('challenges', challenges()),
        MapEntry('total', total()),
        MapEntry('timestamp', DateTime.now().millisecondsSinceEpoch),
        MapEntry('device', await FitPlugin.getDeviceInfo()),
        MapEntry('client', await FitPlugin.getAppInfo()),
        /*
        MapEntry(
            '_',
            (await Preferences.getUserKey())
                .split('@')
                .first
                ?.replaceAll('.', '_'))*/
      ],
    );
  }

  ///
  num today() {
    return data['today'] ?? 0;
  }

  ///
  num yesterday() {
    return data['yesterday'] ?? 0;
  }

  ///
  num week() {
    return data['week'] ?? 0;
  }

  ///
  num lastWeek() {
    return data['lastWeek'] ?? 0;
  }

  ///
  num total() {
    return data['total'] ?? 0;
  }

  ///
  List<num> challenges() {
    return data['challenges'] ?? [0, 0];
  }
}
