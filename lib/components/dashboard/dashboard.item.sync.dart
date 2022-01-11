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
  final String userKey;

  ///
  final String teamName;

  ///
  final DashboardSyncDelegate delegate;

  ///
  DashboardSyncItem({
    Key key,
    String title,
    this.delegate,
    this.userKey,
    this.teamName,
  }) : super(key: key, title: title);

  @override
  DashboardSyncItemState createState() => DashboardSyncItemState();
}

class DashboardSyncItemState extends State<DashboardSyncItem>
    implements FitnessRepositoryClient {
  ///
  bool _loading = true;

  ///
  bool _autoSyncEnabled = true;

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  @override
  void initState() {
    super.initState();

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
      _loading = true;
    });
    _syncSteps(context);
  }

  void _syncSteps(BuildContext context) {
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

    Preferences().hasRestoredData().then((restored) {
      if (restored) {
        _repository.syncPoints(
          userKey: widget.userKey,
          teamName: widget.teamName,
          challenges: widget.delegate.getChallenges(),
          client: this,
          pushData: true,
        );
      } else {
        _repository
            .restorePoints(userKey: widget.userKey, client: this)
            .then((_) async {
          await Preferences().setHasRestoredData(true);
          _repository.syncPoints(
            userKey: widget.userKey,
            teamName: widget.teamName,
            challenges: widget.delegate.getChallenges(),
            client: this,
            pushData: true,
          );
        });
      }
    });
  }

  @override
  void fitnessRepositoryDidUpdate(
    FitnessRepository repository, {
    SyncState state,
    DateTime day,
    FitSnapshot snapshot,
  }) {
    if (!mounted) return;
    switch (state) {
      case SyncState.NOT_FETCHED:
      case SyncState.FETCHING_DATA:
        // loading indicator
        break;
      default:
        widget.delegate?.onFitnessDataUpdate(snapshot);
        break;
    }

    setState(() {
      _fitnessSyncState = state;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _loading
            ? LoadingIndicator(height: 96.0)
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
                            child: Icon(Icons.sync_rounded),
                          ),
                          Expanded(
                            child: Text(
                              Localizer.translate(
                                  context,
                                  Platform.isIOS
                                      ? 'lblDashboardUserStatsAutoSyncOnApple'
                                      : 'lblDashboardUserStatsAutoSyncOnGoogle'),
                              style: TextStyle(fontSize: 16.0),
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
                      widget.delegate?.onSettingsRequested();
                    }),
      ),
    );
  }
}
