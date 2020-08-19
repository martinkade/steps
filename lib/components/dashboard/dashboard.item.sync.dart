import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/progress.text.animated.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

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
  bool _loading = true;

  ///
  bool _isAuthorized = false;

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  FitSnapshot _snapshot;

  ///
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  @override
  void initState() {
    super.initState();

    load();
  }

  void load() {
    _repository.hasPermissions().then((authorized) {
      if (!mounted) return;
      _isAuthorized = authorized;

      if (!authorized) {
        setState(() {
          _loading = false;
        });
      } else {
        _repository.syncTodaysSteps(
          userKey: widget.userKey,
          teamName: widget.teamName,
          client: this,
          pushData: true,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 96.0,
    );

    final Widget unauthorizedWidget = Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Localizer.translate(
                  context, 'lblDashboardUserStatsConnectErrorTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                Platform.isIOS
                    ? Localizer.translate(
                        context, 'lblDashboardUserStatsConnectErrorApple')
                    : Localizer.translate(
                        context, 'lblDashboardUserStatsConnectErrorGoogle'),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    final Widget contentWidget = _isAuthorized
        ? Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                        target: 30,
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
                        target: 210,
                        fontSize: 32.0,
                        label: Localizer.translate(
                            context, 'lblDashboardUserStatsWeek'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : unauthorizedWidget;

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
