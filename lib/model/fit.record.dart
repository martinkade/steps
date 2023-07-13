import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:intl/intl.dart';
import 'package:wandr/model/calendar.dart';

class FitRecord {
  static const int SOURCE_MANUAL = 0;
  static const int SOURCE_GOOGLE_FIT = 1;
  static const int SOURCE_APPLE_HEALTH = 2;

  static const int TYPE_ACTIVE_MINUTES = 0;
  static const int TYPE_STEPS = 1;

  ///
  int timestamp = 0;

  ///
  int source = SOURCE_MANUAL;

  ///
  int type = TYPE_ACTIVE_MINUTES;

  ///
  int value = 0;

  ///
  String? name;

  ///
  int count = 0;

  ///
  FitRecord({DateTime? dateTime}) {
    final DateTime mDateTime = dateTime ?? DateTime.now();
    timestamp = mDateTime
        .subtract(Duration(milliseconds: mDateTime.millisecond))
        .millisecondsSinceEpoch;
    source = SOURCE_MANUAL;
    type = TYPE_ACTIVE_MINUTES;
    value = 0;
  }

  ///
  void initWithCursor(Map<String, dynamic> cursor) {
    timestamp = cursor[FitRecordDao.COL_TIMESTAMP];
    source = cursor[FitRecordDao.COL_SOURCE];
    type = cursor[FitRecordDao.COL_TYPE];
    value = cursor[FitRecordDao.COL_VALUE];
    name = cursor[FitRecordDao.COL_NAME];
    count = 1;
  }

  ///
  void fill(
      {required int source,
      required int value,
      required int type,
      String? name}) {
    this.source = source;
    this.value = value;
    this.type = type;
    this.name = name;
    count = 1;
  }

  ///
  String get idString => timestamp.toString();

  ///
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  ///
  String get dateString => DateFormat('yyyy-MM-dd').format(dateTime);

  ///
  int get dayOfWeek => DateTime.fromMillisecondsSinceEpoch(timestamp).weekday;

  ///
  String get dateTimeString =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

  ///
  String relativeDate(BuildContext context,
      {required Calendar calendar, required DateTime now}) {
    final DateTime date = dateTime;
    if (calendar.isToday(date, now)) {
      return Localizer.translate(context, 'lblToday');
    } else if (calendar.isYesterday(date, now)) {
      return Localizer.translate(context, 'lblYesterday');
    }
    return DateFormat.yMMMEd(LOCALE).format(date);
  }

  ///
  String relativeDateTime(BuildContext context,
      {required Calendar calendar, required DateTime now}) {
    final DateTime date = dateTime;
    return DateFormat.Hm(LOCALE).format(date);
  }

  ///
  String typeString(BuildContext context) {
    switch (type) {
      case TYPE_ACTIVE_MINUTES:
        return Localizer.translate(context, 'lblUnitActiveMinutes');
      default:
        return Localizer.translate(context, 'lblUnitSteps');
    }
  }

  ///
  String valueString({bool displayKilometers = false}) {
    if (displayKilometers) {
      return (value / 12.0).toStringAsFixed(1);
    }
    return value.toString();
  }

  ///
  String title(BuildContext context) {
    if (count > 1) {
      return Localizer.translate(context, 'lblHistoryDataMultiple')
          .replaceFirst('%1', count.toString());
    }
    if (source == SOURCE_MANUAL) {
      return name ?? Localizer.translate(context, 'lblHistoryDataManual');
    } else if (source == SOURCE_GOOGLE_FIT) {
      return Localizer.translate(context, 'lblHistoryDataGoogle');
    } else {
      return Localizer.translate(context, 'lblHistoryDataApple');
    }
  }
}
