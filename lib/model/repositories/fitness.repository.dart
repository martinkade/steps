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
  static const fitness = const MethodChannel('com.mediabeam/fitness');
  static const notification = const MethodChannel('com.mediabeam/notification');

  ///
  Future<bool> isNotificationsEnabled() async {
    try {
      final bool notificationsEnabled =
          await notification.invokeMethod('isNotificationsEnabled');
      return notificationsEnabled;
    } on Exception catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<bool> enableNotifications(bool enable) async {
    try {
      final bool notificationsEnabled =
          await notification.invokeMethod('enableNotifications', <String, dynamic>{
        'enable': enable,
      });
      return notificationsEnabled;
    } on Exception catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<bool> hasPermissions() async {
    try {
      final bool isAuthenticated =
          await fitness.invokeMethod('isAuthenticated');
      return isAuthenticated;
    } on Exception catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<bool> requestPermissions() async {
    try {
      final bool isAuthenticated = await fitness.invokeMethod('authenticate');
      return isAuthenticated;
    } on Exception catch (ex) {
      print(ex.toString());
    }
    return false;
  }

  ///
  Future<List<FitRecord>> fetchHistory({String day}) async {
    final FitRecordDao dao = FitRecordDao();
    if (day != null) {
      return await dao.fetchAllOfDay(day: day);
    }
    DateTime start = DateTime.now();
    start = start.subtract(
      Duration(
        days: 21 + start.weekday,
        hours: start.hour,
        minutes: start.minute,
        seconds: start.second,
        milliseconds: start.microsecond,
      ),
    );
    return await dao.fetchAllByDayAndPoints(from: start);
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

    // restrict local data to start on august, 24
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
            await fitness.invokeMethod('getFitnessMetrics');
        await snapshot.fillWithExternalData(dao, data);
      }
    } on Exception catch (ex) {
      print(ex.toString());
    }

    localData.clear();
    localData.addAll(
        await dao.fetch(from: anchor, onlyManualRecords: !isAutoSyncEnabled));
    snapshot.fillWithLocalData(localData, anchor: anchor);

    client.fitnessRepositoryDidUpdate(this,
        state: SyncState.DATA_READY, day: anchor, snapshot: snapshot);

    // restrict server data to start on august, 31
    snapshot = FitSnapshot();
    snapshot.fillWithLocalData(localData, anchor: DateTime(2020, 8, 31));
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
