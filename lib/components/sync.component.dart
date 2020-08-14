import 'package:flutter/material.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

class SyncController extends StatefulWidget {
  ///
  final String userKey;

  ///
  final String team;

  ///
  SyncController({Key key, this.userKey, this.team}) : super(key: key);

  @override
  _SyncControllerState createState() => _SyncControllerState();
}

class _SyncControllerState extends State<SyncController>
    implements FitnessRepositoryClient {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  FitSnapshot _snapshot;

  ///
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  @override
  void initState() {
    super.initState();

    _repository.syncTodaysSteps(
        userKey: widget.userKey, teamName: widget.team, client: this);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(_fitnessSyncState == SyncState.FETCHING_DATA
            ? 'Loading steps'
            : '${_snapshot?.today()} steps'),
      ),
    );
  }
}
