import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/cache/fit.record.dao.dart';
import 'package:intl/intl.dart';
import 'package:steps/model/calendar.dart';

class FitRecord {
  static const int SOURCE_MANUAL = 0;
  static const int SOURCE_GOOGLE_FIT = 1;
  static const int SOURCE_APPLE_HEALTH = 2;

  static const int TYPE_ACTIVE_MINUTES = 0;
  static const int TYPE_STEPS = 1;

  ///
  int timestamp;

  ///
  int source;

  ///
  int type;

  ///
  int value;

  ///
  String name;

  ///
  FitRecord({DateTime dateTime}) {
    timestamp = dateTime?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;
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
  }

  ///
  void fill({int source, int value, int type, String name}) {
    this.source = source;
    this.value = value;
    this.type = type;
    this.name = name;
  }

  ///
  String get idString => timestamp.toString();

  ///
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  ///
  String relativeDate(BuildContext context, {Calendar calendar, DateTime now}) {
    final DateTime date = dateTime;
    if (calendar.isToday(date, now)) {
      return Localizer.translate(context, 'lblToday');
    } else if (calendar.isYesterday(date, now)) {
      return Localizer.translate(context, 'lblYesterday');
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String typeString(BuildContext context) {
    switch (type) {
      case TYPE_ACTIVE_MINUTES:
        return Localizer.translate(context, 'lblUnitActiveMinutes');
      default:
        return Localizer.translate(context, 'lblUnitSteps');
    }
  }

  ///
  String title(BuildContext context) {
    if (source == SOURCE_MANUAL) {
      return name ?? Localizer.translate(context, 'lblHistoryDataManual');
    } else if (source == SOURCE_GOOGLE_FIT) {
      return Localizer.translate(context, 'lblHistoryDataGoogle');
    } else {
      return Localizer.translate(context, 'lblHistoryDataApple');
    }
  }
}
