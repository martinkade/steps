import 'dart:async';
import 'package:health/health.dart';
import 'package:steps/model/repositories/repository.dart';

abstract class FitnessRepositoryClient {
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, List<HealthDataPoint> data});
}

class FitnessRepository extends Repository {
  ///
  Future<void> syncTodaysSteps({FitnessRepositoryClient client}) async {
    List<HealthDataPoint> data = [];

    final DateTime endDate = DateTime.now();
    final DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day);
    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.FETCHING_DATA, day: startDate);

    final HealthFactory health = HealthFactory();
    final List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
    ];

    /// Get all available data for each declared type
    for (HealthDataType type in types) {
      /// Calls must be wrapped in a try catch block
      /// Fetch new data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromType(startDate, endDate, type);

      /// Save all the new data points
      data.addAll(healthData);

      /// Filter out duplicates
      data = HealthFactory.removeDuplicates(data);
    }

    if (data.isEmpty) {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.NO_DATA, day: startDate, data: data);
    } else {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.DATA_READY, day: startDate, data: data);
    }
  }
}
