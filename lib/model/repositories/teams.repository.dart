import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/repository.dart';
import 'package:wandr/model/storage.dart';

///
abstract class TeamsRepositoryClient {
  /// Notify client with updated local data from Google Fit or Apple Health (or manually recordet data).
  void fitnessRepositoryDidUpdate(
      FitnessRepository repository, {
        required SyncState state,
        required DateTime day,
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
  Future<List> _readSnapshot(String userKey) async {
    final FirebaseApp? instance = await Storage().access();
    final FirebaseDatabase db = FirebaseDatabase(app: instance);
    db.setPersistenceEnabled(true);
    db.setPersistenceCacheSizeBytes(1024 * 1024);
    final DataSnapshot? data =
    await db.reference().child('users').child(userKey).get();
    Map<dynamic, dynamic> history;
    Map dict;
    if (data?.value != null) {
      dict = data!.value! as Map;
      history = dict['history'] == null ? Map() : dict['history'] ?? Map();
    } else {
      history = Map();
    }
    print('FitRepository#_readSnapshot:\n\t$userKey\n\t$history');
    return [];
  }

  ///
  Future<void> _writeSnapshot({
        required String userKey,
        required String teamName,
      }) async {
    Storage().access().then((instance) async {
      final FirebaseDatabase db = FirebaseDatabase(app: instance);
      db.setPersistenceEnabled(true);
      db.setPersistenceCacheSizeBytes(1024 * 1024);

      final Map<String, dynamic> snapshotData = Map();
      snapshotData.putIfAbsent('team', () => teamName);
      print('FitRepository#_writeSnapshot:\n\t$userKey\n\t$snapshotData');

      await db.reference().child('users').child(userKey).set(snapshotData);
      await db.ref().child('teams').set("{'test': 'test'}");
    });
  }
}
