import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/loading.indicator.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/fit.record.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardGoalCalendar extends StatefulWidget {
  ///
  final FitSnapshot snapshot;

  ///
  final int dailyGoal, weeklyGoal;

  ///
  DashboardGoalCalendar({
    Key key,
    @required this.snapshot,
    @required this.dailyGoal,
    @required this.weeklyGoal,
  }) : super(key: key);

  @override
  _DashboardGoalCalendarState createState() => _DashboardGoalCalendarState();
}

class _DashboardGoalCalendarState extends State<DashboardGoalCalendar> {
  ///
  bool _loading = true;

  ///
  final List<_WeekModel> _weeks = <_WeekModel>[];

  @override
  void initState() {
    super.initState();

    // _load(true);
  }

  void _load() {
    if (_weeks.isEmpty) {
      setState(() {
        _loading = true;
      });
    }
    _weeks.clear();
    _loadStats(context).then((weeks) {
      if (!mounted) return;
      _weeks.clear();
      _weeks.addAll(weeks);
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void didUpdateWidget(DashboardGoalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load();
  }

  Future<List<_WeekModel>> _loadStats(BuildContext context) async {
    print('DashboardGoalCalendar#_loadStats');
    final DateTime now = DateTime.now();
    DateTime weekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .subtract(Duration(hours: now.hour))
        .subtract(Duration(minutes: now.minute))
        .subtract(Duration(seconds: now.second))
        .subtract(Duration(milliseconds: now.millisecond))
        .subtract(Duration(microseconds: now.microsecond));
    DateTime weekEnd =
        weekStart.add(Duration(days: 7)).subtract(Duration(microseconds: 1));

    final int week = _isoWeekOfYear(weekStart);
    final FitRecordDao dao = FitRecordDao();
    final List<_WeekModel> weeks = <_WeekModel>[];

    int weekPoints;
    List<FitRecord> records;
    for (int i = week; i > 0; i--) {
      print('Fetch Week stats $i: $weekStart to $weekEnd');
      records = await dao.fetchAllByDayAndPoints(
        from: weekStart,
        to: weekEnd,
      );
      weekPoints = records.fold(0, (sum, item) => sum + item.value);
      weeks.add(
        _WeekModel(
          index: i,
          percent: min(1.0, weekPoints / widget.weeklyGoal),
        ),
      );

      weekStart = weekStart.subtract(Duration(days: 7));
      weekEnd = weekEnd.subtract(Duration(days: 7));
    }
    return weeks;
  }

  int _isoWeekOfYear(DateTime date) {
    int daysToAdd = DateTime.thursday - date.weekday;
    DateTime thursdayDate = daysToAdd > 0
        ? date.add(Duration(days: daysToAdd))
        : date.subtract(Duration(days: daysToAdd.abs()));
    int dayOfYearThursday = _isoDayOfYear(thursdayDate);
    return 1 + ((dayOfYearThursday - 1) / 7).floor();
  }

  int _isoDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingIndicator()
        : Container(
            height: 96.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return _CalendarWeekDisplay(
                  label: 'KW${_weeks[index].index}',
                  percent: _weeks[index].percent,
                );
              },
              itemCount: _weeks.length,
            ),
          );
  }
}

class _WeekModel {
  ///
  final int index;

  ///
  final double percent;

  ///
  _WeekModel({@required this.index, this.percent = 0.0});
}

class _CalendarWeekDisplay extends StatefulWidget {
  ///
  final double percent;

  ///
  final String label;

  ///
  _CalendarWeekDisplay({
    Key key,
    @required this.label,
    @required this.percent,
  }) : super(key: key);
  @override
  _CalendarWeekDisplayState createState() => _CalendarWeekDisplayState();
}

class _CalendarWeekDisplayState extends State<_CalendarWeekDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 64.0,
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 64.0,
              lineWidth: 4.0,
              percent: this.widget.percent,
              center: Text('${(this.widget.percent * 100).round()}%'),
              animation: true,
              // circularStrokeCap: CircularStrokeCap.round,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(50),
              progressColor: Theme.of(context).colorScheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(widget.label),
            )
          ],
        ),
      ),
    );
  }
}
