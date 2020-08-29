import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:steps/model/cache/fit.record.dao.dart';
import 'package:steps/model/fit.record.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/preferences.dart';
import 'package:steps/model/repositories/repository.dart';
import 'package:steps/model/storage.dart';

///
abstract class FitnessRepositoryClient {
  ///
  void fitnessRepositoryDidUpdate(FitnessRepository repository,
      {SyncState state, DateTime day, FitSnapshot snapshot});
}

class FitnessRepository extends Repository {
  ///
  static const platform = const MethodChannel('com.mediabeam/fitness');

  ///
  Future<bool> hasPermissions() async {
    try {
      final bool isAuthenticated =
          await platform.invokeMethod('isAuthenticated');
      return isAuthenticated;
    } on PlatformException catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<bool> requestPermissions() async {
    try {
      final bool isAuthenticated = await platform.invokeMethod('authenticate');
      return isAuthenticated;
    } on PlatformException catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<List<FitRecord>> fetchHistory() async {
    final FitRecordDao dao = FitRecordDao();
    return await dao.fetchAll();
  }

  ///
  Future<void> addRecord(FitRecord record, {FitRecord oldRecord}) async {
    final FitRecordDao dao = FitRecordDao();
    if (oldRecord != null) {
      await deleteRecord(oldRecord);
    }
    return dao.insertOrReplace(records: [record]);
  }

  ///
  Future<void> deleteRecord(FitRecord record) async {
    final FitRecordDao dao = FitRecordDao();
    return dao.delete(records: [record]);
  }

  ///
  Future<void> syncPoints(
      {String userKey,
      String teamName,
      FitnessRepositoryClient client,
      bool pushData = false}) async {
    FitSnapshot snapshot = FitSnapshot();
    final bool isAutoSyncEnabled = await Preferences().isAutoSyncEnabled();

    final DateTime anchor = DateTime(2020, 8, 24);
    final FitRecordDao dao = FitRecordDao();
    final List<FitRecord> localData =
        await dao.fetch(from: anchor, onlyManualRecords: !isAutoSyncEnabled);
    await dao.delete(records: localData, exclude: true);
    snapshot.fillWithLocalData(localData, anchor: anchor);
    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.FETCHING_DATA, day: anchor, snapshot: snapshot);

    try {
      if (isAutoSyncEnabled && await hasPermissions()) {
        final Map<dynamic, dynamic> data =
            await platform.invokeMethod('getFitnessMetrics');
        await snapshot.fillWithExternalData(dao, data);
      }
    } on PlatformException catch (ex) {
      print(ex.toString());
    }

    localData.clear();
    localData.addAll(
        await dao.fetch(from: anchor, onlyManualRecords: !isAutoSyncEnabled));
    snapshot.fillWithLocalData(localData, anchor: anchor);

    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.DATA_READY, day: anchor, snapshot: snapshot);

    // restrict server data to start on august, 30
    snapshot = FitSnapshot();
    snapshot.fillWithLocalData(localData, anchor: DateTime(2020, 8, 30));
    if (pushData) {
      applySnapshot(snapshot, userKey: userKey, teamName: teamName);
    }
  }

  ///
  Future<void> applySnapshot(FitSnapshot snapshot,
      {String userKey, String teamName}) async {
    Storage().access().then((instance) async {
      final FirebaseDatabase db = FirebaseDatabase(app: instance);
      db.setPersistenceEnabled(true);
      db.setPersistenceCacheSizeBytes(1024 * 1024);

      final Map<String, dynamic> snapshotData = Map();
      snapshotData.putIfAbsent('team', () => teamName);
      snapshotData.addAll(await snapshot.persist());

      db.reference().child('users').child(userKey).set(snapshotData);
    });
  }
}
