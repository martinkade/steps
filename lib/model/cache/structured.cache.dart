import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wandr/model/cache/structured.cache.spec.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';

class StructuredCache extends IStructuredCache {
  static final StructuredCache _instance = StructuredCache._internal();

  factory StructuredCache() {
    return _instance;
  }

  StructuredCache._internal();

  Database? _db;
  bool _didInit = false;

  /// Usage: var db = await LocalDatabase().getDb();
  Future<Database> getDb() async {
    if (!_didInit) await _init();
    return _db!;
  }

  @override
  getVersion() {
    return 1;
  }

  @override
  Future<void> onConfigure(Database db) async {}

  @override
  Future<void> onCreate(Database db, int version) async {
    print('Creating database with version $version ...');
    await db.transaction((txn) async {
      await FitRecordDao.create(txn: txn);
    });
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
        'Upgrading database from version $oldVersion to version $newVersion ...');
    await db.transaction((txn) async {
      await FitRecordDao.upgrade(oldVersion, newVersion, txn: txn);
    });
  }

  @override
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    print(
        'Downgrading database from version $oldVersion to version $newVersion ...');
    await db.transaction((txn) async {
      await FitRecordDao.downgrade(oldVersion, newVersion, txn: txn);
    });
  }

  @override
  Future<void> onOpen(Database db) async {
    print('Opening database with version ${getVersion()} ...');
  }

  @override
  Future<void> onClose(Database db) async {}

  @override
  Future<void> onDestroy(Database db, int version) async {
    print('Destroying database with version $version ...');
    await db.transaction((txn) async {
      // await txn.execute(EmgvMemberDao.CMD_CREATE_TABLE);
    });
  }

  Future<void> _init() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'structured_cache.db');
    _db = await openDatabase(path, version: getVersion(),
        onConfigure: (Database db) async {
      await onConfigure(db);
    }, onCreate: (Database db, int version) async {
      await onCreate(db, version);
    }, onOpen: (Database db) async {
      await onOpen(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await onUpgrade(db, oldVersion, newVersion);
    }, onDowngrade: (Database db, int oldVersion, int newVersion) async {
      await onDowngrade(db, oldVersion, newVersion);
    });
    _didInit = true;
  }

  Future<void> clear() async {
    final Database db = await getDb();
    await onDestroy(db, getVersion());
    await onCreate(db, getVersion());
  }

  Future<void> close() async {
    final Database db = await getDb();
    return db.close();
  }
}
