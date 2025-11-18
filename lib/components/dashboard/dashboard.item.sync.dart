import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.component.dart';
import 'dart:io' show Platform;
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/components/shared/loading.indicator.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/lifecycle.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';
import 'package:wandr/model/repositories/repository.dart';

class DashboardSyncItem extends DashboardItem {
  ///
  final String? userKey;

  ///
  final String? teamName;

  ///
  final String? organizationName;

  ///
  final FitnessRepository repository;

  ///
  final DashboardSyncDelegate delegate;

  ///
  DashboardSyncItem({
    Key? key,
    required title,
    required this.repository,
    required this.delegate,
    this.userKey,
    this.teamName,
    this.organizationName,
  }) : super(key: key, title: title);

  @override
  DashboardSyncItemState createState() => DashboardSyncItemState();
}

class DashboardSyncItemState extends State<DashboardSyncItem>
    with AutomaticKeepAliveClientMixin<DashboardSyncItem>
    implements FitnessRepositoryClient {
  ///
  bool _loadingAutoSyncState = true;
  bool _loadingPoints = true;
  double _loadingPointsProgressOld = 0;
  double _loadingPointsProgressNew = 0.2;

  ///
  bool _autoSyncEnabled = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    print('DashboardSyncItemState#initState');

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          if (!mounted) return;
          _syncSteps(context);
        },
      ),
    );

    _load();
  }

  void reload() {
    _syncSteps(context);
  }

  void _load() {
    setState(() {
      _loadingAutoSyncState = true;
    });
    _syncSteps(context);
  }

  void _syncSteps(BuildContext context) async {
    final isAutoSyncEnabled = await Preferences().isAutoSyncEnabled();
    if (isAutoSyncEnabled) {
      final hasProviderPermissions = await widget.repository.hasPermissions();
      setState(() {
        _autoSyncEnabled = hasProviderPermissions;
        _loadingAutoSyncState = false;
      });
    } else {
      setState(() {
        _autoSyncEnabled = false;
        _loadingAutoSyncState = false;
      });
    }

    await widget.repository.syncTeams();
    final hasRestoredData = await Preferences().hasRestoredData();
    if (hasRestoredData) {
      widget.repository.syncPoints(
        isAutoSyncEnabled: isAutoSyncEnabled,
        userKey: widget.userKey!,
        teamName: widget.teamName!,
        organizationName: widget.organizationName!,
        challenges: widget.delegate.getChallenges(),
        client: this,
        pushData: true,
      );
    } else {
      widget.repository
          .restorePoints(userKey: widget.userKey!, client: this)
          .then((_) async {
        await Preferences().setHasRestoredData(true);
        widget.repository.syncPoints(
          isAutoSyncEnabled: isAutoSyncEnabled,
          userKey: widget.userKey!,
          teamName: widget.teamName!,
          organizationName: widget.organizationName!,
          challenges: widget.delegate.getChallenges(),
          client: this,
          pushData: true,
        );
      });
    }
  }

  @override
  void fitnessRepositoryDidUpdate(
    FitnessRepository repository, {
    required SyncState state,
    required DateTime day,
    required FitSnapshot snapshot,
  }) {
    if (!mounted) return;
    switch (state) {
      case SyncState.DATA_READY:
        widget.delegate.onFitnessDataUpdate(snapshot, syncState: state);
        setState(() {
          _loadingPointsProgressOld = _loadingPointsProgressNew;
          _loadingPointsProgressNew = 1.0;
        });
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            _loadingPoints = false;
          });
        });
        break;
      case SyncState.FETCHING_DATA:
        widget.delegate.onFitnessDataUpdate(snapshot, syncState: state);
        setState(() {
          _loadingPointsProgressOld = _loadingPointsProgressNew;
          _loadingPointsProgressNew = 0.8;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: _loadingAutoSyncState
            ? LoadingIndicator()
            : _autoSyncEnabled
                ? Container(
                    color: Colors.green.withAlpha(50),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              child: Image.asset(Platform.isIOS
                                  ? 'assets/images/fit_apple.png'
                                  : 'assets/images/fit_google.png'),
                              width: 44.0,
                              height: 44.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(right: 16.0),
                              child: _loadingPoints
                                  ? Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Localizer.translate(
                                            context,
                                            Platform.isIOS
                                                ? 'lblDashboardUserStatsAutoSyncProgressApple'
                                                : 'lblDashboardUserStatsAutoSyncProgressGoogle',
                                          ),
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsGeometry.only(top: 8.0),
                                          child: TweenAnimationBuilder<double>(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            tween: Tween<double>(
                                              begin: _loadingPointsProgressOld,
                                              end: _loadingPointsProgressNew,
                                            ),
                                            builder: (context, value, _) =>
                                                LinearProgressIndicator(
                                              color: Colors.green.withAlpha(80),
                                              backgroundColor:
                                                  Colors.green.withAlpha(50),
                                              value: value,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Text(
                                      Localizer.translate(
                                        context,
                                        Platform.isIOS
                                            ? 'lblDashboardUserStatsAutoSyncOnApple'
                                            : 'lblDashboardUserStatsAutoSyncOnGoogle',
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        height: 1.1,
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : GestureDetector(
                    child: Container(
                      color: Colors.red.withAlpha(50),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.sync_problem_rounded),
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
                      ),
                    ),
                    onTap: () {
                      widget.delegate.onSettingsRequested();
                    }),
      ),
    );
  }
}
