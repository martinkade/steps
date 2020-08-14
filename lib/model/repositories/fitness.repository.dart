import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/repositories/repository.dart';
import 'package:steps/model/storage.dart';

abstract class FitnessRepositoryClient {
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, FitSnapshot snapshot});
}

/// https://flutter.dev/docs/development/platform-integration/platform-channels
class FitnessRepository extends Repository {
  ///
  static const platform = const MethodChannel('com.mediabeam/fitness');

  ///
  Future<bool> hasPermissions() async {
    return true;
  }

  ///
  Future<void> syncTodaysSteps(
      {String userKey,
      String teamName,
      FitnessRepositoryClient client,
      bool pushData = false}) async {
    Map<dynamic, dynamic> data = Map();

    final DateTime endDate = DateTime.now();
    final DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day);

    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.FETCHING_DATA, day: startDate);

    try {
      data = await platform.invokeMethod('getFitnessMetrics');
      print('$data');
    } on PlatformException catch (e) {
      print(e.toString());
    }

    final FitSnapshot snapshot = FitSnapshot(data: data);

    if (pushData) {
      applySnapshot(snapshot, userKey: userKey, teamName: teamName);
    }

    if (data.isEmpty) {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.NO_DATA, day: startDate, snapshot: snapshot);
    } else {
      client.fitnessRepositoryDidUpdate(this,
          state: SyncState.DATA_READY, day: startDate, snapshot: snapshot);
    }
  }

  ///
  Future<void> applySnapshot(FitSnapshot snapshot,
      {String userKey, String teamName}) async {
    Storage().access().then((instance) {
      final FirebaseDatabase db = FirebaseDatabase(app: instance);
      db.setPersistenceEnabled(true);
      db.setPersistenceCacheSizeBytes(1024 * 1024);

      final Map<String, dynamic> snapshotData = Map();
      snapshotData.putIfAbsent('team', () => teamName);
      snapshotData.addAll(snapshot.persist());

      db.reference().child('users').child(userKey).set(snapshotData);
    });
  }
}
