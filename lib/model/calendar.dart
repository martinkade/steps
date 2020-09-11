class Calendar {
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

  ///
  Duration delta(DateTime moment, DateTime now) {
    return moment.difference(now);
  }
}
