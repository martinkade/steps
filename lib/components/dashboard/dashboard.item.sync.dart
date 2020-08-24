import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/progress.text.animated.dart';
import 'package:steps/lifecycle.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

import 'dashboard.item.settings.dialog.dart';

abstract class DashboardSyncDelegate {
  void onFitnessDataUpadte(FitSnapshot snapshot);
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
  _DashboardSyncItemState createState() => _DashboardSyncItemState();
}

class _DashboardSyncItemState extends State<DashboardSyncItem>
    implements FitnessRepositoryClient {
  ///
  bool _loading = false;

  ///
  bool _isAuthorized = false;

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  FitSnapshot _snapshot;

  ///
  List<int> activity_level = [55, 65, 75, 85];

  ///
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      final int dailyTargetPoints = preferences.getInt('dailyTargetPoints');
      if (!mounted) return;

      if (dailyTargetPoints != null) {
        setState(() {
          DAILY_TARGET_POINTS = dailyTargetPoints;
        });
      }
    });

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          if (_isAuthorized) {
            _syncSteps();
          }
        },
      ),
    );

    load();
  }

  void load() {
    setState(() {
      _loading = true;
    });
    _repository.hasPermissions().then((authorized) {
      if (!mounted) return;
      _isAuthorized = authorized;

      if (!authorized) {
        setState(() {
          _loading = false;
        });
      } else {
        _syncSteps();
      }
    });
  }

  void _requestPermission() {
    setState(() {
      _loading = true;
    });
    _repository.requestPermissions().then((authorized) {
      if (!mounted) return;
      _isAuthorized = authorized;

      if (!authorized) {
        setState(() {
          _loading = false;
        });
      } else {
        _syncSteps();
      }
    });
  }

  void _syncSteps() {
    _repository.syncTodaysSteps(
      userKey: widget.userKey,
      teamName: widget.teamName,
      client: this,
      pushData: true,
    );
  }

  int get _delta => DAILY_TARGET_POINTS - (_snapshot?.today() ?? 0);

  bool get _showMotivation {
    final int hour = DateTime.now().hour;
    return _delta > 0 && hour >= 18;
  }

  void _showUserStatsSettings(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardSettingsDialogContent(
                setDailyTargetPoints: (int level) {
                  SharedPreferences.getInstance().then((preferences) {
                    if (!mounted) return;
                    preferences.setInt(
                        'dailyTargetPoints', activity_level[level]);
                    DAILY_TARGET_POINTS = preferences.getInt('dailyTargetPoints');
                  });

                  Navigator.of(context).pop();
                  this.setState(() {});
                },
                activity_level: activity_level),
          );
        });
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
        widget.delegate?.onFitnessDataUpadte(snapshot);
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

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 96.0,
    );

    /*final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 0.0, 22.0, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );*/

    final Widget unauthorizedWidget = Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Localizer.translate(
                  context, 'lblDashboardUserStatsConnectErrorTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
              child: Text(
                Platform.isIOS
                    ? Localizer.translate(
                        context, 'lblDashboardUserStatsConnectErrorApple')
                    : Localizer.translate(
                        context, 'lblDashboardUserStatsConnectErrorGoogle'),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              onPressed: () {
                _requestPermission();
              },
              child: Text(
                Localizer.translate(context, 'lblActionRetry'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget contentWidget = _isAuthorized
        ? Container(
            child: Stack(
            children: [
              Padding(
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
                            child: AnimatedProgressText(
                              start: 0,
                              end: _snapshot?.today() ?? 0,
                              target: DAILY_TARGET_POINTS,
                              fontSize: 48.0,
                              label: Localizer.translate(
                                  context, 'lblDashboardUserStatsToday'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: AnimatedProgressText(
                              start: 0,
                              end: _snapshot?.week() ?? 0,
                              target: DAILY_TARGET_POINTS * 7,
                              fontSize: 32.0,
                              label: Localizer.translate(
                                  context, 'lblDashboardUserStatsWeek'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _showMotivation ? _motivationWidget(context) : Container(),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    _showUserStatsSettings(this.context);
                  },
                  icon: Icon(Icons.settings, color: Colors.grey),
                ),
              ),
            ],
          ))
        : unauthorizedWidget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // titleWidget,
        Padding(
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
        ),
      ],
    );
  }
}
