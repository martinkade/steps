import 'dart:async';
import 'package:fit_kit/fit_kit.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/repository.dart';

abstract class FitnessRepositoryClient {
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, Map<DataType, FitSnapshot> data});
}

class FitnessRepository extends Repository {
  ///
  Future<void> syncTodaysSteps({FitnessRepositoryClient client}) async {
    Map<DataType, FitSnapshot> data = Map();

    final DateTime endDate = DateTime.now();
    final DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day);

    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.FETCHING_DATA, day: startDate);

    try {
      if (!await FitKit.requestPermissions(DataType.values)) {
        // 'requestPermissions: failed';
      } else {
        final DateTime today = DateTime.now();
        final DateTime from = DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: 10));
        final DateTime to =
            DateTime(today.year, today.month, today.day, 23, 59);
        List<FitData> dataSet;
        for (DataType type in [DataType.STEP_COUNT]) {
          try {
            dataSet = await FitKit.read(
              type,
              dateFrom: from,
              dateTo: to,
              limit: 9999,
            );
            data[type] = FitSnapshot(data: dataSet);
          } on UnsupportedException catch (e) {
            print(e.toString());
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }

    if (data.isEmpty) {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.NO_DATA, day: startDate, data: data);
    } else {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.DATA_READY, day: startDate, data: data);
    }
  }

  Future<bool> revokePermissions() async {
    try {
      await FitKit.revokePermissions();
      return await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      return await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
