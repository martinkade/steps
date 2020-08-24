import 'package:sqflite/sqflite.dart';

abstract class IStructuredCache {
  int getVersion();

  Future<void> onConfigure(Database db);

  Future<void> onCreate(Database db, int version);

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);

  Future<void> onDowngrade(Database db, int oldVersion, int newVersion);

  Future<void> onOpen(Database db);

  Future<void> onClose(Database db);

  Future<void> onDestroy(Database db, int version);
}
