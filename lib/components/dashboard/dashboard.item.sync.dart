import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

class DashboardSyncItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  DashboardSyncItem({Key key, String title, this.userKey, this.teamName})
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
            pushData: true);
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
              'Schade :(',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Die App kann nicht auf die Daten aus Google Fit bzw. Apple Health zugreifen.',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_snapshot?.today() ?? 0}',
                          style: TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Punktzahl heute')
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 22.0),
                          child: Text(
                            '${_snapshot?.week() ?? 0}',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Text('diese Woche')
                      ],
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
