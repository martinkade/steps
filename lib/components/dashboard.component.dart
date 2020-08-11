import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:steps/model/repositories/fitness.repository.dart';
import 'package:steps/model/repositories/repository.dart';

class Dashboard extends StatefulWidget {
  final String title;

  Dashboard({Key key, this.title}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    implements FitnessRepositoryClient {
  final FitnessRepository _repository = FitnessRepository();
  SyncState _fitnessSyncState = SyncState.NOT_FETCHED;

  @override
  void initState() {
    super.initState();

    _repository.syncTodaysSteps(client: this);
  }

  @override
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, List<HealthDataPoint> data}) {
    if (!mounted) return;

    switch (state) {
      case SyncState.NOT_FETCHED:
      case SyncState.FETCHING_DATA:
        // loading indicator
        break;
      default:
        data.forEach((x) => print("Data point: $x"));
        break;
    }

    setState(() {
      _fitnessSyncState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Center(
          child: Text(_fitnessSyncState == SyncState.FETCHING_DATA
              ? 'Loading steps'
              : 'Step display'),
        ),
      ),
    );
  }
}
