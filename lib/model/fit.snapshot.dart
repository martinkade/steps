import 'package:steps/model/cache/fit.record.dao.dart';
import 'package:steps/model/fit.record.dart';
import 'dart:io' show Platform;

class FitSnapshot {
  ///
  Map<dynamic, int> data = Map();

  ///
  FitSnapshot();

  ///
  void fillWithLocalData(List<FitRecord> records) {
    int today = 0;
    int yesterday = 0;
    int week = 0;
    int lastWeek = 0;
    int total = 0;

    int points;
    DateTime date;
    final DateTime anchor = DateTime(2020, 8, 24);
    final DateTime now = DateTime.now();
    records.forEach((record) {
      date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
      if (date.isAfter(anchor) || date.isAtSameMomentAs(anchor)) {
        points = record.type == FitRecord.TYPE_ACTIVE_MINUTES
            ? record.value
            : record.value ~/ 80;
        total += points;
        if (isThisWeek(date, now)) {
          week += points;
          if (isToday(date, now)) {
            today += points;
          } else if (isYesterday(date, now)) {
            yesterday += points;
          }
        } else if (isLastWeek(date, now)) {
          lastWeek += points;
          if (isYesterday(date, now)) {
            yesterday += points;
          }
        }
      }
    });

    if (data['today'] == null) {
      data['today'] = today;
    } else {
      data['today'] = data['today'] + today;
    }

    if (data['yesterday'] == null) {
      data['yesterday'] = yesterday;
    } else {
      data['yesterday'] = data['yesterday'] + yesterday;
    }

    if (data['week'] == null) {
      data['week'] = week;
    } else {
      data['week'] = data['week'] + week;
    }

    if (data['lastWeek'] == null) {
      data['lastWeek'] = lastWeek;
    } else {
      data['lastWeek'] = data['lastWeek'] + lastWeek;
    }

    if (data['total'] == null) {
      data['total'] = total;
    } else {
      data['total'] = data['total'] + total;
    }

    print('$data');
  }

  ///
  Future<void> fillWithExternalData(
      FitRecordDao dao, Map<dynamic, dynamic> data) async {
    final int source = Platform.isIOS
        ? FitRecord.SOURCE_APPLE_HEALTH
        : FitRecord.SOURCE_GOOGLE_FIT;
    DateTime id;
    FitRecord record;
    final List<FitRecord> records = List();
    data['steps']?.forEach((key, value) {
      id = DateTime.parse(key);
      record = FitRecord(dateTime: id);
      record.fill(
          source: source, value: value.toInt(), type: FitRecord.TYPE_STEPS);
      records.add(record);
    });
    data['activeMinutes']?.forEach((key, value) {
      id = DateTime.parse(key);
      record = FitRecord(dateTime: id);
      record.fill(
          source: source,
          value: value.toInt(),
          type: FitRecord.TYPE_ACTIVE_MINUTES);
      records.add(record);
    });

    await dao.insertOrReplace(records: records);

    fillWithLocalData(records);
  }

  ///
  Map<String, num> persist() {
    return Map.fromEntries(
      [
        MapEntry('today', today()),
        MapEntry('yesterday', yesterday()),
        MapEntry('week', week()),
        MapEntry('lastWeek', lastWeek()),
        MapEntry('total', total()),
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
  bool isToday(DateTime moment, DateTime now) {
    return moment.year == now.year &&
        moment.month == now.month &&
        moment.day == now.day;
  }

  ///
  bool isYesterday(DateTime moment, DateTime now) {
    final DateTime yesterday = now.subtract(Duration(days: 1));
    return moment.year == yesterday.year &&
        moment.month == yesterday.month &&
        moment.day == yesterday.day;
  }

  ///
  bool isThisWeek(DateTime moment, DateTime now) {
    final DateTime weekStart = now.subtract(
      Duration(
        days: now.weekday - 1,
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );
    return moment.isAfter(weekStart) || moment.isAtSameMomentAs(weekStart);
  }

  ///
  bool isLastWeek(DateTime moment, DateTime now) {
    final DateTime weekStart = now.subtract(
      Duration(
        days: now.weekday - 1 + 7,
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );
    final DateTime weekEnd = now.subtract(
      Duration(
        days: now.weekday - 1,
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );
    return (moment.isAfter(weekStart) || moment.isAtSameMomentAs(weekStart)) &&
        moment.isBefore(weekEnd);
  }
}
