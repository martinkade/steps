import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.component.dart';
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/components/dashboard/dashboard.item.goal.calendar.dart';
import 'package:wandr/components/dashboard/dashboard.item.goal.display.dart';
import 'package:wandr/components/shared/loading.indicator.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:wandr/model/preferences.dart';

class DashboardGoalItem extends DashboardItem {
  ///
  final String? userKey;

  ///
  final String? teamName;

  ///
  final String? organizationName;

  ///
  final DashboardSyncDelegate delegate;

  ///
  DashboardGoalItem({
    Key? key,
    required String title,
    required this.delegate,
    this.userKey,
    this.teamName,
    this.organizationName,
  }) : super(key: key, title: title);

  @override
  DashboardGoalItemState createState() => DashboardGoalItemState();
}

class DashboardGoalItemState extends State<DashboardGoalItem>
    with AutomaticKeepAliveClientMixin<DashboardGoalItem> {
  ///
  bool _loading = true;

  ///
  FitSnapshot? _snapshot;

  ///
  int _goalDaily = DAILY_TARGET_POINTS;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _load();
  }

  void reload(FitSnapshot snapshot) {
    _snapshot = snapshot;
    _syncSteps(context);
  }

  void _load() {
    setState(() {
      _loading = true;
    });
    _syncSteps(context);
  }

  void _syncSteps(BuildContext context) {
    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      _goalDaily = value;

      setState(() {
        _loading = false;
      });
    });
  }

  int get _delta => _goalDaily - ((_snapshot?.today ?? 0).toInt());

  bool get _showMotivation {
    final int hour = DateTime.now().hour;
    return _delta != _goalDaily && _delta > 0 && hour >= 18;
  }

  Widget _calendarWidget(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        DashboardGoalCalendar(
          snapshot: _snapshot,
          dailyGoal: _goalDaily,
          weeklyGoal: _goalDaily * 7,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ],
    );
  }

  Widget _motivationWidget(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.access_time_rounded),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: Localizer.translate(
                              context, 'lblDashboardMotivation') +
                          ' ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: Localizer.translate(
                              context, 'lblDashboardMotivationDay')
                          .replaceFirst('%1', '$_delta'),
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  String _approxKilometers(int points) {
    if (points == 0) return 0.0.toString();
    final num kilometers = points / 12;
    if (kilometers < 0.1) return '< 0.1';
    return kilometers.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Widget contentWidget = Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: DashboardGoalDisplay(
                      displayType: DashboardGoalDisplayType.DAILY,
                      end: (_snapshot?.today ?? 0).toInt(),
                      target: _goalDaily,
                      label: Localizer.translate(
                          context, 'lblDashboardUserStatsToday'),
                      text: Localizer.translate(
                              context, 'lblDashboardUserStatsKilometer')
                          .replaceAll(
                        '%1',
                        _approxKilometers((_snapshot?.today ?? 0).toInt()),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: DashboardGoalDisplay(
                      displayType: DashboardGoalDisplayType.WEEKLY,
                      end: (_snapshot?.week ?? 0).toInt(),
                      target: _goalDaily * 7,
                      label: Localizer.translate(
                          context, 'lblDashboardUserStatsWeek'),
                      text: Localizer.translate(
                              context, 'lblDashboardUserStatsKilometer')
                          .replaceAll(
                        '%1',
                        _approxKilometers((_snapshot?.week ?? 0).toInt()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _calendarWidget(context),
            _showMotivation ? _motivationWidget(context) : Container()
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _loading ? LoadingIndicator() : contentWidget,
      ),
    );
  }
}
