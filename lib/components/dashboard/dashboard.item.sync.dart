import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/progress.text.animated.dart';
import 'package:steps/lifecycle.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/preferences.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

abstract class DashboardSyncDelegate {
  void onFitnessDataUpdate(FitSnapshot snapshot);
  void onSettingsRequested();
}

class DashboardSyncItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  final DashboardSyncDelegate delegate;

  ///
  DashboardSyncItem(
      {Key key, String title, this.delegate, this.userKey, this.teamName})
      : super(key: key, title: title);

  @override
  DashboardSyncItemState createState() => DashboardSyncItemState();
}

class DashboardSyncItemState extends State<DashboardSyncItem>
    implements FitnessRepositoryClient {
  ///
  bool _loading = false;

  ///
  bool _autoSyncEnabled = true;

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  FitSnapshot _snapshot;

  ///
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  ///
  int _goalDaily = DAILY_TARGET_POINTS;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          if (!mounted) return;
          _syncSteps();
        },
      ),
    );

    _load();
  }

  void reload() {
    _syncSteps();
  }

  void _load() {
    setState(() {
      _loading = true;
    });
    _syncSteps();
  }

  void _syncSteps() {
    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      _goalDaily = value;
    });
    Preferences().isAutoSyncEnabled().then((enabled) {
      if (!mounted) return;
      if (enabled) {
        _repository.hasPermissions().then((authorized) {
          if (!mounted) return;
          setState(() {
            _autoSyncEnabled = authorized;
          });
        });
      } else {
        setState(() {
          _autoSyncEnabled = false;
        });
      }
    });

    _repository.syncPoints(
      userKey: widget.userKey,
      teamName: widget.teamName,
      client: this,
      pushData: true,
    );
  }

  int get _delta => _goalDaily - (_snapshot?.today() ?? 0);

  bool get _showMotivation {
    final int hour = DateTime.now().hour;
    return _delta != _goalDaily && _delta > 0 && hour >= 18;
  }

  @override
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, FitSnapshot snapshot}) {
    if (!mounted) return;

    switch (state) {
      case SyncState.NOT_FETCHED:
      case SyncState.FETCHING_DATA:
        // loading indicator
        break;
      default:
        _snapshot = snapshot;
        widget.delegate?.onFitnessDataUpdate(snapshot);
        break;
    }

    setState(() {
      _fitnessSyncState = state;
      _loading = false;
    });
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
              child: Icon(Icons.av_timer),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: Localizer.translate(
                              context, 'lblDashboardMotivation1') +
                          ' ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: Localizer.translate(
                              context, 'lblDashboardMotivation2')
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

  Widget _autoSyncWidget(BuildContext context) {
    return GestureDetector(
        child: Column(
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
                  child: Icon(Icons.sync_disabled),
                ),
                Expanded(
                  child: Text(
                    Localizer.translate(
                        context,
                        Platform.isIOS
                            ? 'lblDashboardUserStatsAutoSyncOffApple'
                            : 'lblDashboardUserStatsAutoSyncOffGoogle'),
                    style: TextStyle(fontSize: 16.0),
                  ),
                )
              ],
            ),
          ],
        ),
        onTap: () {
          widget.delegate?.onSettingsRequested();
        });
  }

  String _approxKilometers(int points) {
    if (points == 0) return 0.0.toString();
    final num kilometers = points / 12;
    if (kilometers < 0.1) return '< 0.1';
    return kilometers.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 148.0,
    );

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedProgressText(
                          start: 0,
                          end: _snapshot?.today() ?? 0,
                          target: _goalDaily,
                          fontSize: 48.0,
                          label: Localizer.translate(
                              context, 'lblDashboardUserStatsToday'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            Localizer.translate(
                                    context, 'lblDashboardUserStatsKilometer')
                                .replaceAll(
                              '%1',
                              _approxKilometers(_snapshot?.today() ?? 0),
                            ),
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedProgressText(
                          start: 0,
                          end: _snapshot?.week() ?? 0,
                          target: _goalDaily * 7,
                          fontSize: 32.0,
                          label: Localizer.translate(
                              context, 'lblDashboardUserStatsWeek'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            Localizer.translate(
                                    context, 'lblDashboardUserStatsKilometer')
                                .replaceAll(
                              '%1',
                              _approxKilometers(_snapshot?.week() ?? 0),
                            ),
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _showMotivation
                ? _motivationWidget(context)
                : (!_autoSyncEnabled ? _autoSyncWidget(context) : Container()),
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
        child: _loading ? loadingWidget : contentWidget,
      ),
    );
  }
}
