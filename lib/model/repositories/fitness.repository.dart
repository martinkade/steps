import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.record.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/repository.dart';
import 'package:wandr/model/storage.dart';

///
abstract class FitnessRepositoryClient {
  /// Notify client with updated local data from Google Fit or Apple Health (or manually recordet data).
  void fitnessRepositoryDidUpdate(
    FitnessRepository repository, {
    SyncState state,
    DateTime day,
    FitSnapshot snapshot,
  });
}

class FitnessRepository extends Repository {
  ///
  static const fitness = const MethodChannel('com.mediabeam/fitness');
  static const notification = const MethodChannel('com.mediabeam/notification');

  ///
  static DateTime firstPossibleDate() {
    return DateTime(2020, 9, 1);
  }

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
      final bool notificationsEnabled = await notification
          .invokeMethod('enableNotifications', <String, dynamic>{
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
  Future<void> restorePoints({
    String userKey,
    FitnessRepositoryClient client,
  }) async {
    // restrict data to start on september, 1
    final DateTime anchor = FitnessRepository.firstPossibleDate();
    final FitRecordDao dao = FitRecordDao();
    final List<FitRecord> historicalData = await _readSnapshot(userKey);
    final List<FitRecord> localData = await dao.fetch(
      from: anchor,
      onlyManualRecords: false,
    );
    await dao.restore(oldRecords: historicalData, records: localData);
  }

  ///
  Future<void> syncPoints({
    @required String userKey,
    @required String teamName,
    @required FitnessRepositoryClient client,
    @required List<FitChallenge> challenges,
    bool pushData = false,
  }) async {
    FitSnapshot snapshot = FitSnapshot();
    final bool isAutoSyncEnabled = await Preferences().isAutoSyncEnabled();

    // restrict data to start on september, 1
    final DateTime anchor = FitnessRepository.firstPossibleDate();
    final FitRecordDao dao = FitRecordDao();
    final List<FitRecord> localData = await dao.fetch(
      from: anchor,
      onlyManualRecords: !isAutoSyncEnabled,
    );
    await dao.delete(records: localData, exclude: true);
    snapshot.fillWithLocalData(
      localData,
      challenges: challenges,
      anchor: anchor,
    );
    client.fitnessRepositoryDidUpdate(
      this,
      state: SyncState.FETCHING_DATA,
      day: anchor,
      snapshot: snapshot,
    );

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
    localData.addAll(await dao.fetch(
      from: anchor,
      onlyManualRecords: !isAutoSyncEnabled,
    ));
    snapshot.fillWithLocalData(
      localData,
      challenges: challenges,
      anchor: anchor,
    );

    client.fitnessRepositoryDidUpdate(
      this,
      state: SyncState.DATA_READY,
      day: anchor,
      snapshot: snapshot,
    );

    snapshot = FitSnapshot();
    snapshot.fillWithLocalData(
      localData,
      challenges: challenges,
      anchor: anchor,
    );
    if (pushData) {
      _writeSnapshot(snapshot, userKey: userKey, teamName: teamName);
    }
  }

  ///
  Future<List<FitRecord>> _readSnapshot(String userKey) async {
    final FirebaseApp instance = await Storage().access();
    final FirebaseDatabase db = FirebaseDatabase(app: instance);
    db.setPersistenceEnabled(true);
    db.setPersistenceCacheSizeBytes(1024 * 1024);
    final DataSnapshot data =
        await db.reference().child('users').child(userKey).get();
    Map<dynamic, dynamic> history;
    if (data?.value != null) {
      history = data.value['history'] == null ? Map() : data.value['history'] ?? Map();
    } else {
      history = Map();
    }
    print('FitRepository#_readSnapshot:\n\t$userKey\n\t$history');

    FitRecord record;
    final List<FitRecord> records = <FitRecord>[];
    DateTime timestamp;
    history.forEach((key, value) {
      timestamp = DateTime.parse(key.toString());
      record = FitRecord(dateTime: timestamp);
      record.fill(
        source: value['source']?.toInt() ?? 0,
        value: value['value']?.toInt() ?? 0,
        type: value['type']?.toInt() ?? 0,
        name: value['name']?.toString(),
      );
      print('FitRepository#_readSnapshot: \t${record.dateTimeString}');
      records.add(record);
    });
    return records;
  }

  ///
  Future<void> _writeSnapshot(
    FitSnapshot snapshot, {
    String userKey,
    String teamName,
  }) async {
    Storage().access().then((instance) async {
      final FirebaseDatabase db = FirebaseDatabase(app: instance);
      db.setPersistenceEnabled(true);
      db.setPersistenceCacheSizeBytes(1024 * 1024);

      final Map<String, dynamic> snapshotData = Map();
      snapshotData.putIfAbsent('team', () => teamName);
      snapshotData.addAll(await snapshot.persist());
      print('FitRepository#_writeSnapshot:\n\t$userKey\n\t$snapshotData');

      await db.reference().child('users').child(userKey).set(snapshotData);
    });
  }
}
